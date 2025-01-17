// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../../cloud_firestore.dart';

// ignore: do_not_use_environment
const kIsWasm = bool.fromEnvironment('dart.library.js_interop') &&
    // html package is not available in wasm
    // ignore: do_not_use_environment
    !bool.fromEnvironment('dart.library.html');

class _CodecUtility {
  static Map<String, dynamic>? replaceValueWithDelegatesInMap(
    Map<dynamic, dynamic>? data,
  ) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((_, value) => valueEncode(value));
    return output;
  }

  static Map<FieldPath, dynamic>? replaceValueWithDelegatesInMapFieldPath(
    Map<Object, dynamic>? data,
  ) {
    if (data == null) {
      return null;
    }
    Map<FieldPath, dynamic> output = <FieldPath, dynamic>{};
    data.forEach((key, value) {
      if (key is FieldPath) {
        output[key] = valueEncode(value);
      } else if (key is String) {
        output[FieldPath.fromString(key)] = valueEncode(value);
      } else {
        throw StateError(
          'Invalid key type for map. Expected String or FieldPath, but got $key: ${key.runtimeType}.',
        );
      }
    });
    return output;
  }

  static List<dynamic>? replaceValueWithDelegatesInArray(
    Iterable<dynamic>? data,
  ) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueEncode).toList();
  }

  static Map<String, dynamic>? replaceDelegatesWithValueInMap(
    Map<dynamic, dynamic>? data,
    FirebaseFirestore firestore,
  ) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((_, value) => valueDecode(value, firestore));
    return output;
  }

  static List<dynamic>? replaceDelegatesWithValueInArray(
    List<dynamic>? data,
    FirebaseFirestore firestore,
  ) {
    if (data == null) {
      return null;
    }
    return List.from(data)
        .map((value) => valueDecode(value, firestore))
        .toList();
  }

  static dynamic valueEncode(dynamic value) {
    if (value is DocumentReference) {
      return value._delegate;
    } else if (value is Iterable) {
      return replaceValueWithDelegatesInArray(value);
    } else if (value is Map<dynamic, dynamic>) {
      return replaceValueWithDelegatesInMap(value);
    }
    return value;
  }

  static dynamic valueDecode(dynamic value, FirebaseFirestore firestore) {
    if (value is DocumentReferencePlatform) {
      return _JsonDocumentReference(firestore, value);
    } else if (value is List) {
      return replaceDelegatesWithValueInArray(value, firestore);
    } else if (value is Map<dynamic, dynamic>) {
      return replaceDelegatesWithValueInMap(value, firestore);
    } else if (value is num) {
      return convertNum(value);
    }
    return value;
  }
}

num convertNum(num input) {
  // This workaround is only needed for WASM
  if (!kIsWasm) {
    return input;
  }
  // Can fail for NaN, Infinity, etc.
  try {
    if (input is int) {
      return input; // It's already an int
    } else if (input is double) {
      if (input == input.toInt()) {
        return input.toInt(); // Convert to int if no fractional part
      }
    }

    return input; // Return as double if fractional part exists
  } catch (_) {
    return input;
  }
}
