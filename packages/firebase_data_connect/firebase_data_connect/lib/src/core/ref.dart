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
import 'dart:convert';
import 'dart:developer';

import '../../firebase_data_connect.dart';
import '../common/common_library.dart';

/// Result data source
enum DataSource {
  cache, // results come from cache
  server // results come from server
}

/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.source, this.ref);
  Data data;
  DataSource source;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.source, super.ref);
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

  Future<OperationResult<Data, Variables>> execute(
      {QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache});

  Future<bool> _shouldRetry() async {
    String? newToken;
    try {
      newToken = await dataConnect.auth?.currentUser?.getIdToken();
    } catch (e) {
      // Don't retry if there was an issue getting the ID Token.
      log('There was an error attempting to retrieve the ID Token: $e');
    }
    bool shouldRetry = newToken != null && _lastToken != newToken;
    _lastToken = newToken;
    return shouldRetry;
  }

  // Converts a hydrated Json tree to Typed Data
  Data _convertBodyJsonToData(Map<String, dynamic> bodyJson) {
    List errors = bodyJson['errors'] ?? [];
    final data = bodyJson['data'] ?? bodyJson;
    List<DataConnectOperationFailureResponseErrorInfo> suberrors = errors
        .map((e) => switch (e) {
              {'path': List? path, 'message': String? message} =>
                DataConnectOperationFailureResponseErrorInfo(
                    (path ?? [])
                        .map((val) => switch (val) {
                              String() => DataConnectFieldPathSegment(val),
                              int() => DataConnectListIndexPathSegment(val),
                              _ => throw DataConnectError(
                                  DataConnectErrorCode.other,
                                  'Incorrect type for $val')
                            })
                        .toList(),
                    message ??
                        (throw DataConnectError(
                            DataConnectErrorCode.other, 'Missing message'))),
              _ => throw DataConnectError(
                  DataConnectErrorCode.other, 'Unable to parse JSON: $e')
            })
        .toList();
    Data? decodedData;
    Object? decodeError;
    try {
      /// The response we get is in the data field of the response
      /// Once we get the data back, it's not quite json-encoded,
      /// so we have to encode it and then send it to the user's deserializer.
      decodedData = deserializer(jsonEncode(data));
    } catch (e) {
      decodeError = e;
    }
    if (suberrors.isNotEmpty) {
      final response =
          DataConnectOperationFailureResponse(suberrors, data, decodedData);

      throw DataConnectOperationError(
          DataConnectErrorCode.other, 'Failed to invoke operation: ', response);
    } else {
      if (decodeError != null) {
        throw DataConnectError(
            DataConnectErrorCode.other, 'Unable to decode data: $decodeError');
      }
      if (decodedData is! Data) {
        throw DataConnectError(
          DataConnectErrorCode.other,
          "Decoded data wasn't parsed properly. Expected $Data, got $decodedData",
        );
      }
      return decodedData;
    }
  }
}

class QueryManager {
  QueryManager(this.dataConnect) {
    if (dataConnect.cacheManager != null) {
      _impactedQueriesSubscription =
          dataConnect.cacheManager!.impactedQueries.listen((impactedQueryIds) {
        for (final queryId in impactedQueryIds) {
          final queryParts = queryId.split('-');
          final queryName = queryParts[0];
          final varsAsStr = queryParts.sublist(1).join('-');
          if (trackedQueries[queryName] != null &&
              trackedQueries[queryName]![varsAsStr] != null) {
            final queryRef = trackedQueries[queryName]![varsAsStr]!;
            queryRef.execute(fetchPolicy: QueryFetchPolicy.cacheOnly);
          }
        }
      });
    }
  }

  /// FirebaseDataConnect instance;
  FirebaseDataConnect dataConnect;

  StreamSubscription? _impactedQueriesSubscription;

  /// Keeps track of what queries are currently active.
  Map<String, Map<String, QueryRef>> trackedQueries = {};
  bool containsQuery<Variables>(
    String queryName,
    Variables variables,
    String varsAsStr,
  ) {
    String key = varsAsStr;
    return (trackedQueries[queryName] != null) &&
        trackedQueries[queryName]![key] != null;
  }

