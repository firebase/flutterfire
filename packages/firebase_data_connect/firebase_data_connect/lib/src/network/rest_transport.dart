// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect_rest;

/// RestTransport makes requests out to the REST endpoints of the configured backend.
class RestTransport implements DataConnectTransport {
  /// Initializes necessary protocol and port.
  RestTransport(this.transportOptions, this.options) {
    String protocol = 'http';
    if (transportOptions.isSecure == null ||
        transportOptions.isSecure == true) {
      protocol += 's';
    }
    String host = transportOptions.host;
    int port = transportOptions.port ?? 443;
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    _url =
        '$protocol://$host:$port/v1alpha/projects/$project/locations/$location/services/$service/connectors/$connector';
  }

  /// Current endpoint URL.
  late String _url;

  /// Current host configuration.
  @override
  TransportOptions transportOptions;

  /// Data Connect backend configuration options.
  @override
  DataConnectOptions options;

  /// Invokes the current operation, whether its a query or mutation.
  Future<Data> invokeOperation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      OperationType opType,
      String? token) async {
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-goog-api-client': 'gl-dart/flutter fire/$packageVersion'
    };
    if (token != null) {
      headers['X-Firebase-Auth-Token'] = token;
    }
    Map<String, dynamic> body = {
      'name':
          'projects/$project/locations/$location/services/$service/connectors/$connector',
      'operationName': queryName,
    };
    if (vars != null && serializer != null) {
      body['variables'] = json.decode(serializer(vars));
    }
    String endpoint =
        opType == OperationType.query ? 'executeQuery' : 'executeMutation';
    try {
      http.Response r = await http.post(Uri.parse('$_url:$endpoint'),
          body: json.encode(body), headers: headers);

      /// The response we get is in the data field of the response
      /// Once we get the data back, it's not quite json-encoded,
      /// so we have to encode it and then send it to the user's deserializer.
      return deserializer(jsonEncode(jsonDecode(r.body)['data']));
    } on Exception catch (e) {
      throw FirebaseDataConnectError(DataConnectErrorCode.other,
          'Failed to invoke operation: ${e.toString()}');
    }
  }

  /// Invokes query REST endpoint.
  @override
  Future<Data> invokeQuery<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token) async {
    return invokeOperation(
        queryName, deserializer, serializer, vars, OperationType.query, token);
  }

  /// Invokes mutation REST endpoint.
  @override
  Future<Data> invokeMutation<Data, Variables>(
      String queryName,
      Deserializer<Data> deserializer,
      Serializer<Variables>? serializer,
      Variables? vars,
      String? token) async {
    return invokeOperation(queryName, deserializer, serializer, vars,
        OperationType.mutation, token);
  }
}

/// Initializes Rest transport for Data Connect.
DataConnectTransport getTransport(
        TransportOptions transportOptions, DataConnectOptions options) =>
    RestTransport(transportOptions, options);
