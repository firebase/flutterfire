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

part of 'transport_library.dart';

/// WebSocketTransport makes requests out to the streaming endpoints of the configured backend,
/// multiplexing multiple subscriptions and unary operations over a single WebSocket connection.
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
    String protocol = 'ws';
    if (transportOptions.isSecure ?? true) {
      protocol += 's';
    }
    String host = transportOptions.host;
    int port = transportOptions.port ?? 443;
    String location = options.location;
    _url = '$protocol://$host:$port/v1/Connect/locations/$location';
    
    _currentUid = auth?.currentUser?.uid;
    _authSubscription = auth?.idTokenChanges().listen((user) async {
      final newUid = user?.uid;
      // Don't disconnect if auth state changes from not logged in to logged in.
      // Only disconnect if logged in user changes.
      if (_currentUid != null && _currentUid != newUid) {
        _disconnect();
      } else if (newUid != null && isConnected) {
        try {
          final token = await user?.getIdToken();
          final request = StreamRequest(
            requestId: _generateRequestId('auth'),
            authToken: token,
          );
          _channel!.sink.add(jsonEncode(request.toJson()));
        } catch (e) {
          // Ignored
        }
      }
      _currentUid = newUid;
    });
  }

  FirebaseAuth? auth;
  String? _currentUid;
  StreamSubscription<User?>? _authSubscription;


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
  StreamSubscription? _channelSubscription;

  // Active listeners for stream subscriptions mapped by requestId.
  final Map<String, List<StreamController<ServerResponse>>> _streamListeners = {};

  // Active completers for unary operations mapped by requestId.
  final Map<String, List<Completer<ServerResponse>>> _unaryListeners = {};

  // Active subscriptions mapped by operationId => requestId.
  final Map<String, String> _activeSubscriptions = {};

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
    } catch (e) {
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
      name: 'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}',
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
        final completers = _unaryListeners.remove(requestId)!;
        for (var completer in completers) {
          completer.complete(serverResponse);
        }
      } 
      
      if (_streamListeners.containsKey(requestId)) {
        final controllers = _streamListeners[requestId]!;
        if (response.cancelled == true) {
          for (var controller in controllers) {
            controller.close();
          }
          _streamListeners.remove(requestId);
          _activeSubscriptions.removeWhere((key, value) => value == requestId);
        } else {
          for (var controller in controllers) {
            controller.add(serverResponse);
          }
        }
      }
    } catch (e) {
      // JSON decoding error or unknown format
      developer.log('error decoding server response $e');
    }
  }

  void _onError(dynamic error) {
    final e = DataConnectError(DataConnectErrorCode.other, 'WebSocket error: $error');
    for (final completers in _unaryListeners.values) {
      for (var completer in completers) completer.completeError(e);
    }
    for (final controllers in _streamListeners.values) {
      for (var controller in controllers) controller.addError(e);
    }
    _unaryListeners.clear();
    _streamListeners.clear();
    _activeSubscriptions.clear();
    _channel = null;
  }

  void _disconnect() {
    _channel?.sink.close();
  }

  void _onDone() {
    _channel = null;
    for (final controllers in _streamListeners.values) {
      for (var controller in controllers) controller.close();
    }
    _unaryListeners.clear();
    _streamListeners.clear();
    _activeSubscriptions.clear();
  }

  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    return _invokeUnary(queryName, deserializer, serializer, vars, authToken, RequestKind.execute);
  }

  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    return _invokeUnary(queryName, deserializer, serializer, vars, authToken, RequestKind.execute);
  }

  Future<ServerResponse> _invokeUnary<Data, Variables>(
    String operationName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
    RequestKind requestKind,
  ) async {
    await _ensureConnected(authToken);

    final operationId = OperationRef.createOperationId(operationName, vars, serializer);
    final completer = Completer<ServerResponse>();

    if (_activeSubscriptions.containsKey(operationId)) {
      final existingRequestId = _activeSubscriptions[operationId]!;
      _unaryListeners.putIfAbsent(existingRequestId, () => []).add(completer);
      
      String? appCheckToken;
      try {
        appCheckToken = await appCheck?.getToken();
      } catch (e) {
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
    _unaryListeners.putIfAbsent(requestId, () => []).add(completer);

    Map<String, dynamic>? variables;
    if (vars != null && serializer != null) {
      variables = json.decode(serializer(vars));
    }

    String? appCheckToken;
    try {
      appCheckToken = await appCheck?.getToken();
    } catch (e) {
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
    final operationId = OperationRef.createOperationId(queryName, vars, serializer);

    controller = StreamController<ServerResponse>(
      onListen: () async {
        await _ensureConnected(authToken);
        
        if (_activeSubscriptions.containsKey(operationId)) {
          final existingRequestId = _activeSubscriptions[operationId]!;
          _streamListeners.putIfAbsent(existingRequestId, () => []).add(controller);
          return;
        }

        final requestId = _generateRequestId(operationId);
        _activeSubscriptions[operationId] = requestId;
        _streamListeners.putIfAbsent(requestId, () => []).add(controller);

        Map<String, dynamic>? variables;
        if (vars != null && serializer != null) {
          variables = json.decode(serializer(vars));
        }

        String? appCheckToken;
        try {
          appCheckToken = await appCheck?.getToken();
        } catch (e) {
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
            
            if (_channel != null) {
              final cancelReq = StreamRequest(
                requestId: requestId,
                requestKind: RequestKind.cancel,
                cancel: true,
              );
              _channel!.sink.add(jsonEncode(cancelReq.toJson()));
            }
          }
        }
      },
    );

    return controller.stream;
  }
}
