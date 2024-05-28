part of firebase_data_connect;

/// DataConnect class
class FirebaseDataConnect extends FirebasePluginPlatform {
  /// Constructor
  late QueryManager _queryManager;
  FirebaseDataConnect._(
      {required this.app, required this.connectorConfig, this.auth})
      : super(app.name, 'plugins.flutter.io/firebase_data_connect') {
    options = DataConnectOptions(
        app.options.projectId,
        connectorConfig.location,
        connectorConfig.connector,
        connectorConfig.serviceId);
    _queryManager = QueryManager();
  }

  /// FirebaseApp
  FirebaseApp app;

  /// GRPCTransport
  late DataConnectTransport transport;

  /// FirebaseAuth
  FirebaseAuth? auth;

  /// ConnectorConfig + projectId
  late DataConnectOptions options;

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
  QueryRef<Data, Variables>
      query<Data extends DataConnectClass, Variables extends DataConnectClass>(
          String queryName, Serializer<Data> serializer, Variables? vars) {
    _checkTransportOptionsInit();
    _checkTransportInit();
    return QueryRef<Data, Variables>(
        queryName, vars, transport, serializer, _queryManager);
  }

  /// mutation
  MutationRef<Data, Variables> mutation<Data extends DataConnectClass,
          Variables extends DataConnectClass>(
      String queryName, Serializer<Data> serializer, Variables? vars) {
    _checkTransportOptionsInit();
    _checkTransportInit();
    return MutationRef<Data, Variables>(queryName, vars, transport, serializer);
  }

  /// useDataConnectEmulator connects to the DataConnect emulator.
  void useDataConnectEmulator(String host, int? port, bool? isSecure) {
    _transportOptions = TransportOptions(host, port, isSecure);
  }

  /// gets instance of FirebaseDataConnect
  static FirebaseDataConnect get instance {
    return FirebaseDataConnect.instanceFor(
      app: Firebase.app(),
    );
  }

  static final Map<String, FirebaseDataConnect> _cachedInstances = {};

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  /// If pass in [appCheck], request session will get protected from abusing.
  static FirebaseDataConnect instanceFor({
    FirebaseApp? app,
    FirebaseAuth? auth,
    ConnectorConfig? connectorConfig,
  }) {
    app ??= Firebase.app();

    if (_cachedInstances.containsKey(app.name)) {
      return _cachedInstances[app.name]!;
    }

    FirebaseDataConnect newInstance = FirebaseDataConnect._(
        app: app, auth: auth, connectorConfig: connectorConfig!);
    _cachedInstances[app.name] = newInstance;

    return newInstance;
  }
}
