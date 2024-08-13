part of firebase_data_connect;

/// ConnectorConfig
class ConnectorConfig {
  /// Constructor
  ConnectorConfig(this.location, this.connector, this.serviceId);

  /// location
  String location;

  /// connector
  String connector;

  /// serviceId
  String serviceId;

  /// String representation of connectorConfig
  String toJson() {
    return jsonEncode({
      location: location,
      connector: connector,
      serviceId: serviceId,
    });
  }
}

/// DataConnectOptions
class DataConnectOptions extends ConnectorConfig {
  /// Constructor
  DataConnectOptions(
      this.projectId, String location, String connector, String serviceId)
      : super(location, connector, serviceId);

  /// projectId for Firebase App
  String projectId;
}
