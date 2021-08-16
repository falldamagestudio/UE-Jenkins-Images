/*
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.jenkins.plugins.computeengine;

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST;

import com.cloudbees.plugins.credentials.CredentialsMatchers;
import com.cloudbees.plugins.credentials.CredentialsProvider;
import com.cloudbees.plugins.credentials.common.StandardCredentials;
import com.cloudbees.plugins.credentials.common.StandardListBoxModel;
import com.cloudbees.plugins.credentials.domains.DomainRequirement;
import com.google.api.services.compute.Compute;
import com.google.api.services.compute.model.Instance;
import com.google.cloud.graphite.platforms.plugin.client.ClientFactory;
import com.google.cloud.graphite.platforms.plugin.client.ComputeClient;
import com.google.common.base.Strings;
import com.google.common.collect.ImmutableMap;
import com.google.jenkins.plugins.computeengine.client.ClientUtil;
import com.google.jenkins.plugins.computeengine.client.ComputeClient2;
import com.google.jenkins.plugins.computeengine.client.ComputeFactory;
import com.google.jenkins.plugins.credentials.oauth.GoogleOAuth2Credentials;
import hudson.Extension;
import hudson.model.Computer;
import hudson.model.Descriptor;
import hudson.model.Item;
import hudson.model.Job;
import hudson.model.Label;
import hudson.model.Node;
import hudson.model.Slave;
import hudson.model.TaskListener;
import hudson.security.ACL;
import hudson.security.Permission;
import hudson.slaves.AbstractCloudImpl;
import hudson.slaves.Cloud;
import hudson.slaves.NodeProvisioner.PlannedNode;
import hudson.util.FormValidation;
import hudson.util.HttpResponses;
import hudson.util.ListBoxModel;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.logging.Level;
import java.util.logging.LogRecord;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import javax.annotation.Nonnull;
import javax.servlet.ServletException;
import jenkins.model.Jenkins;
import lombok.Getter;
import lombok.extern.java.Log;
import org.kohsuke.stapler.AncestorInPath;
import org.kohsuke.stapler.DataBoundConstructor;
import org.kohsuke.stapler.DataBoundSetter;
import org.kohsuke.stapler.HttpResponse;
import org.kohsuke.stapler.QueryParameter;
import org.kohsuke.stapler.interceptor.RequirePOST;

@Getter
@Log
public class ComputeEngineCloud extends AbstractCloudImpl {
  public static final String CLOUD_PREFIX = "gce-";
  public static final String CONFIG_LABEL_KEY = "jenkins_config_name";
  public static final String CLOUD_ID_LABEL_KEY = "jenkins_cloud_id";

  private static final SimpleFormatter sf = new SimpleFormatter();

  private final String projectId;
  private final String credentialsId;

  private String instanceId;
  private List<InstanceConfiguration> configurations;

  private transient volatile ComputeClient client;
  private transient volatile ComputeClient2 client2;
  private transient volatile Compute compute;
  private boolean noDelayProvisioning;

  private InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
      new InstanceConfigurationPrioritizer();

  private InstanceOperationTracker instanceInsertOperationTracker =
      new InstanceOperationTracker(this);

  private InstanceOperationTracker instanceDeleteOperationTracker =
      new InstanceOperationTracker(this);

  @DataBoundConstructor
  public ComputeEngineCloud(
      String cloudName, String projectId, String credentialsId, String instanceCapStr) {
    super(createCloudId(cloudName), instanceCapStr);

    this.credentialsId = credentialsId;
    this.projectId = projectId;
    setInstanceId(null);
    setConfigurations(null);
  }

  @Deprecated
  public ComputeEngineCloud(
      String cloudName,
      String projectId,
      String credentialsId,
      String instanceCapStr,
      List<InstanceConfiguration> configurations) {
    this(cloudName, projectId, credentialsId, instanceCapStr);

    setConfigurations(configurations);
  }

  private static String createCloudId(String name) {
    return CLOUD_PREFIX + name.trim();
  }

  public static void log(Logger logger, Level level, TaskListener listener, String message) {
    log(logger, level, listener, message, null);
  }

  public static void log(
      Logger logger, Level level, TaskListener listener, String message, Throwable exception) {
    logger.log(level, message, exception);
    if (listener != null) {
      if (exception != null) message += " Exception: " + exception;
      LogRecord lr = new LogRecord(level, message);
      PrintStream printStream = listener.getLogger();
      printStream.print(sf.format(lr));
    }
  }

  public String getCloudName() {
    return name.substring(CLOUD_PREFIX.length());
  }

  @Override
  public String getDisplayName() {
    return getCloudName();
  }

  public boolean isNoDelayProvisioning() {
    return noDelayProvisioning;
  }

  @DataBoundSetter
  public void setNoDelayProvisioning(boolean noDelayProvisioning) {
    this.noDelayProvisioning = noDelayProvisioning;
  }

  protected Object readResolve() {
    if (configurations != null) {
      for (InstanceConfiguration configuration : configurations) {
        configuration.setCloud(this);
        configuration.readResolve();
        // Apply a label that associates an instance configuration with
        // this cloud provider
        configuration.appendLabel(CLOUD_ID_LABEL_KEY, getInstanceId());

        // Apply a label that identifies the name of this instance configuration
        configuration.appendLabel(CONFIG_LABEL_KEY, configuration.getNamePrefix());
      }
    }
    setInstanceId(instanceId);
    return this;
  }

  /**
   * Sets unique ID of that cloud instance.
   *
   * <p>This ID allows us to find machines from our cloud in GCP. <b>This value should not change
   * between config reload, or nodes may be lost in GCP side</b>
   */
  @DataBoundSetter
  public void setInstanceId(String instanceId) {
    if (Strings.isNullOrEmpty(instanceId)) {
      this.instanceId = UUID.randomUUID().toString();
    } else {
      this.instanceId = instanceId;
    }
  }

  private ComputeClient createClient() {
    try {
      ClientFactory clientFactory = ClientUtil.getClientFactory(Jenkins.get(), credentialsId);
      return clientFactory.computeClient();
    } catch (IOException e) {
      log.log(Level.SEVERE, "Exception when creating GCE client", e);
      // TODO: https://github.com/jenkinsci/google-compute-engine-plugin/issues/62
      return null;
    }
  }

  public Compute createCompute() {
    try {
      ComputeFactory computeFactory = ClientUtil.getComputeFactory(Jenkins.get(), credentialsId);
      return computeFactory.compute();
    } catch (IOException e) {
      log.log(Level.SEVERE, "Exception when creating GCE compute", e);
      // TODO: https://github.com/jenkinsci/google-compute-engine-plugin/issues/62
      return null;
    }
  }

  private ComputeClient2 createClient2() {
    return new ComputeClient2(getCompute());
  }

  /**
   * Returns GCP client for that cloud.
   *
   * @return GCP client object.
   */
  public ComputeClient getClient() {
    if (client == null) {
      synchronized (this) {
        if (client == null) {
          client = createClient();
        }
      }
    }
    return client;
  }

  /**
   * Returns GCP compute for that cloud.
   *
   * @return GCP compute object.
   */
  public Compute getCompute() {
    if (compute == null) {
      synchronized (this) {
        if (compute == null) {
          compute = createCompute();
        }
      }
    }
    return compute;
  }

  /**
   * Returns GCP client 2 (additional methods) for that cloud.
   *
   * @return GCP client 2 object.
   */
  public ComputeClient2 getClient2() {
    if (client2 == null) {
      synchronized (this) {
        if (client2 == null) {
          client2 = createClient2();
        }
      }
    }
    return client2;
  }

  /**
   * Set configurations for this cloud.
   *
   * @param configurations configurations to be used
   */
  @DataBoundSetter
  public void setConfigurations(List<InstanceConfiguration> configurations) {
    this.configurations = configurations;
    readResolve();
  }

  /**
   * Adds one configuration.
   *
   * @param configuration configuration to add
   */
  @Deprecated
  public void addConfiguration(InstanceConfiguration configuration) {
    if (configurations == null) {
      this.configurations = new ArrayList<>();
    }
    configurations.add(configuration);
    readResolve();
  }

  public Stream<String> getAllNodes() {
    return Jenkins.get().getNodes().stream()
        .filter(node -> node instanceof ComputeEngineInstance)
        .map(node -> (ComputeEngineInstance) node)
        .filter(node -> node.getCloud().equals(this))
        .map(Slave::getNodeName);
  }

  // Get all instances associated with a cloud, regardless of their status

  public Stream<Instance> getAllInstances() {
    Map<String, String> filterLabel = ImmutableMap.of(CLOUD_ID_LABEL_KEY, getInstanceId());
    try {
      return getClient().listInstancesWithLabel(getProjectId(), filterLabel).stream();
    } catch (IOException ex) {
      log.log(Level.WARNING, "Error finding instances", ex);
      return Stream.<Instance>empty();
    }
  }

  private Stream<Instance> filterTerminatedInstances(Stream<Instance> instances) {
    return instances.filter(instance -> instance.getStatus().equals("TERMINATED"));
  }

  // Given a stream of nodes, and a stream of instances,
  //   identify which of those instances are candidates for being re-used during provisioning
  //
  // An instance needs to satisfy these conditions to be provisionable:
  // * It must not currently be associated with a node
  // * It must currently have TERMINATED status
  // * It must not currently have a delete in progress

  private Stream<Instance> filterProvisionableInstances(
      Stream<String> allNodes,
      Stream<Instance> allInstances,
      Stream<InstanceOperationTracker.InstanceOperation> deletesInProgress) {
    Stream<Instance> terminatedInstances = filterTerminatedInstances(allInstances);

    Set<String> allNodesSet = allNodes.collect(Collectors.toSet());
    Set<String> deletesInProgressNamesSet =
        deletesInProgress
            .map(instanceOperation -> instanceOperation.getName())
            .collect(Collectors.toSet());

    Stream<Instance> provisionableInstances =
        terminatedInstances
            .filter(instance -> !deletesInProgressNamesSet.contains(instance.getName()))
            .filter(instance -> !allNodesSet.contains(instance.getName()));

    return provisionableInstances;
  }

  private void logConfigAndInstanceResult(
      InstanceConfigurationPrioritizer.ConfigAndInstance configAndInstance) {
    if (configAndInstance != null
        && configAndInstance.config != null
        && configAndInstance.instance != null) {
      log.info(
          String.format(
              "Cloud provider %s - choosing configuration %s and persistent instance %s for provisioning a new node",
              getCloudName(),
              configAndInstance.config.getDisplayName(),
              configAndInstance.instance.getName()));
    } else if (configAndInstance != null
        && configAndInstance.config != null
        && configAndInstance.instance == null) {
      log.info(
          String.format(
              "Cloud provider %s - choosing configuration %s but no existing instance for provisioning a new node",
              getCloudName(), configAndInstance.config.getDisplayName()));
    } else if (configAndInstance == null) {
      log.warning(
          String.format(
              "Could not provision new nodes to meet demand. All instance configurations for cloud provider %s have reached their max num instances",
              getCloudName()));
    }
  }

  @Override
  public Collection<PlannedNode> provision(Label label, int excessWorkload) {
    List<PlannedNode> result = new ArrayList<>();
    try {
      List<InstanceConfiguration> configs = getInstanceConfigurations(label);
      log.log(
          Level.INFO,
          "Provisioning node from configs "
              + configs
              + " for excess workload of "
              + excessWorkload
              + " units of label '"
              + label
              + "'");
      int availableCapacity = availableNodeCapacity();
      while (excessWorkload > 0) {
        if (availableCapacity <= 0) {
          log.warning(
              String.format(
                  "Could not provision new nodes to meet excess workload demand (%d). Cloud provider %s has reached its configured capacity of %d",
                  excessWorkload, getCloudName(), getInstanceCap()));
          break;
        }

        instanceInsertOperationTracker.removeCompleted();
        instanceDeleteOperationTracker.removeCompleted();
        Set<InstanceOperationTracker.InstanceOperation> insertsInProgress =
            instanceInsertOperationTracker.get();
        Set<InstanceOperationTracker.InstanceOperation> deletesInProgress =
            instanceDeleteOperationTracker.get();

        Stream<String> allNodes = getAllNodes();
        Set<Instance> allInstances = getAllInstances().collect(Collectors.toSet());

        log.log(
            Level.FINE,
            "When provisioning, the following instances are visible in the GCE APIs: [ "
                + String.join(
                    ", ",
                    allInstances.stream()
                        .map(instance -> instance.getName())
                        .toArray(String[]::new))
                + " ], the following instances have insert operations active: [ "
                + String.join(
                    ", ",
                    insertsInProgress.stream()
                        .map(instance -> instance.getName())
                        .toArray(String[]::new))
                + " ], the following instances have delete operations active: [ "
                + String.join(
                    ", ",
                    deletesInProgress.stream()
                        .map(instance -> instance.getName())
                        .toArray(String[]::new))
                + " ]");

        Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig =
            instanceConfigurationPrioritizer.getProjectedInstanceCountPerConfig(
                configs, allInstances, insertsInProgress, deletesInProgress);
        List<Instance> provisionableInstances =
            filterProvisionableInstances(
                    allNodes, allInstances.stream(), deletesInProgress.stream())
                .collect(Collectors.toList());
        InstanceConfigurationPrioritizer.ConfigAndInstance configAndInstance =
            instanceConfigurationPrioritizer.getConfigAndInstance(
                configs, provisionableInstances, projectedInstanceCountPerConfig);
        logConfigAndInstanceResult(configAndInstance);

        if (configAndInstance == null) {
          break;
        }

        final ComputeEngineInstance node =
            configAndInstance.config.provision(configAndInstance.instance);
        Jenkins.get().addNode(node);
        result.add(createPlannedNode(configAndInstance.config, node));
        excessWorkload -= node.getNumExecutors();
        availableCapacity -= node.getNumExecutors();
      }
    } catch (IOException ioe) {
      log.log(Level.WARNING, "Error provisioning node", ioe);
    } catch (NoConfigurationException nce) {
      log.log(
          Level.WARNING,
          String.format(
              "An instance configuration could not be found to provision a node for label %s",
              label.getName()),
          nce.getMessage());
    }
    return result;
  }

  private PlannedNode createPlannedNode(InstanceConfiguration config, ComputeEngineInstance node) {
    return new PlannedNode(
        node.getNodeName(), getPlannedNodeFuture(config, node), node.getNumExecutors());
  }

  private Future<Node> getPlannedNodeFuture(
      InstanceConfiguration config, ComputeEngineInstance node) {
    return Computer.threadPoolForRemoting.submit(
        () -> {
          long startTime = System.currentTimeMillis();
          log.log(
              Level.INFO,
              String.format(
                  "Waiting %dms for node %s to connect",
                  config.getLaunchTimeoutMillis(), node.getNodeName()));
          try {
            Computer c = node.toComputer();
            if (c != null) {
              c.connect(false).get(config.getLaunchTimeoutMillis(), TimeUnit.MILLISECONDS);
              log.log(
                  Level.INFO,
                  String.format(
                      "%dms elapsed waiting for node %s to connect",
                      System.currentTimeMillis() - startTime, node.getNodeName()));
            } else {
              log.log(
                  Level.WARNING,
                  String.format("No computer for node %s found", node.getNodeName()));
            }
          } catch (TimeoutException e) {
            log.log(
                Level.WARNING,
                String.format("Timeout waiting for node %s to connect", node.getNodeName()),
                e);
          }
          return null;
        });
  }

  /**
   * Determine the number of nodes that may be provisioned for this Cloud.
   *
   * @return
   * @throws IOException
   */
  private synchronized Integer availableNodeCapacity() throws IOException {
    try {
      // We only care about instances that have a label indicating they
      // belong to this cloud
      Map<String, String> filterLabel = ImmutableMap.of(CLOUD_ID_LABEL_KEY, getInstanceId());
      List<Instance> instances =
          new ArrayList<>(getClient().listInstancesWithLabel(projectId, filterLabel));

      // Don't count instances that are not running (or starting up)
      Iterator it = instances.iterator();
      while (it.hasNext()) {
        Instance o = (Instance) it.next();
        if (!(o.getStatus().equals("PROVISIONING")
            || o.getStatus().equals("STAGING")
            || o.getStatus().equals("RUNNING"))) {
          it.remove();
        }
      }
      Integer capacity = getInstanceCap() - instances.size();
      log.info(String.format("Found capacity for %d nodes in cloud %s", capacity, getCloudName()));
      return (getInstanceCap() - instances.size());
    } catch (IOException ioe) {
      log.warning(
          String.format(
              "An error occurred counting the number of existing instances in cloud %s: %s",
              getCloudName(), ioe.getMessage()));
      throw ioe;
    }
  }

  @Override
  public boolean canProvision(Label label) {
    try {
      getInstanceConfigurations(label);
      return true;
    } catch (NoConfigurationException nce) {
      return false;
    }
  }

  /** Gets all instances of {@link InstanceConfiguration} that has the matching {@link Label}. */
  public List<InstanceConfiguration> getInstanceConfigurations(Label label)
      throws NoConfigurationException {
    if (configurations == null) {
      throw new NoConfigurationException(
          String.format(
              "Cloud %s does not have any defined instance configurations.", this.getCloudName()));
    }

    List<InstanceConfiguration> configurations =
        this.configurations.stream()
            .filter(configuration -> matchesLabel(configuration, label))
            .collect(Collectors.toList());

    if (configurations.isEmpty()) {
      throw new NoConfigurationException(
          String.format(
              "Cloud %s does not have any matching instance configurations.", this.getCloudName()));
    }
    return configurations;
  }

  private boolean matchesLabel(InstanceConfiguration configuration, Label label) {
    if (configuration.getMode() == Node.Mode.NORMAL) {
      return label == null || label.matches(configuration.getLabelSet());
    } else if (configuration.getMode() == Node.Mode.EXCLUSIVE) {
      return label != null && label.matches(configuration.getLabelSet());
    }
    return false;
  }

  public InstanceConfigurationPrioritizer getInstanceConfigurationPrioritizer() {
    return instanceConfigurationPrioritizer;
  }

  public InstanceOperationTracker getInstanceInsertOperationTracker() {
    return instanceInsertOperationTracker;
  }

  public InstanceOperationTracker getInstanceDeleteOperationTracker() {
    return instanceDeleteOperationTracker;
  }

  /** Gets {@link InstanceConfiguration} that has the matching Name. */
  public InstanceConfiguration getInstanceConfigurationByName(String name) {
    for (InstanceConfiguration c : configurations) {
      if (c.getNamePrefix().equals(name)) {
        return c;
      }
    }
    return null;
  }

  /** Gets {@link InstanceConfiguration} that has the matching Description. */
  public InstanceConfiguration getInstanceConfigurationByDescription(String description) {
    for (InstanceConfiguration c : configurations) {
      if (c.getDescription().equals(description)) {
        return c;
      }
    }
    return null;
  }

  @RequirePOST
  public HttpResponse doProvision(@QueryParameter String configuration)
      throws ServletException, IOException {
    checkPermissions(PROVISION);
    if (configuration == null) {
      throw HttpResponses.error(SC_BAD_REQUEST, "The 'configuration' query parameter is missing");
    }
    InstanceConfiguration c = getInstanceConfigurationByDescription(configuration);
    if (c == null) {
      throw HttpResponses.error(SC_BAD_REQUEST, "No such Instance Configuration: " + configuration);
    }

    List<InstanceConfiguration> configs = Arrays.asList(new InstanceConfiguration[] {c});

    instanceInsertOperationTracker.removeCompleted();
    instanceDeleteOperationTracker.removeCompleted();
    Set<InstanceOperationTracker.InstanceOperation> insertsInProgress =
        instanceInsertOperationTracker.get();
    Set<InstanceOperationTracker.InstanceOperation> deletesInProgress =
        instanceDeleteOperationTracker.get();

    Stream<String> allNodes = getAllNodes();
    Set<Instance> allInstances = getAllInstances().collect(Collectors.toSet());

    log.log(
        Level.FINE,
        "When provisioning, the following instances are visible in the GCE APIs: [ "
            + String.join(
                ", ",
                allInstances.stream().map(instance -> instance.getName()).toArray(String[]::new))
            + " ], the following instances have insert operations active: [ "
            + String.join(
                ", ",
                insertsInProgress.stream()
                    .map(instance -> instance.getName())
                    .toArray(String[]::new))
            + " ], the following instances have delete operations active: [ "
            + String.join(
                ", ",
                deletesInProgress.stream()
                    .map(instance -> instance.getName())
                    .toArray(String[]::new))
            + " ]");

    Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig =
        instanceConfigurationPrioritizer.getProjectedInstanceCountPerConfig(
            configs, allInstances, insertsInProgress, deletesInProgress);
    List<Instance> provisionableInstances =
        filterProvisionableInstances(allNodes, allInstances.stream(), deletesInProgress.stream())
            .collect(Collectors.toList());
    InstanceConfigurationPrioritizer.ConfigAndInstance configAndInstance =
        instanceConfigurationPrioritizer.getConfigAndInstance(
            configs, provisionableInstances, projectedInstanceCountPerConfig);
    logConfigAndInstanceResult(configAndInstance);

    if (configAndInstance == null)
      throw HttpResponses.error(
          SC_BAD_REQUEST, "No instance configuration is suitable for provisioning a new node.");

    ComputeEngineInstance node = configAndInstance.config.provision(configAndInstance.instance);
    if (node == null) throw HttpResponses.error(SC_BAD_REQUEST, "Could not provision new node.");
    Jenkins.get().addNode(node);

    return HttpResponses.redirectViaContextPath("/computer/" + node.getNodeName());
  }

  /**
   * Ensures the executing user has the specified permissions.
   *
   * @param permissions The list of permissions to be checked. If empty, defaults to Job.CONFIGURE.
   * @throws AccessDeniedException If the user lacks the proper permissions.
   */
  static void checkPermissions(Permission... permissions) {
    Jenkins jenkins = Jenkins.getInstanceOrNull();
    if (jenkins != null) {
      if (permissions.length > 0) {
        for (Permission permission : permissions) {
          jenkins.checkPermission(permission);
        }
      } else {
        jenkins.checkPermission(Job.CONFIGURE);
      }
    }
  }

  @Extension
  public static class GoogleCloudDescriptor extends Descriptor<Cloud> {

    @Nonnull
    @Override
    public String getDisplayName() {
      return Messages.ComputeEngineCloud_DisplayName();
    }

    public FormValidation doCheckProjectId(@QueryParameter String value) {
      checkPermissions();
      if (value == null || value.isEmpty()) {
        return FormValidation.error("Project ID is required");
      }
      return FormValidation.ok();
    }

    public ListBoxModel doFillCredentialsIdItems(
        @AncestorInPath Jenkins context, @QueryParameter String value) {
      checkPermissions();
      if (context == null || !context.hasPermission(Item.CONFIGURE)) {
        return new StandardListBoxModel();
      }

      List<DomainRequirement> domainRequirements = new ArrayList<DomainRequirement>();
      return new StandardListBoxModel()
          .withEmptySelection()
          .withMatching(
              CredentialsMatchers.instanceOf(GoogleOAuth2Credentials.class),
              CredentialsProvider.lookupCredentials(
                  StandardCredentials.class, context, ACL.SYSTEM, domainRequirements));
    }

    @RequirePOST
    public FormValidation doCheckCredentialsId(
        @AncestorInPath Jenkins context,
        @QueryParameter("projectId") String projectId,
        @QueryParameter String value) {
      checkPermissions();
      if (value.isEmpty()) return FormValidation.error("No credential selected");

      if (projectId.isEmpty())
        return FormValidation.error("Project ID required to validate credential");
      try {
        ClientFactory clientFactory = ClientUtil.getClientFactory(context, value);
        ComputeClient compute = clientFactory.computeClient();
        compute.listRegions(projectId);
        return FormValidation.ok(
            "The credential successfully made an API request to Google Compute Engine.");
      } catch (IOException ioe) {
        return FormValidation.error("Could not list regions in project " + projectId);
      }
    }
  }
}
