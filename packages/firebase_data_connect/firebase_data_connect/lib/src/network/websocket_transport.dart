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

  _PendingUnary(this.completer, this.operationName, this.variables, this.isMutation);
}

class _PendingSubscription {
  final String operationId;
  final String queryName;
  final Map<String, dynamic>? variables;
  
  _PendingSubscription(this.operationId, this.queryName, this.variables);
}

class WebSocketTransport implements DataConnectTransport {
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
      path: '/v1/Connect/locations/$location',
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
          _channel!.sink.add(jsonEncode(request.toJson()));
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
  final Map<String, List<StreamController<ServerResponse>>> _streamListeners = {};

  // Pending information for subscriptions mapped by requestId.
  final Map<String, _PendingSubscription> _pendingSubscriptions = {};

  // Active completers for unary operations mapped by requestId.
  final Map<String, List<_PendingUnary>> _unaryListeners = {};

  // Active subscriptions mapped by operationId => requestId.
  final Map<String, String> _activeSubscriptions = {};

  bool _isReconnecting = false;
  bool _isIdleDisconnect = false;
  int _reconnectAttempts = 0;

  void _checkIdleAndDisconnect() {
    if (_streamListeners.isEmpty && _unaryListeners.isEmpty) {
      _isIdleDisconnect = true;
      _disconnect();
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

  Future<void> _ensureConnected(String? authToken) async {
    if (_channel != null) return;

    String? appCheckToken;
    try {
      appCheckToken = await appCheck?.getToken();
    } catch (_) {
      // Ignored
    }

    final headers = _buildHeaders(authToken, appCheckToken);

    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _channelSubscription = _channel!.stream.listen(
      _onMessage,
      onError: _onError,
      onDone: _onDone,
    );

    final initRequest = StreamRequest(
      name:
          'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}',
      headers: headers,
    );
    _channel!.sink.add(jsonEncode(initRequest.toJson()));
  }

  void _onMessage(dynamic message) {
    try {
      developer.log("Received stream response \n $message");
      final bodyJson = jsonDecode(message as String) as Map<String, dynamic>;
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
    final e = error ?? DataConnectError(DataConnectErrorCode.other, 'WebSocket connection closed.');
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

  void _scheduleReconnect() {
    if (_isReconnecting) return;
    _isReconnecting = true;

    if (_reconnectAttempts >= 10) {
      _clearState(DataConnectError(DataConnectErrorCode.other, 'Network disconnected after max attempts.'));
      return;
    }

    final delay = min(1000 * pow(2, _reconnectAttempts).toInt(), 30000);
    Future.delayed(Duration(milliseconds: delay), () {
      _performReconnect();
    });
  }

  Future<void> _performReconnect() async {
    _channel?.sink.close();
    _channel = null;
    _reconnectAttempts++;

    String? authToken;
    try {
      authToken = await auth?.currentUser?.getIdToken();
    } catch (_) {
      // If fetching token fails, continue unauthenticated.
      authToken = null;
    }
    
    try {
      if (appCheck != null) {
        await appCheck!.getToken();
      }
    } catch (_) {
      // Ignored: continue without AppCheck token if it fails.
    }

    try {
      await _ensureConnected(authToken);
      
      _reconnectAttempts = 0;
      _isReconnecting = false;

      // Resubscribe active subscriptions
      for (final sub in _pendingSubscriptions.values) {
        final reqId = _activeSubscriptions[sub.operationId];
        if (reqId == null) continue;
        final headers = _buildHeaders(authToken, appCheck == null ? null : await appCheck!.getToken());
        final request = StreamRequest(
          authToken: authToken,
          appCheckToken: headers['X-Firebase-AppCheck'],
          requestId: reqId,
          requestKind: RequestKind.subscribe,
          subscribe: ExecuteRequest(sub.queryName, sub.variables),
          headers: headers,
        );
        _channel!.sink.add(jsonEncode(request.toJson()));
      }

      // Replay queries, fail mutations
      final unariesToReplay = <String, List<_PendingUnary>>{};
      for (final entry in _unaryListeners.entries) {
         final reqId = entry.key;
         final kept = <_PendingUnary>[];
         for (final p in entry.value) {
            if (p.isMutation) {
               p.completer.completeError(DataConnectError(DataConnectErrorCode.other, 'Network reconnected; mutations cannot be safely retried.'));
            } else {
               kept.add(p);
               final headers = _buildHeaders(authToken, appCheck == null ? null : await appCheck!.getToken());
               final request = StreamRequest(
                authToken: authToken,
                appCheckToken: headers['X-Firebase-AppCheck'],
                requestId: reqId,
                requestKind: RequestKind.execute,
                execute: ExecuteRequest(p.operationName, p.variables),
                headers: headers,
              );
              _channel!.sink.add(jsonEncode(request.toJson()));
            }
         }
         if (kept.isNotEmpty) {
           unariesToReplay[reqId] = kept;
         }
      }
      _unaryListeners.clear();
      _unaryListeners.addAll(unariesToReplay);
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onError(dynamic error) {
    developer.log('WebSocket error: $error');
    _channel = null;
    if (!_isIdleDisconnect) {
      _scheduleReconnect();
    } else {
      _clearState();
      _isIdleDisconnect = false;
    }
  }

  void _disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void _onDone() {
    developer.log('WebSocket connection closed.');
    _channel = null;
    if (!_isIdleDisconnect) {
      _scheduleReconnect();
    } else {
      _clearState();
      _isIdleDisconnect = false;
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
      if (vars != null && serializer != null) variablesMap = jsonDecode(serializer(vars));
      _unaryListeners.putIfAbsent(existingRequestId, () => []).add(_PendingUnary(completer, operationName, variablesMap, isMutation));

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
      _channel!.sink.add(jsonEncode(request.toJson()));

      return completer.future;
    }

    final requestId = _generateRequestId(operationId);

    Map<String, dynamic>? variables;
    if (vars != null && serializer != null) {
      variables = json.decode(serializer(vars));
    }
    _unaryListeners.putIfAbsent(requestId, () => []).add(_PendingUnary(completer, operationName, variables, isMutation));

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

    _channel!.sink.add(jsonEncode(request.toJson()));

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
        await _ensureConnected(authToken);

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
        _pendingSubscriptions[requestId] = _PendingSubscription(operationId, queryName, variables);

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

        _channel!.sink.add(jsonEncode(request.toJson()));
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
              _channel!.sink.add(jsonEncode(cancelReq.toJson()));
            }
            _checkIdleAndDisconnect();
          }
        }
      },
    );

    return controller.stream;
  }
}
