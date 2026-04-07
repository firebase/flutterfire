// Copyright 2026 Google LLC
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

part of 'transport_library.dart';

/// WebSocketTransport makes requests out to the streaming endpoints of the configured backend,
/// multiplexing multiple subscriptions and unary operations over a single WebSocket connection.

class _PendingUnary {
  final Completer<ServerResponse> completer;
  final String operationName;
  final Map<String, dynamic>? variables;
  final bool isMutation;

  _PendingUnary(
      this.completer, this.operationName, this.variables, this.isMutation);
}

class _PendingSubscription {
  final String operationId;
  final String queryName;
  final Map<String, dynamic>? variables;

  _PendingSubscription(this.operationId, this.queryName, this.variables);
}

class WebSocketTransport implements DataConnectTransport {
  static const int _maxReconnectAttempts = 10;
  static const int _maxReconnectDelayMs = 30000;
  static const int _initialReconnectDelayMs = 1000;

  /// Initializes necessary protocol and port.
  WebSocketTransport(
    this.transportOptions,
    this.options,
    this.appId,
    this.sdkType,
    this.appCheck, [
    this.auth,
  ]) {
    final protocol = (transportOptions.isSecure ?? true) ? 'wss' : 'ws';
    final host = transportOptions.host;
    final port = transportOptions.port ?? 443;
    final location = options.location;

    _url = Uri(
      scheme: protocol,
      host: host,
      port: port,
      path:
          '/ws/google.firebase.dataconnect.v1.ConnectorStreamService/Connect/locations/$location',
    ).toString();

    _currentUid = auth?.currentUser?.uid;
    _authSubscription = auth?.idTokenChanges().listen((user) async {
      final newUid = user?.uid;
      // Disconnect and reconnect on any fundamental user change (login, logout, switch).
      if (_currentUid != newUid) {
        _disconnect();
        _scheduleReconnect();
      } else if (newUid != null && isConnected) {
        // Token refreshed for the same user, push the new token natively down the socket.
        try {
          final token = await user?.getIdToken();
          final request = StreamRequest(
            requestId: _generateRequestId('auth'),
            authToken: token,
          );
          _channel?.sink.add(jsonEncode(request.toJson()));
        } catch (_) {
          // Ignored
        }
      }
      _currentUid = newUid;
    });
  }

  FirebaseAuth? auth;
  String? _currentUid;
  // ignore: unused_field
  StreamSubscription<User?>? _authSubscription; //required to hold reference

  @override
  FirebaseAppCheck? appCheck;

  @override
  CallerSDKType sdkType;

  late String _url;

  @override
  TransportOptions transportOptions;

  @override
  DataConnectOptions options;

  @override
  String appId;

  WebSocketChannel? _channel;
  // ignore: unused_field
  StreamSubscription? _channelSubscription;

  // Active listeners for stream subscriptions mapped by requestId.
  final Map<String, List<StreamController<ServerResponse>>> _streamListeners =
      {};

  // Pending information for subscriptions mapped by requestId.
  final Map<String, _PendingSubscription> _pendingSubscriptions = {};

  // Active completers for unary operations mapped by requestId.
  final Map<String, List<_PendingUnary>> _unaryListeners = {};

  // Active subscriptions mapped by operationId => requestId.
  final Map<String, String> _activeSubscriptions = {};

  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  bool _isExpectedDisconnect = false;

  void _checkIdleAndDisconnect() {
    if (_streamListeners.isEmpty && _unaryListeners.isEmpty) {
      _isExpectedDisconnect = true;
      _disconnect();
      _clearState();
    }
  }

