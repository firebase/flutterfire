// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_trace.dart';
import 'package:flutter/services.dart';

import '../../firebase_performance_platform_interface.dart';
import 'method_channel_http_metric.dart';
import 'utils/exception.dart';

/// The method channel implementation of [FirebasePerformancePlatform].
class MethodChannelFirebasePerformance extends FirebasePerformancePlatform {
  MethodChannelFirebasePerformance({required FirebaseApp app})
      : super(appInstance: app);
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_performance');

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebasePerformance._() : super();

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebasePerformance get instance {
    return MethodChannelFirebasePerformance._();
  }

  /// Instances are cached and reused for incoming event handlers.
  @override
  FirebasePerformancePlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebasePerformance(app: app);
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    try {
      final isPerformanceCollectionEnabled = await channel.invokeMethod<bool>(
        'FirebasePerformance#isPerformanceCollectionEnabled',
      );
      return isPerformanceCollectionEnabled!;
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    try {
      await channel.invokeMethod<void>(
        'FirebasePerformance#setPerformanceCollectionEnabled',
        <String, Object?>{'enable': enabled},
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  TracePlatform newTrace(String name) {
    return MethodChannelTrace(name);
  }

  @override
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    return MethodChannelHttpMetric(url, httpMethod);
  }
}
