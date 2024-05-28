part of firebase_data_connect_transport;

class TransportStub implements DataConnectTransport {
  TransportStub(this.transportOptions, this.options);
  @override
  DataConnectOptions options;

  @override
  TransportOptions transportOptions;

  @override
  Future<OperationResult<Data, Variables>> invokeMutation<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars) {
    // TODO: implement invokeMutation
    throw UnimplementedError();
  }

  @override
  Future<OperationResult<Data, Variables>> invokeQuery<
          Data extends DataConnectClass, Variables extends DataConnectClass>(
      String queryName, Serializer serialize, Variables? vars) {
    // TODO: implement invokeQuery
    throw UnimplementedError();
  }
}

DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    TransportStub(transportOptions, options);
