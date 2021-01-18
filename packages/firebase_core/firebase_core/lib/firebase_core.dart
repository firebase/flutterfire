// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_core;

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    hide MethodChannelFirebaseApp, MethodChannelFirebase;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseOptions, defaultFirebaseAppName, FirebaseException;

part 'src/firebase_app.dart';
part 'src/firebase.dart';
