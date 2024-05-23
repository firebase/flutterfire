part of firebase_data_connect;

/// TransportOptions stores connection information
class TransportOptions {
  /// Constructor
  TransportOptions(this.host, this.port, this.isSecure);

  /// Host to connect to
  String host;

  /// Port to connect to
  int? port;

  /// isSecure - use secure protocol
  bool? isSecure;
}
