//
//  Generated code. Do not modify.
//  source: graphql_error.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use graphqlErrorDescriptor instead')
const GraphqlError$json = {
  '1': 'GraphqlError',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'locations', '3': 2, '4': 3, '5': 11, '6': '.google.firebase.dataconnect.v1.SourceLocation', '10': 'locations'},
    {'1': 'path', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.ListValue', '10': 'path'},
    {'1': 'extensions', '3': 4, '4': 1, '5': 11, '6': '.google.firebase.dataconnect.v1.GraphqlErrorExtensions', '10': 'extensions'},
  ],
};

/// Descriptor for `GraphqlError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List graphqlErrorDescriptor = $convert.base64Decode(
    'CgxHcmFwaHFsRXJyb3ISGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZRJMCglsb2NhdGlvbnMYAi'
    'ADKAsyLi5nb29nbGUuZmlyZWJhc2UuZGF0YWNvbm5lY3QudjEuU291cmNlTG9jYXRpb25SCWxv'
    'Y2F0aW9ucxIuCgRwYXRoGAMgASgLMhouZ29vZ2xlLnByb3RvYnVmLkxpc3RWYWx1ZVIEcGF0aB'
    'JWCgpleHRlbnNpb25zGAQgASgLMjYuZ29vZ2xlLmZpcmViYXNlLmRhdGFjb25uZWN0LnYxLkdy'
    'YXBocWxFcnJvckV4dGVuc2lvbnNSCmV4dGVuc2lvbnM=');

@$core.Deprecated('Use sourceLocationDescriptor instead')
const SourceLocation$json = {
  '1': 'SourceLocation',
  '2': [
    {'1': 'line', '3': 1, '4': 1, '5': 5, '10': 'line'},
    {'1': 'column', '3': 2, '4': 1, '5': 5, '10': 'column'},
  ],
};

/// Descriptor for `SourceLocation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sourceLocationDescriptor = $convert.base64Decode(
    'Cg5Tb3VyY2VMb2NhdGlvbhISCgRsaW5lGAEgASgFUgRsaW5lEhYKBmNvbHVtbhgCIAEoBVIGY2'
    '9sdW1u');

@$core.Deprecated('Use graphqlErrorExtensionsDescriptor instead')
const GraphqlErrorExtensions$json = {
  '1': 'GraphqlErrorExtensions',
  '2': [
    {'1': 'file', '3': 1, '4': 1, '5': 9, '10': 'file'},
  ],
};

/// Descriptor for `GraphqlErrorExtensions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List graphqlErrorExtensionsDescriptor = $convert.base64Decode(
    'ChZHcmFwaHFsRXJyb3JFeHRlbnNpb25zEhIKBGZpbGUYASABKAlSBGZpbGU=');

