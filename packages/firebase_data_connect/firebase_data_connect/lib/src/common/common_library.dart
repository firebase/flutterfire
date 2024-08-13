library firebase_data_connect_common;

import 'dart:convert';

part 'dataconnect_error.dart';
part 'dataconnect_options.dart';

/// Transport Options for connecting to a specific host.
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

/// Interface for transports connecting to the DataConnect backend.
abstract class DataConnectTransport {
  /// Constructor.
  DataConnectTransport(this.transportOptions, this.options);

  /// Transport options.
  TransportOptions transportOptions;

  /// DataConnect backend configuration.
  DataConnectOptions options;

  /// Invokes corresponding query endpoint.
  Future<Data> invokeQuery<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token);

  /// Invokes corresponding mutation endpoint.
  Future<Data> invokeMutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token);
}
