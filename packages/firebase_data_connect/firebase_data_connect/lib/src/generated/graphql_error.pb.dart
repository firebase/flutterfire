//
//  Generated code. Do not modify.
//  source: graphql_error.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/struct.pb.dart' as $1;

///  GraphqlError conforms to the GraphQL error spec.
///  https://spec.graphql.org/draft/#sec-Errors
///
///  Firebase Data Connect API surfaces `GraphqlError` in various APIs:
///  - Upon compile error, `UpdateSchema` and `UpdateConnector` return
///  Code.Invalid_Argument with a list of `GraphqlError` in error details.
///  - Upon query compile error, `ExecuteGraphql` and `ExecuteGraphqlRead` return
///  Code.OK with a list of `GraphqlError` in response body.
///  - Upon query execution error, `ExecuteGraphql`, `ExecuteGraphqlRead`,
///  `ExecuteMutation` and `ExecuteQuery` all return Code.OK with a list of
///  `GraphqlError` in response body.
class GraphqlError extends $pb.GeneratedMessage {
  factory GraphqlError({
    $core.String? message,
    $core.Iterable<SourceLocation>? locations,
    $1.ListValue? path,
    GraphqlErrorExtensions? extensions,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (locations != null) {
      $result.locations.addAll(locations);
    }
    if (path != null) {
      $result.path = path;
    }
    if (extensions != null) {
      $result.extensions = extensions;
    }
    return $result;
  }
  GraphqlError._() : super();
  factory GraphqlError.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GraphqlError.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GraphqlError', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.firebase.dataconnect.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..pc<SourceLocation>(2, _omitFieldNames ? '' : 'locations', $pb.PbFieldType.PM, subBuilder: SourceLocation.create)
    ..aOM<$1.ListValue>(3, _omitFieldNames ? '' : 'path', subBuilder: $1.ListValue.create)
    ..aOM<GraphqlErrorExtensions>(4, _omitFieldNames ? '' : 'extensions', subBuilder: GraphqlErrorExtensions.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GraphqlError clone() => GraphqlError()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GraphqlError copyWith(void Function(GraphqlError) updates) => super.copyWith((message) => updates(message as GraphqlError)) as GraphqlError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlError create() => GraphqlError._();
  GraphqlError createEmptyInstance() => create();
  static $pb.PbList<GraphqlError> createRepeated() => $pb.PbList<GraphqlError>();
  @$core.pragma('dart2js:noInline')
  static GraphqlError getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GraphqlError>(create);
  static GraphqlError? _defaultInstance;

  /// The detailed error message.
  /// The message should help developer understand the underlying problem without
  /// leaking internal data.
  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);

  ///  The source locations where the error occurred.
  ///  Locations should help developers and toolings identify the source of error
  ///  quickly.
  ///
  ///  Included in admin endpoints (`ExecuteGraphql`, `ExecuteGraphqlRead`,
  ///  `UpdateSchema` and `UpdateConnector`) to reference the provided GraphQL
  ///  GQL document.
  ///
  ///  Omitted in `ExecuteMutation` and `ExecuteQuery` since the caller shouldn't
  ///  have access access the underlying GQL source.
  @$pb.TagNumber(2)
  $core.List<SourceLocation> get locations => $_getList(1);

  ///  The result field which could not be populated due to error.
  ///
  ///  Clients can use path to identify whether a null result is intentional or
  ///  caused by a runtime error.
  ///  It should be a list of string or index from the root of GraphQL query
  ///  document.
  @$pb.TagNumber(3)
  $1.ListValue get path => $_getN(2);
  @$pb.TagNumber(3)
  set path($1.ListValue v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => clearField(3);
  @$pb.TagNumber(3)
  $1.ListValue ensurePath() => $_ensure(2);

  /// Additional error information.
  @$pb.TagNumber(4)
  GraphqlErrorExtensions get extensions => $_getN(3);
  @$pb.TagNumber(4)
  set extensions(GraphqlErrorExtensions v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasExtensions() => $_has(3);
  @$pb.TagNumber(4)
  void clearExtensions() => clearField(4);
  @$pb.TagNumber(4)
  GraphqlErrorExtensions ensureExtensions() => $_ensure(3);
}

/// SourceLocation references a location in a GraphQL source.
class SourceLocation extends $pb.GeneratedMessage {
  factory SourceLocation({
    $core.int? line,
    $core.int? column,
  }) {
    final $result = create();
    if (line != null) {
      $result.line = line;
    }
    if (column != null) {
      $result.column = column;
    }
    return $result;
  }
  SourceLocation._() : super();
  factory SourceLocation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SourceLocation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SourceLocation', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.firebase.dataconnect.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'line', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'column', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SourceLocation clone() => SourceLocation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SourceLocation copyWith(void Function(SourceLocation) updates) => super.copyWith((message) => updates(message as SourceLocation)) as SourceLocation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SourceLocation create() => SourceLocation._();
  SourceLocation createEmptyInstance() => create();
  static $pb.PbList<SourceLocation> createRepeated() => $pb.PbList<SourceLocation>();
  @$core.pragma('dart2js:noInline')
  static SourceLocation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SourceLocation>(create);
  static SourceLocation? _defaultInstance;

  /// Line number starting at 1.
  @$pb.TagNumber(1)
  $core.int get line => $_getIZ(0);
  @$pb.TagNumber(1)
  set line($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLine() => $_has(0);
  @$pb.TagNumber(1)
  void clearLine() => clearField(1);

  /// Column number starting at 1.
  @$pb.TagNumber(2)
  $core.int get column => $_getIZ(1);
  @$pb.TagNumber(2)
  set column($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasColumn() => $_has(1);
  @$pb.TagNumber(2)
  void clearColumn() => clearField(2);
}

/// GraphqlErrorExtensions contains additional information of `GraphqlError`.
/// (-- TODO(b/305311379): include more detailed error fields:
/// go/firemat:api:gql-errors.  --)
class GraphqlErrorExtensions extends $pb.GeneratedMessage {
  factory GraphqlErrorExtensions({
    $core.String? file,
  }) {
    final $result = create();
    if (file != null) {
      $result.file = file;
    }
    return $result;
  }
  GraphqlErrorExtensions._() : super();
  factory GraphqlErrorExtensions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GraphqlErrorExtensions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GraphqlErrorExtensions', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.firebase.dataconnect.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'file')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GraphqlErrorExtensions clone() => GraphqlErrorExtensions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GraphqlErrorExtensions copyWith(void Function(GraphqlErrorExtensions) updates) => super.copyWith((message) => updates(message as GraphqlErrorExtensions)) as GraphqlErrorExtensions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlErrorExtensions create() => GraphqlErrorExtensions._();
  GraphqlErrorExtensions createEmptyInstance() => create();
  static $pb.PbList<GraphqlErrorExtensions> createRepeated() => $pb.PbList<GraphqlErrorExtensions>();
  @$core.pragma('dart2js:noInline')
  static GraphqlErrorExtensions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GraphqlErrorExtensions>(create);
  static GraphqlErrorExtensions? _defaultInstance;

  /// The source file name where the error occurred.
  /// Included only for `UpdateSchema` and `UpdateConnector`, it corresponds
  /// to `File.path` of the provided `Source`.
  @$pb.TagNumber(1)
  $core.String get file => $_getSZ(0);
  @$pb.TagNumber(1)
  set file($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
