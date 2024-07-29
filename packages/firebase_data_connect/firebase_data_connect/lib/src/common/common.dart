// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect_common;

/// DataConnectOptions
class DataConnectOptions extends ConnectorConfig {
  /// Constructor
  DataConnectOptions(
      this.projectId, String location, String connector, String serviceId)
      : super(location, connector, serviceId);

  /// projectId for Firebase App
  String projectId;
}

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

abstract class DataConnectTransport {
  DataConnectTransport(this.transportOptions, this.options);
  TransportOptions transportOptions;
  DataConnectOptions options;
  Future<Data> invokeQuery<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token);

  Future<Data> invokeMutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token);
}

class OperationResult<Data, Variables> {
  OperationResult(this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
}

enum OperationType { query, mutation }

class OperationRef<Data, Variables> {
  /// Constructor
  OperationRef(this.auth, this.operationName, this.variables, this._transport,
      this.opType, this.deserializer, this.serializer) {
    if (this.variables != null && this.serializer == null) {
      throw Exception('Serializer required for variables');
    }
  }
  FirebaseAuth? auth;
  Variables? variables;
  String operationName;
  DataConnectTransport _transport;
  Deserializer<Data> deserializer;
  Serializer<Variables>? serializer;
  OperationType opType;

  Future<OperationResult<Data, Variables>> execute() async {
    String? token = await this.auth?.currentUser?.getIdToken();
    if (this.opType == OperationType.query) {
      Data data = await this._transport.invokeQuery<Data, Variables>(
          this.operationName,
          this.deserializer,
          this.serializer,
          variables,
          token);
      return OperationResult(data, this);
    } else {
      Data data = await this._transport.invokeMutation<Data, Variables>(
          this.operationName,
          this.deserializer,
          this.serializer,
          variables,
          token);
      return OperationResult(data, this);
    }
  }
}

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

typedef Serializer<Variables> = String Function(Variables vars);
typedef Deserializer<Data> = Data Function(String data);
