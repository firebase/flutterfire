// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The platform interface for Firebase Core.
library;

import 'dart:async';

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:firebase_core_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// The pure-Dart types and contracts live in `firebase_core_interface`, so that
// Dart apps without Flutter can use them. They stay importable from here. The
// list is explicit so that names it adds later do not clash with other imports
// in the plugins.
export 'package:firebase_core_interface/firebase_core_interface.dart'
    show
        FirebaseAppPlatform,
        FirebaseException,
        FirebaseOptions,
        FirebasePlatform,
        FirebasePlugin,
        coreNotInitialized,
        defaultFirebaseAppName,
        duplicateApp,
        noAppExists,
        noDefaultAppDelete,
        noDefaultAppInitialization;

part 'src/method_channel/method_channel_firebase.dart';
part 'src/method_channel/method_channel_firebase_app.dart';
part 'src/pigeon_extensions.dart';
