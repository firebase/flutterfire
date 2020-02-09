// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';
import 'package:cloud_firestore_web/src/field_value_web.dart';

/// Class containing static utility methods to encode/decode firestore data.
class CodecUtility {
  /// Encodes a Map of values from their proper types to a serialized version.
  static Map<String, dynamic> encodeMapData(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueEncode(value));
    return output;
  }

  /// Encodes an Array of values from their proper types to a serialized version.
  static List<dynamic> encodeArrayData(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueEncode).toList();
  }

  /// Encodes a value from its proper type to a serialized version.
  static dynamic valueEncode(dynamic value) {
    if (value is FieldValuePlatform) {
      FieldValueWeb delegate = FieldValuePlatform.getDelegate(value);
      return delegate.data;
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is GeoPoint) {
      return web.GeoPoint(value.latitude, value.longitude);
    } else if (value is Blob) {
      return web.Blob.fromUint8Array(value.bytes);
    } else if (value is DocumentReferenceWeb) {
      return value.delegate;
    } else if (value is Map<String, dynamic>) {
      return encodeMapData(value);
    } else if (value is List<dynamic>) {
      return encodeArrayData(value);
    }
    return value;
  }

  /// Decodes the values on an incoming Map to their proper types.
  static Map<String, dynamic> decodeMapData(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueDecode(value));
    return output;
  }

  /// Decodes the values on an incoming Array to their proper types.
  static List<dynamic> decodeArrayData(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueDecode).toList();
  }

  /// Decodes an incoming value to its proper type.
  static dynamic valueDecode(dynamic value) {
    if (value is web.GeoPoint) {
      return GeoPoint(value.latitude, value.longitude);
    } else if (value is DateTime) {
      return Timestamp.fromDate(value);
    } else if (value is web.Blob) {
      return Blob(value.toUint8Array());
    } else if (value is web.DocumentReference) {
      return (FirestorePlatform.instance as FirestoreWeb).document(value.path);
    } else if (value is Map<String, dynamic>) {
      return decodeMapData(value);
    } else if (value is List<dynamic>) {
      return decodeArrayData(value);
    }
    return value;
  }
}
