// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// DataConnect class
class FirebaseDataConnect extends FirebasePluginPlatform {
  /// Constructor for initializing Data Connect
  FirebaseDataConnect._({
    required this.app,
    required this.connectorConfig,
    this.auth,
    this.appCheck,
  })  : _options = DataConnectOptions(
            app.options.projectId,
            connectorConfig.location,
            connectorConfig.connector,
            connectorConfig.serviceId),
        super(app.name, 'plugins.flutter.io/firebase_data_connect') {
    _queryManager = _QueryManager(this);
  }

  /// QueryManager manages ongoing queries, and their subscriptions.
  late _QueryManager _queryManager;

  /// FirebaseApp
  FirebaseApp app;

  /// FirebaseAppCheck
  FirebaseAppCheck? appCheck;

  /// Due to compatibility issues with grpc-web, we swap out the transport based on what platform the user is using.
  /// For web, we use RestTransport. For mobile, we use GRPCTransport.
  late DataConnectTransport transport;

  /// FirebaseAuth
  FirebaseAuth? auth;

  /// ConnectorConfig + projectId
  DataConnectOptions _options;

  /// Data Connect specific config information
  ConnectorConfig connectorConfig;

  /// Custom transport options for connecting to the Data Connect service.
  TransportOptions? _transportOptions;

  /// Checks whether the transport has been properly initialized.
  void _checkTransport() {
    _transportOptions ??=
        TransportOptions('firebasedataconnect.googleapis.com', null, true);
    transport = getTransport(_transportOptions!, _options, auth, appCheck);
  }

  /// Returns a [QueryRef] object.
  QueryRef<Data, Variables> query<Data, Variables>(
      String operationName,
      Deserializer<Data> dataDeserializer,
      Serializer<Variables> varsSerializer,
      Variables? vars) {
    _checkTransport();
    return QueryRef<Data, Variables>(this, operationName, transport,
        dataDeserializer, _queryManager, varsSerializer, vars);
  }

  /// Returns a [MutationRef] object.
  MutationRef<Data, Variables> mutation<Data, Variables>(
      String operationName,
      Deserializer<Data> dataDeserializer,
      Serializer<Variables> varsSerializer,
      Variables? vars) {
    _checkTransport();
    return MutationRef<Data, Variables>(
        this, operationName, transport, dataDeserializer, varsSerializer, vars);
  }

  /// useDataConnectEmulator connects to the DataConnect emulator.
  void useDataConnectEmulator(String host, int port,
      {bool automaticHostMapping = true, bool isSecure = false}) {
    String mappedHost = automaticHostMapping ? getMappedHost(host) : host;
    _transportOptions = TransportOptions(mappedHost, port, isSecure);
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
    FirebaseAppCheck? appCheck,
    required ConnectorConfig connectorConfig,
  }) {
    app ??= Firebase.app();
    auth ??= FirebaseAuth.instanceFor(app: app);
    appCheck ??= FirebaseAppCheck.instanceFor(app: app);

    if (_cachedInstances[app.name] != null &&
        _cachedInstances[app.name]![connectorConfig.toJson()] != null) {
      return _cachedInstances[app.name]![connectorConfig.toJson()]!;
    }

    FirebaseDataConnect newInstance = FirebaseDataConnect._(
        app: app,
        auth: auth,
        appCheck: appCheck,
        connectorConfig: connectorConfig);
    if (_cachedInstances[app.name] == null) {
      _cachedInstances[app.name] = <String, FirebaseDataConnect>{};
    }
    _cachedInstances[app.name]![connectorConfig.toJson()] = newInstance;

    return newInstance;
  }
}
