package com.google.jenkins.plugins.computeengine.client;

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.googleapis.services.AbstractGoogleClientRequest;
import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.HttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.compute.Compute;
import com.google.common.base.Preconditions;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Optional;

public class ComputeFactory {
  private final HttpTransport transport;
  private final JsonFactory jsonFactory;
  private final HttpRequestInitializer httpRequestInitializer;
  private final String applicationName;

  /**
   * Constructor for {@link ComputeFactory}.
   *
   * @param httpTransport An optional HTTP Transport for making HTTP requests. If not specified, the
   *     default trusted NetHttpTransport will be generated.
   * @param httpRequestInitializer Used to initialize HTTP requests, and must contain the Credential
   *     for authenticating requests.
   * @param applicationName The name of the application which is using the clients in order to tie
   *     this information to requests to track usage.
   * @throws IOException If generating a new trusted HTTP Transport failed
   * @throws GeneralSecurityException If generating a new trusted HTTP Transport failed due to
   */
  public ComputeFactory(
      final Optional<HttpTransport> httpTransport,
      final HttpRequestInitializer httpRequestInitializer,
      final String applicationName)
      throws IOException, GeneralSecurityException {
    this.transport = httpTransport.orElse(GoogleNetHttpTransport.newTrustedTransport());
    this.jsonFactory = new JacksonFactory();
    this.httpRequestInitializer = Preconditions.checkNotNull(httpRequestInitializer);
    this.applicationName = Preconditions.checkNotNull(applicationName);
  }

  /**
   * Initializes a {@link ComputeClient} with the properties of this {@link ClientFactory}.
   *
   * @return A {@link ComputeClient} for interacting with the Google Compute Engine API.
   */
  public Compute compute() {
    return new Compute.Builder(transport, jsonFactory, httpRequestInitializer)
        .setGoogleClientRequestInitializer(this::initializeRequest)
        .setApplicationName(applicationName)
        .build();
  }

  private void initializeRequest(final AbstractGoogleClientRequest request) {
    request.setRequestHeaders(request.getRequestHeaders().setUserAgent(applicationName));
  }
}
