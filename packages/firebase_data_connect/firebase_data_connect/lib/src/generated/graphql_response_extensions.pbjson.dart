//
//  Generated code. Do not modify.
//  source: graphql_response_extensions.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use graphqlResponseExtensionsDescriptor instead')
const GraphqlResponseExtensions$json = {
  '1': 'GraphqlResponseExtensions',
  '2': [
    {
      '1': 'data_connect',
      '3': 1,
      '4': 3,
      '5': 11,
      '6':
          '.google.firebase.dataconnect.v1.GraphqlResponseExtensions.DataConnectProperties',
      '10': 'dataConnect'
    },
  ],
  '3': [GraphqlResponseExtensions_DataConnectProperties$json],
};

@$core.Deprecated('Use graphqlResponseExtensionsDescriptor instead')
const GraphqlResponseExtensions_DataConnectProperties$json = {
  '1': 'DataConnectProperties',
  '2': [
    {
      '1': 'path',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.ListValue',
      '10': 'path'
    },
    {'1': 'entity_id', '3': 2, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'entity_ids', '3': 3, '4': 3, '5': 9, '10': 'entityIds'},
    {
      '1': 'max_age',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Duration',
      '10': 'maxAge'
    },
  ],
};

/// Descriptor for `GraphqlResponseExtensions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List graphqlResponseExtensionsDescriptor = $convert.base64Decode(
    'ChlHcmFwaHFsUmVzcG9uc2VFeHRlbnNpb25zEnIKDGRhdGFfY29ubmVjdBgBIAMoCzJPLmdvb2'
    'dsZS5maXJlYmFzZS5kYXRhY29ubmVjdC52MS5HcmFwaHFsUmVzcG9uc2VFeHRlbnNpb25zLkRh'
    'dGFDb25uZWN0UHJvcGVydGllc1ILZGF0YUNvbm5lY3QatwEKFURhdGFDb25uZWN0UHJvcGVydG'
    'llcxIuCgRwYXRoGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLkxpc3RWYWx1ZVIEcGF0aBIbCgll'
    'bnRpdHlfaWQYAiABKAlSCGVudGl0eUlkEh0KCmVudGl0eV9pZHMYAyADKAlSCWVudGl0eUlkcx'
    'IyCgdtYXhfYWdlGAQgASgLMhkuZ29vZ2xlLnByb3RvYnVmLkR1cmF0aW9uUgZtYXhBZ2U=');
