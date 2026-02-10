//
//  Generated code. Do not modify.
//  source: graphql_response_extensions.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/duration.pb.dart' as $2;
import 'google/protobuf/struct.pb.dart' as $1;

/// Data Connect specific properties for a path under response.data.
/// (-- Design doc: http://go/fdc-caching-wire-protocol --)
class GraphqlResponseExtensions_DataConnectProperties
    extends $pb.GeneratedMessage {
  factory GraphqlResponseExtensions_DataConnectProperties({
    $1.ListValue? path,
    $core.String? entityId,
    $core.Iterable<$core.String>? entityIds,
    $2.Duration? maxAge,
  }) {
    final $result = create();
    if (path != null) {
      $result.path = path;
    }
    if (entityId != null) {
      $result.entityId = entityId;
    }
    if (entityIds != null) {
      $result.entityIds.addAll(entityIds);
    }
    if (maxAge != null) {
      $result.maxAge = maxAge;
    }
    return $result;
  }
  GraphqlResponseExtensions_DataConnectProperties._() : super();
  factory GraphqlResponseExtensions_DataConnectProperties.fromBuffer(
          $core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GraphqlResponseExtensions_DataConnectProperties.fromJson(
          $core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames
          ? ''
          : 'GraphqlResponseExtensions.DataConnectProperties',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..aOM<$1.ListValue>(1, _omitFieldNames ? '' : 'path',
        subBuilder: $1.ListValue.create)
    ..aOS(2, _omitFieldNames ? '' : 'entityId')
    ..pPS(3, _omitFieldNames ? '' : 'entityIds')
    ..aOM<$2.Duration>(4, _omitFieldNames ? '' : 'maxAge',
        subBuilder: $2.Duration.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GraphqlResponseExtensions_DataConnectProperties clone() =>
      GraphqlResponseExtensions_DataConnectProperties()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GraphqlResponseExtensions_DataConnectProperties copyWith(
          void Function(GraphqlResponseExtensions_DataConnectProperties)
              updates) =>
      super.copyWith((message) => updates(
              message as GraphqlResponseExtensions_DataConnectProperties))
          as GraphqlResponseExtensions_DataConnectProperties;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlResponseExtensions_DataConnectProperties create() =>
      GraphqlResponseExtensions_DataConnectProperties._();
  GraphqlResponseExtensions_DataConnectProperties createEmptyInstance() =>
      create();
  static $pb.PbList<GraphqlResponseExtensions_DataConnectProperties>
      createRepeated() =>
          $pb.PbList<GraphqlResponseExtensions_DataConnectProperties>();
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
  $1.ListValue get path => $_getN(0);
  @$pb.TagNumber(1)
  set path($1.ListValue v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);
  @$pb.TagNumber(1)
  $1.ListValue ensurePath() => $_ensure(0);

  /// A single Entity ID. Set if the path points to a single entity.
  @$pb.TagNumber(2)
  $core.String get entityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasEntityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityId() => clearField(2);

  /// A list of Entity IDs. Set if the path points to an array of entities. An
  /// ID is present for each element of the array at the corresponding index.
  @$pb.TagNumber(3)
  $core.List<$core.String> get entityIds => $_getList(2);

  /// The server-suggested duration before data under path is considered stale.
  /// (-- Right now, this field is never set. For future plans, see
  /// http://go/fdc-sdk-caching-config#heading=h.rmvncy2rao3g --)
  @$pb.TagNumber(4)
  $2.Duration get maxAge => $_getN(3);
  @$pb.TagNumber(4)
  set maxAge($2.Duration v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasMaxAge() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxAge() => clearField(4);
  @$pb.TagNumber(4)
  $2.Duration ensureMaxAge() => $_ensure(3);
}

/// GraphqlResponseExtensions contains additional information of
/// `GraphqlResponse` or `ExecuteQueryResponse`.
class GraphqlResponseExtensions extends $pb.GeneratedMessage {
  factory GraphqlResponseExtensions({
    $core.Iterable<GraphqlResponseExtensions_DataConnectProperties>?
        dataConnect,
  }) {
    final $result = create();
    if (dataConnect != null) {
      $result.dataConnect.addAll(dataConnect);
    }
    return $result;
  }
  GraphqlResponseExtensions._() : super();
  factory GraphqlResponseExtensions.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GraphqlResponseExtensions.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GraphqlResponseExtensions',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'google.firebase.dataconnect.v1'),
      createEmptyInstance: create)
    ..pc<GraphqlResponseExtensions_DataConnectProperties>(
        1, _omitFieldNames ? '' : 'dataConnect', $pb.PbFieldType.PM,
        subBuilder: GraphqlResponseExtensions_DataConnectProperties.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GraphqlResponseExtensions clone() =>
      GraphqlResponseExtensions()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GraphqlResponseExtensions copyWith(
          void Function(GraphqlResponseExtensions) updates) =>
      super.copyWith((message) => updates(message as GraphqlResponseExtensions))
          as GraphqlResponseExtensions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GraphqlResponseExtensions create() => GraphqlResponseExtensions._();
  GraphqlResponseExtensions createEmptyInstance() => create();
  static $pb.PbList<GraphqlResponseExtensions> createRepeated() =>
      $pb.PbList<GraphqlResponseExtensions>();
  @$core.pragma('dart2js:noInline')
  static GraphqlResponseExtensions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GraphqlResponseExtensions>(create);
  static GraphqlResponseExtensions? _defaultInstance;

  /// Data Connect specific GraphQL extension, a list of paths and properties.
  /// (-- Future fields should go inside to avoid name conflicts with other GQL
  /// extensions in the wild unless we're implementing a common 3P pattern in
  /// extensions such as versioning and telemetry. --)
  @$pb.TagNumber(1)
  $core.List<GraphqlResponseExtensions_DataConnectProperties> get dataConnect =>
      $_getList(0);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
