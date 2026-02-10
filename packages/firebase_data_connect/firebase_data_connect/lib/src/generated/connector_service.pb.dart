//
//  Generated code. Do not modify.
//  source: connector_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/struct.pb.dart' as $1;
import 'graphql_error.pb.dart' as $3;
import 'graphql_response_extensions.pb.dart' as $4;

/// The ExecuteQuery request to Firebase Data Connect.
class ExecuteQueryRequest extends $pb.GeneratedMessage {
  factory ExecuteQueryRequest({
    $core.String? name,
    $core.String? operationName,
    $1.Struct? variables,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (operationName != null) {
      $result.operationName = operationName;
    }
    if (variables != null) {
      $result.variables = variables;
    }
    return $result;
  }
  ExecuteQueryRequest._() : super();
  factory ExecuteQueryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExecuteQueryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExecuteQueryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.firebase.dataconnect.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'operationName')
    ..aOM<$1.Struct>(3, _omitFieldNames ? '' : 'variables', subBuilder: $1.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExecuteQueryRequest clone() => ExecuteQueryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExecuteQueryRequest copyWith(void Function(ExecuteQueryRequest) updates) => super.copyWith((message) => updates(message as ExecuteQueryRequest)) as ExecuteQueryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteQueryRequest create() => ExecuteQueryRequest._();
  ExecuteQueryRequest createEmptyInstance() => create();
  static $pb.PbList<ExecuteQueryRequest> createRepeated() => $pb.PbList<ExecuteQueryRequest>();
  @$core.pragma('dart2js:noInline')
  static ExecuteQueryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExecuteQueryRequest>(create);
  static ExecuteQueryRequest? _defaultInstance;

  /// The resource name of the connector to find the predefined query, in
  /// the format:
  /// ```
  /// projects/{project}/locations/{location}/services/{service}/connectors/{connector}
  /// ```
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  /// The name of the GraphQL operation name.
  /// Required because all Connector operations must be named.
  /// See https://graphql.org/learn/queries/#operation-name.
  /// (-- api-linter: core::0122::name-suffix=disabled
  ///     aip.dev/not-precedent: Must conform to GraphQL HTTP spec standard. --)
  @$pb.TagNumber(2)
  $core.String get operationName => $_getSZ(1);
  @$pb.TagNumber(2)
  set operationName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOperationName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperationName() => clearField(2);

  /// Values for GraphQL variables provided in this request.
  @$pb.TagNumber(3)
  $1.Struct get variables => $_getN(2);
  @$pb.TagNumber(3)
  set variables($1.Struct v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasVariables() => $_has(2);
  @$pb.TagNumber(3)
  void clearVariables() => clearField(3);
  @$pb.TagNumber(3)
  $1.Struct ensureVariables() => $_ensure(2);
}

/// The ExecuteMutation request to Firebase Data Connect.
class ExecuteMutationRequest extends $pb.GeneratedMessage {
  factory ExecuteMutationRequest({
    $core.String? name,
    $core.String? operationName,
    $1.Struct? variables,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (operationName != null) {
      $result.operationName = operationName;
    }
    if (variables != null) {
      $result.variables = variables;
    }
    return $result;
  }
  ExecuteMutationRequest._() : super();
  factory ExecuteMutationRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExecuteMutationRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExecuteMutationRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.firebase.dataconnect.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'operationName')
    ..aOM<$1.Struct>(3, _omitFieldNames ? '' : 'variables', subBuilder: $1.Struct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExecuteMutationRequest clone() => ExecuteMutationRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExecuteMutationRequest copyWith(void Function(ExecuteMutationRequest) updates) => super.copyWith((message) => updates(message as ExecuteMutationRequest)) as ExecuteMutationRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteMutationRequest create() => ExecuteMutationRequest._();
  ExecuteMutationRequest createEmptyInstance() => create();
  static $pb.PbList<ExecuteMutationRequest> createRepeated() => $pb.PbList<ExecuteMutationRequest>();
  @$core.pragma('dart2js:noInline')
  static ExecuteMutationRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExecuteMutationRequest>(create);
  static ExecuteMutationRequest? _defaultInstance;

  /// The resource name of the connector to find the predefined mutation, in
  /// the format:
  /// ```
  /// projects/{project}/locations/{location}/services/{service}/connectors/{connector}
  /// ```
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  /// The name of the GraphQL operation name.
  /// Required because all Connector operations must be named.
  /// See https://graphql.org/learn/queries/#operation-name.
  /// (-- api-linter: core::0122::name-suffix=disabled
  ///     aip.dev/not-precedent: Must conform to GraphQL HTTP spec standard. --)
  @$pb.TagNumber(2)
  $core.String get operationName => $_getSZ(1);
  @$pb.TagNumber(2)
  set operationName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOperationName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperationName() => clearField(2);

  /// Values for GraphQL variables provided in this request.
  @$pb.TagNumber(3)
  $1.Struct get variables => $_getN(2);
  @$pb.TagNumber(3)
  set variables($1.Struct v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasVariables() => $_has(2);
  @$pb.TagNumber(3)
  void clearVariables() => clearField(3);
  @$pb.TagNumber(3)
  $1.Struct ensureVariables() => $_ensure(2);
}

/// The ExecuteQuery response from Firebase Data Connect.
class ExecuteQueryResponse extends $pb.GeneratedMessage {
  factory ExecuteQueryResponse({
    $1.Struct? data,
    $core.Iterable<$3.GraphqlError>? errors,
    $4.GraphqlResponseExtensions? extensions,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (errors != null) {
      $result.errors.addAll(errors);
    }
    if (extensions != null) {
      $result.extensions = extensions;
    }
    return $result;
  }
  ExecuteQueryResponse._() : super();
  factory ExecuteQueryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExecuteQueryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExecuteQueryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.firebase.dataconnect.v1'), createEmptyInstance: create)
    ..aOM<$1.Struct>(1, _omitFieldNames ? '' : 'data', subBuilder: $1.Struct.create)
    ..pc<$3.GraphqlError>(2, _omitFieldNames ? '' : 'errors', $pb.PbFieldType.PM, subBuilder: $3.GraphqlError.create)
    ..aOM<$4.GraphqlResponseExtensions>(3, _omitFieldNames ? '' : 'extensions', subBuilder: $4.GraphqlResponseExtensions.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExecuteQueryResponse clone() => ExecuteQueryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExecuteQueryResponse copyWith(void Function(ExecuteQueryResponse) updates) => super.copyWith((message) => updates(message as ExecuteQueryResponse)) as ExecuteQueryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteQueryResponse create() => ExecuteQueryResponse._();
  ExecuteQueryResponse createEmptyInstance() => create();
  static $pb.PbList<ExecuteQueryResponse> createRepeated() => $pb.PbList<ExecuteQueryResponse>();
  @$core.pragma('dart2js:noInline')
  static ExecuteQueryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExecuteQueryResponse>(create);
  static ExecuteQueryResponse? _defaultInstance;

  /// The result of executing the requested operation.
  @$pb.TagNumber(1)
  $1.Struct get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($1.Struct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  $1.Struct ensureData() => $_ensure(0);

  /// Errors of this response.
  @$pb.TagNumber(2)
  $core.List<$3.GraphqlError> get errors => $_getList(1);

  /// Additional response information.
  @$pb.TagNumber(3)
  $4.GraphqlResponseExtensions get extensions => $_getN(2);
  @$pb.TagNumber(3)
  set extensions($4.GraphqlResponseExtensions v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasExtensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearExtensions() => clearField(3);
  @$pb.TagNumber(3)
  $4.GraphqlResponseExtensions ensureExtensions() => $_ensure(2);
}

/// The ExecuteMutation response from Firebase Data Connect.
class ExecuteMutationResponse extends $pb.GeneratedMessage {
  factory ExecuteMutationResponse({
    $1.Struct? data,
    $core.Iterable<$3.GraphqlError>? errors,
    $4.GraphqlResponseExtensions? extensions,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (errors != null) {
      $result.errors.addAll(errors);
    }
    if (extensions != null) {
      $result.extensions = extensions;
    }
    return $result;
  }
  ExecuteMutationResponse._() : super();
  factory ExecuteMutationResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExecuteMutationResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExecuteMutationResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.firebase.dataconnect.v1'), createEmptyInstance: create)
    ..aOM<$1.Struct>(1, _omitFieldNames ? '' : 'data', subBuilder: $1.Struct.create)
    ..pc<$3.GraphqlError>(2, _omitFieldNames ? '' : 'errors', $pb.PbFieldType.PM, subBuilder: $3.GraphqlError.create)
    ..aOM<$4.GraphqlResponseExtensions>(3, _omitFieldNames ? '' : 'extensions', subBuilder: $4.GraphqlResponseExtensions.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExecuteMutationResponse clone() => ExecuteMutationResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExecuteMutationResponse copyWith(void Function(ExecuteMutationResponse) updates) => super.copyWith((message) => updates(message as ExecuteMutationResponse)) as ExecuteMutationResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteMutationResponse create() => ExecuteMutationResponse._();
  ExecuteMutationResponse createEmptyInstance() => create();
  static $pb.PbList<ExecuteMutationResponse> createRepeated() => $pb.PbList<ExecuteMutationResponse>();
  @$core.pragma('dart2js:noInline')
  static ExecuteMutationResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExecuteMutationResponse>(create);
  static ExecuteMutationResponse? _defaultInstance;

  /// The result of executing the requested operation.
  @$pb.TagNumber(1)
  $1.Struct get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($1.Struct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);
  @$pb.TagNumber(1)
  $1.Struct ensureData() => $_ensure(0);

  /// Errors of this response.
  @$pb.TagNumber(2)
  $core.List<$3.GraphqlError> get errors => $_getList(1);

  /// Additional response information.
  @$pb.TagNumber(3)
  $4.GraphqlResponseExtensions get extensions => $_getN(2);
  @$pb.TagNumber(3)
  set extensions($4.GraphqlResponseExtensions v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasExtensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearExtensions() => clearField(3);
  @$pb.TagNumber(3)
  $4.GraphqlResponseExtensions ensureExtensions() => $_ensure(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
