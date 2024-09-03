// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

/// Reference to a specific query.
/// Contains variables, transport to execute queries, and serialization/deserialization strategies.
abstract class OperationRef<Data, Variables> {
  /// Constructor
  OperationRef(this.dataConnect, this.operationName, this.variables,
      this._transport, this.deserializer, this.serializer);
  Variables? variables;
  String operationName;
  DataConnectTransport _transport;
  Deserializer<Data> deserializer;
  Serializer<Variables> serializer;

  FirebaseDataConnect dataConnect;

  Future<OperationResult<Data, Variables>> execute();
}

/// Tracks currently active queries, and emits events when a new query is executed.
class _QueryManager {
  _QueryManager(this.dataConnect);

  /// FirebaseDataConnect instance;
  FirebaseDataConnect dataConnect;

  /// Keeps track of what queries are currently active.
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
    }
    if (trackedQueries[queryName]![key] == null) {
      trackedQueries[queryName]![key] = StreamController.broadcast();
    }
    return trackedQueries[queryName]![key]!.stream;
  }

  Future<void> triggerCallback<Data, Variables>(
      String operationName,
      String varsAsStr,
      QueryRef<Data, Variables> ref,
      Data? data,
      Exception? error) async {
    String key = varsAsStr;
    if (trackedQueries[operationName] == null ||
        trackedQueries[operationName]![key] == null) {
      return;
    }
    StreamController stream = trackedQueries[operationName]![key]!;
    // TODO(mtewani): Prevent this from getting called multiple times.
    stream.onCancel = () => stream.close();
    if (error != null) {
      stream.addError(error);
    } else {
      stream.add(
          OperationResult<Data, Variables>(dataConnect, data as Data, ref));
    }
  }
}

class QueryRef<Data, Variables> extends OperationRef<Data, Variables> {
  QueryRef(
      FirebaseDataConnect dataConnect,
      String operationName,
      DataConnectTransport transport,
      Deserializer<Data> deserializer,
      this._queryManager,
      Variables? variables,
      Serializer<Variables> serializer)
      : super(dataConnect, operationName, variables, transport, deserializer,
            serializer);

  _QueryManager _queryManager;
  @override
  Future<QueryResult<Data, Variables>> execute() async {
    try {
      Data data = await _transport.invokeQuery<Data, Variables>(
          operationName, deserializer, serializer, variables);
      QueryResult<Data, Variables> res = QueryResult(dataConnect, data, this);
      await _queryManager.triggerCallback<Data, Variables>(operationName,
          serializer(variables as Variables), this, res.data, null);
      return res;
    } on Exception catch (e) {
      await _queryManager.triggerCallback<Data, Variables>(
          operationName, serializer(variables as Variables), this, null, e);
      rethrow;
    }
  }

  Stream<QueryResult<Data, Variables>> subscribe() {
    String varsSerialized = serializer(variables as Variables);

    Stream<QueryResult<Data, Variables>> res = _queryManager
        .addQuery(operationName, variables, varsSerialized)
        .cast<QueryResult<Data, Variables>>();
    if (_queryManager.containsQuery(operationName, variables, varsSerialized)) {
      this.execute().ignore();
    }
    return res;
  }
}

class MutationRef<Data, Variables> extends OperationRef<Data, Variables> {
  MutationRef(
    FirebaseDataConnect dataConnect,
    String operationName,
    DataConnectTransport transport,
    Deserializer<Data> deserializer,
    Variables? variables,
    Serializer<Variables> serializer,
  ) : super(dataConnect, operationName, variables, transport, deserializer,
            serializer);
  @override
  Future<OperationResult<Data, Variables>> execute() async {
    Data data = await _transport.invokeMutation<Data, Variables>(
        operationName, deserializer, serializer, variables);
    return OperationResult(dataConnect, data, this);
  }
}
