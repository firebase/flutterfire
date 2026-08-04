// This is a generated file - do not edit.
//
// Generated from graphql_error.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// GraphqlError conforms to the GraphQL error spec.
/// https://spec.graphql.org/draft/#sec-Errors
///
/// Firebase Data Connect API surfaces `GraphqlError` in various APIs:
/// - Upon compile error, `UpdateSchema` and `UpdateConnector` return
/// Code.Invalid_Argument with a list of `GraphqlError` in error details.
/// - Upon query compile error, `ExecuteGraphql` and `ExecuteGraphqlRead` return
/// Code.OK with a list of `GraphqlError` in response body.
/// - Upon query execution error, `ExecuteGraphql`, `ExecuteGraphqlRead`,
/// `ExecuteMutation` and `ExecuteQuery` all return Code.OK with a list of
/// `GraphqlError` in response body.
class GraphqlError extends $pb.GeneratedMessage {
  factory GraphqlError({
    $core.String? message,
    $core.Iterable<SourceLocation>? locations,
    $0.ListValue? path,
    GraphqlErrorExtensions? extensions,
  }) {
    final result = create();
    if (message != null) result.message = message;
    if (locations != null) result.locations.addAll(locations);
    if (path != null) result.path = path;
    if (extensions != null) result.extensions = extensions;
    return result;
  }

  GraphqlError._();

  factory GraphqlError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GraphqlError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GraphqlError',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..pPM<SourceLocation>(2, _omitFieldNames ? '' : 'locations',
        subBuilder: SourceLocation.create)
    ..aOM<$0.ListValue>(3, _omitFieldNames ? '' : 'path',
        subBuilder: $0.ListValue.create)
    ..aOM<GraphqlErrorExtensions>(4, _omitFieldNames ? '' : 'extensions',
        subBuilder: GraphqlErrorExtensions.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlError copyWith(void Function(GraphqlError) updates) =>
      super.copyWith((message) => updates(message as GraphqlError))
          as GraphqlError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlError create() => GraphqlError._();
  @$core.override
  GraphqlError createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GraphqlError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GraphqlError>(create);
  static GraphqlError? _defaultInstance;

  /// The detailed error message.
  /// The message should help developer understand the underlying problem without
  /// leaking internal data.
  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);

  /// The source locations where the error occurred.
  /// Locations should help developers and toolings identify the source of error
  /// quickly.
  ///
  /// Included in admin endpoints (`ExecuteGraphql`, `ExecuteGraphqlRead`,
  /// `UpdateSchema` and `UpdateConnector`) to reference the provided GraphQL
  /// GQL document.
  ///
  /// Omitted in `ExecuteMutation` and `ExecuteQuery` since the caller shouldn't
  /// have access access the underlying GQL source.
  @$pb.TagNumber(2)
  $pb.PbList<SourceLocation> get locations => $_getList(1);

  /// The result field which could not be populated due to error.
  ///
  /// Clients can use path to identify whether a null result is intentional or
  /// caused by a runtime error.
  /// It should be a list of string or index from the root of GraphQL query
  /// document.
  @$pb.TagNumber(3)
  $0.ListValue get path => $_getN(2);
  @$pb.TagNumber(3)
  set path($0.ListValue value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.ListValue ensurePath() => $_ensure(2);

  /// Additional error information.
  @$pb.TagNumber(4)
  GraphqlErrorExtensions get extensions => $_getN(3);
  @$pb.TagNumber(4)
  set extensions(GraphqlErrorExtensions value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasExtensions() => $_has(3);
  @$pb.TagNumber(4)
  void clearExtensions() => $_clearField(4);
  @$pb.TagNumber(4)
  GraphqlErrorExtensions ensureExtensions() => $_ensure(3);
}

/// SourceLocation references a location in a GraphQL source.
class SourceLocation extends $pb.GeneratedMessage {
  factory SourceLocation({
    $core.int? line,
    $core.int? column,
  }) {
    final result = create();
    if (line != null) result.line = line;
    if (column != null) result.column = column;
    return result;
  }

  SourceLocation._();

  factory SourceLocation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SourceLocation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SourceLocation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'line')
    ..aI(2, _omitFieldNames ? '' : 'column')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SourceLocation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SourceLocation copyWith(void Function(SourceLocation) updates) =>
      super.copyWith((message) => updates(message as SourceLocation))
          as SourceLocation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SourceLocation create() => SourceLocation._();
  @$core.override
  SourceLocation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SourceLocation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SourceLocation>(create);
  static SourceLocation? _defaultInstance;

  /// Line number starting at 1.
  @$pb.TagNumber(1)
  $core.int get line => $_getIZ(0);
  @$pb.TagNumber(1)
  set line($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLine() => $_has(0);
  @$pb.TagNumber(1)
  void clearLine() => $_clearField(1);

  /// Column number starting at 1.
  @$pb.TagNumber(2)
  $core.int get column => $_getIZ(1);
  @$pb.TagNumber(2)
  set column($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasColumn() => $_has(1);
  @$pb.TagNumber(2)
  void clearColumn() => $_clearField(2);
}

/// GraphqlErrorExtensions contains additional information of `GraphqlError`.
/// (-- TODO(b/305311379): include more detailed error fields:
/// go/firemat:api:gql-errors.  --)
class GraphqlErrorExtensions extends $pb.GeneratedMessage {
  factory GraphqlErrorExtensions({
    $core.String? file,
  }) {
    final result = create();
    if (file != null) result.file = file;
    return result;
  }

  GraphqlErrorExtensions._();

  factory GraphqlErrorExtensions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GraphqlErrorExtensions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GraphqlErrorExtensions',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'file')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlErrorExtensions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlErrorExtensions copyWith(
          void Function(GraphqlErrorExtensions) updates) =>
      super.copyWith((message) => updates(message as GraphqlErrorExtensions))
          as GraphqlErrorExtensions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlErrorExtensions create() => GraphqlErrorExtensions._();
  @$core.override
  GraphqlErrorExtensions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GraphqlErrorExtensions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GraphqlErrorExtensions>(create);
  static GraphqlErrorExtensions? _defaultInstance;

  /// The source file name where the error occurred.
  /// Included only for `UpdateSchema` and `UpdateConnector`, it corresponds
  /// to `File.path` of the provided `Source`.
  @$pb.TagNumber(1)
  $core.String get file => $_getSZ(0);
  @$pb.TagNumber(1)
  set file($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
