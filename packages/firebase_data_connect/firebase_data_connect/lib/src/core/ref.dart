// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

class QueryManager {
  Map<String, Map<String, StreamController<dynamic>>> trackedQueries = {};
  bool containsQuery<Variables>(
      String queryName, Variables variables, String varsAsStr) {
    String key = varsAsStr;
    return (trackedQueries[queryName] != null) &&
        trackedQueries[queryName]![key] != null;
  }

  Stream addQuery<Variables>(
      String queryName, Variables variables, String varsAsStr) {
    // TODO(mtewani): Replace with more stable encoder
    String key = varsAsStr;
    if (trackedQueries[queryName] == null) {
      trackedQueries[queryName] = <String, StreamController>{};
      debugPrint('Creating map for $queryName');
    }
    if (trackedQueries[queryName]![key] == null) {
      trackedQueries[queryName]![key] = StreamController.broadcast();
    }
    return trackedQueries[queryName]![key]!.stream;
  }

  void triggerCallback<Data, Variables>(String operationName, String varsAsStr,
      QueryRef<Data, Variables> ref, Data? data, Exception? error) {
    String key = varsAsStr;
    if (trackedQueries[operationName] == null ||
        trackedQueries[operationName]![key] == null) {
      return;
    }
    StreamController stream = trackedQueries[operationName]![key]!;
    if (error != null) {
      stream.addError(error);
    } else {
      stream.add(OperationResult<Data, Variables>(data as Data, ref));
    }
  }
}

class QueryRef<Data, Variables> extends OperationRef<Data, Variables> {
  QueryRef(
      String operationName,
      DataConnectTransport transport,
      Deserializer<Data> deserializer,
      this._queryManager,
      FirebaseAuth? auth,
      Variables? variables,
      Serializer<Variables>? serializer)
      : super(auth, operationName, variables, transport, OperationType.query,
            deserializer, serializer);
  QueryManager _queryManager;
  @override
  Future<OperationResult<Data, Variables>> execute() async {
    try {
      print("executing");
      OperationResult<Data, Variables> res = await super.execute();
      _queryManager.triggerCallback<Data, Variables>(
          operationName,
          serializer != null ? serializer!(variables as Variables) : '',
          this,
          res.data,
          null);
      return res;
    } on Exception catch (e) {
      _queryManager.triggerCallback<Data, Variables>(
          operationName,
          serializer != null ? serializer!(variables as Variables) : '',
          this,
          null,
          e);
      rethrow;
    }
  }

  Stream<OperationResult<Data, Variables>> subscribe() {
    String varsSerialized =
        serializer != null ? serializer!(variables as Variables) : '';

    Stream<OperationResult<Data, Variables>> res = _queryManager
        .addQuery(operationName, variables, varsSerialized)
        .cast<OperationResult<Data, Variables>>();
    if (_queryManager.containsQuery(operationName, variables, varsSerialized)) {
      this.execute().ignore();
    }
    return res;
  }
}

class MutationRef<Data, Variables> extends OperationRef<Data, Variables> {
  MutationRef(
    String operationName,
    DataConnectTransport transport,
    Deserializer<Data> deserializer,
    FirebaseAuth? auth,
    Variables? variables,
    Serializer<Variables>? serializer,
  ) : super(auth, operationName, variables, transport, OperationType.mutation,
            deserializer, serializer);
}
