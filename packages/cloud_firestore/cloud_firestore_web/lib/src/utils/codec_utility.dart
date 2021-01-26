// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart'
    show FirebaseFirestoreWeb;

import '../interop/firestore.dart' as firestore_interop;
import '../document_reference_web.dart';
import '../field_value_web.dart';

/// Class containing static utility methods to encode/decode firestore data.
class CodecUtility {
  /// Encodes a Map of values from their proper types to a serialized version.
  static Map<String, dynamic>? encodeMapData(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueEncode(value));
    return output;
  }

  /// Encodes an Array of values from their proper types to a serialized version.
  static List<dynamic>? encodeArrayData(List<dynamic>? data) {
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
    } else if (value is FieldPath) {
      List<String> components = value.components;
      int length = components.length;

      // The [web.FieldPath] class accepts optional args, which cannot be null/empty-string
      // values. This code below works around that, however limits users to 10 level
      // deep FieldPaths which the web counterpart supports
      switch (length) {
        case 1:
          return firestore_interop.FieldPath(components[0]);
        case 2:
          return firestore_interop.FieldPath(components[0], components[1]);
        case 3:
          return firestore_interop.FieldPath(
              components[0], components[1], components[2]);
        case 4:
          return firestore_interop.FieldPath(
              components[0], components[1], components[2], components[3]);
        case 5:
          return firestore_interop.FieldPath(components[0], components[1],
              components[2], components[3], components[4]);
        case 6:
          return firestore_interop.FieldPath(components[0], components[1],
              components[2], components[3], components[4], components[5]);
        case 7:
          return firestore_interop.FieldPath(
              components[0],
              components[1],
              components[2],
              components[3],
              components[4],
              components[5],
              components[6]);
        case 8:
          return firestore_interop.FieldPath(
              components[0],
              components[1],
              components[2],
              components[3],
              components[4],
              components[5],
              components[6],
              components[7]);
        case 9:
          return firestore_interop.FieldPath(
              components[0],
              components[1],
              components[2],
              components[3],
              components[4],
              components[5],
              components[6],
              components[7],
              components[8]);
        case 10:
          return firestore_interop.FieldPath(
              components[0],
              components[1],
              components[2],
              components[3],
              components[4],
              components[5],
              components[6],
              components[7],
              components[8],
              components[9]);
        default:
          throw Exception(
              'Firestore web FieldPath only supports 10 levels deep field paths');
      }
    } else if (value == FieldPath.documentId) {
      return firestore_interop.FieldPath.documentId();
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is GeoPoint) {
      return firestore_interop.GeoPoint(value.latitude, value.longitude);
    } else if (value is Blob) {
      return firestore_interop.Blob.fromUint8Array(value.bytes);
    } else if (value is DocumentReferenceWeb) {
      return value.firestoreWeb.doc(value.path);
    } else if (value is Map<String, dynamic>) {
      return encodeMapData(value);
    } else if (value is List<dynamic>) {
      return encodeArrayData(value);
    }
    return value;
  }

  /// Decodes the values on an incoming Map to their proper types.
  static Map<String, dynamic>? decodeMapData(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueDecode(value));
    return output;
  }

  /// Decodes the values on an incoming Array to their proper types.
  static List<dynamic>? decodeArrayData(List<dynamic>? data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueDecode).toList();
  }

  /// Decodes an incoming value to its proper type.
  static dynamic valueDecode(dynamic value) {
    if (value is firestore_interop.GeoPoint) {
      return GeoPoint(value.latitude as double, value.longitude as double);
    } else if (value is DateTime) {
      return Timestamp.fromDate(value);
    } else if (value is firestore_interop.Blob) {
      return Blob(value.toUint8Array());
    } else if (value is firestore_interop.DocumentReference) {
      return (FirebaseFirestorePlatform.instance as FirebaseFirestoreWeb)
          .doc(value.path);
    } else if (value is Map<String, dynamic>) {
      return decodeMapData(value);
    } else if (value is List<dynamic>) {
      return decodeArrayData(value);
    }
    return value;
  }
}
