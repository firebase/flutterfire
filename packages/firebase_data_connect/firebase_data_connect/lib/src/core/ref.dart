// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:developer';

import '../../firebase_data_connect.dart';
import '../common/common_library.dart';

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
  OperationRef(
    this.dataConnect,
    this.operationName,
    this._transport,
    this.deserializer,
    this.serializer,
    this.variables,
  );
  Variables? variables;
  String operationName;
  DataConnectTransport _transport;
  Deserializer<Data> deserializer;
  Serializer<Variables> serializer;
  String? _lastToken;

  FirebaseDataConnect dataConnect;

  Future<OperationResult<Data, Variables>> execute();
  Future<bool> _shouldRetry() async {
    String? newToken;
    try {
      newToken = await this.dataConnect.auth?.currentUser?.getIdToken();
    } catch (e) {
      // Don't retry if there was an issue getting the ID Token.
      log('There was an error attempting to retrieve the ID Token: $e');
    }
    bool shouldRetry = newToken != null && _lastToken != newToken;
    _lastToken = newToken;
    return shouldRetry;
  }
}

/// Tracks currently active queries, and emits events when a new query is executed.
class QueryManager {
  QueryManager(this.dataConnect);

  /// FirebaseDataConnect instance;
  FirebaseDataConnect dataConnect;

  /// Keeps track of what queries are currently active.
  Map<String, Map<String, StreamController<dynamic>>> trackedQueries = {};
  bool containsQuery<Variables>(
    String queryName,
    Variables variables,
    String varsAsStr,
  ) {
    String key = varsAsStr;
    return (trackedQueries[queryName] != null) &&
        trackedQueries[queryName]![key] != null;
  }

  Stream addQuery<Variables>(
    String queryName,
    Variables variables,
    String varsAsStr,
  ) {
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
    Exception? error,
  ) async {
    String key = varsAsStr;
    if (trackedQueries[operationName] == null ||
        trackedQueries[operationName]![key] == null) {
      return;
    }
    // ignore: close_sinks
    StreamController stream = trackedQueries[operationName]![key]!;

    if (!stream.isClosed) {
      if (error != null) {
        stream.addError(error);
      } else {
        stream
            .add(QueryResult<Data, Variables>(dataConnect, data as Data, ref));
      }
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
    Serializer<Variables> serializer,
    Variables? variables,
  ) : super(
          dataConnect,
          operationName,
          transport,
          deserializer,
          serializer,
          variables,
        );

  QueryManager _queryManager;

  @override
  Future<QueryResult<Data, Variables>> execute() async {
    bool shouldRetry = await _shouldRetry();
    try {
      QueryResult<Data, Variables> r = await this._executeOperation(_lastToken);
      return r;
    } on DataConnectError catch (e) {
      if (shouldRetry &&
          e.code == DataConnectErrorCode.unauthorized.toString()) {
        return this.execute();
      } else {
        rethrow;
      }
    }
  }

  Future<QueryResult<Data, Variables>> _executeOperation(String? token) async {
    try {
      Data data = await _transport.invokeQuery<Data, Variables>(
        operationName,
        deserializer,
        serializer,
        variables,
        token,
      );
      QueryResult<Data, Variables> res = QueryResult(dataConnect, data, this);
      await _queryManager.triggerCallback<Data, Variables>(
        operationName,
        serializer(variables as Variables),
        this,
        res.data,
        null,
      );
      return res;
    } on Exception catch (e) {
      await _queryManager.triggerCallback<Data, Variables>(
        operationName,
        serializer(variables as Variables),
        this,
        null,
        e,
      );
      rethrow;
    }
  }

  Stream<QueryResult<Data, Variables>> subscribe() {
    String varsSerialized = serializer(variables as Variables);
    Stream<QueryResult<Data, Variables>> res = _queryManager
        .addQuery(operationName, variables, varsSerialized)
        .cast<QueryResult<Data, Variables>>();
    if (_queryManager.containsQuery(operationName, variables, varsSerialized)) {
      try {
        unawaited(this.execute());
      } catch (_) {
        // Call to `execute` should properly pass the error to the Stream.
        log('Error thrown by execute. The error will propagate via onError.');
      }
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
    Serializer<Variables> serializer,
    Variables? variables,
  ) : super(
          dataConnect,
          operationName,
          transport,
          deserializer,
          serializer,
          variables,
        );

  @override
  Future<OperationResult<Data, Variables>> execute() async {
    bool shouldRetry = await _shouldRetry();
    try {
      // Logic below is duplicated due to the fact that `executeOperation` returns
      // an `OperationResult` here, and `QueryRef` expects a `QueryResult`.
      OperationResult<Data, Variables> r =
          await this._executeOperation(_lastToken);
      return r;
    } on DataConnectError catch (e) {
      if (shouldRetry &&
          e.code == DataConnectErrorCode.unauthorized.toString()) {
        return this.execute();
      } else {
        rethrow;
      }
    }
  }

  Future<OperationResult<Data, Variables>> _executeOperation(
    String? token,
  ) async {
    Data data = await _transport.invokeMutation<Data, Variables>(
      operationName,
      deserializer,
      serializer,
      variables,
      token,
    );
    return OperationResult(dataConnect, data, this);
  }
}
