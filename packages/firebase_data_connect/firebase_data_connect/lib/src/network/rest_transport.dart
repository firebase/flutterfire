// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_data_connect_rest;

/// RestTransport makes requests out to the REST endpoints of the configured backend.
class RestTransport implements DataConnectTransport {
  /// Initializes necessary protocol and port.
  RestTransport(this.transportOptions, this.options, this.auth, this.appCheck) {
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

  @override
  FirebaseAuth? auth;

  @override
  FirebaseAppCheck? appCheck;

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
      String endpoint) async {
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-goog-api-client': 'gl-dart/flutter fire/$packageVersion'
    };
    String? authToken;
    try {
      authToken = await auth?.currentUser?.getIdToken();
    } catch (e) {
      print('Unable to get auth token: ' + e.toString());
    }
    String? appCheckToken;
    try {
      authToken = await appCheck?.getToken();
    } catch (e) {
      print('Unable to get app check token: ' + e.toString());
    }
    if (authToken != null) {
      headers['X-Firebase-Auth-Token'] = authToken;
    }
    if (appCheckToken != null) {
      headers['X-Firebase-AppCheck'] = appCheckToken;
    }

    Map<String, dynamic> body = {
      'name':
          'projects/$project/locations/$location/services/$service/connectors/$connector',
      'operationName': queryName,
    };
    if (vars != null && serializer != null) {
      print('decoding');
      body['variables'] = json.decode(serializer(vars));
      print('done decoding');
    }
    try {
      http.Response r = await http.post(Uri.parse('$_url:$endpoint'),
          body: json.encode(body), headers: headers);
      if (r.statusCode != 200) {
        Map<String, dynamic> bodyJson =
            jsonDecode(r.body) as Map<String, dynamic>;
        String message =
            bodyJson.containsKey('message') ? bodyJson['message']! : r.body;
        throw DataConnectError(
            r.statusCode == 401
                ? DataConnectErrorCode.unauthorized
                : DataConnectErrorCode.other,
            "Received a status code of ${r.statusCode} with a message '${message}'");
      }

      /// The response we get is in the data field of the response
      /// Once we get the data back, it's not quite json-encoded,
      /// so we have to encode it and then send it to the user's deserializer.
      return deserializer(jsonEncode(jsonDecode(r.body)['data']));
    } on Exception catch (e) {
      if (e is DataConnectError) {
        rethrow;
      }
      throw DataConnectError(DataConnectErrorCode.other,
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
  ) async {
    return invokeOperation(
        queryName, deserializer, serializer, vars, 'executeQuery');
  }

  /// Invokes mutation REST endpoint.
  @override
  Future<Data> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
  ) async {
    return invokeOperation(
        queryName, deserializer, serializer, vars, 'executeMutation');
  }
}

/// Initializes Rest transport for Data Connect.
DataConnectTransport getTransport(
        TransportOptions transportOptions,
        DataConnectOptions options,
        FirebaseAuth? auth,
        FirebaseAppCheck? appCheck) =>
    RestTransport(transportOptions, options, auth, appCheck);
