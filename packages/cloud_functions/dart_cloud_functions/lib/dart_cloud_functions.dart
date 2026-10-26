// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Experimental pure-Dart client for callable Cloud Functions.
///
/// The API mirrors `cloud_functions` with a `Dart` prefix, so both packages
/// can be imported in the same file:
///
/// ```dart
/// final result = await DartFirebaseFunctions.instance
///     .httpsCallable('listFruit')
///     .call();
/// print(result.data);
/// ```
library;

export 'package:dart_cloud_functions/src/firebase_functions.dart'
    show
        DartFirebaseFunctions,
        DartHttpsCallable,
        DartHttpsCallableOptions,
        DartHttpsCallableResult;
export 'package:dart_cloud_functions/src/firebase_functions_exception.dart'
    show DartFirebaseFunctionsException;
