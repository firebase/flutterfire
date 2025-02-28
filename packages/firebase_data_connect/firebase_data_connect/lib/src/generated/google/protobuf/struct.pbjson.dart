//
//  Generated code. Do not modify.
//  source: google/protobuf/struct.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use nullValueDescriptor instead')
const NullValue$json = {
  '1': 'NullValue',
  '2': [
    {'1': 'NULL_VALUE', '2': 0},
  ],
};

/// Descriptor for `NullValue`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nullValueDescriptor = $convert.base64Decode(
    'CglOdWxsVmFsdWUSDgoKTlVMTF9WQUxVRRAA');

@$core.Deprecated('Use structDescriptor instead')
const Struct$json = {
  '1': 'Struct',
  '2': [
    {'1': 'fields', '3': 1, '4': 3, '5': 11, '6': '.google.protobuf.Struct.FieldsEntry', '10': 'fields'},
  ],
  '3': [Struct_FieldsEntry$json],
};

@$core.Deprecated('Use structDescriptor instead')
const Struct_FieldsEntry$json = {
  '1': 'FieldsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Value', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Struct`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List structDescriptor = $convert.base64Decode(
    'CgZTdHJ1Y3QSOwoGZmllbGRzGAEgAygLMiMuZ29vZ2xlLnByb3RvYnVmLlN0cnVjdC5GaWVsZH'
    'NFbnRyeVIGZmllbGRzGlEKC0ZpZWxkc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiwKBXZhbHVl'
    'GAIgASgLMhYuZ29vZ2xlLnByb3RvYnVmLlZhbHVlUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use valueDescriptor instead')
const Value$json = {
  '1': 'Value',
  '2': [
    {'1': 'null_value', '3': 1, '4': 1, '5': 14, '6': '.google.protobuf.NullValue', '9': 0, '10': 'nullValue'},
    {'1': 'number_value', '3': 2, '4': 1, '5': 1, '9': 0, '10': 'numberValue'},
    {'1': 'string_value', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'stringValue'},
    {'1': 'bool_value', '3': 4, '4': 1, '5': 8, '9': 0, '10': 'boolValue'},
    {'1': 'struct_value', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '9': 0, '10': 'structValue'},
    {'1': 'list_value', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.ListValue', '9': 0, '10': 'listValue'},
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `Value`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List valueDescriptor = $convert.base64Decode(
    'CgVWYWx1ZRI7CgpudWxsX3ZhbHVlGAEgASgOMhouZ29vZ2xlLnByb3RvYnVmLk51bGxWYWx1ZU'
    'gAUgludWxsVmFsdWUSIwoMbnVtYmVyX3ZhbHVlGAIgASgBSABSC251bWJlclZhbHVlEiMKDHN0'
    'cmluZ192YWx1ZRgDIAEoCUgAUgtzdHJpbmdWYWx1ZRIfCgpib29sX3ZhbHVlGAQgASgISABSCW'
    'Jvb2xWYWx1ZRI8CgxzdHJ1Y3RfdmFsdWUYBSABKAsyFy5nb29nbGUucHJvdG9idWYuU3RydWN0'
    'SABSC3N0cnVjdFZhbHVlEjsKCmxpc3RfdmFsdWUYBiABKAsyGi5nb29nbGUucHJvdG9idWYuTG'
    'lzdFZhbHVlSABSCWxpc3RWYWx1ZUIGCgRraW5k');

@$core.Deprecated('Use listValueDescriptor instead')
const ListValue$json = {
  '1': 'ListValue',
  '2': [
    {'1': 'values', '3': 1, '4': 3, '5': 11, '6': '.google.protobuf.Value', '10': 'values'},
  ],
};

/// Descriptor for `ListValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listValueDescriptor = $convert.base64Decode(
    'CglMaXN0VmFsdWUSLgoGdmFsdWVzGAEgAygLMhYuZ29vZ2xlLnByb3RvYnVmLlZhbHVlUgZ2YW'
    'x1ZXM=');

