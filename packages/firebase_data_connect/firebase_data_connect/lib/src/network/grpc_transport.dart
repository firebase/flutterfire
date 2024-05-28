part of firebase_data_connect_grpc;

class GRPCTransport implements DataConnectTransport {
  late ConnectorServiceClient stub;

  /// GRPCTransport creates a new channel
  GRPCTransport(this.transportOptions, this.options) {
    bool isSecure =
        transportOptions.isSecure == null || transportOptions.isSecure == true;
    channel = ClientChannel(transportOptions.host,
        port: transportOptions.port ?? 443,
        options: ChannelOptions(
            credentials: (isSecure == true
                ? const ChannelCredentials.secure()
                : const ChannelCredentials.insecure())));
    stub = ConnectorServiceClient(channel);
  }
  late ClientChannel channel;
  TransportOptions transportOptions;
  DataConnectOptions options;

  /// Invokes emulator
  @override
  Future<OperationResult<Data, Variables>> invokeQuery<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars) async {
    ExecuteQueryResponse response;
    String name =
        'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}';
    if (vars != null && vars.runtimeType == EmptyDataConnectClass) {
      Struct varStruct = Struct.fromJson(vars.toJson());
      response = await stub.executeQuery(ExecuteQueryRequest(
          name: name, operationName: queryName, variables: varStruct));
    } else {
      response = await stub.executeQuery(ExecuteQueryRequest(
        name: name,
        operationName: queryName,
      ));
    }
    return OperationResult<Data, Variables>(
        serialize(jsonEncode(response.data.toProto3Json())), vars);
  }

  /// Invokes emulator
  @override
  Future<OperationResult<Data, Variables>> invokeMutation<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars) async {
    ExecuteMutationResponse response;
    if (vars != null && vars.runtimeType != EmptyDataConnectClass) {
      Struct struct = Struct.create();
      struct.mergeFromProto3Json(jsonDecode(vars.toJson()));

      response = await stub.executeMutation(ExecuteMutationRequest(
          name:
              'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}',
          operationName: queryName,
          variables: struct));
    } else {
      response = await stub.executeMutation(ExecuteMutationRequest(
        name:
            'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}',
        operationName: queryName,
      ));
    }
    return OperationResult(
        serialize(jsonEncode(response.data.toProto3Json())), vars);
  }
}

DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    GRPCTransport(transportOptions, options);
