// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import '../document_reference_web.dart';
import '../field_value_web.dart';
import '../interop/firestore.dart' as firestore_interop;

/// Class containing static utility methods to encode/decode firestore data.
class EncodeUtility {
  /// Encodes a Map of values from their proper types to a serialized version.
  static Map<String, dynamic>? encodeMapData(Map<Object, dynamic>? data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueEncode(value));
    return output;
  }

  static Map<firestore_interop.FieldPath, dynamic>? encodeMapDataFieldPath(
      Map<Object, dynamic>? data) {
    if (data == null) {
      return null;
    }
    final output = <firestore_interop.FieldPath, dynamic>{};
    data.forEach((key, value) {
      output[valueEncode(key)] = valueEncode(value);
    });
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
      return switch (length) {
        1 => firestore_interop.FieldPath(components[0].toJS),
        2 =>
          firestore_interop.FieldPath(components[0].toJS, components[1].toJS),
        3 => firestore_interop.FieldPath(
            components[0].toJS, components[1].toJS, components[2].toJS),
        4 => firestore_interop.FieldPath(components[0].toJS, components[1].toJS,
            components[2].toJS, components[3].toJS),
        5 => firestore_interop.FieldPath(components[0].toJS, components[1].toJS,
            components[2].toJS, components[3].toJS, components[4].toJS),
        6 => firestore_interop.FieldPath(
            components[0].toJS,
            components[1].toJS,
            components[2].toJS,
            components[3].toJS,
            components[4].toJS,
            components[5].toJS),
        7 => firestore_interop.FieldPath(
            components[0].toJS,
            components[1].toJS,
            components[2].toJS,
            components[3].toJS,
            components[4].toJS,
            components[5].toJS,
            components[6].toJS),
        8 => firestore_interop.FieldPath(
            components[0].toJS,
            components[1].toJS,
            components[2].toJS,
            components[3].toJS,
            components[4].toJS,
            components[5].toJS,
            components[6].toJS,
            components[7].toJS),
        9 => firestore_interop.FieldPath(
            components[0].toJS,
            components[1].toJS,
            components[2].toJS,
            components[3].toJS,
            components[4].toJS,
            components[5].toJS,
            components[6].toJS,
            components[7].toJS,
            components[8].toJS),
        10 => firestore_interop.FieldPath(
            components[0].toJS,
            components[1].toJS,
            components[2].toJS,
            components[3].toJS,
            components[4].toJS,
            components[5].toJS,
            components[6].toJS,
            components[7].toJS,
            components[8].toJS,
            components[9].toJS),
        _ => throw Exception(
            'Firestore web FieldPath only supports 10 levels deep field paths')
      };
    } else if (value == FieldPath.documentId) {
      return firestore_interop.documentId();
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is GeoPoint) {
      return firestore_interop.GeoPointJsImpl(
          value.latitude.toJS, value.longitude.toJS);
    } else if (value is VectorValue) {
      return firestore_interop.vector(value.toArray().jsify()! as JSArray);
    } else if (value is Blob) {
      return firestore_interop.BytesJsImpl.fromUint8Array(value.bytes.toJS);
    } else if (value is DocumentReferenceWeb) {
      return value.firestoreWeb.doc(value.path);
    } else if (value is Map<String, dynamic>) {
      return encodeMapData(value);
    } else if (value is List<dynamic>) {
      return encodeArrayData(value);
    } else if (value is Iterable<dynamic>) {
      return encodeArrayData(value.toList());
    }
    return value;
  }
}
