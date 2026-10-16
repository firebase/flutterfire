// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A pure Dart entry point which verifies that this package can be used without
// a Flutter dependency, which is the point of extracting
// `firebase_core_common`.
//
// It is compiled by `melos run check:pure-dart`:
// `dart compile js tool/pure_dart_check.dart` fails as soon as a library which
// depends on Flutter becomes reachable from this package.
import 'package:firebase_core_common/firebase_core_common.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

void main() {
  FirebaseCoreWeb.registerWith(null);

  if (!FirebasePlatform.isRegistered) {
    throw StateError('The web implementation did not register itself.');
  }

  // ignore: avoid_print
  print('firebase_core_web is usable without Flutter.');
}
