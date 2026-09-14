// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The test binding shim used by the Pigeon test APIs that FlutterFire
/// packages ship in `lib/`.
///
/// This exists so those generated files do not have to import `flutter_test`
/// from `lib/`. See `src/test_binding.dart` for the details.
library;

export 'package:firebase_core_platform_interface/src/test_binding.dart';
