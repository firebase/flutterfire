// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import '../platform_interface/platform_interface_firebase_performance.dart';

/// The method channel implementation of [FirebaseAnalyticsPlatform].
class MethodChannelFirebasePerformance extends FirebasePerformancePlatform {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/firebase_performance');

  MethodChannelFirebasePerformance._() : super(appInstance: null);

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebasePerformance get instance {
    return MethodChannelFirebasePerformance._();
  }
}
