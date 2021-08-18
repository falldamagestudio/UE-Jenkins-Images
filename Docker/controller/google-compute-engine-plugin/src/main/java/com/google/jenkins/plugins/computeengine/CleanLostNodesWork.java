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

import com.google.api.services.compute.Compute;
import com.google.api.services.compute.model.Instance;
import hudson.Extension;
import hudson.model.PeriodicWork;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import jenkins.model.Jenkins;
import org.jenkinsci.Symbol;

/** Periodically checks if there are no lost nodes in GCP. If it finds any they are deleted. */
@Extension
@Symbol("cleanLostNodesWork")
public class CleanLostNodesWork extends PeriodicWork {
  protected final Logger logger = Logger.getLogger(getClass().getName());

  /** {@inheritDoc} */
  @Override
  public long getRecurrencePeriod() {
    return HOUR;
  }

  /** {@inheritDoc} */
  @Override
  protected void doRun() {
    logger.log(Level.INFO, "Starting clean lost nodes worker");
    getClouds().forEach(this::cleanCloud);
  }

  private void cleanCloud(ComputeEngineCloud cloud) {
    logger.log(Level.INFO, "Cleaning cloud " + cloud.getCloudName());
    Stream<Instance> allInstances = cloud.getAllInstances();
    Set<String> allNodes = cloud.getAllNodes().collect(Collectors.toSet());

    // We are only interested in instances that do not have matching nodes.
    // Instances that have matching nodes are still properly "under control" by
    //  Jenkins and its plugins.

    List<Instance> orphanedInstances =
        allInstances
            .filter(instance -> isOrphaned(instance, allNodes))
            .collect(Collectors.toList());

    if (!orphanedInstances.isEmpty()) {
      logger.log(
          Level.INFO,
          "Instances without matching nodes in cloud {0}: {1}",
          new Object[] {
            cloud.getCloudName(),
            String.join(
                ",",
                orphanedInstances.stream()
                    .map(instance -> instance.getName())
                    .collect(Collectors.toList()))
          });
    }

    // Any instances that are currently running, but do not have matching nodes, should be stopped
    //  right away.
    // Once they have stopped, they will be deleted during the next cleanup pass in case they also
    //  are expired.

    List<Instance> instancesToStop =
        orphanedInstances.stream()
            .filter(instance -> isRunning(instance))
            .collect(Collectors.toList());

    if (!instancesToStop.isEmpty()) {
      logger.log(
          Level.INFO,
          "Instances that should be stopped in cloud {0}: {1}",
          new Object[] {
            cloud.getCloudName(),
            String.join(
                ",",
                instancesToStop.stream()
                    .map(instance -> instance.getName())
                    .collect(Collectors.toList()))
          });
    }

    // Instances that are terminated, should be deleted, if:
    // A) the instance should not be persisted, or
    // B) the instance should be persisted, but its retention timeout has expired

    List<Instance> instancesToDelete =
        orphanedInstances.stream()
            .filter(instance -> isTerminated(instance) && hasExpired(instance))
            .collect(Collectors.toList());

    if (!instancesToDelete.isEmpty()) {
      logger.log(
          Level.INFO,
          "Instances that should be deleted in cloud {0}: {1}",
          new Object[] {
            cloud.getCloudName(),
            String.join(
                ",",
                instancesToDelete.stream()
                    .map(instance -> instance.getName())
                    .collect(Collectors.toList()))
          });
    }

    instancesToStop.stream().forEach(instance -> stopInstance(instance, cloud));
    instancesToDelete.stream().forEach(instance -> deleteInstance(instance, cloud));
  }

  private boolean isOrphaned(Instance instance, Set<String> nodes) {
    String instanceName = instance.getName();
    return !nodes.contains(instanceName);
  }

  private boolean isRunning(Instance instance) {
    return instance.getStatus().equals("RUNNING");
  }

  private boolean isTerminated(Instance instance) {
    return instance.getStatus().equals("TERMINATED");
  }

  private boolean hasExpired(Instance instance) {
    // TODO: implement
    return false;
  }

  private void stopInstance(Instance instance, ComputeEngineCloud cloud) {
    String instanceName = instance.getName();
    logger.log(
        Level.INFO,
        "Stopping instance {0} in cloud {1}",
        new Object[] {instanceName, cloud.getCloudName()});
    try {
      Compute.Instances.Stop request =
          cloud
              .getCompute()
              .instances()
              .stop(cloud.getProjectId(), nameFromSelfLink(instance.getZone()), instanceName);
      request.execute();
      // TODO: inspect result from request.execute() and react accordingly
      // or even better, package up this functionality somewhere central - we're doing roughly the
      // same thing with similar error handling in at least two places in the codebase
    } catch (IOException ex) {
      logger.log(
          Level.WARNING,
          MessageFormat.format(
              "Error stopping instance {0} in cloud {1}",
              new Object[] {instanceName, cloud.getCloudName()}),
          ex);
    }
  }

  private void deleteInstance(Instance instance, ComputeEngineCloud cloud) {
    String instanceName = instance.getName();
    logger.log(
        Level.INFO,
        "Deleting instance {0} from cloud {1}",
        new Object[] {instanceName, cloud.getCloudName()});
    try {
      cloud
          .getClient()
          .terminateInstanceAsync(cloud.getProjectId(), instance.getZone(), instanceName);
    } catch (IOException ex) {
      logger.log(
          Level.WARNING,
          MessageFormat.format(
              "Error deleting instance {0} from cloud {1}",
              new Object[] {instanceName, cloud.getCloudName()}),
          ex);
    }
  }

  private List<ComputeEngineCloud> getClouds() {
    return Jenkins.get().clouds.stream()
        .filter(cloud -> cloud instanceof ComputeEngineCloud)
        .map(cloud -> (ComputeEngineCloud) cloud)
        .collect(Collectors.toList());
  }
}
