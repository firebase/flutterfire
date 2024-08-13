// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect_grpc;

/// Transport used for Android/iOS. Uses a GRPC transport instead of REST.
class GRPCTransport implements DataConnectTransport {
  /// GRPCTransport creates a new channel
  GRPCTransport(this.transportOptions, this.options) {
    bool isSecure =
        transportOptions.isSecure == null || transportOptions.isSecure == true;
    channel = ClientChannel(transportOptions.host,
        port: transportOptions.port ?? 443,
        options: ChannelOptions(
            credentials: (isSecure
                ? const ChannelCredentials.secure()
                : const ChannelCredentials.insecure())));
    stub = ConnectorServiceClient(channel);
    name =
        'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}';
  }

  /// Name of the endpoint.
  late String name;

  /// ConnectorServiceClient used to execute the query/mutation.
  late ConnectorServiceClient stub;

  /// ClientChannel used to configure connection to the GRPC server.
  late ClientChannel channel;

  /// Current host configuration.
  @override
  TransportOptions transportOptions;

  /// Data Connect backend configuration options.
  @override
  DataConnectOptions options;

  /// Get headers required for all requests.
  Map<String, String> getMetadata(String? authToken) {
    Map<String, String> metadata = {
      'x-goog-request-params': 'location=${options.location}&frontend=data',
      'x-goog-api-client': 'gl-dart/flutter fire/$packageVersion'
    };
    if (authToken != null) {
      metadata['x-firebase-auth-token'] = authToken;
    }
    return metadata;
  }

  /// Invokes GPRC query endpoint.
  @override
  Future<Data> invokeQuery<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token) async {
    ExecuteQueryResponse response;

    Map<String, String> metadata = getMetadata(token);
    ExecuteQueryRequest request =
        ExecuteQueryRequest(name: name, operationName: queryName);
    if (vars != null && serializer != null) {
      request.variables = getStruct(vars, serializer);
    }
    try {
      response = await stub.executeQuery(request,
          options: CallOptions(metadata: metadata));
      return deserializer(jsonEncode(response.data.toProto3Json()));
    } on Exception catch (e) {
      throw FirebaseDataConnectError(DataConnectErrorCode.other,
          'Failed to invoke operation: ${e.toString()}');
    }
  }

  /// Converts the variables into a proto Struct.
  Struct getStruct<Variables>(
      Variables vars, Serializer<Variables> serializer) {
    Struct struct = Struct.create();
    struct.mergeFromProto3Json(jsonDecode(serializer(vars)));
    return struct;
  }

  /// Invokes GPRC mutation endpoint.
  @override
  Future<Data> invokeMutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token) async {
    ExecuteMutationResponse response;
    Map<String, String> metadata = getMetadata(token);
    ExecuteMutationRequest request =
        ExecuteMutationRequest(name: name, operationName: queryName);
    if (vars != null && serializer != null) {
      request.variables = getStruct(vars, serializer);
    }
    try {
      response = await stub.executeMutation(request,
          options: CallOptions(metadata: metadata));
      return deserializer(jsonEncode(response.data.toProto3Json()));
    } on Exception catch (e) {
      throw FirebaseDataConnectError(DataConnectErrorCode.other,
          'Failed to invoke operation: ${e.toString()}');
    }
  }
}

/// Initializes GRPC transport for Data Connect.
DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    GRPCTransport(transportOptions, options);
