// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
}

/// Reference to a specific query.
/// Contains variables, transport to execute queries, and serialization/deserialization strategies.
class OperationRef<Data, Variables> {
  /// Constructor
  OperationRef(this.operationName, this.variables, this._transport, this.opType,
      this.deserializer, this.serializer) {
    if (this.variables != null && this.serializer == null) {
      throw Exception('Serializer required for variables');
    }
  }
  Variables? variables;
  String operationName;
  DataConnectTransport _transport;
  Deserializer<Data> deserializer;
  Serializer<Variables>? serializer;
  OperationType opType;

  Future<OperationResult<Data, Variables>> execute() async {
    if (this.opType == OperationType.query) {
      Data data = await this._transport.invokeQuery<Data, Variables>(
          this.operationName, this.deserializer, this.serializer, variables);
      return OperationResult(data, this);
    } else {
      print('executing');
      Data data = await this._transport.invokeMutation<Data, Variables>(
          this.operationName, this.deserializer, this.serializer, variables);
      print('done executing');
      return OperationResult(data, this);
    }
  }
}

/// Tracks currently active queries, and emits events when a new query is executed.
class _QueryManager {
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
      Variables? variables,
      Serializer<Variables>? serializer)
      : super(operationName, variables, transport, OperationType.query,
            deserializer, serializer);
  _QueryManager _queryManager;
  @override
  Future<OperationResult<Data, Variables>> execute() async {
    try {
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
    Variables? variables,
    Serializer<Variables>? serializer,
  ) : super(operationName, variables, transport, OperationType.mutation,
            deserializer, serializer);
}
