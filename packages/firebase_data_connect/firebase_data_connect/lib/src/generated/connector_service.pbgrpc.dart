// This is a generated file - do not edit.
//
// Generated from connector_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'connector_service.pb.dart' as $0;

export 'connector_service.pb.dart';

/// Firebase Data Connect provides means to deploy a set of predefined GraphQL
/// operations (queries and mutations) as a Connector.
///
/// Firebase developers can build mobile and web apps that uses Connectors
/// to access Data Sources directly. Connectors allow operations without
/// admin credentials and help Firebase customers control the API exposure.
///
/// Note: `ConnectorService` doesn't check IAM permissions and instead developers
/// must define auth policies on each pre-defined operation to secure this
/// connector. The auth policies typically define rules on the Firebase Auth
/// token.
@$pb.GrpcServiceName('google.firebase.dataconnect.v1.ConnectorService')
class ConnectorServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ConnectorServiceClient(super.channel, {super.options, super.interceptors});

  /// Execute a predefined query in a Connector.
  $grpc.ResponseFuture<$0.ExecuteQueryResponse> executeQuery(
    $0.ExecuteQueryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeQuery, request, options: options);
  }

  /// Execute a predefined mutation in a Connector.
  $grpc.ResponseFuture<$0.ExecuteMutationResponse> executeMutation(
    $0.ExecuteMutationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeMutation, request, options: options);
  }

  // method descriptors

  static final _$executeQuery =
      $grpc.ClientMethod<$0.ExecuteQueryRequest, $0.ExecuteQueryResponse>(
          '/google.firebase.dataconnect.v1.ConnectorService/ExecuteQuery',
          ($0.ExecuteQueryRequest value) => value.writeToBuffer(),
          $0.ExecuteQueryResponse.fromBuffer);
  static final _$executeMutation =
      $grpc.ClientMethod<$0.ExecuteMutationRequest, $0.ExecuteMutationResponse>(
          '/google.firebase.dataconnect.v1.ConnectorService/ExecuteMutation',
          ($0.ExecuteMutationRequest value) => value.writeToBuffer(),
          $0.ExecuteMutationResponse.fromBuffer);
}

@$pb.GrpcServiceName('google.firebase.dataconnect.v1.ConnectorService')
abstract class ConnectorServiceBase extends $grpc.Service {
  $core.String get $name => 'google.firebase.dataconnect.v1.ConnectorService';

  ConnectorServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.ExecuteQueryRequest, $0.ExecuteQueryResponse>(
            'ExecuteQuery',
            executeQuery_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ExecuteQueryRequest.fromBuffer(value),
            ($0.ExecuteQueryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExecuteMutationRequest,
            $0.ExecuteMutationResponse>(
        'ExecuteMutation',
        executeMutation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExecuteMutationRequest.fromBuffer(value),
        ($0.ExecuteMutationResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ExecuteQueryResponse> executeQuery_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ExecuteQueryRequest> $request) async {
    return executeQuery($call, await $request);
  }

  $async.Future<$0.ExecuteQueryResponse> executeQuery(
      $grpc.ServiceCall call, $0.ExecuteQueryRequest request);

  $async.Future<$0.ExecuteMutationResponse> executeMutation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ExecuteMutationRequest> $request) async {
    return executeMutation($call, await $request);
  }

  $async.Future<$0.ExecuteMutationResponse> executeMutation(
      $grpc.ServiceCall call, $0.ExecuteMutationRequest request);
}
