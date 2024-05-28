part of firebase_data_connect_common;

/// DataConnectOptions
class DataConnectOptions extends ConnectorConfig {
  /// Constructor
  DataConnectOptions(
      this.projectId, String location, String connector, String serviceId)
      : super(location, connector, serviceId);

  /// projectId for Firebase App
  String projectId;
}

/// ConnectorConfig
class ConnectorConfig {
  /// Constructor
  ConnectorConfig(this.location, this.connector, this.serviceId);

  /// location
  String location;

  /// connector
  String connector;

  /// serviceId
  String serviceId;
}

abstract class DataConnectTransport {
  DataConnectTransport(this.transportOptions, this.options);
  TransportOptions transportOptions;
  DataConnectOptions options;
  Future<OperationResult<Data, Variables>> invokeQuery<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars);

  Future<OperationResult<Data, Variables>> invokeMutation<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars);
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

abstract class DataConnectClass<T> {
  String toJson();
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
  DataConnectTransport _transport;
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

class TransportOptions {
  /// Constructor
  TransportOptions(this.host, this.port, this.isSecure);

  /// Host to connect to
  String host;

  /// Port to connect to
  int? port;

  /// isSecure - use secure protocol
  bool? isSecure;
}

typedef Serializer<Data> = Data Function(String json);
