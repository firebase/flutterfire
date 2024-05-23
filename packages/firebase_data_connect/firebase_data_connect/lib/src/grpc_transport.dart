part of firebase_data_connect;

abstract class DataConnectClass<T> {
  String toJson();
}

class EmptyDataConnectClass implements DataConnectClass {
  @override
  String toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  fromJson(String json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }
}

class GRPCTransport {
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

class OperationResult<Data, Variables> {
  OperationResult(this.data, this.variables);
  Data data;
  Variables? variables;
}

enum OperationType { QUERY, MUTATION }

class OperationRef<Data extends DataConnectClass,
    Variables extends DataConnectClass> {
  /// Constructor
  OperationRef(this.operationName, this.variables, this._transport, this.opType,
      this._serializer);
  Variables variables;
  String operationName;
  GRPCTransport _transport;
  Serializer<Data> _serializer;
  OperationType opType;

  Future<OperationResult<Data, Variables>> execute() {
    if (this.opType == OperationType.QUERY) {
      return this._transport.invokeQuery<Data, Variables>(
          this.operationName, this._serializer, variables);
    } else {
      return this._transport.invokeMutation<Data, Variables>(
          this.operationName, this._serializer, variables);
    }
  }
}

class QueryRef<Data extends DataConnectClass,
    Variables extends DataConnectClass> extends OperationRef<Data, Variables> {
  QueryRef(operationName, variables, transport, serializer)
      : super(operationName, variables, transport, OperationType.QUERY,
            serializer);
}

class MutationRef<Data extends DataConnectClass,
    Variables extends DataConnectClass> extends OperationRef<Data, Variables> {
  MutationRef(operationName, variables, transport, serializer)
      : super(operationName, variables, transport, OperationType.MUTATION,
            serializer);
}

typedef Serializer<Data> = Data Function(String json);
