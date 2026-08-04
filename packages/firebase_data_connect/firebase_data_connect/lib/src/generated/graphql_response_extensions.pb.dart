// This is a generated file - do not edit.
//
// Generated from graphql_response_extensions.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Data Connect specific properties for a path under response.data.
/// (-- Design doc: http://go/fdc-caching-wire-protocol --)
class GraphqlResponseExtensions_DataConnectProperties
    extends $pb.GeneratedMessage {
  factory GraphqlResponseExtensions_DataConnectProperties({
    $0.ListValue? path,
    $core.String? entityId,
    $core.Iterable<$core.String>? entityIds,
    $1.Duration? maxAge,
  }) {
    final result = create();
    if (path != null) result.path = path;
    if (entityId != null) result.entityId = entityId;
    if (entityIds != null) result.entityIds.addAll(entityIds);
    if (maxAge != null) result.maxAge = maxAge;
    return result;
  }

  GraphqlResponseExtensions_DataConnectProperties._();

  factory GraphqlResponseExtensions_DataConnectProperties.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GraphqlResponseExtensions_DataConnectProperties.fromJson(
          $core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames
          ? ''
          : 'GraphqlResponseExtensions.DataConnectProperties',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOM<$0.ListValue>(1, _omitFieldNames ? '' : 'path',
        subBuilder: $0.ListValue.create)
    ..aOS(2, _omitFieldNames ? '' : 'entityId')
    ..pPS(3, _omitFieldNames ? '' : 'entityIds')
    ..aOM<$1.Duration>(4, _omitFieldNames ? '' : 'maxAge',
        subBuilder: $1.Duration.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlResponseExtensions_DataConnectProperties clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlResponseExtensions_DataConnectProperties copyWith(
          void Function(GraphqlResponseExtensions_DataConnectProperties)
              updates) =>
      super.copyWith((message) => updates(
              message as GraphqlResponseExtensions_DataConnectProperties))
          as GraphqlResponseExtensions_DataConnectProperties;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlResponseExtensions_DataConnectProperties create() =>
      GraphqlResponseExtensions_DataConnectProperties._();
  @$core.override
  GraphqlResponseExtensions_DataConnectProperties createEmptyInstance() =>
      create();
  @$core.pragma('dart2js:noInline')
  static GraphqlResponseExtensions_DataConnectProperties getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GraphqlResponseExtensions_DataConnectProperties>(create);
  static GraphqlResponseExtensions_DataConnectProperties? _defaultInstance;

  /// The path under response.data where the rest of the fields apply.
  /// Each element may be a string (field name) or number (array index).
  /// The root of response.data is denoted by the empty list `[]`.
  /// (-- To simplify client logic, the server should never set this to null.
  /// i.e. Use `[]` if the properties below apply to everything in data. --)
  @$pb.TagNumber(1)
  $0.ListValue get path => $_getN(0);
  @$pb.TagNumber(1)
  set path($0.ListValue value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ListValue ensurePath() => $_ensure(0);

  /// A single Entity ID. Set if the path points to a single entity.
  @$pb.TagNumber(2)
  $core.String get entityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityId() => $_clearField(2);

  /// A list of Entity IDs. Set if the path points to an array of entities. An
  /// ID is present for each element of the array at the corresponding index.
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get entityIds => $_getList(2);

  /// The server-suggested duration before data under path is considered stale.
  /// (-- Right now, this field is never set. For future plans, see
  /// http://go/fdc-sdk-caching-config#heading=h.rmvncy2rao3g --)
  @$pb.TagNumber(4)
  $1.Duration get maxAge => $_getN(3);
  @$pb.TagNumber(4)
  set maxAge($1.Duration value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxAge() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxAge() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.Duration ensureMaxAge() => $_ensure(3);
}

/// GraphqlResponseExtensions contains additional information of
/// `GraphqlResponse` or `ExecuteQueryResponse`.
class GraphqlResponseExtensions extends $pb.GeneratedMessage {
  factory GraphqlResponseExtensions({
    $core.Iterable<GraphqlResponseExtensions_DataConnectProperties>?
        dataConnect,
  }) {
    final result = create();
    if (dataConnect != null) result.dataConnect.addAll(dataConnect);
    return result;
  }

  GraphqlResponseExtensions._();

  factory GraphqlResponseExtensions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GraphqlResponseExtensions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GraphqlResponseExtensions',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..pPM<GraphqlResponseExtensions_DataConnectProperties>(
        1, _omitFieldNames ? '' : 'dataConnect',
        subBuilder: GraphqlResponseExtensions_DataConnectProperties.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlResponseExtensions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphqlResponseExtensions copyWith(
          void Function(GraphqlResponseExtensions) updates) =>
      super.copyWith((message) => updates(message as GraphqlResponseExtensions))
          as GraphqlResponseExtensions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlResponseExtensions create() => GraphqlResponseExtensions._();
  @$core.override
  GraphqlResponseExtensions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GraphqlResponseExtensions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GraphqlResponseExtensions>(create);
  static GraphqlResponseExtensions? _defaultInstance;

  /// Data Connect specific GraphQL extension, a list of paths and properties.
  /// (-- Future fields should go inside to avoid name conflicts with other GQL
  /// extensions in the wild unless we're implementing a common 3P pattern in
  /// extensions such as versioning and telemetry. --)
  @$pb.TagNumber(1)
  $pb.PbList<GraphqlResponseExtensions_DataConnectProperties> get dataConnect =>
      $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
