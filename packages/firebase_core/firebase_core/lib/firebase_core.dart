// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    hide MethodChannelFirebaseApp;
import 'package:flutter/foundation.dart';

export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show
        FirebaseApp,
        FirebaseException,
        FirebaseOptions,
        FirebaseService,
        defaultFirebaseAppName;

part 'src/firebase.dart';
part 'src/port_mapping.dart';
