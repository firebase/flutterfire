// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart'
    show FirebaseFirestoreWeb;
import 'package:cloud_firestore_web/src/interop/firestore.dart';

import '../interop/firestore.dart' as firestore_interop;

/// Class containing static utility methods to decode firestore data.
class DecodeUtility {
  /// Decodes the values on an incoming Map to their proper types.
  static Map<String, dynamic>? decodeMapData(
      Map<String, dynamic>? data, FirebaseFirestorePlatform firestore) {
    if (data == null) {
      return null;
    }
    return data..updateAll((key, value) => valueDecode(value, firestore));
  }

  /// Decodes the values on an incoming Array to their proper types.
  static List<dynamic>? decodeArrayData(
      List<dynamic>? data, FirebaseFirestorePlatform firestore) {
    if (data == null) {
      return null;
    }
    return data.map((v) => valueDecode(v, firestore)).toList();
  }

  /// Decodes an incoming value to its proper type.
  static dynamic valueDecode(
      dynamic value, FirebaseFirestorePlatform firestore) {
    // Cannot be done with Dart 3.2 constraints
    // ignore: invalid_runtime_check_with_js_interop_types
    if (value is JSObject &&
        value.instanceof(GeoPointConstructor as JSFunction)) {
      return GeoPoint((value as GeoPointJsImpl).latitude.toDartDouble,
          (value as GeoPointJsImpl).longitude.toDartDouble);
      // Cannot be done with Dart 3.2 constraints
      // ignore: invalid_runtime_check_with_js_interop_types
    } else if (value is JSObject &&
        value.instanceof(VectorValueConstructor as JSFunction)) {
      return VectorValue((value as VectorValueJsImpl)
          .toArray()
          .toDart
          .map((JSAny? e) => (e! as JSNumber).toDartDouble)
          .toList());
    } else if (value is DateTime) {
      return Timestamp.fromDate(value);
      // Cannot be done with Dart 3.2 constraints
      // ignore: invalid_runtime_check_with_js_interop_types
    } else if (value is JSObject &&
        value.instanceof(BytesConstructor as JSFunction)) {
      return Blob((value as BytesJsImpl).toUint8Array().toDart);
    } else if (value is firestore_interop.DocumentReference) {
      return (firestore as FirebaseFirestoreWeb).doc(value.path);
    } else if (value is Map<String, dynamic>) {
      return decodeMapData(value, firestore);
    } else if (value is List<dynamic>) {
      return decodeArrayData(value, firestore);
    }
    return value;
  }
}
