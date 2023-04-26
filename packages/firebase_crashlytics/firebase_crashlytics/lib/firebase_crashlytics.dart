// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_crashlytics;

import 'package:flutter/foundation.dart'
    show kDebugMode, FlutterErrorDetails, FlutterError;

import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;

import 'src/utils.dart';

part 'src/firebase_crashlytics.dart';
