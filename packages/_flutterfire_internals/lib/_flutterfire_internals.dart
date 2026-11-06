// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas
// DO NOT MOVE THIS FILE
//
// Other firebase packages may import `package:firebase_core/src/internals.dart`.
// Moving it would break the imports
//
// This file exports utilities shared between firebase packages, without making
// them public.

export 'src/exception.dart';
// `guardWebExceptions` lives in `firebase_core_js`, which only compiles for
// the web. Elsewhere there are no JS errors to map, so the stub passes results
// through.
export 'src/guard_web_exceptions_stub.dart'
    if (dart.library.js_interop) 'package:firebase_core_js/firebase_core_js_interop.dart'
    show guardWebExceptions;

/// An extension that adds utilities for safely casting objects
extension ObjectX<T> on T? {
  /// Transform an object if that value is not null.
  ///
  /// Doing:
  ///
  /// ```dart
  /// Map? json;
  /// var result = json?['key']?.guard((json) => Model.fromJson(json));
  /// ```
  ///
  /// is equivalent to doing:
  ///
  /// ```dart
  /// Map? json;
  /// var key = json?['key'];
  /// var result = key == null ? null : Model.fromJson(key);
  /// ```
  R? guard<R>(R Function(T value) cb) {
    if (this is T) return cb(this as T);
    return null;
  }

  /// Safely cast an object, returning `null` if the casted object does not
  /// match the casted type.
  R? safeCast<R>() {
    if (this is R) return this as R;
    return null;
  }
}
