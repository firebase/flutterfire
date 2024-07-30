// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect_grpc;

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
  }
  late ConnectorServiceClient stub;
  late ClientChannel channel;
  @override
  TransportOptions transportOptions;
  @override
  DataConnectOptions options;

  /// Invokes emulator
  @override
  Future<Data> invokeQuery<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serialize,
      Variables? vars,
      String? token) async {
    ExecuteQueryResponse response;

    String name =
        'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}';

    Map<String, String> metadata = {
      'x-goog-request-params': 'location=${options.location}&frontend=data'
    };
    if (token != null) {
      metadata['x-firebase-auth-token'] = token;
    }
    if (vars != null && serialize != null) {
      Struct varStruct = Struct.fromJson(serialize(vars));
      response = await stub.executeQuery(
          ExecuteQueryRequest(
              name: name, operationName: queryName, variables: varStruct),
          options: CallOptions(metadata: metadata));
    } else {
      response = await stub.executeQuery(
          ExecuteQueryRequest(
            name: name,
            operationName: queryName,
          ),
          options: CallOptions(metadata: metadata));
    }
    return deserializer(jsonEncode(response.data.toProto3Json()));
  }

  /// Invokes emulator
  @override
  Future<Data> invokeMutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token) async {
    ExecuteMutationResponse response;
    String name =
        'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}';
    Map<String, String> metadata = {
      'x-goog-request-params': 'location=${options.location}&frontend=data',
      'x-goog-api-client': 'gl-dart/flutter fire/$packageVersion'
    };
    if (token != null) {
      metadata['x-firebase-auth-token'] = token;
    }
    if (vars != null && serializer != null) {
      Struct struct = Struct.create();
      struct.mergeFromProto3Json(jsonDecode(serializer(vars)));
      // Struct varStruct = Struct.fromJson(serializer(vars));
      response = await stub.executeMutation(
          ExecuteMutationRequest(
              name: name, operationName: queryName, variables: struct),
          options: CallOptions(metadata: {
            'x-goog-request-params':
                'location=${options.location}&frontend=data'
          }));
    } else {
      response = await stub.executeMutation(
          ExecuteMutationRequest(
            name: name,
            operationName: queryName,
          ),
          options: CallOptions(metadata: {
            'x-goog-request-params':
                'location=${options.location}&frontend=data'
          }));
    }
    return deserializer(jsonEncode(response.data.toProto3Json()));
  }
}

DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    GRPCTransport(transportOptions, options);
