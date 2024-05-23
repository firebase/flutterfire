//
//  Generated code. Do not modify.
//  source: google/protobuf/struct.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/src/protobuf/mixins/well_known.dart' as $mixin;

import 'struct.pbenum.dart';

export 'struct.pbenum.dart';

///  `Struct` represents a structured data value, consisting of fields
///  which map to dynamically typed values. In some languages, `Struct`
///  might be supported by a native representation. For example, in
///  scripting languages like JS a struct is represented as an
///  object. The details of that representation are described together
///  with the proto support for the language.
///
///  The JSON representation for `Struct` is JSON object.
class Struct extends $pb.GeneratedMessage with $mixin.StructMixin {
  factory Struct({
    $core.Map<$core.String, Value>? fields,
  }) {
    final $result = create();
    if (fields != null) {
      $result.fields.addAll(fields);
    }
    return $result;
  }
  Struct._() : super();
  factory Struct.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Struct.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Struct', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.protobuf'), createEmptyInstance: create, toProto3Json: $mixin.StructMixin.toProto3JsonHelper, fromProto3Json: $mixin.StructMixin.fromProto3JsonHelper)
    ..m<$core.String, Value>(1, _omitFieldNames ? '' : 'fields', entryClassName: 'Struct.FieldsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: Value.create, valueDefaultOrMaker: Value.getDefault, packageName: const $pb.PackageName('google.protobuf'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Struct clone() => Struct()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Struct copyWith(void Function(Struct) updates) => super.copyWith((message) => updates(message as Struct)) as Struct;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Struct create() => Struct._();
  Struct createEmptyInstance() => create();
  static $pb.PbList<Struct> createRepeated() => $pb.PbList<Struct>();
  @$core.pragma('dart2js:noInline')
  static Struct getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Struct>(create);
  static Struct? _defaultInstance;

  /// Unordered map of dynamically typed values.
  @$pb.TagNumber(1)
  $core.Map<$core.String, Value> get fields => $_getMap(0);
}

enum Value_Kind {
  nullValue, 
  numberValue, 
  stringValue, 
  boolValue, 
  structValue, 
  listValue, 
  notSet
}

