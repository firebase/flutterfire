// This is a generated file - do not edit.
//
// Generated from connector_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $1;

import 'graphql_error.pb.dart' as $2;
import 'graphql_response_extensions.pb.dart' as $3;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// The ExecuteQuery request to Firebase Data Connect.
class ExecuteQueryRequest extends $pb.GeneratedMessage {
  factory ExecuteQueryRequest({
    $core.String? name,
    $core.String? operationName,
    $1.Struct? variables,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (operationName != null) result.operationName = operationName;
    if (variables != null) result.variables = variables;
    return result;
  }

  ExecuteQueryRequest._();

  factory ExecuteQueryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecuteQueryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecuteQueryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'operationName')
    ..aOM<$1.Struct>(3, _omitFieldNames ? '' : 'variables',
        subBuilder: $1.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteQueryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteQueryRequest copyWith(void Function(ExecuteQueryRequest) updates) =>
      super.copyWith((message) => updates(message as ExecuteQueryRequest))
          as ExecuteQueryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteQueryRequest create() => ExecuteQueryRequest._();
  @$core.override
  ExecuteQueryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecuteQueryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecuteQueryRequest>(create);
  static ExecuteQueryRequest? _defaultInstance;

  /// The resource name of the connector to find the predefined query, in
  /// the format:
  /// ```
  /// projects/{project}/locations/{location}/services/{service}/connectors/{connector}
  /// ```
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// The name of the GraphQL operation name.
  /// Required because all Connector operations must be named.
  /// See https://graphql.org/learn/queries/#operation-name.
  /// (-- api-linter: core::0122::name-suffix=disabled
  ///     aip.dev/not-precedent: Must conform to GraphQL HTTP spec standard. --)
  @$pb.TagNumber(2)
  $core.String get operationName => $_getSZ(1);
  @$pb.TagNumber(2)
  set operationName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperationName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperationName() => $_clearField(2);

  /// Values for GraphQL variables provided in this request.
  @$pb.TagNumber(3)
  $1.Struct get variables => $_getN(2);
  @$pb.TagNumber(3)
  set variables($1.Struct value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVariables() => $_has(2);
  @$pb.TagNumber(3)
  void clearVariables() => $_clearField(3);
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
    final result = create();
    if (name != null) result.name = name;
    if (operationName != null) result.operationName = operationName;
    if (variables != null) result.variables = variables;
    return result;
  }

  ExecuteMutationRequest._();

  factory ExecuteMutationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecuteMutationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecuteMutationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'operationName')
    ..aOM<$1.Struct>(3, _omitFieldNames ? '' : 'variables',
        subBuilder: $1.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteMutationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteMutationRequest copyWith(
          void Function(ExecuteMutationRequest) updates) =>
      super.copyWith((message) => updates(message as ExecuteMutationRequest))
          as ExecuteMutationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteMutationRequest create() => ExecuteMutationRequest._();
  @$core.override
  ExecuteMutationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecuteMutationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecuteMutationRequest>(create);
  static ExecuteMutationRequest? _defaultInstance;

  /// The resource name of the connector to find the predefined mutation, in
  /// the format:
  /// ```
  /// projects/{project}/locations/{location}/services/{service}/connectors/{connector}
  /// ```
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// The name of the GraphQL operation name.
  /// Required because all Connector operations must be named.
  /// See https://graphql.org/learn/queries/#operation-name.
  /// (-- api-linter: core::0122::name-suffix=disabled
  ///     aip.dev/not-precedent: Must conform to GraphQL HTTP spec standard. --)
  @$pb.TagNumber(2)
  $core.String get operationName => $_getSZ(1);
  @$pb.TagNumber(2)
  set operationName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOperationName() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperationName() => $_clearField(2);

  /// Values for GraphQL variables provided in this request.
  @$pb.TagNumber(3)
  $1.Struct get variables => $_getN(2);
  @$pb.TagNumber(3)
  set variables($1.Struct value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVariables() => $_has(2);
  @$pb.TagNumber(3)
  void clearVariables() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Struct ensureVariables() => $_ensure(2);
}

/// The ExecuteQuery response from Firebase Data Connect.
class ExecuteQueryResponse extends $pb.GeneratedMessage {
  factory ExecuteQueryResponse({
    $1.Struct? data,
    $core.Iterable<$2.GraphqlError>? errors,
    $3.GraphqlResponseExtensions? extensions,
  }) {
    final result = create();
    if (data != null) result.data = data;
    if (errors != null) result.errors.addAll(errors);
    if (extensions != null) result.extensions = extensions;
    return result;
  }

  ExecuteQueryResponse._();

  factory ExecuteQueryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecuteQueryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecuteQueryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Struct>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $1.Struct.create)
    ..pPM<$2.GraphqlError>(2, _omitFieldNames ? '' : 'errors',
        subBuilder: $2.GraphqlError.create)
    ..aOM<$3.GraphqlResponseExtensions>(3, _omitFieldNames ? '' : 'extensions',
        subBuilder: $3.GraphqlResponseExtensions.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteQueryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteQueryResponse copyWith(void Function(ExecuteQueryResponse) updates) =>
      super.copyWith((message) => updates(message as ExecuteQueryResponse))
          as ExecuteQueryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteQueryResponse create() => ExecuteQueryResponse._();
  @$core.override
  ExecuteQueryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecuteQueryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecuteQueryResponse>(create);
  static ExecuteQueryResponse? _defaultInstance;

  /// The result of executing the requested operation.
  @$pb.TagNumber(1)
  $1.Struct get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($1.Struct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Struct ensureData() => $_ensure(0);

  /// Errors of this response.
  @$pb.TagNumber(2)
  $pb.PbList<$2.GraphqlError> get errors => $_getList(1);

  /// Additional response information.
  @$pb.TagNumber(3)
  $3.GraphqlResponseExtensions get extensions => $_getN(2);
  @$pb.TagNumber(3)
  set extensions($3.GraphqlResponseExtensions value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExtensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearExtensions() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.GraphqlResponseExtensions ensureExtensions() => $_ensure(2);
}

/// The ExecuteMutation response from Firebase Data Connect.
class ExecuteMutationResponse extends $pb.GeneratedMessage {
  factory ExecuteMutationResponse({
    $1.Struct? data,
    $core.Iterable<$2.GraphqlError>? errors,
    $3.GraphqlResponseExtensions? extensions,
  }) {
    final result = create();
    if (data != null) result.data = data;
    if (errors != null) result.errors.addAll(errors);
    if (extensions != null) result.extensions = extensions;
    return result;
  }

  ExecuteMutationResponse._();

  factory ExecuteMutationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExecuteMutationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExecuteMutationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Struct>(1, _omitFieldNames ? '' : 'data',
        subBuilder: $1.Struct.create)
    ..pPM<$2.GraphqlError>(2, _omitFieldNames ? '' : 'errors',
        subBuilder: $2.GraphqlError.create)
    ..aOM<$3.GraphqlResponseExtensions>(3, _omitFieldNames ? '' : 'extensions',
        subBuilder: $3.GraphqlResponseExtensions.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteMutationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecuteMutationResponse copyWith(
          void Function(ExecuteMutationResponse) updates) =>
      super.copyWith((message) => updates(message as ExecuteMutationResponse))
          as ExecuteMutationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecuteMutationResponse create() => ExecuteMutationResponse._();
  @$core.override
  ExecuteMutationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExecuteMutationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExecuteMutationResponse>(create);
  static ExecuteMutationResponse? _defaultInstance;

  /// The result of executing the requested operation.
  @$pb.TagNumber(1)
  $1.Struct get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($1.Struct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Struct ensureData() => $_ensure(0);

  /// Errors of this response.
  @$pb.TagNumber(2)
  $pb.PbList<$2.GraphqlError> get errors => $_getList(1);

  /// Additional response information.
  @$pb.TagNumber(3)
  $3.GraphqlResponseExtensions get extensions => $_getN(2);
  @$pb.TagNumber(3)
  set extensions($3.GraphqlResponseExtensions value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExtensions() => $_has(2);
  @$pb.TagNumber(3)
  void clearExtensions() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.GraphqlResponseExtensions ensureExtensions() => $_ensure(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