  Stream addQuery<Data, Variables>(
    QueryRef<Data, Variables> ref,
  ) {
    final queryName = ref.operationName;
    final varsAsStr = ref.serializer(ref.variables as Variables);
    if (trackedQueries[queryName] == null) {
      trackedQueries[queryName] = <String, QueryRef>{};
    }
    if (trackedQueries[queryName]![varsAsStr] == null) {
      trackedQueries[queryName]![varsAsStr] = ref;
    }

    final streamController =
        StreamController<QueryResult<Data, Variables>>.broadcast();
    ref
        .execute()
        .then((value) => streamController.add(value))
        .catchError((error) => streamController.addError(error));

    return streamController.stream;
  }

  void dispose() {
    _impactedQueriesSubscription?.cancel();
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

  Future<QueryResult<Data, Variables>> execute(
      {QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) async {
    if (dataConnect.cacheManager != null) {
      switch (fetchPolicy) {
        case QueryFetchPolicy.cacheOnly:
          return _executeFromCache(fetchPolicy);
        case QueryFetchPolicy.preferCache:
          try {
            return await _executeFromCache(fetchPolicy);
          } catch (e) {
            return _executeFromServer();
          }
        case QueryFetchPolicy.serverOnly:
          return _executeFromServer();
      }
    } else {
      return _executeFromServer();
    }
  }

  String get _queryId => '$operationName-${serializer(variables as Variables)}';

  Future<QueryResult<Data, Variables>> _executeFromCache(
      QueryFetchPolicy fetchPolicy) async {
        if (dataConnect.cacheManager == null) {
          throw DataConnectError(DataConnectErrorCode.cacheMiss, 'Cache miss. No configured cache'); 
        }
    final cacheManager = dataConnect.cacheManager!;
    bool allowStale = fetchPolicy ==
        QueryFetchPolicy.cacheOnly; //if its cache only, we always allow stale
    final cachedData = await cacheManager.get(_queryId, allowStale);

    if (cachedData != null) {
      final result = QueryResult(
          dataConnect,
          deserializer(jsonEncode(cachedData['data'] ?? cachedData)),
          DataSource.cache,
          this);
      return result;
    } else {
      if (fetchPolicy == QueryFetchPolicy.cacheOnly) {
        throw DataConnectError(DataConnectErrorCode.cacheMiss, 'Cache miss');
      } else {
        throw DataConnectError(
            DataConnectErrorCode.cacheMiss, 'Possible stale cache miss');
      }
    }
  }

  Future<QueryResult<Data, Variables>> _executeFromServer() async {
    bool shouldRetry = await _shouldRetry();
    try {
      ServerResponse serverResponse =
          await _transport.invokeQuery<Data, Variables>(
        operationName,
        deserializer,
        serializer,
        variables,
        _lastToken,
      );

      if (dataConnect.cacheManager != null) {
        await dataConnect.cacheManager!.update(_queryId, serverResponse);
      }
      Data typedData = _convertBodyJsonToData(serverResponse.data);

      QueryResult<Data, Variables> res =
          QueryResult(dataConnect, typedData, DataSource.server, this);
      return res;
    } on DataConnectError catch (e) {
      if (shouldRetry &&
          e.code == DataConnectErrorCode.unauthorized.toString()) {
        return _executeFromServer();
      } else {
        rethrow;
      }
    }
  }

  Stream<QueryResult<Data, Variables>> subscribe() {
    return _queryManager.addQuery(this).cast<QueryResult<Data, Variables>>();
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
  Future<OperationResult<Data, Variables>> execute(
      {QueryFetchPolicy fetchPolicy = QueryFetchPolicy.serverOnly}) async {
    bool shouldRetry = await _shouldRetry();
    try {
      // Logic below is duplicated due to the fact that `executeOperation` returns
      // an `OperationResult` here, and `QueryRef` expects a `QueryResult`.
      OperationResult<Data, Variables> r = await _executeOperation(_lastToken);
      return r;
    } on DataConnectError catch (e) {
      if (shouldRetry &&
          e.code == DataConnectErrorCode.unauthorized.toString()) {
        return _executeOperation(_lastToken);
      } else {
        rethrow;
      }
    }
  }

  Future<OperationResult<Data, Variables>> _executeOperation(
    String? token,
  ) async {
    ServerResponse serverResponse =
        await _transport.invokeMutation<Data, Variables>(
      operationName,
      deserializer,
      serializer,
      variables,
      token,
    );

    Data typedData = _convertBodyJsonToData(serverResponse.data);

    return OperationResult(dataConnect, typedData, DataSource.server, this);
  }
}
