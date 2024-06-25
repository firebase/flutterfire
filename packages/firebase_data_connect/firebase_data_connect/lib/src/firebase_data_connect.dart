part of firebase_data_connect;

/// DataConnect class
class FirebaseDataConnect extends FirebasePluginPlatform {
  /// Constructor
  FirebaseDataConnect._(
      {required this.app, required this.connectorConfig, this.auth})
      : options = DataConnectOptions(
            app.options.projectId,
            connectorConfig.location,
            connectorConfig.connector,
            connectorConfig.serviceId),
        _queryManager = QueryManager(),
        super(app.name, 'plugins.flutter.io/firebase_data_connect');

  QueryManager _queryManager;

  /// FirebaseApp
  FirebaseApp app;

  /// GRPCTransport
  late DataConnectTransport transport;

  /// FirebaseAuth
  FirebaseAuth? auth;

  /// ConnectorConfig + projectId
  DataConnectOptions options;

  /// ConnectorConfig info
  ConnectorConfig connectorConfig;

  TransportOptions? _transportOptions;

  void _checkTransportInit() {
    transport = getTransport(_transportOptions!, options);
  }

  void _checkTransportOptionsInit() {
    _transportOptions ??=
        TransportOptions('firebasedataconnect.googleapis.com', null, true);
  }

  /// query
  QueryRef<Data, Variables> query<Data, Variables>(
      String queryName,
      Deserializer<Data> dataDeserializer,
      Serializer<Variables> varsSerializer,
      Variables vars) {
    _checkTransportOptionsInit();
    _checkTransportInit();
    return QueryRef<Data, Variables>(auth, queryName, vars, transport,
        dataDeserializer, varsSerializer, _queryManager);
  }

  /// mutation
  MutationRef<Data, Variables> mutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables> serializer,
      Variables vars) {
    _checkTransportOptionsInit();
    _checkTransportInit();
    return MutationRef<Data, Variables>(
        auth, queryName, vars, transport, deserializer, serializer);
  }

  /// useDataConnectEmulator connects to the DataConnect emulator.
  void useDataConnectEmulator(String host, {int? port, bool isSecure = false}) {
    _transportOptions = TransportOptions(host, port, isSecure);
  }

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
