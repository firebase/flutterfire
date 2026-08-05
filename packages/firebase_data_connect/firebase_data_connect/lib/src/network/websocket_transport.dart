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
            headers: _buildHeaders(token, null),
          );
          _send(request.toJson());
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
  String? _hotRestartKey;
  String? _hotRestartToken;

  bool get _shouldUseHotRestartGuard => kIsWeb && kDebugMode;

  String get _webSocketTransportKey {
    return 'flutterfire_dataconnect_ws_${appId}_${options.projectId}_'
        '${options.location}_${options.serviceId}_${options.connector}_$_url';
  }

  bool get _isCurrentWebSocketTransport {
    if (!_shouldUseHotRestartGuard) {
      return true;
    }

    final key = _hotRestartKey;
    if (key == null) {
      return true;
    }
    return isCurrentDataConnectWebSocketTransport(key, _hotRestartToken);
  }

  void _claimWebSocketTransport() {
    if (!_shouldUseHotRestartGuard) {
      return;
    }

    _hotRestartKey = _webSocketTransportKey;
    _hotRestartToken = claimDataConnectWebSocketTransport(_hotRestartKey!);
  }

  void _closeStaleWebSocketTransport() {
    _isExpectedDisconnect = true;
    _disconnect();
  }

  /// Number of operations that are currently between "requested by the caller"
  /// and "registered in [_unaryListeners] / [_streamListeners]".
  ///
  /// Both `_invokeUnary` and `invokeStreamQuery` have to await the connection
  /// handshake (and an AppCheck token) before they can send anything, so there
  /// is a window during which a brand new operation is invisible to
  /// [_checkIdleAndDisconnect]. Without this counter an unrelated unary
  /// response arriving in that window makes the transport look idle, closes the
  /// socket and — because the close is flagged as *expected* — permanently
  /// vetoes any reconnect for the operation that was still being set up.
  int _pendingOperationSetups = 0;

  void _checkIdleAndDisconnect() {
    if (_pendingOperationSetups > 0) return;
    if (_streamListeners.isEmpty && _unaryListeners.isEmpty) {
      _isExpectedDisconnect = true;
      _disconnect();
      _releaseWebSocketTransport();
      _clearState();
    }
  }

  /// Re-establishes the connection on behalf of operations that are already
  /// registered.
  ///
  /// An explicit `execute`/`subscribe` is an explicit intent to be connected,
  /// so a previous *expected* disconnect (from [_checkIdleAndDisconnect] or
  /// [disconnect]) must not veto the retry: [_scheduleReconnect] returns early
  /// while `_isExpectedDisconnect` is set, which would strand the operation
  /// forever with no event and no error.
  void _reconnectForActiveOperations() {
    _isExpectedDisconnect = false;
    _scheduleReconnect();
  }

  final Random _random = Random();
  static const String _chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  String _generateRequestId(String operationName) {
    final randStr = String.fromCharCodes(Iterable.generate(
        15, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));
    return '${operationName}_$randStr';
  }

  void _send(Map<String, dynamic> json) {
    if (_channel == null) return;
    final encoded = jsonEncode(json);
    if (encoded.isNotEmpty) {
      _channel!.sink.add(encoded);
    }
  }

  bool get isConnected => _channel != null;

  @visibleForTesting
  Map<String, String> buildHeaders(String? authToken, String? appCheckToken) =>
      _buildHeaders(authToken, appCheckToken);

  Map<String, String> _buildHeaders(String? authToken, String? appCheckToken) {
    Map<String, String> headers = {
      'x-goog-api-client': getGoogApiVal(sdkType, packageVersion),
      'x-firebase-client': getFirebaseClientVal(packageVersion),
      'x-client-version': 'flutter/$packageVersion',
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

    _claimWebSocketTransport();

    // Detach any listener still attached to a previous socket, so a late
    // `done`/`error` from it cannot clobber the channel we are about to open.
    unawaited(_channelSubscription?.cancel());

    final channel = WebSocketChannel.connect(Uri.parse(_url));
    _channel = channel;
    _channelSubscription = channel.stream.listen(
      _onMessage,
      onError: (Object error) => _onError(channel, error),
      onDone: () => _onDone(channel),
    );

    // reset this since an explicit connect was requested
    _isExpectedDisconnect = false;

    try {
      // Await the local `channel`, never `_channel`: `_channel` can be nulled
      // out while we are connecting, and `await null` would silently report
      // success for a socket that is not usable.
      await channel.ready;
    } catch (e) {
      developer.log('WebSocket connection failed to become ready: $e');
      if (identical(_channel, channel)) {
        _channel = null;
      }
      _releaseWebSocketTransport();
      throw DataConnectError(
          DataConnectErrorCode.other, 'WebSocket connection failed: $e');
    }

    if (!identical(_channel, channel)) {
      // The socket was torn down or replaced while the handshake was in
      // flight; whoever replaced it owns sending the init request.
      return;
    }

    final initRequest = StreamRequest(
      name:
          'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}',
      headers: headers,
    );
    _send(initRequest.toJson());
  }

  // called when a message is received from the stream
  void _onMessage(dynamic message) {
    if (!_isCurrentWebSocketTransport) {
      _closeStaleWebSocketTransport();
      return;
    }

    try {
      var bodyString = '';
      if (message is List<int>) {
        bodyString = utf8.decode(message);
      } else {
        bodyString = message as String;
      }

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
        final pendings = _unaryListeners.remove(requestId) ?? [];
        for (final p in pendings) {
          if (!p.completer.isCompleted) {
            p.completer.complete(serverResponse);
          }
        }
        _checkIdleAndDisconnect();
      }

      if (_streamListeners.containsKey(requestId)) {
        final controllers = _streamListeners[requestId] ?? [];
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
    if (!_isCurrentWebSocketTransport) {
      _closeStaleWebSocketTransport();
      return;
    }
    if (_isReconnecting || _isExpectedDisconnect) return;
    if (_streamListeners.isEmpty && _unaryListeners.isEmpty) return;
    _isReconnecting = true;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _clearState(DataConnectError(DataConnectErrorCode.other,
          'Network disconnected after max attempts.'));
      return;
    }

    final delay = min(
        _initialReconnectDelayMs * pow(2, _reconnectAttempts).toInt(),
        _maxReconnectDelayMs);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () async {
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
        requestId: reqId,
        requestKind: RequestKind.subscribe,
        subscribe: ExecuteRequest(sub.queryName, sub.variables),
        headers: headers,
      );
      _send(request.toJson());
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
            requestId: reqId,
            requestKind: RequestKind.execute,
            execute: ExecuteRequest(p.operationName, p.variables),
            headers: headers,
          );
          _send(request.toJson());
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
    if (!_isCurrentWebSocketTransport) {
      _closeStaleWebSocketTransport();
      return;
    }

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

  void _onError(WebSocketChannel channel, dynamic error) {
    if (!_isCurrentWebSocketTransport) {
      _closeStaleWebSocketTransport();
      return;
    }
    // Ignore events from a socket that is no longer the active one.
    if (!identical(_channel, channel)) return;
    developer.log('WebSocket error: $error');
    _channel = null;
    _isReconnecting = false;
    _scheduleReconnect();
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    // The stream subscription is intentionally left attached so the close
    // handshake can complete; `_onDone`/`_onError` ignore it once `_channel`
    // no longer points at it, and `_doConnect` detaches it before opening the
    // replacement socket.
    _channel?.sink.close();
    _channel = null;
  }

  void disconnect() {
    _isExpectedDisconnect = true;
    _disconnect();
    _releaseWebSocketTransport();
  }

  void _onDone(WebSocketChannel channel) {
    if (!_isCurrentWebSocketTransport) {
      _closeStaleWebSocketTransport();
      return;
    }
    // A `done` from a socket we already replaced must not null out the current
    // channel: every later `_send` would be dropped on the floor silently.
    if (!identical(_channel, channel)) return;
    _channel = null;
    _isReconnecting = false;
    if (!_isExpectedDisconnect) {
      _scheduleReconnect();
    }
  }

  void _releaseWebSocketTransport() {
    if (!_shouldUseHotRestartGuard) {
      return;
    }

    final key = _hotRestartKey;
    if (key == null) {
      return;
    }
    releaseDataConnectWebSocketTransport(key, _hotRestartToken);
    _hotRestartKey = null;
    _hotRestartToken = null;
  }

  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    return _invokeUnary(operationId, queryName, deserializer, serializer, vars,
        authToken, RequestKind.execute, false);
  }

  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    return _invokeUnary(operationId, queryName, deserializer, serializer, vars,
        authToken, RequestKind.execute, true);
  }

  Future<ServerResponse> _invokeUnary<Data, Variables>(
    String operationId,
    String operationName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
    RequestKind requestKind,
    bool isMutation,
  ) async {
    // The setup is only "in flight" until the operation is registered and its
    // request has been written; the returned future is intentionally awaited
    // outside the guard so idle detection still works once we are waiting on
    // the server.
    _pendingOperationSetups++;
    Completer<ServerResponse> completer;
    try {
      completer = await _sendUnary(operationId, operationName, serializer, vars,
          authToken, requestKind, isMutation);
    } finally {
      _pendingOperationSetups--;
    }
    return completer.future;
  }

  Future<Completer<ServerResponse>> _sendUnary<Variables>(
    String operationId,
    String operationName,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
    RequestKind requestKind,
    bool isMutation,
  ) async {
    await _ensureConnected(authToken);
    if (!isConnected) {
      // A concurrent teardown closed the socket while we were connecting.
      // Reconnect explicitly rather than writing into a null channel, which
      // `_send` would drop silently and hang the returned future forever.
      _isExpectedDisconnect = false;
      await _ensureConnected(authToken);
    }

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
        requestId: existingRequestId,
        requestKind: RequestKind.resume,
        resume: ResumeRequest(),
        headers: headers,
      );
      if (isConnected) {
        _send(request.toJson());
      } else {
        _reconnectForActiveOperations();
      }

      return completer;
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
      requestId: requestId,
      requestKind: requestKind,
      execute: ExecuteRequest(operationName, variables),
      headers: headers,
    );

    if (isConnected) {
      _send(request.toJson());
    } else {
      // Registered in `_unaryListeners`, so the reconnect replays it.
      _reconnectForActiveOperations();
    }

    return completer;
  }

  @override
  Stream<ServerResponse> invokeStreamQuery<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) {
    late StreamController<ServerResponse> controller;

    controller = StreamController<ServerResponse>(
      onListen: () async {
        _pendingOperationSetups++;
        try {
          // Register this listener *synchronously*, before awaiting anything.
          // `_checkIdleAndDisconnect()` and `_scheduleReconnect()` both key off
          // `_streamListeners`, so a listener that is only registered after the
          // `await` below is invisible to them: an unrelated unary response
          // arriving in that window makes the transport look idle, closes the
          // socket, flags the close as *expected*, and this subscription is
          // then stranded forever — no first event, and (by design) no error.
          final existingRequestId = _activeSubscriptions[operationId];
          final isNewSubscription = existingRequestId == null;

          Map<String, dynamic>? variables;
          if (vars != null && serializer != null) {
            variables = json.decode(serializer(vars));
          }

          final requestId =
              existingRequestId ?? _generateRequestId(operationId);

          if (isNewSubscription) {
            _activeSubscriptions[operationId] = requestId;
            _pendingSubscriptions[requestId] =
                _PendingSubscription(operationId, queryName, variables);
          }
          _streamListeners.putIfAbsent(requestId, () => []).add(controller);

          try {
            await _ensureConnected(authToken);
          } catch (e) {
            developer.log("Error subscribing - setting up stream $e");
            // Do NOT add error to sink here. The stream is designed to quietly
            // keep the query in `_pendingSubscriptions` and silently retry
            // when the network reconnects via `_scheduleReconnect`.
          }

          if (!isNewSubscription) {
            // Multiplexed onto a `subscribe` that was already sent for
            // `requestId`; nothing more to write.
            if (!isConnected) _reconnectForActiveOperations();
            return;
          }

          if (!isConnected) {
            // we are not connected -
            // keep pending sub to use for retry
            _reconnectForActiveOperations();
            return;
          }

          String? appCheckToken;
          try {
            appCheckToken = await appCheck?.getToken();
          } catch (_) {
            // Ignored
          }

          if (!isConnected) {
            _reconnectForActiveOperations();
            return;
          }

          final headers = _buildHeaders(authToken, appCheckToken);

          final request = StreamRequest(
            requestId: requestId,
            requestKind: RequestKind.subscribe,
            subscribe: ExecuteRequest(queryName, variables),
            headers: headers,
          );

          _send(request.toJson());
        } finally {
          _pendingOperationSetups--;
        }
      },
      onCancel: () {
        final requestId = _activeSubscriptions[operationId];
        if (requestId == null) return;

        final listeners = _streamListeners[requestId];
        listeners?.remove(controller);
        if (listeners == null || listeners.isEmpty) {
          // Always drop the `operationId -> requestId` mapping here. Leaving it
          // behind (which the previous `listeners != null` guard did) makes
          // every later `subscribe()` for this query attach to a request the
          // server is no longer streaming, so it never gets a first event.
          _streamListeners.remove(requestId);
          _activeSubscriptions.remove(operationId);
          _pendingSubscriptions.remove(requestId);

          if (isConnected) {
            final cancelReq = StreamRequest(
              requestId: requestId,
              requestKind: RequestKind.cancel,
              cancel: true,
            );
            _send(cancelReq.toJson());
          }
          _checkIdleAndDisconnect();
        }
      },
    );

    return controller.stream;
  }
}
