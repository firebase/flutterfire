// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//
//  Generated code. Do not modify.
//  source: connector_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use executeQueryRequestDescriptor instead')
const ExecuteQueryRequest$json = {
  '1': 'ExecuteQueryRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'operation_name', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'operationName'},
    {'1': 'variables', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '8': {}, '10': 'variables'},
  ],
};

/// Descriptor for `ExecuteQueryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeQueryRequestDescriptor = $convert.base64Decode(
    'ChNFeGVjdXRlUXVlcnlSZXF1ZXN0EhcKBG5hbWUYASABKAlCA+BBAlIEbmFtZRIqCg5vcGVyYX'
    'Rpb25fbmFtZRgCIAEoCUID4EECUg1vcGVyYXRpb25OYW1lEjoKCXZhcmlhYmxlcxgDIAEoCzIX'
    'Lmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RCA+BBAVIJdmFyaWFibGVz');

@$core.Deprecated('Use executeMutationRequestDescriptor instead')
const ExecuteMutationRequest$json = {
  '1': 'ExecuteMutationRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'operation_name', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'operationName'},
    {'1': 'variables', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '8': {}, '10': 'variables'},
  ],
};

/// Descriptor for `ExecuteMutationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeMutationRequestDescriptor = $convert.base64Decode(
    'ChZFeGVjdXRlTXV0YXRpb25SZXF1ZXN0EhcKBG5hbWUYASABKAlCA+BBAlIEbmFtZRIqCg5vcG'
    'VyYXRpb25fbmFtZRgCIAEoCUID4EECUg1vcGVyYXRpb25OYW1lEjoKCXZhcmlhYmxlcxgDIAEo'
    'CzIXLmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RCA+BBAVIJdmFyaWFibGVz');

@$core.Deprecated('Use executeQueryResponseDescriptor instead')
const ExecuteQueryResponse$json = {
  '1': 'ExecuteQueryResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'data'},
    {'1': 'errors', '3': 2, '4': 3, '5': 11, '6': '.google.firebase.dataconnect.v1alpha.GraphqlError', '10': 'errors'},
  ],
};

/// Descriptor for `ExecuteQueryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeQueryResponseDescriptor = $convert.base64Decode(
    'ChRFeGVjdXRlUXVlcnlSZXNwb25zZRIrCgRkYXRhGAEgASgLMhcuZ29vZ2xlLnByb3RvYnVmLl'
    'N0cnVjdFIEZGF0YRJJCgZlcnJvcnMYAiADKAsyMS5nb29nbGUuZmlyZWJhc2UuZGF0YWNvbm5l'
    'Y3QudjFhbHBoYS5HcmFwaHFsRXJyb3JSBmVycm9ycw==');

@$core.Deprecated('Use executeMutationResponseDescriptor instead')
const ExecuteMutationResponse$json = {
  '1': 'ExecuteMutationResponse',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'data'},
    {'1': 'errors', '3': 2, '4': 3, '5': 11, '6': '.google.firebase.dataconnect.v1alpha.GraphqlError', '10': 'errors'},
  ],
};

/// Descriptor for `ExecuteMutationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List executeMutationResponseDescriptor = $convert.base64Decode(
    'ChdFeGVjdXRlTXV0YXRpb25SZXNwb25zZRIrCgRkYXRhGAEgASgLMhcuZ29vZ2xlLnByb3RvYn'
    'VmLlN0cnVjdFIEZGF0YRJJCgZlcnJvcnMYAiADKAsyMS5nb29nbGUuZmlyZWJhc2UuZGF0YWNv'
    'bm5lY3QudjFhbHBoYS5HcmFwaHFsRXJyb3JSBmVycm9ycw==');

