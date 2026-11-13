// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

// `Firebase` and `FirebaseApp` are pure Dart, so that Dart apps without Flutter
// can use them through `firebase_core_js`.
export 'package:firebase_core_interface/firebase_core_interface.dart'
    show Firebase, FirebaseApp, FirebaseService;
export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseOptions, defaultFirebaseAppName, FirebaseException;

part 'src/port_mapping.dart';
