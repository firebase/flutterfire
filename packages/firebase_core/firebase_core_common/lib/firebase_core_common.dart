// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Pure Dart shared types and platform interfaces for Firebase Core.
///
/// This library must never import `package:flutter/*` or any library which
/// does, so that Firebase Core platform implementations (such as
/// `firebase_core_web`) can be used outside of Flutter, for example in
/// pure Dart web applications.
///
/// `firebase_core_platform_interface` re-exports this library, so importing
/// that package (directly or through `firebase_core`) keeps giving access to
/// exactly the same types.
library;

export 'src/default_firebase_app_name.dart';
export 'src/firebase_app.dart';
export 'src/firebase_core_exceptions.dart';
export 'src/firebase_exception.dart';
export 'src/firebase_options.dart';
export 'src/platform_interface/platform_interface_firebase.dart';
export 'src/platform_interface/platform_interface_firebase_app.dart';
export 'src/platform_interface/platform_interface_firebase_plugin.dart';
