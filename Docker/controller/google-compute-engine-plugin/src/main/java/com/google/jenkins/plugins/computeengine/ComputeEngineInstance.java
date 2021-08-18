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

import static com.google.cloud.graphite.platforms.plugin.client.util.ClientUtil.nameFromSelfLink;

import com.google.api.services.compute.model.Instance;
import com.google.api.services.compute.model.Operation;
import com.google.cloud.graphite.platforms.plugin.client.ComputeClient.OperationException;
import com.google.common.base.Strings;
import com.google.jenkins.plugins.computeengine.ssh.GoogleKeyPair;
import hudson.Extension;
import hudson.model.Computer;
import hudson.model.Descriptor;
import hudson.model.TaskListener;
import hudson.slaves.AbstractCloudComputer;
import hudson.slaves.AbstractCloudSlave;
import hudson.slaves.ComputerLauncher;
import hudson.slaves.RetentionStrategy;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import javax.annotation.Nullable;
import jenkins.model.Jenkins;
import lombok.Builder;
import lombok.Getter;

@Getter
public class ComputeEngineInstance extends AbstractCloudSlave {
  private static final long serialVersionUID = 1;
  private static final Logger LOGGER = Logger.getLogger(ComputeEngineInstance.class.getName());
  private static final long CREATE_SNAPSHOT_TIMEOUT_LINUX = 120000;
  private static final long CREATE_SNAPSHOT_TIMEOUT_WINDOWS = 600000;

  // TODO: https://issues.jenkins-ci.org/browse/JENKINS-55518
  private final String zone;
  private final String cloudName;
  private final String instanceConfigurationName;
  private final String sshUser;
  private final WindowsConfiguration windowsConfig;
  private final boolean createSnapshot;
  private final boolean oneShot;
  private final boolean ignoreProxy;
  private final String javaExecPath;
  private final GoogleKeyPair sshKeyPair;
  private Integer launchTimeout; // Seconds
  private Boolean connected;
  private transient ComputeEngineCloud cloud;

  @Builder
  private ComputeEngineInstance(
      String cloudName,
      String instanceConfigurationName,
      String name,
      String zone,
      String nodeDescription,
      String sshUser,
      String remoteFS,
      // NOTE(stephenashank): Could not use optional due to serialization req.
      @Nullable WindowsConfiguration windowsConfig,
      boolean createSnapshot,
      boolean oneShot,
      boolean ignoreProxy,
      int numExecutors,
      Mode mode,
      String labelString,
      ComputerLauncher launcher,
      RetentionStrategy retentionStrategy,
      Integer launchTimeout,
      // NOTE(craigatgoogle): Could not use Optional due to serialization req.
      @Nullable String javaExecPath,
      @Nullable GoogleKeyPair sshKeyPair,
      @Nullable ComputeEngineCloud cloud)
      throws Descriptor.FormException, IOException {
    super(
        name,
        nodeDescription,
        remoteFS,
        numExecutors,
        mode,
        labelString,
        launcher,
        retentionStrategy,
        Collections.emptyList());
    this.launchTimeout = launchTimeout;
    this.zone = zone;
    this.cloudName = cloudName;
    this.instanceConfigurationName = instanceConfigurationName;
    this.sshUser = sshUser;
    this.windowsConfig = windowsConfig;
    this.createSnapshot = createSnapshot;
    this.oneShot = oneShot;
    this.ignoreProxy = ignoreProxy;
    this.javaExecPath = javaExecPath;
    this.sshKeyPair = sshKeyPair;
    this.cloud = cloud;
  }

  @Override
  public AbstractCloudComputer createComputer() {
    return new ComputeEngineComputer(this);
  }

