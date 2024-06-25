part of firebase_data_connect;

abstract class Listener<Data, Variables> {
  Stream<OperationResult<Data, Variables>> onResult();
  // void onError();
}

class QueryManager {
  Map<String, Map<String, StreamController<dynamic>>> trackedQueries = {};
  Stream addQuery<Variables>(
      String queryName, Variables variables, String varsAsStr) {
    // TODO(mtewani): Replace with more stable encoder
    String key = varsAsStr;
    if (trackedQueries[queryName] == null) {
      trackedQueries[queryName] = <String, StreamController>{};
      debugPrint('Creating map for $queryName');
    }
    if (trackedQueries[queryName]![key] == null) {
      print('Creating broadcast stream for $key');
      trackedQueries[queryName]![key] = StreamController.broadcast();
    }
    print('Created stream for $queryName, $key');
    return trackedQueries[queryName]![key]!.stream;
  }

  triggerCallback<Data, Variables>(
      String operationName, String varsAsStr, Data data) {
    String key = varsAsStr;
    if (trackedQueries[operationName] == null ||
        trackedQueries[operationName]![key] == null) {
      return;
    }
    trackedQueries[operationName]![key]!.add(data);
  }
}

class QueryRef<Data, Variables> extends OperationRef<Data, Variables> {
  QueryRef(
      FirebaseAuth? auth,
      String operationName,
      Variables variables,
      DataConnectTransport transport,
      Deserializer<Data> deserializer,
      Serializer<Variables> serializer,
      this._queryManager)
      : super(auth, operationName, variables, transport, OperationType.query,
            deserializer, serializer);
  QueryManager _queryManager;
  @override
  Future<OperationResult<Data, Variables>> execute() async {
    OperationResult<Data, Variables> res = await super.execute();
    _queryManager.triggerCallback<Data, Variables>(
        operationName, serializer(variables), res.data);
    return res;
  }

  /// @example: ref.subscribe()
  // TODO(mtewani): Implement ability to execute a query if no cache is available.
  Stream<Data> subscribe() {
    return _queryManager
        .addQuery(operationName, variables, serializer(variables))
        .cast<Data>();
  }
}

class MutationRef<Data, Variables> extends OperationRef<Data, Variables> {
  MutationRef(
    FirebaseAuth? auth,
    String operationName,
    Variables variables,
    DataConnectTransport transport,
    Deserializer<Data> deserializer,
    Serializer<Variables> serializer,
  ) : super(auth, operationName, variables, transport, OperationType.mutation,
            deserializer, serializer);
}
