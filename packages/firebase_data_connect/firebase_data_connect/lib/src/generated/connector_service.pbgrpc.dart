//
//  Generated code. Do not modify.
//  source: connector_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'connector_service.pb.dart' as $0;

export 'connector_service.pb.dart';

@$pb.GrpcServiceName('google.firebase.dataconnect.v1.ConnectorService')
class ConnectorServiceClient extends $grpc.Client {
  static final _$executeQuery = $grpc.ClientMethod<$0.ExecuteQueryRequest, $0.ExecuteQueryResponse>(
      '/google.firebase.dataconnect.v1.ConnectorService/ExecuteQuery',
      ($0.ExecuteQueryRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ExecuteQueryResponse.fromBuffer(value));
  static final _$executeMutation = $grpc.ClientMethod<$0.ExecuteMutationRequest, $0.ExecuteMutationResponse>(
      '/google.firebase.dataconnect.v1.ConnectorService/ExecuteMutation',
      ($0.ExecuteMutationRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ExecuteMutationResponse.fromBuffer(value));

  ConnectorServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ExecuteQueryResponse> executeQuery($0.ExecuteQueryRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$executeQuery, request, options: options);
  }

  $grpc.ResponseFuture<$0.ExecuteMutationResponse> executeMutation($0.ExecuteMutationRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$executeMutation, request, options: options);
  }
}

@$pb.GrpcServiceName('google.firebase.dataconnect.v1.ConnectorService')
abstract class ConnectorServiceBase extends $grpc.Service {
  $core.String get $name => 'google.firebase.dataconnect.v1.ConnectorService';

  ConnectorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ExecuteQueryRequest, $0.ExecuteQueryResponse>(
        'ExecuteQuery',
        executeQuery_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExecuteQueryRequest.fromBuffer(value),
        ($0.ExecuteQueryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExecuteMutationRequest, $0.ExecuteMutationResponse>(
        'ExecuteMutation',
        executeMutation_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExecuteMutationRequest.fromBuffer(value),
        ($0.ExecuteMutationResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ExecuteQueryResponse> executeQuery_Pre($grpc.ServiceCall call, $async.Future<$0.ExecuteQueryRequest> request) async {
    return executeQuery(call, await request);
  }

  $async.Future<$0.ExecuteMutationResponse> executeMutation_Pre($grpc.ServiceCall call, $async.Future<$0.ExecuteMutationRequest> request) async {
    return executeMutation(call, await request);
  }

  $async.Future<$0.ExecuteQueryResponse> executeQuery($grpc.ServiceCall call, $0.ExecuteQueryRequest request);
  $async.Future<$0.ExecuteMutationResponse> executeMutation($grpc.ServiceCall call, $0.ExecuteMutationRequest request);
}
