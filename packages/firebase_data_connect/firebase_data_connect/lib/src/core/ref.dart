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
      print("Creating map for $queryName");
      debugPrint('Creating map for $queryName');
    }
    if (trackedQueries[queryName]![key] == null) {
      print("Creating stream for $queryName");
      trackedQueries[queryName]![key] = StreamController.broadcast();
    }
    return trackedQueries[queryName]![key]!.stream;
  }

  triggerCallback<Data, Variables>(String operationName, String varsAsStr,
      Data data, QueryRef<Data, Variables> ref) {
    String key = varsAsStr;
    if (trackedQueries[operationName] == null ||
        trackedQueries[operationName]![key] == null) {
      print("No streams available yet!");
      return;
    }
    trackedQueries[operationName]![key]!
        .add(OperationResult<Data, Variables>(data, ref));
  }
}

class QueryRef<Data, Variables> extends OperationRef<Data, Variables> {
  QueryRef(
      FirebaseAuth? auth,
      String operationName,
      Variables? variables,
      DataConnectTransport transport,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      this._queryManager)
      : super(auth, operationName, variables, transport, OperationType.query,
            deserializer, serializer);
  QueryManager _queryManager;
  @override
  Future<OperationResult<Data, Variables>> execute() async {
    OperationResult<Data, Variables> res = await super.execute();
    _queryManager.triggerCallback<Data, Variables>(
        operationName,
        serializer != null ? serializer!(variables as Variables) : '',
        res.data,
        this);
    return res;
  }

  /// @example: ref.subscribe()
  // TODO(mtewani): Implement ability to execute a query if no cache is available.
  Stream<OperationResult<Data, Variables>> subscribe() {
    return _queryManager
        .addQuery(operationName, variables,
            serializer != null ? serializer!(variables as Variables) : '')
        .cast<OperationResult<Data, Variables>>();
  }
}

class MutationRef<Data, Variables> extends OperationRef<Data, Variables> {
  MutationRef(
    FirebaseAuth? auth,
    String operationName,
    Variables? variables,
    DataConnectTransport transport,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
  ) : super(auth, operationName, variables, transport, OperationType.mutation,
            deserializer, serializer);
}
