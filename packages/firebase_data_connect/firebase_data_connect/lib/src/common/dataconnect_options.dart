part of firebase_data_connect_common;

/// ConnectorConfig options required for connecting to a Data Connect instance.
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

/// DataConnectOptions includes the Project ID along with the existing ConnectorConfig.
class DataConnectOptions extends ConnectorConfig {
  /// Constructor
  DataConnectOptions(
      this.projectId, String location, String connector, String serviceId)
      : super(location, connector, serviceId);

  /// projectId for Firebase App
  String projectId;
}
