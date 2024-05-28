part of firebase_data_connect;

abstract class Listener<Data, Variables> {
  Stream<OperationResult<Data, Variables>> onResult();
  // void onError();
}

class TrackedQuery<Data, Variables> {
  TrackedQuery({required this.name, required this.variables});
  String name;
  Variables variables;
}

class QueryManager {
  Map<String, Map<String, StreamController<dynamic>>> trackedQueries = {};
  Stream addQuery<Variables extends DataConnectClass>(
      String queryName, Variables variables) {
    TrackedQuery<dynamic, Variables> trackedQuery =
        TrackedQuery<dynamic, Variables>(name: queryName, variables: variables);
    // TODO(mtewani): Replace with more stable encoder
    String key = variables.toJson();
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

  triggerCallback<Data, Variables extends DataConnectClass>(
      String operationName, Variables variables, Data data) {
    String key = '';
    if (variables.runtimeType != EmptyDataConnectClass) {
      key = variables.toJson();
    }
    print('Checking broadcast stream for $operationName, $key');
    if (trackedQueries[operationName] == null ||
        trackedQueries[operationName]![key] == null) {
      print(trackedQueries);
      return;
    }
    trackedQueries[operationName]![key]!.add(data);
  }
}

class QueryRef<Data extends DataConnectClass,
    Variables extends DataConnectClass> extends OperationRef<Data, Variables> {
  QueryRef(operationName, variables, transport, serializer, this._queryManager)
      : super(operationName, variables, transport, OperationType.QUERY,
            serializer);
  late QueryManager _queryManager;
  @override
  Future<OperationResult<Data, Variables>> execute() async {
    OperationResult<Data, Variables> res = await super.execute();
    _queryManager.triggerCallback<Data, Variables>(
        operationName, variables, res.data);
    return res;
  }

  /// @example: ref.subscribe()
  Stream<Data> subscribe() {
    return _queryManager.addQuery(operationName, variables).cast<Data>();
  }
}

class MutationRef<Data extends DataConnectClass,
    Variables extends DataConnectClass> extends OperationRef<Data, Variables> {
  MutationRef(operationName, variables, transport, serializer)
      : super(operationName, variables, transport, OperationType.MUTATION,
            serializer);
}
