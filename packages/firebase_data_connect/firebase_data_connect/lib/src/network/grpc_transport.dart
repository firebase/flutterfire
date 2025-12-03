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

part of 'grpc_library.dart';

/// Transport used for Android/iOS. Uses a GRPC transport instead of REST.
class GRPCTransport implements DataConnectTransport {
  /// GRPCTransport creates a new channel
  GRPCTransport(
    this.transportOptions,
    this.options,
    this.appId,
    this.sdkType,
    this.appCheck,
  ) {
    bool isSecure = transportOptions.isSecure ?? true;
    channel = ClientChannel(
      transportOptions.host,
      port: transportOptions.port ?? 443,
      options: ChannelOptions(
        credentials: (isSecure
            ? const ChannelCredentials.secure()
            : const ChannelCredentials.insecure()),
      ),
    );
    stub = ConnectorServiceClient(channel);
    name =
        'projects/${options.projectId}/locations/${options.location}/services/${options.serviceId}/connectors/${options.connector}';
  }

  /// FirebaseAppCheck
  @override
  FirebaseAppCheck? appCheck;

  @override
  CallerSDKType sdkType;

  /// Name of the endpoint.
  late String name;

  /// ConnectorServiceClient used to execute the query/mutation.
  late ConnectorServiceClient stub;

  /// ClientChannel used to configure connection to the GRPC server.
  late ClientChannel channel;

  /// Current host configuration.
  @override
  TransportOptions transportOptions;

  /// Data Connect backend configuration options.
  @override
  DataConnectOptions options;

  /// Application ID
  @override
  String appId;

  Future<Map<String, String>> getMetadata(String? authToken) async {
    String? appCheckToken;
    try {
      appCheckToken = await appCheck?.getToken();
    } catch (e) {
      log('Unable to get app check token: $e');
    }
    Map<String, String> metadata = {
      'x-goog-request-params': 'location=${options.location}&frontend=data',
      'x-goog-api-client': getGoogApiVal(sdkType, packageVersion),
      'x-firebase-client': getFirebaseClientVal(packageVersion)
    };

    if (authToken != null) {
      metadata['x-firebase-auth-token'] = authToken;
    }
    if (appCheckToken != null) {
      metadata['X-Firebase-AppCheck'] = appCheckToken;
    }
    metadata['x-firebase-gmpid'] = appId;
    return metadata;
  }

  /// Invokes GPRC query endpoint.
  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    ExecuteQueryResponse response;

    ExecuteQueryRequest request =
        ExecuteQueryRequest(name: name, operationName: queryName);
    if (vars != null && serializer != null) {
      request.variables = getStruct(vars, serializer);
    }
    try {
      response = await stub.executeQuery(
        request,
        options: CallOptions(metadata: await getMetadata(authToken)),
      );
      return handleResponse(
          CommonResponse.fromExecuteQuery(deserializer, response));
    } on Exception catch (e) {
      if (e.toString().contains('invalid Firebase Auth Credentials')) {
        throw DataConnectError(
          DataConnectErrorCode.unauthorized,
          'Failed to invoke operation: $e',
        );
      }
      rethrow;
    }
  }

  /// Converts the variables into a proto Struct.
  Struct getStruct<Variables>(
    Variables vars,
    Serializer<Variables> serializer,
  ) {
    Struct struct = Struct.create();
    struct.mergeFromProto3Json(jsonDecode(serializer(vars)));
    return struct;
  }

  /// Invokes GPRC mutation endpoint.
  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? authToken,
  ) async {
    ExecuteMutationResponse response;
    ExecuteMutationRequest request =
        ExecuteMutationRequest(name: name, operationName: queryName);
    if (vars != null && serializer != null) {
      request.variables = getStruct(vars, serializer);
    }

    try {
      response = await stub.executeMutation(
        request,
        options: CallOptions(metadata: await getMetadata(authToken)),
      );
      return handleResponse(
          CommonResponse.fromExecuteMutation(deserializer, response));
    } on Exception catch (e) {
      if (e.toString().contains('invalid Firebase Auth Credentials')) {
        throw DataConnectError(
          DataConnectErrorCode.unauthorized,
          'Failed to invoke operation: $e',
        );
      }
      rethrow;
    }
  }
}

ServerResponse handleResponse<Data>(CommonResponse<Data> commonResponse) {
  log('handleResponse type ${commonResponse.data.runtimeType}');
  Map<String, dynamic>? jsond = commonResponse.data as Map<String, dynamic>?;
  log('handleResponse got json data $jsond');
  String jsonEncoded = jsonEncode(commonResponse.data);

  if (commonResponse.errors.isNotEmpty) {
    Map<String, dynamic>? data =
        jsonDecode(jsonEncoded) as Map<String, dynamic>?;
    Data? decodedData;
    List<DataConnectOperationFailureResponseErrorInfo> errors = commonResponse
        .errors
        .map((e) => DataConnectOperationFailureResponseErrorInfo(
            e.path.values
                .map((val) => val.hasStringValue()
                    ? DataConnectFieldPathSegment(val.stringValue)
                    : DataConnectListIndexPathSegment(val.numberValue.toInt()))
                .toList(),
            e.message))
        .toList();
    if (data != null) {
      try {
        decodedData = commonResponse.deserializer(jsonEncoded);
      } catch (e) {
        // nothing required
      }
    }
    final response =
        DataConnectOperationFailureResponse(errors, data, decodedData);
    throw DataConnectOperationError(DataConnectErrorCode.other,
        'failed to invoke operation: ${response.errors}', response);
  }

  // no errors - return a standard response
  if (jsond != null) {
    return ServerResponse(jsond!);
  } else {
    return ServerResponse({});
  }
}

/// Initializes GRPC transport for Data Connect.
DataConnectTransport getTransport(
  TransportOptions transportOptions,
  DataConnectOptions options,
  String appId,
  CallerSDKType sdkType,
  FirebaseAppCheck? appCheck,
) =>
    GRPCTransport(transportOptions, options, appId, sdkType, appCheck);

class CommonResponse<Data> {
  CommonResponse(this.deserializer, this.data, this.errors);
  static CommonResponse<Data> fromExecuteMutation<Data>(
      Deserializer<Data> deserializer, ExecuteMutationResponse response) {
    return CommonResponse(
        deserializer, response.data.toProto3Json(), response.errors);
  }

  static CommonResponse<Data> fromExecuteQuery<Data>(
      Deserializer<Data> deserializer, ExecuteQueryResponse response) {
    return CommonResponse(
        deserializer, response.data.toProto3Json(), response.errors);
  }

  final Deserializer<Data> deserializer;
  final Object? data;
  final List<GraphqlError> errors;
}
