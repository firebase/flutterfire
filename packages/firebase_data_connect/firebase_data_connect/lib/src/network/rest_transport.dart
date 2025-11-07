// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of 'rest_library.dart';

/// RestTransport makes requests out to the REST endpoints of the configured backend.
class RestTransport implements DataConnectTransport {
  /// Initializes necessary protocol and port.
  RestTransport(
    this.transportOptions,
    this.options,
    this.appId,
    this.sdkType,
    this.appCheck,
  ) {
    String protocol = 'http';
    if (transportOptions.isSecure ?? true) {
      protocol += 's';
    }
    String host = transportOptions.host;
    int port = transportOptions.port ?? 443;
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    url =
        '$protocol://$host:$port/v1/projects/$project/locations/$location/services/$service/connectors/$connector';
  }

  @override
  FirebaseAppCheck? appCheck;

  @override
  CallerSDKType sdkType;

  /// Current endpoint URL.
  @visibleForTesting
  late String url;

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void setHttp(http.Client client) {
    _client = client;
  }

  http.Client _client = http.Client();

  /// Current host configuration.
  @override
  TransportOptions transportOptions;

  /// Data Connect backend configuration options.
  @override
  DataConnectOptions options;

  /// Firebase application ID.
  @override
  String appId;

  /// Invokes the current operation, whether its a query or mutation.
  Future<ServerResponse> invokeOperation<Data, Variables>(
    String queryName,
    String endpoint,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    String project = options.projectId;
    String location = options.location;
    String service = options.serviceId;
    String connector = options.connector;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-goog-api-client': getGoogApiVal(sdkType, packageVersion),
      'x-firebase-client': getFirebaseClientVal(packageVersion)
    };
    String? appCheckToken;
    try {
      appCheckToken = await appCheck?.getToken();
    } catch (e) {
      log('Unable to get app check token: $e');
    }
    if (authToken != null) {
      headers['X-Firebase-Auth-Token'] = authToken;
    }
    if (appCheckToken != null) {
      headers['X-Firebase-AppCheck'] = appCheckToken;
    }
    headers['x-firebase-gmpid'] = appId;

    Map<String, dynamic> body = {
      'name':
          'projects/$project/locations/$location/services/$service/connectors/$connector',
      'operationName': queryName,
    };
    if (vars != null && serializer != null) {
      body['variables'] = json.decode(serializer(vars));
    }
    try {
      http.Response r = await _client.post(
        Uri.parse('$url:$endpoint'),
        body: json.encode(body),
        headers: headers,
      );
      Map<String, dynamic> bodyJson =
          jsonDecode(r.body) as Map<String, dynamic>;
      if (r.statusCode != 200) {
        String message =
            bodyJson.containsKey('message') ? bodyJson['message']! : r.body;
        throw DataConnectError(
          r.statusCode == 401
              ? DataConnectErrorCode.unauthorized
              : DataConnectErrorCode.other,
          "Received a status code of ${r.statusCode} with a message '$message'",
        );
      }
      return ServerResponse(bodyJson);
      /*
      List errors = bodyJson['errors'] ?? [];
      final data = bodyJson['data'];
      List<DataConnectOperationFailureResponseErrorInfo> suberrors = errors
          .map((e) => switch (e) {
                {'path': List? path, 'message': String? message} =>
                  DataConnectOperationFailureResponseErrorInfo(
                      (path ?? [])
                          .map((val) => switch (val) {
                                String() => DataConnectFieldPathSegment(val),
                                int() => DataConnectListIndexPathSegment(val),
                                _ => throw DataConnectError(
                                    DataConnectErrorCode.other,
                                    'Incorrect type for $val')
                              })
                          .toList(),
                      message ??
                          (throw DataConnectError(
                              DataConnectErrorCode.other, 'Missing message'))),
                _ => throw DataConnectError(
                    DataConnectErrorCode.other, 'Unable to parse JSON: $e')
              })
          .toList();
      Data? decodedData;
      Object? decodeError;
      try {
        /// The response we get is in the data field of the response
        /// Once we get the data back, it's not quite json-encoded,
        /// so we have to encode it and then send it to the user's deserializer.
        decodedData = deserializer(jsonEncode(bodyJson['data']));
      } catch (e) {
        decodeError = e;
      }
      if (suberrors.isNotEmpty) {
        final response =
            DataConnectOperationFailureResponse(suberrors, data, decodedData);

        throw DataConnectOperationError(DataConnectErrorCode.other,
            'Failed to invoke operation: ', response);
      } else {
        if (decodeError != null) {
          throw DataConnectError(DataConnectErrorCode.other,
              'Unable to decode data: $decodeError');
        }
        if (decodedData is! Data) {
          throw DataConnectError(
            DataConnectErrorCode.other,
            "Decoded data wasn't parsed properly. Expected $Data, got $decodedData",
          );
        }
        return decodedData;
      }
      */
    } on Exception catch (e) {
      if (e is DataConnectError) {
        rethrow;
      }
      throw DataConnectError(
        DataConnectErrorCode.other,
        'Failed to invoke operation: $e',
      );
    }
  }

  /// Invokes query REST endpoint.
  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) async {
    return invokeOperation(
      queryName,
      'executeQuery',
      deserializer,
      serializer,
      vars,
      token,
    );
  }

  /// Invokes mutation REST endpoint.
  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) async {
    return invokeOperation(
      queryName,
      'executeMutation',
      deserializer,
      serializer,
      vars,
      token,
    );
  }
}

/// Initializes Rest transport for Data Connect.
DataConnectTransport getTransport(
  TransportOptions transportOptions,
  DataConnectOptions options,
  String appId,
  CallerSDKType sdkType,
  FirebaseAppCheck? appCheck,
) =>
    RestTransport(transportOptions, options, appId, sdkType, appCheck);
