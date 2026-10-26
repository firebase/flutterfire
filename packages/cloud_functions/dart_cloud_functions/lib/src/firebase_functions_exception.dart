// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';

/// An error returned by a callable function, or raised while calling it.
///
/// Mirrors `FirebaseFunctionsException` from `cloud_functions`: [code] uses
/// the same values, such as `not-found`, `invalid-argument` or
/// `deadline-exceeded`. Both classes extend [FirebaseException], so
/// `on FirebaseException catch (e)` handles errors from either package.
class DartFirebaseFunctionsException extends FirebaseException {
  /// Creates an exception with a callable error [code].
  DartFirebaseFunctionsException({
    required String super.code,
    required String super.message,
    this.details,
    super.stackTrace,
  }) : super(plugin: 'dart_cloud_functions');

  /// Extra data the function attached to its error, if any.
  final Object? details;
}