  final Random _random = Random();
  static const String _chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  String _generateRequestId(String operationName) {
    final randStr = String.fromCharCodes(Iterable.generate(
        15, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
    return '${operationName}_$randStr';
  }

  bool get isConnected => _channel != null;

  Map<String, String> _buildHeaders(String? authToken, String? appCheckToken) {
    Map<String, String> headers = {
      'x-goog-api-client': getGoogApiVal(sdkType, packageVersion),
      'x-firebase-client': getFirebaseClientVal(packageVersion)
    };
    if (authToken != null) {
      headers['X-Firebase-Auth-Token'] = authToken;
    }
    if (appCheckToken != null) {
      headers['X-Firebase-AppCheck'] = appCheckToken;
    }
    headers['x-firebase-gmpid'] = appId;
    return headers;
  }

  Future<void>? _connectionFuture;

  Future<void> _ensureConnected(String? authToken) {
    if (_channel != null) return Future.value();
    if (_connectionFuture != null) return _connectionFuture!;
    _connectionFuture = _doConnect(authToken).whenComplete(() {
      _connectionFuture = null;
    });
    return _connectionFuture!;
  }

  Future<void> _doConnect(String? authToken) async {
    String? appCheckToken;
    try {
      appCheckToken = await appCheck?.getToken();
    } catch (_) {
      // Ignored
    }

    final headers = _buildHeaders(authToken, appCheckToken);

    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _channelSubscription = _channel?.stream.listen(
      _onMessage,
      onError: _onError,
      onDone: _onDone,
    );

    // reset this since an explicit connect was requested
    _isExpectedDisconnect = false;

    try {
      await _channel?.ready;
    } catch (e) {
      developer.log('WebSocket connection failed to become ready: $e');
      _channel = null;
      throw DataConnectError(
          DataConnectErrorCode.other, 'WebSocket connection failed: $e');
    }

    final initRequest = StreamRequest(
      name:
          'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}',
      headers: headers,
    );
    _channel?.sink.add(jsonEncode(initRequest.toJson()));
  }

  // called when a message is received from the stream
  void _onMessage(dynamic message) {
    try {
      var bodyString = '';
      if (message is List<int>) {
        bodyString = utf8.decode(message);
      } else {
        bodyString = message as String;
      }
      developer.log("Received stream response \n $bodyString");

      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final response = StreamResponse.fromJson(bodyJson);

      final requestId = response.requestId;
      if (requestId == null) return;

      final serverResponse = ServerResponse(
        response.data ?? {},
        extensions: response.extensions,
      );

      // Append errors if any exist on the stream payload
      if (response.errors != null && response.errors!.isNotEmpty) {
        // We simulate a DataConnectOperationError payload structure
        // so that ref.dart can parse it correctly
        serverResponse.data['errors'] = response.errors;
      }

      if (_unaryListeners.containsKey(requestId)) {
        final pendings = _unaryListeners.remove(requestId)!;
        for (final p in pendings) {
          if (!p.completer.isCompleted) {
            p.completer.complete(serverResponse);
          }
        }
        _checkIdleAndDisconnect();
      }

      if (_streamListeners.containsKey(requestId)) {
        final controllers = _streamListeners[requestId]!;
        if (response.cancelled == true) {
          for (final controller in controllers) {
            controller.close();
          }
          _streamListeners.remove(requestId);
          _activeSubscriptions.removeWhere((key, value) => value == requestId);
          _pendingSubscriptions.remove(requestId);
          _checkIdleAndDisconnect();
        } else {
          for (final controller in controllers) {
            controller.add(serverResponse);
          }
        }
      }
    } catch (e) {
      // JSON decoding error or unknown format
      developer.log('error decoding server response $e');
    }
  }

  void _clearState([DataConnectError? error]) {
    final e = error ??
        DataConnectError(
            DataConnectErrorCode.other, 'WebSocket connection closed.');
    for (final pendings in _unaryListeners.values) {
      for (final p in pendings) {
        if (!p.completer.isCompleted) {
          p.completer.completeError(e);
        }
      }
    }
    for (final controllers in _streamListeners.values) {
      for (final controller in controllers) {
        controller.addError(e);
        controller.close();
      }
    }
    _unaryListeners.clear();
    _streamListeners.clear();
    _activeSubscriptions.clear();
    _pendingSubscriptions.clear();
    _isReconnecting = false;
    _reconnectAttempts = 0;
  }

  Timer? _reconnectTimer;

  void _scheduleReconnect() {
    developer.log(
        '${DateTime.now()} _scheduleReconnect $_reconnectAttempts $_isReconnecting $_isExpectedDisconnect');
    if (_isReconnecting || _isExpectedDisconnect) return;
    _isReconnecting = true;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _clearState(DataConnectError(DataConnectErrorCode.other,
          'Network disconnected after max attempts.'));
      return;
    }

    final delay = min(
        _initialReconnectDelayMs * pow(2, _reconnectAttempts).toInt(),
        _maxReconnectDelayMs);
    var startTime = DateTime.now();
    developer.log('$startTime scheduling _performReconnect in $delay ms');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () async {
      developer.log(
          '${DateTime.now()} calling delayed _performReconnect scheduled at $startTime');
      _performReconnect();
    });
  }