///  `Value` represents a dynamically typed value which can be either
///  null, a number, a string, a boolean, a recursive struct value, or a
///  list of values. A producer of value is expected to set one of these
///  variants. Absence of any variant indicates an error.
///
///  The JSON representation for `Value` is JSON value.
class Value extends $pb.GeneratedMessage with $mixin.ValueMixin {
  factory Value({
    NullValue? nullValue,
    $core.double? numberValue,
    $core.String? stringValue,
    $core.bool? boolValue,
    Struct? structValue,
    ListValue? listValue,
  }) {
    final $result = create();
    if (nullValue != null) {
      $result.nullValue = nullValue;
    }
    if (numberValue != null) {
      $result.numberValue = numberValue;
    }
    if (stringValue != null) {
      $result.stringValue = stringValue;
    }
    if (boolValue != null) {
      $result.boolValue = boolValue;
    }
    if (structValue != null) {
      $result.structValue = structValue;
    }
    if (listValue != null) {
      $result.listValue = listValue;
    }
    return $result;
  }
  Value._() : super();
  factory Value.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Value.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Value_Kind> _Value_KindByTag = {
    1 : Value_Kind.nullValue,
    2 : Value_Kind.numberValue,
    3 : Value_Kind.stringValue,
    4 : Value_Kind.boolValue,
    5 : Value_Kind.structValue,
    6 : Value_Kind.listValue,
    0 : Value_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Value', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.protobuf'), createEmptyInstance: create, toProto3Json: $mixin.ValueMixin.toProto3JsonHelper, fromProto3Json: $mixin.ValueMixin.fromProto3JsonHelper)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..e<NullValue>(1, _omitFieldNames ? '' : 'nullValue', $pb.PbFieldType.OE, defaultOrMaker: NullValue.NULL_VALUE, valueOf: NullValue.valueOf, enumValues: NullValue.values)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'numberValue', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'stringValue')
    ..aOB(4, _omitFieldNames ? '' : 'boolValue')
    ..aOM<Struct>(5, _omitFieldNames ? '' : 'structValue', subBuilder: Struct.create)
    ..aOM<ListValue>(6, _omitFieldNames ? '' : 'listValue', subBuilder: ListValue.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Value clone() => Value()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Value copyWith(void Function(Value) updates) => super.copyWith((message) => updates(message as Value)) as Value;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Value create() => Value._();
  Value createEmptyInstance() => create();
  static $pb.PbList<Value> createRepeated() => $pb.PbList<Value>();
  @$core.pragma('dart2js:noInline')
  static Value getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Value>(create);
  static Value? _defaultInstance;

  Value_Kind whichKind() => _Value_KindByTag[$_whichOneof(0)]!;
  void clearKind() => clearField($_whichOneof(0));

  /// Represents a null value.
  @$pb.TagNumber(1)
  NullValue get nullValue => $_getN(0);
  @$pb.TagNumber(1)
  set nullValue(NullValue v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNullValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearNullValue() => clearField(1);

  /// Represents a double value.
  @$pb.TagNumber(2)
  $core.double get numberValue => $_getN(1);
  @$pb.TagNumber(2)
  set numberValue($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNumberValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumberValue() => clearField(2);

  /// Represents a string value.
  @$pb.TagNumber(3)
  $core.String get stringValue => $_getSZ(2);
  @$pb.TagNumber(3)
  set stringValue($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStringValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearStringValue() => clearField(3);

  /// Represents a boolean value.
  @$pb.TagNumber(4)
  $core.bool get boolValue => $_getBF(3);
  @$pb.TagNumber(4)
  set boolValue($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBoolValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearBoolValue() => clearField(4);

  /// Represents a structured value.
  @$pb.TagNumber(5)
  Struct get structValue => $_getN(4);
  @$pb.TagNumber(5)
  set structValue(Struct v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasStructValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearStructValue() => clearField(5);
  @$pb.TagNumber(5)
  Struct ensureStructValue() => $_ensure(4);

  /// Represents a repeated `Value`.
  @$pb.TagNumber(6)
  ListValue get listValue => $_getN(5);
  @$pb.TagNumber(6)
  set listValue(ListValue v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasListValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearListValue() => clearField(6);
  @$pb.TagNumber(6)
  ListValue ensureListValue() => $_ensure(5);
}

///  `ListValue` is a wrapper around a repeated field of values.
///
///  The JSON representation for `ListValue` is JSON array.
class ListValue extends $pb.GeneratedMessage with $mixin.ListValueMixin {
  factory ListValue({
    $core.Iterable<Value>? values,
  }) {
    final $result = create();
    if (values != null) {
      $result.values.addAll(values);
    }
    return $result;
  }
  ListValue._() : super();
  factory ListValue.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListValue.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListValue', package: const $pb.PackageName(_omitMessageNames ? '' : 'google.protobuf'), createEmptyInstance: create, toProto3Json: $mixin.ListValueMixin.toProto3JsonHelper, fromProto3Json: $mixin.ListValueMixin.fromProto3JsonHelper)
    ..pc<Value>(1, _omitFieldNames ? '' : 'values', $pb.PbFieldType.PM, subBuilder: Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListValue clone() => ListValue()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListValue copyWith(void Function(ListValue) updates) => super.copyWith((message) => updates(message as ListValue)) as ListValue;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListValue create() => ListValue._();
  ListValue createEmptyInstance() => create();
  static $pb.PbList<ListValue> createRepeated() => $pb.PbList<ListValue>();
  @$core.pragma('dart2js:noInline')
  static ListValue getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListValue>(create);
  static ListValue? _defaultInstance;

  /// Repeated field of dynamically typed values.
  @$pb.TagNumber(1)
  $core.List<Value> get values => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
