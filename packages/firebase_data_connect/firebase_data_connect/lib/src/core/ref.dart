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
  final Variables? variables;
  final String operationName;
  final DataConnectTransport _transport;
  final Deserializer<Data> deserializer;
  final Serializer<Variables> serializer;
  String? _lastToken;

  final FirebaseDataConnect dataConnect;

  late final String operationId =
      createOperationId(operationName, variables, serializer);

  static dynamic _sortKeys(dynamic value) {
    if (value is Map) {
      final sortedMap = <String, dynamic>{};
      final sortedKeys = value.keys.toList()..sort();
      for (final key in sortedKeys) {
        sortedMap[key.toString()] = _sortKeys(value[key]);
      }
      return sortedMap;
    } else if (value is List) {
      return value.map(_sortKeys).toList();
    }
    return value;
  }

  static String createOperationId<Variables>(String operationName,
      Variables? vars, Serializer<Variables>? serializer) {
    if (vars != null && serializer != null) {
      try {
        final decoded = jsonDecode(serializer(vars));
        final sortedStr = jsonEncode(_sortKeys(decoded));
        final hashVars = convertToSha256(sortedStr);
        return '$operationName::$hashVars';
      } catch (_) {
        final rawVars = serializer(vars);
        final hashVars = convertToSha256(rawVars);
        return '$operationName::$hashVars';
      }
    } else {
      return operationName;
    }
  }

  Future<OperationResult<Data, Variables>> execute();

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
  QueryManager(this.dataConnect);

  /// FirebaseDataConnect instance;
  FirebaseDataConnect dataConnect;

  StreamSubscription? _impactedQueriesSubscription;

  void initializeImpactedQueriesSub() {
    // this is dependent on the cachemanager, which is initialized lazily
    // this should be called whenever cacheManager is initialized.
    if (dataConnect.cacheManager != null) {
      _impactedQueriesSubscription = dataConnect.cacheManager!.impactedQueries
          .listen((impactedQueryIds) async {
        for (final queryId in impactedQueryIds) {
          final queryRef = trackedQueries[queryId];
          if (queryRef != null) {
            try {
              await queryRef.execute(fetchPolicy: QueryFetchPolicy.cacheOnly);
            } catch (e) {
              log('Error executing impacted query $queryId $e');
            }
          }
        }
      });
    }
  }

  /// Keeps track of what queries are currently active.
  Map<String, QueryRef> trackedQueries = {};

  bool containsQuery<Variables>(
    String queryName,
    Variables variables,
    String varsAsStr,
  ) {
    String key = '$queryName::$varsAsStr';
    return (trackedQueries[key] != null);
  }

  StreamController<QueryResult<Data, Variables>> addQuery<Data, Variables>(
    QueryRef<Data, Variables> ref,
  ) {
    final queryId = ref._queryId;
    trackedQueries[queryId] = ref;

    final streamController =
        StreamController<QueryResult<Data, Variables>>.broadcast(
      onCancel: () {
        trackedQueries.remove(queryId);
        ref._onAllSubscribersCancelled();
      },
    );

    return streamController;
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

  final QueryManager _queryManager;

  @override
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

  String get _queryId =>
      OperationRef.createOperationId(operationName, variables, serializer);

  Future<QueryResult<Data, Variables>> _executeFromCache(
      QueryFetchPolicy fetchPolicy) async {
    if (dataConnect.cacheManager == null) {
      throw DataConnectError(
          DataConnectErrorCode.cacheMiss, 'Cache miss. No configured cache');
    }
    final cacheManager = dataConnect.cacheManager!;
    bool allowStale = fetchPolicy ==
        QueryFetchPolicy.cacheOnly; //if its cache only, we always allow stale
    final cachedData = await cacheManager.resultTree(_queryId, allowStale);

    if (cachedData != null) {
      try {
        final result = QueryResult(
            dataConnect,
            deserializer(jsonEncode(cachedData['data'] ?? cachedData)),
            DataSource.cache,
            this);
        publishResultToStream(result);
        return result;
      } catch (e) {
        rethrow;
      }
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
        operationId,
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
      publishResultToStream(res);
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

  StreamController<QueryResult<Data, Variables>>? _streamController;
  Stream<ServerResponse>? _serverStream;
  StreamSubscription<ServerResponse>? _serverStreamSubscription;

  void _onAllSubscribersCancelled() {
    _serverStreamSubscription?.cancel();
    _serverStreamSubscription = null;
    _serverStream = null;
    log("QueryRef $_queryId: All subscribers cancelled. Unsubscribed from server stream.");
  }

  Stream<QueryResult<Data, Variables>> subscribe() {
    _streamController ??= _queryManager.addQuery(this);

    final stream =
        _streamController!.stream.cast<QueryResult<Data, Variables>>();

    // Return the stream to the caller, then execute fetches
    Future.microtask(() async {
      if (dataConnect.cacheManager != null) {
        try {
          await _executeFromCache(QueryFetchPolicy.cacheOnly);
        } catch (err) {
          log("Error fetching from cache during subscribe $err");
          // Ignore cache misses here, server stream will provide latest data
        }
      }

      // Initiate Web Socket stream only if not already streaming
      if (_serverStream == null) {
        _streamFromServer();
      }
    });

    return stream;
  }

  void _streamFromServer() async {
    bool shouldRetry = await _shouldRetry();
    log("QueryRef $_queryId _streamFromServer loop started.");
    try {
      _serverStream = _transport.invokeStreamQuery<Data, Variables>(
        operationId,
        operationName,
        deserializer,
        serializer,
        variables,
        _lastToken,
      );

      _serverStreamSubscription = _serverStream!.listen(
        (serverResponse) async {
          log("QueryRef $_queryId _streamFromServer loop received snapshot.");
          if (dataConnect.cacheManager != null) {
            try {
              await dataConnect.cacheManager!.update(_queryId, serverResponse);
            } catch (e) {
              log("QueryRef $_queryId _streamFromServer loop cache update failed: $e");
            }
          }
          Data typedData = _convertBodyJsonToData(serverResponse.data);

          QueryResult<Data, Variables> res =
              QueryResult(dataConnect, typedData, DataSource.server, this);
          publishResultToStream(res);
        },
        onError: (e) {
          _serverStreamSubscription?.cancel();
          _serverStreamSubscription = null;
          _serverStream = null;

          if (shouldRetry &&
              e is DataConnectError &&
              e.code == DataConnectErrorCode.unauthorized.toString()) {
            _streamFromServer();
          } else {
            publishErrorToStream(e);
          }
        },
        onDone: () {
          _serverStreamSubscription?.cancel();
          _serverStreamSubscription = null;
          _serverStream = null;
        },
      );
    } catch (e) {
      _serverStreamSubscription?.cancel();
      _serverStreamSubscription = null;
      _serverStream = null;
      log("QueryRef $_queryId _streamFromServer loop Unknown loop failure: $e");
      publishErrorToStream(e);
    }
  }

  void publishResultToStream(QueryResult<Data, Variables> result) {
    if (_streamController != null) {
      _streamController?.add(result);
    } else {
      log("QueryRef $_queryId _streamFromServer loop _streamController is null");
    }
  }

  void publishErrorToStream(Object err) {
    if (_streamController != null) {
      _streamController?.addError(err);
    }
  }
}

class MutationRef<Data, Variables> extends OperationRef<Data, Variables> {
  MutationRef(
    super.dataConnect,
    super.operationName,
    super.transport,
    super.deserializer,
    super.serializer,
    super.variables,
  );

  @override
  Future<OperationResult<Data, Variables>> execute() async {
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
      operationId,
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