  private void _terminateThreadedWork(Operation stopResponse) {

    // Wait for instance stop operation to complete

    {
      Operation.Error opError = new Operation.Error();
      try {
        LOGGER.log(
            Level.INFO,
            "Waiting for stop operation for instance {0} to complete",
            new Object[] {name});
        Operation stopResponseFinal =
            cloud
                .getClient()
                .waitForOperationCompletion(cloud.getProjectId(), stopResponse, 600000);
        opError = stopResponseFinal.getError();
      } catch (InterruptedException e) {
        LOGGER.info(
            String.format("Stop failed while waiting for operation to complete. Interrupted"));
        return;

      } catch (OperationException e) {
        opError = e.getError();
      }
      if (opError != null) {
        LOGGER.info(
            String.format(
                "Stop failed while waiting for operation %s to complete. Operation error was %s",
                stopResponse, opError.getErrors().get(0).getMessage()));
        return;
      }
    }

    boolean persist = false;

    // If there is a valid instance configuration,
    //   and the instance configuration allows persisting the same or more than the current number
    // of
    //   instances, choose to persist the current instance

    InstanceConfiguration instanceConfiguration = getInstanceConfiguration();
    if (instanceConfiguration != null) {

      InstanceOperationTracker instanceInsertOperationTracker =
          cloud.getInstanceInsertOperationTracker();
      InstanceOperationTracker instanceDeleteOperationTracker =
          cloud.getInstanceDeleteOperationTracker();
      instanceInsertOperationTracker.removeCompleted();
      instanceDeleteOperationTracker.removeCompleted();
      Set<InstanceOperationTracker.InstanceOperation> insertsInProgress =
          instanceInsertOperationTracker.get();
      Set<InstanceOperationTracker.InstanceOperation> deletesInProgress =
          instanceDeleteOperationTracker.get();

      Set<Instance> allInstances = cloud.getAllInstances().collect(Collectors.toSet());

      LOGGER.fine(
          "When deleting node, the following instances are visible in the GCE APIs: [ "
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
          cloud
              .getInstanceConfigurationPrioritizer()
              .getProjectedInstanceCountPerConfig(
                  Arrays.asList(new InstanceConfiguration[] {instanceConfiguration}),
                  allInstances,
                  insertsInProgress,
                  deletesInProgress);

      int maxNumInstancesToPersist = instanceConfiguration.getMaxNumInstancesToPersist();
      long numInstancesForConfig = projectedInstanceCountPerConfig.get(instanceConfiguration);
      persist = (maxNumInstancesToPersist >= numInstancesForConfig);
      LOGGER.log(
          Level.INFO,
          "Instance configuration "
              + instanceConfigurationName
              + " specifies max "
              + Integer.toString(maxNumInstancesToPersist)
              + " instances to persist: there are currently "
              + Long.toString(numInstancesForConfig)
              + " for that instance configuration; the instance will "
              + (persist ? "" : "not ")
              + "be persisted");
    } else {
      LOGGER.log(
          Level.INFO,
          "Instance configuration "
              + instanceConfigurationName
              + " not found; instance will not be persisted");
    }

    if (!persist) {

      // This instance should not be persisted. Delete it right away.

      LOGGER.log(Level.INFO, "Deleting instance {0}", new Object[] {name});

      // Ensure that any work on other threads is aware that this instance is scheduled to be
      // deleted
      InstanceOperationTracker.InstanceOperation deleteOperation =
          new InstanceOperationTracker.InstanceOperation(
              name, zone, instanceConfiguration.getNamePrefix(), null);
      cloud.getInstanceDeleteOperationTracker().add(deleteOperation);

      Operation terminateResponse = null;
      try {
        terminateResponse =
            cloud.getClient().terminateInstanceAsync(cloud.getProjectId(), zone, name);
      } catch (IOException e) {
        // Deletion failed; cancel tracking of the instance delete operation
        cloud.getInstanceDeleteOperationTracker().remove(deleteOperation);
        LOGGER.info(
            String.format("Delete failed while issuing operation to complete. IOException"));
        return;
      }
      // Deletion has been scheduled; add operation ID to tracker entry
      deleteOperation.setOperationId(terminateResponse.getName());

      Operation.Error opError = new Operation.Error();
      try {
        LOGGER.log(
            Level.INFO,
            "Waiting for delete operation for instance {0} to complete",
            new Object[] {name});
        Operation terminateResponseFinal =
            cloud
                .getClient()
                .waitForOperationCompletion(cloud.getProjectId(), terminateResponse, 600000);
        opError = terminateResponseFinal.getError();
      } catch (InterruptedException e) {
        LOGGER.info(
            String.format("Delete failed while waiting for operation to complete. Interrupted"));
        return;
      } catch (OperationException e) {
        opError = e.getError();
      }
      if (opError != null) {
        LOGGER.info(
            String.format(
                "Delete instance failed while waiting for operation %s to complete. Operation error was %s",
                terminateResponse, opError.getErrors().get(0).getMessage()));
        return;
      }

      LOGGER.log(Level.INFO, "Deleting instance {0} done", new Object[] {name});
    }
  }

  @Override
  protected void _terminate(TaskListener listener) throws IOException, InterruptedException {
    try {
      ComputeEngineCloud cloud = getCloud();

      Computer computer = this.toComputer();
      if (this.oneShot
          && this.createSnapshot
          && computer != null
          && !computer.getBuilds().failureOnly().isEmpty()) {
        LOGGER.log(Level.INFO, "Creating snapshot for node ... " + this.getNodeName());
        long createSnapshotTimeout =
            (windowsConfig != null)
                ? CREATE_SNAPSHOT_TIMEOUT_WINDOWS
                : CREATE_SNAPSHOT_TIMEOUT_LINUX;
        cloud
            .getClient()
            .createSnapshotSync(
                cloud.getProjectId(), this.zone, this.getNodeName(), createSnapshotTimeout);
      }

      LOGGER.log(Level.INFO, "Stopping instance {0}", new Object[] {name});

      Operation stopResponse =
          cloud.getClient2().stopInstance(cloud.getProjectId(), nameFromSelfLink(zone), name);

      Computer.threadPoolForRemoting.submit(
          () -> {
            _terminateThreadedWork(stopResponse);
          });

    } catch (CloudNotFoundException cnfe) {
      listener.error(cnfe.getMessage());
    } catch (OperationException oe) {
      listener.error(oe.getError().toPrettyString());
    } catch (IOException e) {
      listener.error(e.getMessage());
    }
  }

  public void onConnected() {
    this.connected = true;
  }

  public long getLaunchTimeoutMillis() {
    return launchTimeout * 1000L;
  }

  /** @return The configured Java executable path, or else the default Java binary. */
  public String getJavaExecPathOrDefault() {
    return !Strings.isNullOrEmpty(javaExecPath) ? javaExecPath : "java";
  }

  /** @return The configured Linux SSH key pair for this {@link ComputeEngineInstance}. */
  public Optional<GoogleKeyPair> getSSHKeyPair() {
    return Optional.ofNullable(sshKeyPair);
  }

  public ComputeEngineCloud getCloud() throws CloudNotFoundException {
    ComputeEngineCloud cloud = (ComputeEngineCloud) Jenkins.get().getCloud(cloudName);
    if (cloud == null)
      throw new CloudNotFoundException(
          String.format("Could not find cloud %s in Jenkins configuration", cloudName));
    return cloud;
  }

  public InstanceConfiguration getInstanceConfiguration() {
    ComputeEngineCloud cloud = getCloud();
    return cloud.getInstanceConfigurationByName(instanceConfigurationName);
  }

  @Extension
  public static final class DescriptorImpl extends SlaveDescriptor {
    @Override
    public String getDisplayName() {
      return Messages.ComputeEngineAgent_DisplayName();
    }
  }
}
