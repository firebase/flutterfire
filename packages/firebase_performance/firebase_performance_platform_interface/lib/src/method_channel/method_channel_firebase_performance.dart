// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_trace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../firebase_performance_platform_interface.dart';
import 'method_channel_http_metric.dart';
import 'utils/exception.dart';

/// The method channel implementation of [FirebasePerformancePlatform].
class MethodChannelFirebasePerformance extends FirebasePerformancePlatform {
  MethodChannelFirebasePerformance({required FirebaseApp app})
      : _handle = _nextHandle++,
        super(appInstance: app);
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_performance');

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebasePerformance._()
      : _handle = 0,
        super();

  static int _nextHandle = 0;
  final int _handle;

  @visibleForTesting
  static void clearState() {
    //TODO refactor 'handle' system. MethodChannel doesn't needs its own handle.
    _nextHandle = 0;
  }

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
        <String, Object?>{'handle': _handle},
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
        <String, Object?>{'handle': _handle, 'enable': enabled},
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  TracePlatform newTrace(String name) {
    final int traceHandle = _nextHandle++;
    return MethodChannelTrace(_handle, traceHandle, name);
  }

  @override
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    final int httpMetricHandle = _nextHandle++;
    return MethodChannelHttpMetric(_handle, httpMetricHandle, url, httpMethod);
  }
}
