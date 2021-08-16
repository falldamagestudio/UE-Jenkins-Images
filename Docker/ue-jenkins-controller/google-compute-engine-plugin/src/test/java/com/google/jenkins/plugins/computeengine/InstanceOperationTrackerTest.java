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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import com.google.api.services.compute.model.Operation;
import com.google.jenkins.plugins.computeengine.client.ComputeClient2;
import java.util.Set;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.jvnet.hudson.test.JenkinsRule;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class InstanceOperationTrackerTest {

  @Rule public JenkinsRule r = new JenkinsRule();

  @Test
  public void acceptsNewOperations() {
    InstanceOperationTracker instanceOperationTracker = new InstanceOperationTracker(null);

    InstanceOperationTracker.InstanceOperation instanceOperation1 =
        new InstanceOperationTracker.InstanceOperation("instance1", "zone1", "prefix1", "1234");
    InstanceOperationTracker.InstanceOperation instanceOperation2 =
        new InstanceOperationTracker.InstanceOperation("instance2", "zone2", "prefix2", "5678");
    InstanceOperationTracker.InstanceOperation instanceOperation3 =
        new InstanceOperationTracker.InstanceOperation("instance3", "zone3", "prefix3", "abcd");

    instanceOperationTracker.add(instanceOperation1);
    instanceOperationTracker.add(instanceOperation2);

    Set<InstanceOperationTracker.InstanceOperation> instanceOperations =
        instanceOperationTracker.get();

    assertEquals(2, instanceOperations.size());
    assertTrue(instanceOperations.contains(instanceOperation1));
    assertTrue(instanceOperations.contains(instanceOperation2));
    assertFalse(instanceOperations.contains(instanceOperation3));
  }

  @Test
  public void removesExistingOperations() {
    InstanceOperationTracker instanceOperationTracker = new InstanceOperationTracker(null);

    InstanceOperationTracker.InstanceOperation instanceOperation1 =
        new InstanceOperationTracker.InstanceOperation("instance1", "zone1", "prefix1", "1234");
    InstanceOperationTracker.InstanceOperation instanceOperation2 =
        new InstanceOperationTracker.InstanceOperation("instance2", "zone2", "prefix2", "5678");
    InstanceOperationTracker.InstanceOperation instanceOperation3 =
        new InstanceOperationTracker.InstanceOperation("instance3", "zone3", "prefix3", "abcd");

    instanceOperationTracker.add(instanceOperation1);
    instanceOperationTracker.add(instanceOperation2);
    instanceOperationTracker.remove(instanceOperation1);

    Set<InstanceOperationTracker.InstanceOperation> instanceOperations =
        instanceOperationTracker.get();

    assertEquals(1, instanceOperations.size());
    assertFalse(instanceOperations.contains(instanceOperation1));
    assertTrue(instanceOperations.contains(instanceOperation2));
    assertFalse(instanceOperations.contains(instanceOperation3));
  }

  @Test
  public void acceptsRemoveForOperationThatIsNotPartOfTracker() {
    InstanceOperationTracker instanceOperationTracker = new InstanceOperationTracker(null);

    InstanceOperationTracker.InstanceOperation instanceOperation1 =
        new InstanceOperationTracker.InstanceOperation("instance1", "zone1", "prefix1", "1234");
    InstanceOperationTracker.InstanceOperation instanceOperation2 =
        new InstanceOperationTracker.InstanceOperation("instance2", "zone2", "prefix2", "5678");
    InstanceOperationTracker.InstanceOperation instanceOperation3 =
        new InstanceOperationTracker.InstanceOperation("instance3", "zone3", "prefix3", "abcd");

    instanceOperationTracker.add(instanceOperation1);
    instanceOperationTracker.add(instanceOperation2);
    instanceOperationTracker.remove(instanceOperation3);

    Set<InstanceOperationTracker.InstanceOperation> instanceOperations =
        instanceOperationTracker.get();

    assertEquals(2, instanceOperations.size());
    assertTrue(instanceOperations.contains(instanceOperation1));
    assertTrue(instanceOperations.contains(instanceOperation2));
    assertFalse(instanceOperations.contains(instanceOperation3));
  }

  @Test
  public void removesCompletedOperations() throws Exception {

    ComputeEngineCloud cloud = Mockito.mock(ComputeEngineCloud.class);
    ComputeClient2 client2 = Mockito.mock(ComputeClient2.class);
    Mockito.when(cloud.getProjectId()).thenReturn("test-project");
    Mockito.when(cloud.getClient2()).thenReturn(client2);

    InstanceOperationTracker instanceOperationTracker = new InstanceOperationTracker(cloud);

    InstanceOperationTracker.InstanceOperation instanceOperation1 =
        new InstanceOperationTracker.InstanceOperation("instance1", "zone1", "prefix1", "1234");
    InstanceOperationTracker.InstanceOperation instanceOperation2 =
        new InstanceOperationTracker.InstanceOperation("instance2", "zone2", "prefix2", "5678");
    InstanceOperationTracker.InstanceOperation instanceOperation3 =
        new InstanceOperationTracker.InstanceOperation("instance3", "zone3", "prefix3", "abcd");

    Operation zoneOperationsGetOperation1 = Mockito.mock(Operation.class);
    Mockito.when(client2.getZoneOperation("test-project", "zone1", "1234"))
        .thenReturn(zoneOperationsGetOperation1);
    Operation zoneOperationsGetOperation2 = Mockito.mock(Operation.class);
    Mockito.when(client2.getZoneOperation("test-project", "zone2", "5678"))
        .thenReturn(zoneOperationsGetOperation2);
    Operation zoneOperationsGetOperation3 = Mockito.mock(Operation.class);
    Mockito.when(client2.getZoneOperation("test-project", "zone3", "abcd"))
        .thenReturn(zoneOperationsGetOperation3);

    instanceOperationTracker.add(instanceOperation1);
    instanceOperationTracker.add(instanceOperation2);

    // Initially, there are two operations in the tracker

    {
      Set<InstanceOperationTracker.InstanceOperation> instanceOperations =
          instanceOperationTracker.get();

      assertEquals(2, instanceOperations.size());
      assertTrue(instanceOperations.contains(instanceOperation1));
      assertTrue(instanceOperations.contains(instanceOperation2));
      assertFalse(instanceOperations.contains(instanceOperation3));
    }

    // One of the operations is complete: removes operation

    Mockito.when(zoneOperationsGetOperation1.getStatus()).thenReturn("RUNNING");
    Mockito.when(zoneOperationsGetOperation2.getStatus()).thenReturn("DONE");
    Mockito.when(zoneOperationsGetOperation3.getStatus())
        .thenThrow(new RuntimeException("instance 3 has not yet been added"));

    instanceOperationTracker.removeCompleted();

    {
      Set<InstanceOperationTracker.InstanceOperation> instanceOperations =
          instanceOperationTracker.get();

      assertEquals(1, instanceOperations.size());
      assertTrue(instanceOperations.contains(instanceOperation1));
      assertFalse(instanceOperations.contains(instanceOperation2));
      assertFalse(instanceOperations.contains(instanceOperation3));
    }

    // Repeating when there have been no changes, has no effect

    instanceOperationTracker.removeCompleted();

    {
      Set<InstanceOperationTracker.InstanceOperation> instanceOperations =
          instanceOperationTracker.get();

      assertEquals(1, instanceOperations.size());
      assertTrue(instanceOperations.contains(instanceOperation1));
      assertFalse(instanceOperations.contains(instanceOperation2));
      assertFalse(instanceOperations.contains(instanceOperation3));
    }
  }
}