  Future<String?> _refreshAuthToken() async {
    try {
      return await auth?.currentUser?.getIdToken();
    } catch (_) {
      // If fetching token fails, continue unauthenticated.
      return null;
    }
  }

  Future<String?> _refreshAppCheckToken() async {
    try {
      if (appCheck != null) {
        return await appCheck!.getToken();
      }
    } catch (_) {
      // Ignored: continue without AppCheck token if it fails.
    }
    return null;
  }

  void _resubscribeActive(String? authToken, String? appCheckToken) {
    for (final sub in _pendingSubscriptions.values) {
      final reqId = _activeSubscriptions[sub.operationId];
      if (reqId == null) continue;
      final headers = _buildHeaders(authToken, appCheckToken);
      final request = StreamRequest(
        authToken: authToken,
        appCheckToken: headers['X-Firebase-AppCheck'],
        requestId: reqId,
        requestKind: RequestKind.subscribe,
        subscribe: ExecuteRequest(sub.queryName, sub.variables),
        headers: headers,
      );
      _channel?.sink.add(jsonEncode(request.toJson()));
    }
  }

  void _replayQueriesAndFailMutations(
      String? authToken, String? appCheckToken) {
    final unariesToReplay = <String, List<_PendingUnary>>{};
    for (final entry in _unaryListeners.entries) {
      final reqId = entry.key;
      final kept = <_PendingUnary>[];
      for (final p in entry.value) {
        if (p.isMutation) {
          p.completer.completeError(DataConnectError(DataConnectErrorCode.other,
              'Network reconnected; mutations cannot be safely retried.'));
        } else {
          kept.add(p);
          final headers = _buildHeaders(authToken, appCheckToken);
          final request = StreamRequest(
            authToken: authToken,
            appCheckToken: headers['X-Firebase-AppCheck'],
            requestId: reqId,
            requestKind: RequestKind.execute,
            execute: ExecuteRequest(p.operationName, p.variables),
            headers: headers,
          );
          _channel?.sink.add(jsonEncode(request.toJson()));
        }
      }
      if (kept.isNotEmpty) {
        unariesToReplay[reqId] = kept;
      }
    }
    _unaryListeners.clear();
    _unaryListeners.addAll(unariesToReplay);
  }

  Future<void> _performReconnect() async {
    _channel?.sink.close();
    _channel = null;
    _reconnectAttempts++;

    final authToken = await _refreshAuthToken();
    final appCheckToken = await _refreshAppCheckToken();

    try {
      await _ensureConnected(authToken);

      _reconnectAttempts = 0;
      _isReconnecting = false;

      _resubscribeActive(authToken, appCheckToken);
      _replayQueriesAndFailMutations(authToken, appCheckToken);
    } catch (e) {
      _isReconnecting = false;
      _scheduleReconnect();
    }
  }

  void _onError(dynamic error) {
    if (_channel == null) return;
    developer.log('WebSocket error: $error');
    _channel = null;
    _isReconnecting = false;
    _scheduleReconnect();
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
    _authSubscription?.cancel();
    _authSubscription = null;
  }

  void disconnect() {
    _isExpectedDisconnect = true;
    _disconnect();
  }

