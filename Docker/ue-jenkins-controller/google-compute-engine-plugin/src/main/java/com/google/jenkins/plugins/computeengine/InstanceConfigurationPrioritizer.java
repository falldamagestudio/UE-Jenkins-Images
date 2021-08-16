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

import com.google.api.services.compute.model.Instance;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class InstanceConfigurationPrioritizer {

  private static int configsNext;
  private static int instancesNext;

  /**
   * Choose config from list of available configs. Current implementation use round robin strategy
   * starting at semi random element of list. Because most of times arriving requests asks for only
   * 1 new node, we don't want to start every time from 1 element.
   *
   * @param configs List of configs to choose from.
   * @return Chosen config from list.
   */
  private InstanceConfiguration chooseConfigFromList(List<InstanceConfiguration> configs) {
    return configs.get(Math.abs(configsNext++) % configs.size());
  }

  /**
   * Choose instance from list of available instances. Current implementation use round robin
   * strategy starting at semi random element of list.
   *
   * @param instances List of instances to choose from.
   * @return Chosen instance from list.
   */
  private Instance chooseInstanceFromList(List<Instance> instances) {
    return instances.get(Math.abs(instancesNext++) % instances.size());
  }

  // Given a config, and a stream of instances,
  //  return those instances that are associated with that config

  Stream<Instance> filterInstancesForConfig(
      InstanceConfiguration config, Stream<Instance> instances) {
    return instances.filter(
        instance ->
            instance
                .getLabels()
                .getOrDefault(ComputeEngineCloud.CONFIG_LABEL_KEY, "<no config label key found>")
                .equals(config.getNamePrefix()));
  }

  // Given a list of configs, and a list of provisionable instances,
  //  return those configs that have at least one provisionable instance associated with it

  List<InstanceConfiguration> getConfigsWithProvisionableInstances(
      List<InstanceConfiguration> configs, List<Instance> provisionableInstances) {

    List<InstanceConfiguration> configsWithProvisionableInstances =
        configs.stream()
            .filter(
                config ->
                    filterInstancesForConfig(config, provisionableInstances.stream())
                        .findAny()
                        .isPresent())
            .collect(Collectors.toList());
    return configsWithProvisionableInstances;
  }

  // Given a config, and a list of provisionable instances,
  //  return those provisionable instances that are associated with that particular config

  List<Instance> getProvisionableInstancesForConfig(
      InstanceConfiguration config, List<Instance> provisionableInstances) {
    List<Instance> provisionableInstancesForConfig =
        filterInstancesForConfig(config, provisionableInstances.stream())
            .collect(Collectors.toList());
    return provisionableInstancesForConfig;
  }

  // Given a list of configs, and a list of projected instance count for those configs
  //  return those configs that have capacity for at least one extra instance

  List<InstanceConfiguration> getConfigsWithSpareCapacity(
      List<InstanceConfiguration> configs,
      Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig) {

    List<InstanceConfiguration> configsWithSpareCapacity =
        configs.stream()
            .filter(
                config ->
                    config.getMaxNumInstancesToCreate()
                        > projectedInstanceCountPerConfig.getOrDefault(config, 0))
            .collect(Collectors.toList());
    return configsWithSpareCapacity;
  }

  public static class ConfigAndInstance {
    InstanceConfiguration config;
    Instance instance;

    public ConfigAndInstance(InstanceConfiguration config, Instance instance) {
      this.config = config;
      this.instance = instance;
    }
  }

  // Given a list of relevant configs, a list of all instances related to these configs,
  // and a list of all instances not currnently used by these configs,
  // choose a suitable config (and possible also an instance) to provision
  //
  // The result is either:
  // - a ConfigAndInstance identifying a config & an instance - use this config, re-use this
  // instance
  // - a ConfigAndInstance identifying a config, but no instance - use this config, provision a new
  // instance
  // - null - there is no config suitable for provisioning

  public ConfigAndInstance getConfigAndInstance(
      List<InstanceConfiguration> configs,
      List<Instance> provisionableInstances,
      Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig) {

    // First, look for a config that has provisionable instances
    // If we find one, choose that config, plus a corresponding instance

    if (!provisionableInstances.isEmpty()) {
      List<InstanceConfiguration> configsWithProvisionableInstances =
          getConfigsWithProvisionableInstances(configs, provisionableInstances);
      if (!configsWithProvisionableInstances.isEmpty()) {
        InstanceConfiguration tentativeConfig =
            chooseConfigFromList(configsWithProvisionableInstances);
        List<Instance> provisionableInstancesForConfig =
            getProvisionableInstancesForConfig(tentativeConfig, provisionableInstances);
        if (!provisionableInstancesForConfig.isEmpty()) {
          return new ConfigAndInstance(
              tentativeConfig, chooseInstanceFromList(provisionableInstancesForConfig));
        }
      }
    }

    // Second, look for a config that has no provisionable instances but available capacity
    // If we find one, choose that config, but leave the instance blank

    List<InstanceConfiguration> configsWithSpareCapacity =
        getConfigsWithSpareCapacity(configs, projectedInstanceCountPerConfig);
    if (!configsWithSpareCapacity.isEmpty()) {
      return new ConfigAndInstance(chooseConfigFromList(configsWithSpareCapacity), null);
    }

    // We did not find any suitable config

    return null;
  }

  // Given a config, and a stream of instance operations,
  //  return those instance operations that are associated with that config

  Stream<InstanceOperationTracker.InstanceOperation> filterInstanceOperationsForConfig(
      InstanceConfiguration config,
      Stream<InstanceOperationTracker.InstanceOperation> instanceOperations) {
    return instanceOperations.filter(
        instanceOperation -> instanceOperation.getNamePrefix().equals(config.getNamePrefix()));
  }

  // Given a config, a set of instances,
  //  and sets of insert & delete operations in progress
  //  return names of the instances associated with that config that will
  //  exist once the insert & delete operations have completed

  Set<String> getProjectedInstanceNamesForConfig(
      InstanceConfiguration config,
      Set<Instance> allInstances,
      Set<InstanceOperationTracker.InstanceOperation> insertsInProgress,
      Set<InstanceOperationTracker.InstanceOperation> deletesInProgress) {

    Stream<Instance> currentInstancesForConfig =
        filterInstancesForConfig(config, allInstances.stream());
    Set<String> currentInstanceNamesForConfig =
        currentInstancesForConfig.map(instance -> instance.getName()).collect(Collectors.toSet());

    Stream<InstanceOperationTracker.InstanceOperation> insertsInProgressForConfig =
        filterInstanceOperationsForConfig(config, insertsInProgress.stream());
    Set<String> insertNamesInProgressForConfig =
        insertsInProgressForConfig
            .map(instanceOperation -> instanceOperation.getName())
            .collect(Collectors.toSet());

    Stream<InstanceOperationTracker.InstanceOperation> deletesInProgressForConfig =
        filterInstanceOperationsForConfig(config, deletesInProgress.stream());
    Set<String> deleteNamesInProgressForConfig =
        deletesInProgressForConfig
            .map(instanceOperation -> instanceOperation.getName())
            .collect(Collectors.toSet());

    Set<String> projectedInstanceNamesForConfig =
        new HashSet<String>(currentInstanceNamesForConfig);
    projectedInstanceNamesForConfig.addAll(insertNamesInProgressForConfig);
    projectedInstanceNamesForConfig.removeAll(deleteNamesInProgressForConfig);

    return projectedInstanceNamesForConfig;
  }

  // Given a list of configs, a set of instances,
  //  and sets of insert & delete operations in progress
  //  return how many instances that will be active for each config
  //  once the insert & delete operations have completed

  public Map<InstanceConfiguration, Integer> getProjectedInstanceCountPerConfig(
      List<InstanceConfiguration> configs,
      Set<Instance> allInstances,
      Set<InstanceOperationTracker.InstanceOperation> insertsInProgress,
      Set<InstanceOperationTracker.InstanceOperation> deletesInProgress) {

    Map<InstanceConfiguration, Integer> instancesPerConfig =
        new HashMap<InstanceConfiguration, Integer>();

    for (InstanceConfiguration config : configs) {
      instancesPerConfig.put(
          config,
          getProjectedInstanceNamesForConfig(
                  config, allInstances, insertsInProgress, deletesInProgress)
              .size());
    }

    return instancesPerConfig;
  }
}
