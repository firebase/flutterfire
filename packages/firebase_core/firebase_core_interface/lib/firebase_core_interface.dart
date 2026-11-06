// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The `Firebase` entry point, the contracts that `firebase_core`
/// implementations extend, and the client types they use.
library;

export 'package:firebase_common/firebase_common.dart' show FirebaseException;

export 'src/constants.dart';
export 'src/firebase.dart';
export 'src/firebase_core_exceptions.dart';
export 'src/firebase_options.dart';
export 'src/platform_interface/platform_interface_firebase.dart';
export 'src/platform_interface/platform_interface_firebase_app.dart';
export 'src/platform_interface/platform_interface_firebase_plugin.dart';
