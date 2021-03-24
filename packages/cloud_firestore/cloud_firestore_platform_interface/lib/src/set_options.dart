// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'field_path.dart';

/// An options class that configures the behavior of set() calls in [DocumentReference],
/// [WriteBatch] and [Transaction].
class SetOptions {
  /// Changes the behavior of a set() call to only replace the values specified
  /// in its data argument.
  ///
  /// Fields omitted from the set() call remain untouched.
  final bool? merge;

  /// Changes the behavior of set() calls to only replace the specified field paths.
  ///
  /// Any field path that is not specified is ignored and remains untouched.
  List<FieldPath>? mergeFields;

  /// Creates a [SetOptions] instance.
  SetOptions({
    // ignore: avoid_init_to_null
    this.merge = null,
    // ignore: avoid_init_to_null
    List<dynamic>? mergeFields = null,
  }) {
    // ignore: prefer_asserts_in_initializer_lists
    assert(!(merge == null && mergeFields == null),
        "options must provide 'merge' or 'mergeFields'");
    // ignore: prefer_asserts_in_initializer_lists
    assert(!(mergeFields != null && merge != null),
        "options cannot have both 'merge' & 'mergeFields'");
    if (mergeFields != null) {
      assert(
          mergeFields
                  .where((value) => value is String || value is FieldPath)
                  .length ==
              mergeFields.length,
          '[mergeFields] must be a [String] or [FieldPath]');
      this.mergeFields = mergeFields.map((field) {
        if (field is String) return FieldPath.fromString(field);
        return field as FieldPath;
      }).toList(growable: false);
    }
  }
}
