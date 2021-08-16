package com.google.jenkins.plugins.computeengine.client;

import com.google.api.services.compute.Compute;
import com.google.api.services.compute.model.Operation;
import java.io.IOException;

// This class is a collection of things that ought to be in
// com.google.cloud.graphite.platforms.plugin.client.ComputeClient,
//  but is missing - at least in the version of the library that we use.

public class ComputeClient2 {

  private Compute compute;

  public ComputeClient2(Compute compute) {
    this.compute = compute;
  }

  public Operation startInstance(String project, String zone, String name) throws IOException {
    Compute.Instances.Start request = compute.instances().start(project, zone, name);
    Operation operation = request.execute();
    return operation;
  }

  public Operation stopInstance(String project, String zone, String name) throws IOException {
    Compute.Instances.Stop request = compute.instances().stop(project, zone, name);
    Operation operation = request.execute();
    return operation;
  }

  public Operation getZoneOperation(String project, String zone, String operation)
      throws IOException {
    Compute.ZoneOperations.Get request = compute.zoneOperations().get(project, zone, operation);
    Operation response = request.execute();
    return response;
  }
}