  void _onDone() {
    if (_channel == null) return;
    developer.log('WebSocket connection closed.');
    _channel = null;
    _isReconnecting = false;
    if (!_isExpectedDisconnect) {
      _scheduleReconnect();
    }
  }

  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    return _invokeUnary(queryName, deserializer, serializer, vars, authToken,
        RequestKind.execute, false);
  }

  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    return _invokeUnary(queryName, deserializer, serializer, vars, authToken,
        RequestKind.execute, true);
  }

  Future<ServerResponse> _invokeUnary<Data, Variables>(
    String operationName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
    RequestKind requestKind,
    bool isMutation,
  ) async {
    await _ensureConnected(authToken);

    final operationId =
        OperationRef.createOperationId(operationName, vars, serializer);
    final completer = Completer<ServerResponse>();

    if (_activeSubscriptions.containsKey(operationId)) {
      final existingRequestId = _activeSubscriptions[operationId]!;
      Map<String, dynamic>? variablesMap;
      if (vars != null && serializer != null) {
        variablesMap = jsonDecode(serializer(vars));
      }
      _unaryListeners.putIfAbsent(existingRequestId, () => []).add(
          _PendingUnary(completer, operationName, variablesMap, isMutation));

      String? appCheckToken;
      try {
        appCheckToken = await appCheck?.getToken();
      } catch (_) {
        // Ignored
      }

      final headers = _buildHeaders(authToken, appCheckToken);

      final request = StreamRequest(
        authToken: authToken,
        appCheckToken: appCheckToken,
        requestId: existingRequestId,
        requestKind: RequestKind.resume,
        resume: ResumeRequest(),
        headers: headers,
      );
      _channel?.sink.add(jsonEncode(request.toJson()));

      return completer.future;
    }

    final requestId = _generateRequestId(operationId);

    Map<String, dynamic>? variables;
    if (vars != null && serializer != null) {
      variables = jsonDecode(serializer(vars));
    }
    _unaryListeners
        .putIfAbsent(requestId, () => [])
        .add(_PendingUnary(completer, operationName, variables, isMutation));

    String? appCheckToken;
    try {
      appCheckToken = await appCheck?.getToken();
    } catch (_) {
      // Ignored
    }

    final headers = _buildHeaders(authToken, appCheckToken);

    final request = StreamRequest(
      authToken: authToken,
      appCheckToken: appCheckToken,
      requestId: requestId,
      requestKind: requestKind,
      execute: ExecuteRequest(operationName, variables),
      headers: headers,
    );

    _channel?.sink.add(jsonEncode(request.toJson()));

    return completer.future;
  }

  @override
  Stream<ServerResponse> invokeStreamQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) {
    late StreamController<ServerResponse> controller;
    final operationId =
        OperationRef.createOperationId(queryName, vars, serializer);

    controller = StreamController<ServerResponse>(
      onListen: () async {
        try {
          await _ensureConnected(authToken);
        } catch (e) {
          developer.log("Error subscribing - setting up stream $e");
          // Do NOT add error to sink here. The stream is designed to quietly
          // add the query to `_pendingSubscriptions` below and silently
          // retry when the network reconnects via `_scheduleReconnect`.
        }

        if (_activeSubscriptions.containsKey(operationId)) {
          final existingRequestId = _activeSubscriptions[operationId]!;
          _streamListeners
              .putIfAbsent(existingRequestId, () => [])
              .add(controller);
          return;
        }

        final requestId = _generateRequestId(operationId);
        _activeSubscriptions[operationId] = requestId;
        _streamListeners.putIfAbsent(requestId, () => []).add(controller);

        Map<String, dynamic>? variables;
        if (vars != null && serializer != null) {
          variables = json.decode(serializer(vars));
        }
        _pendingSubscriptions[requestId] =
            _PendingSubscription(operationId, queryName, variables);

        if (!isConnected) {
          // we are not connected -
          // keep pending sub to use for retry
          _scheduleReconnect();
          return;
        }

        String? appCheckToken;
        try {
          appCheckToken = await appCheck?.getToken();
        } catch (_) {
          // Ignored
        }

        final headers = _buildHeaders(authToken, appCheckToken);

        final request = StreamRequest(
          authToken: authToken,
          appCheckToken: appCheckToken,
          requestId: requestId,
          requestKind: RequestKind.subscribe,
          subscribe: ExecuteRequest(queryName, variables),
          headers: headers,
        );

        if (_channel != null) {
          final encodedMessage = jsonEncode(request.toJson());
          developer.log('Sending subscribe message $encodedMessage');
          _channel?.sink.add(encodedMessage);
        }
      },
      onCancel: () {
        if (!_activeSubscriptions.containsKey(operationId)) return;
        final requestId = _activeSubscriptions[operationId]!;

        final listeners = _streamListeners[requestId];
        if (listeners != null) {
          listeners.remove(controller);
          if (listeners.isEmpty) {
            _streamListeners.remove(requestId);
            _activeSubscriptions.remove(operationId);
            _pendingSubscriptions.remove(requestId);

            if (_channel != null) {
              final cancelReq = StreamRequest(
                requestId: requestId,
                requestKind: RequestKind.cancel,
                cancel: true,
              );
              _channel?.sink.add(jsonEncode(cancelReq.toJson()));
            }
            _checkIdleAndDisconnect();
          }
        }
      },
    );

    return controller.stream;
  }
}
