// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
    {
      '1': 'locations',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.google.firebase.dataconnect.v1alpha.SourceLocation',
      '10': 'locations'
    },
    {
      '1': 'path',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.ListValue',
      '10': 'path'
    },
    {
      '1': 'extensions',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.firebase.dataconnect.v1alpha.GraphqlErrorExtensions',
      '10': 'extensions'
    },
  ],
};

/// Descriptor for `GraphqlError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List graphqlErrorDescriptor = $convert.base64Decode(
    'CgxHcmFwaHFsRXJyb3ISGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZRJRCglsb2NhdGlvbnMYAi'
    'ADKAsyMy5nb29nbGUuZmlyZWJhc2UuZGF0YWNvbm5lY3QudjFhbHBoYS5Tb3VyY2VMb2NhdGlv'
    'blIJbG9jYXRpb25zEi4KBHBhdGgYAyABKAsyGi5nb29nbGUucHJvdG9idWYuTGlzdFZhbHVlUg'
    'RwYXRoElsKCmV4dGVuc2lvbnMYBCABKAsyOy5nb29nbGUuZmlyZWJhc2UuZGF0YWNvbm5lY3Qu'
    'djFhbHBoYS5HcmFwaHFsRXJyb3JFeHRlbnNpb25zUgpleHRlbnNpb25z');

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
final $typed_data.Uint8List graphqlErrorExtensionsDescriptor =
    $convert.base64Decode(
        'ChZHcmFwaHFsRXJyb3JFeHRlbnNpb25zEhIKBGZpbGUYASABKAlSBGZpbGU=');
