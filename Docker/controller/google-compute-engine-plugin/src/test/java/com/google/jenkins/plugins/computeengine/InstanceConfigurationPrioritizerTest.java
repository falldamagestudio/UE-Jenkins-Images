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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import com.google.api.services.compute.model.Instance;
import com.google.common.collect.ImmutableMap;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.jvnet.hudson.test.JenkinsRule;
import org.mockito.junit.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class InstanceConfigurationPrioritizerTest {

  @Rule public JenkinsRule r = new JenkinsRule();

  @Test
  public void shouldFilterInstancesForConfig() {
    InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
        new InstanceConfigurationPrioritizer();

    String namePrefix1 = "name-prefix-1";
    String namePrefix2 = "name-prefix-2";

    InstanceConfiguration config = InstanceConfiguration.builder().namePrefix(namePrefix1).build();

    Instance instance1 = new Instance();
    instance1.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix1));

    Instance instance2 = new Instance();
    instance2.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix2));

    Instance instance3 = new Instance();
    instance3.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix1));

    List<Instance> instances = Arrays.asList(new Instance[] {instance1, instance2, instance3});

    List<Instance> filteredInstances =
        instanceConfigurationPrioritizer
            .filterInstancesForConfig(config, instances.stream())
            .collect(Collectors.toList());

    assertEquals(2, filteredInstances.size());

    assertEquals(instance1, filteredInstances.get(0));
    assertEquals(instance3, filteredInstances.get(1));
  }

  @Test
  public void shouldFilterConfigsWithProvisionableInstances() {
    InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
        new InstanceConfigurationPrioritizer();

    String namePrefix1 = "name-prefix-1";
    String namePrefix2 = "name-prefix-2";
    String namePrefix3 = "name-prefix-3";

    InstanceConfiguration config1 = InstanceConfiguration.builder().namePrefix(namePrefix1).build();
    InstanceConfiguration config2 = InstanceConfiguration.builder().namePrefix(namePrefix2).build();
    InstanceConfiguration config3 = InstanceConfiguration.builder().namePrefix(namePrefix3).build();

    Instance instance1 = new Instance();
    instance1.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix2));

    Instance instance2 = new Instance();
    instance2.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix2));

    Instance instance3 = new Instance();
    instance3.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix3));

    List<InstanceConfiguration> configs =
        Arrays.asList(new InstanceConfiguration[] {config1, config2, config3});

    List<Instance> instances = Arrays.asList(new Instance[] {instance1, instance2, instance3});

    List<InstanceConfiguration> configsWithProvisionableInstances =
        instanceConfigurationPrioritizer.getConfigsWithProvisionableInstances(configs, instances);

    assertEquals(2, configsWithProvisionableInstances.size());

    assertEquals(config2, configsWithProvisionableInstances.get(0));
    assertEquals(config3, configsWithProvisionableInstances.get(1));
  }

  @Test
  public void shouldFilterProvisionableInstancesForConfig() {
    InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
        new InstanceConfigurationPrioritizer();

    String namePrefix1 = "name-prefix-1";
    String namePrefix2 = "name-prefix-2";
    String namePrefix3 = "name-prefix-3";

    InstanceConfiguration config = InstanceConfiguration.builder().namePrefix(namePrefix1).build();

    Instance instance1 = new Instance();
    instance1.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix1));

    Instance instance2 = new Instance();
    instance2.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix1));

    Instance instance3 = new Instance();
    instance3.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix3));

    List<Instance> instances = Arrays.asList(new Instance[] {instance1, instance2, instance3});

    List<Instance> provisionableInstancesForConfig =
        instanceConfigurationPrioritizer.getProvisionableInstancesForConfig(config, instances);

    assertEquals(2, provisionableInstancesForConfig.size());

    assertEquals(instance1, provisionableInstancesForConfig.get(0));
    assertEquals(instance2, provisionableInstancesForConfig.get(1));
  }

  @Test
  public void shouldFilterConfigsWithSpareCapacity() {
    InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
        new InstanceConfigurationPrioritizer();

    String namePrefix1 = "name-prefix-1";
    String namePrefix2 = "name-prefix-2";
    String namePrefix3 = "name-prefix-3";

    // config1 has spare capacity: max nodes = 1, current nodes = 0
    InstanceConfiguration config1 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix1)
            .maxNumInstancesToCreateStr("1")
            .build();
    // config2 has no spare capacity: max nodes = 0, current nodes = 1
    InstanceConfiguration config2 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix2)
            .maxNumInstancesToCreateStr("0")
            .build();
    // config3 has no spare capcity: max nodes = 2, current nodes = 2
    InstanceConfiguration config3 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix3)
            .maxNumInstancesToCreateStr("2")
            .build();

    List<InstanceConfiguration> configs =
        Arrays.asList(new InstanceConfiguration[] {config1, config2, config3});

    Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig =
        ImmutableMap.of(
            config1, 0,
            config2, 1,
            config3, 2);

    List<InstanceConfiguration> configsWithSpareCapacity =
        instanceConfigurationPrioritizer.getConfigsWithSpareCapacity(
            configs, projectedInstanceCountPerConfig);

    assertEquals(1, configsWithSpareCapacity.size());

    assertEquals(config1, configsWithSpareCapacity.get(0));
  }

  @Test
  public void shouldPreferConfigWithProvisionableInstance() {

    String namePrefix1 = "name-prefix-1";
    String namePrefix2 = "name-prefix-2";
    String namePrefix3 = "name-prefix-3";

    // config1 has one provisionable instance: instance1
    InstanceConfiguration config1 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix1)
            .maxNumInstancesToCreateStr("3")
            .build();
    // config2 has no provisionable instances
    InstanceConfiguration config2 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix2)
            .maxNumInstancesToCreateStr("3")
            .build();
    // config2 has two provisionable instances: instance2 & instance3
    InstanceConfiguration config3 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix3)
            .maxNumInstancesToCreateStr("3")
            .build();

    Instance instance1 = new Instance();
    instance1.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix1));

    Instance instance2 = new Instance();
    instance2.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix3));

    Instance instance3 = new Instance();
    instance3.setLabels(Collections.singletonMap(ComputeEngineCloud.CONFIG_LABEL_KEY, namePrefix3));

    List<InstanceConfiguration> configs =
        Arrays.asList(new InstanceConfiguration[] {config1, config2, config3});

    Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig_none =
        ImmutableMap.of(
            config1, 0,
            config2, 0,
            config3, 0);

    List<Instance> instances_config1Only = Arrays.asList(new Instance[] {instance1});
    List<Instance> instances_config3Only = Arrays.asList(new Instance[] {instance2, instance3});
    List<Instance> instances_none = Arrays.asList(new Instance[] {});

    {
      // Prefer config 1 if that is the only config with provisionable instances

      InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
          new InstanceConfigurationPrioritizer();
      InstanceConfigurationPrioritizer.ConfigAndInstance configAndInstance =
          instanceConfigurationPrioritizer.getConfigAndInstance(
              configs, instances_config1Only, projectedInstanceCountPerConfig_none);
      assertNotNull(configAndInstance);
      assertEquals(config1, configAndInstance.config);
      assertEquals(instance1, configAndInstance.instance);
    }

    {
      // Prefer config 3 if that is the only config with provisionable instances

      InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
          new InstanceConfigurationPrioritizer();
      InstanceConfigurationPrioritizer.ConfigAndInstance configAndInstance =
          instanceConfigurationPrioritizer.getConfigAndInstance(
              configs, instances_config3Only, projectedInstanceCountPerConfig_none);
      assertNotNull(configAndInstance);
      assertEquals(config3, configAndInstance.config);
      assertEquals(instance2, configAndInstance.instance);
    }
  }

  @Test
  public void shouldPreferConfigWithCapacity() {

    String namePrefix1 = "name-prefix-1";
    String namePrefix2 = "name-prefix-2";
    String namePrefix3 = "name-prefix-3";

    // config1 has no spare capacity: max nodes = 0, current nodes = 1
    InstanceConfiguration config1 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix1)
            .maxNumInstancesToCreateStr("0")
            .build();
    // config2 has spare capacity: max nodes = 1, current nodes = 0
    InstanceConfiguration config2 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix2)
            .maxNumInstancesToCreateStr("1")
            .build();
    // config3 has no spare capcity: max nodes = 2, current nodes = 2
    InstanceConfiguration config3 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix3)
            .maxNumInstancesToCreateStr("2")
            .build();

    List<InstanceConfiguration> configs =
        Arrays.asList(new InstanceConfiguration[] {config1, config2, config3});

    Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig =
        ImmutableMap.of(
            config1, 1,
            config2, 0,
            config3, 2);

    // Prefer config 2 since that is the only config with spare capacity

    InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
        new InstanceConfigurationPrioritizer();
    InstanceConfigurationPrioritizer.ConfigAndInstance configAndInstance =
        instanceConfigurationPrioritizer.getConfigAndInstance(
            configs, new ArrayList<Instance>(), projectedInstanceCountPerConfig);

    assertNotNull(configAndInstance);
    assertEquals(config2, configAndInstance.config);
    assertNull(configAndInstance.instance);
  }

  @Test
  public void shouldNotChooseAnyConfigIfAllConfigsAreFull() {

    String namePrefix1 = "name-prefix-1";
    String namePrefix2 = "name-prefix-2";
    String namePrefix3 = "name-prefix-3";

    // config1 has no spare capacity: max nodes = 0, current nodes = 0
    InstanceConfiguration config1 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix1)
            .maxNumInstancesToCreateStr("0")
            .build();
    // config2 has no spare capacity: max nodes = 1, current nodes = 1
    InstanceConfiguration config2 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix2)
            .maxNumInstancesToCreateStr("1")
            .build();
    // config3 has no spare capcity: max nodes = 2, current nodes = 2
    InstanceConfiguration config3 =
        InstanceConfiguration.builder()
            .namePrefix(namePrefix3)
            .maxNumInstancesToCreateStr("2")
            .build();

    List<InstanceConfiguration> configs =
        Arrays.asList(new InstanceConfiguration[] {config1, config2, config3});

    Map<InstanceConfiguration, Integer> projectedInstanceCountPerConfig =
        ImmutableMap.of(
            config1, 0,
            config2, 1,
            config3, 2);

    // No configuration is suitable; all are at max capacity, with no provisionable instances

    InstanceConfigurationPrioritizer instanceConfigurationPrioritizer =
        new InstanceConfigurationPrioritizer();
    InstanceConfigurationPrioritizer.ConfigAndInstance configAndInstance =
        instanceConfigurationPrioritizer.getConfigAndInstance(
            configs, new ArrayList<Instance>(), projectedInstanceCountPerConfig);

    assertNull(configAndInstance);
  }
}
