// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect;

/// DataConnect class
class FirebaseDataConnect extends FirebasePluginPlatform {
  /// Constructor for initializing Data Connect
  @visibleForTesting
  FirebaseDataConnect(
      {required this.app,
      required this.connectorConfig,
      this.auth,
      this.appCheck,
      CallerSDKType? sdkType})
      : options = DataConnectOptions(
            app.options.projectId,
            connectorConfig.location,
            connectorConfig.connector,
            connectorConfig.serviceId),
        super(app.name, 'plugins.flutter.io/firebase_data_connect') {
    _queryManager = QueryManager(this);
    if (sdkType != null) {
      this._sdkType = sdkType;
    }
  }

  /// QueryManager manages ongoing queries, and their subscriptions.
  late QueryManager _queryManager;

  /// Type of SDK the user is currently calling.
  CallerSDKType _sdkType = CallerSDKType.core;

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
  @visibleForTesting
  DataConnectOptions options;

  /// Data Connect specific config information
  ConnectorConfig connectorConfig;

  /// Custom transport options for connecting to the Data Connect service.
  @visibleForTesting
  TransportOptions? transportOptions;

  /// Checks whether the transport has been properly initialized.
  @visibleForTesting
  void checkTransport() {
    transportOptions ??=
        TransportOptions('firebasedataconnect.googleapis.com', null, true);
    transport =
        getTransport(transportOptions!, options, _sdkType, auth, appCheck);
  }

  /// Returns a [QueryRef] object.
  QueryRef<Data, Variables> query<Data, Variables>(
      String operationName,
      Deserializer<Data> dataDeserializer,
      Serializer<Variables> varsSerializer,
      Variables? vars) {
    checkTransport();
    return QueryRef<Data, Variables>(this, operationName, transport,
        dataDeserializer, _queryManager, varsSerializer, vars);
  }

  /// Returns a [MutationRef] object.
  MutationRef<Data, Variables> mutation<Data, Variables>(
      String operationName,
      Deserializer<Data> dataDeserializer,
      Serializer<Variables> varsSerializer,
      Variables? vars) {
    checkTransport();
    return MutationRef<Data, Variables>(
        this, operationName, transport, dataDeserializer, varsSerializer, vars);
  }

  /// useDataConnectEmulator connects to the DataConnect emulator.
  void useDataConnectEmulator(String host, int port,
      {bool automaticHostMapping = true, bool isSecure = false}) {
    String mappedHost = automaticHostMapping ? getMappedHost(host) : host;
    transportOptions = TransportOptions(mappedHost, port, isSecure);
  }

  /// Currently cached DataConnect instances. Maps from app name to <ConnectorConfigStr, DataConnect>.
  @visibleForTesting
  static final Map<String, Map<String, FirebaseDataConnect>> cachedInstances =
      {};

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseDataConnect instanceFor({
    FirebaseApp? app,
    FirebaseAuth? auth,
    FirebaseAppCheck? appCheck,
    CallerSDKType? sdkType,
    required ConnectorConfig connectorConfig,
  }) {
    app ??= Firebase.app();
    auth ??= FirebaseAuth.instanceFor(app: app);
    appCheck ??= FirebaseAppCheck.instanceFor(app: app);

    if (cachedInstances[app.name] != null &&
        cachedInstances[app.name]![connectorConfig.toJson()] != null) {
      return cachedInstances[app.name]![connectorConfig.toJson()]!;
    }

    FirebaseDataConnect newInstance = FirebaseDataConnect(
        app: app,
        auth: auth,
        appCheck: appCheck,
        connectorConfig: connectorConfig,
        sdkType: sdkType);
    if (cachedInstances[app.name] == null) {
      cachedInstances[app.name] = <String, FirebaseDataConnect>{};
    }
    cachedInstances[app.name]![connectorConfig.toJson()] = newInstance;

    return newInstance;
  }
}
