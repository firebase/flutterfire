// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// DataConnect class
class FirebaseDataConnect extends FirebasePluginPlatform {
  /// Constructor for initializing Data Connect
  FirebaseDataConnect._(
      {required this.app, required this.connectorConfig, this.auth})
      : options = DataConnectOptions(
            app.options.projectId,
            connectorConfig.location,
            connectorConfig.connector,
            connectorConfig.serviceId),
        _queryManager = QueryManager(),
        super(app.name, 'plugins.flutter.io/firebase_data_connect');

  /// QueryManager manages ongoing queries, and their subscriptions.
  QueryManager _queryManager;

  /// FirebaseApp
  FirebaseApp app;

  /// Due to compatibility issues with grpc-web, we swap out the transport based on what platform the user is using.
  /// For web, we use RestTransport. For mobile, we use GRPCTransport.
  late DataConnectTransport transport;

  /// FirebaseAuth
  FirebaseAuth? auth;

  /// ConnectorConfig + projectId
  DataConnectOptions options;

  /// Data Connect specific config information
  ConnectorConfig connectorConfig;

  /// Custom transport options for connecting to the Data Connect service.
  TransportOptions? _transportOptions;

  /// Checks whether the transport has been properly initialized.
  void _checkTransportInit() {
    transport = getTransport(_transportOptions!, options);
  }

  /// Initializes [_transportOptions] with defaults if not specified.
  void _checkTransportOptionsInit() {
    _transportOptions ??=
        TransportOptions('firebasedataconnect.googleapis.com', null, true);
  }

  /// Returns a [QueryRef] object.
  QueryRef<Data, Variables> query<Data, Variables>(
      String queryName,
      Deserializer<Data> dataDeserializer,
      Serializer<Variables>? varsSerializer,
      Variables? vars) {
    _checkTransportOptionsInit();
    _checkTransportInit();
    return QueryRef<Data, Variables>(queryName, transport, dataDeserializer,
        _queryManager, auth, vars, varsSerializer);
  }

  /// Returns a [MutationRef] object.
  MutationRef<Data, Variables> mutation<Data, Variables>(
      String queryName,
      Deserializer<Data> dataDeserializer,
      Serializer<Variables>? varsSerializer,
      Variables? vars) {
    _checkTransportOptionsInit();
    _checkTransportInit();
    return MutationRef<Data, Variables>(
        queryName, transport, dataDeserializer, auth, vars, varsSerializer);
  }

  /// useDataConnectEmulator connects to the DataConnect emulator.
  void useDataConnectEmulator(String host, {int? port, bool isSecure = false}) {
    _transportOptions = TransportOptions(host, port, isSecure);
  }

  /// Currently cached DataConnect instances. Maps from app name to <ConnectorConfigStr, DataConnect>.
  static final Map<String, Map<String, FirebaseDataConnect>> _cachedInstances =
      {};

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseDataConnect instanceFor({
    FirebaseApp? app,
    FirebaseAuth? auth,
    required ConnectorConfig connectorConfig,
  }) {
    app ??= Firebase.app();
    auth ??= FirebaseAuth.instanceFor(app: app);

    if (_cachedInstances[app.name] != null &&
        _cachedInstances[app.name]![connectorConfig.toJson()] != null) {
      return _cachedInstances[app.name]![connectorConfig.toJson()]!;
    }

    FirebaseDataConnect newInstance = FirebaseDataConnect._(
        app: app, auth: auth, connectorConfig: connectorConfig);
    if (_cachedInstances[app.name] == null) {
      _cachedInstances[app.name] = <String, FirebaseDataConnect>{};
    }
    _cachedInstances[app.name]![connectorConfig.toJson()] = newInstance;

    return newInstance;
  }
}
