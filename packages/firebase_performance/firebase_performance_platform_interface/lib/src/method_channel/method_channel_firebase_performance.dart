// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_trace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../firebase_performance_platform_interface.dart';
import '../platform_interface/platform_interface_firebase_performance.dart';
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
    //TODO refactor 'handle' system. Don't think MethodChannel needs its own. Keep track on native.
    _nextHandle = 0;
  }

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebasePerformance get instance {
    return MethodChannelFirebasePerformance._();
  }

  @override
  FirebasePerformancePlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebasePerformance(app: app);
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    try {
      final isPerformanceCollectionEnabled = await channel.invokeMethod<bool>(
        'FirebasePerformance#isPerformanceCollectionEnabled',
        //todo is handle needed here?
        <String, Object?>{'handle': _handle},
      );
      return isPerformanceCollectionEnabled!;
    } catch (e, s) {
      throw convertPlatformException(e, s);
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
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<TracePlatform> newTrace(String name) async {
    final int handle = _nextHandle + 1;
    try {
      await channel.invokeMethod<void>(
        'FirebasePerformance#newTrace',
        <String, Object?>{
          'handle': _handle,
          'traceHandle': handle,
          'name': name
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }

    return MethodChannelTrace(handle, name);
  }

  @override
  Future<HttpMetricPlatform> newHttpMetric(
      String url, HttpMethod httpMethod) async {
    final int handle = _nextHandle + 1;
    //todo update this so that the handle is passed on first use. No need to create yet.
    try {
      await channel.invokeMethod<void>(
        'FirebasePerformance#newHttpMetric',
        <String, Object?>{
          'handle': _handle,
          'httpMetricHandle': handle,
          'url': url,
          'httpMethod': httpMethod.toString(),
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }

    return MethodChannelHttpMetric(handle, url, httpMethod);
  }
}
