// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

import 'src/trace.dart';
import 'src/interop/performance.dart' as performance_interop;

/// Web implementation for [FirebasePerformancePlatform]
class FirebasePerformanceWeb extends FirebasePerformancePlatform {
  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebasePerformanceWeb._()
      : _webPerformance = null,
        super(appInstance: null);

  /// Instance of Performance from the web plugin.
  performance_interop.Performance? _webPerformance;

  /// Keep settings so we can pass to Performance instance.
  performance_interop.PerformanceSettings? _settings;

  /// Lazily initialize [_webRemoteConfig] on first method call
  performance_interop.Performance get _delegate {
    if (_settings == null) {
      return _webPerformance ??= performance_interop.getPerformanceInstance();
    }

    return _webPerformance = performance_interop.getPerformanceInstance(
      core_interop.app(app.name),
      _settings,
    );
  }

  /// Builds an instance of [FirebasePerformanceWeb]
  /// Performance web currently only supports the default app instance
  FirebasePerformanceWeb() : super();

  /// Initializes a stub instance to allow the class to be registered.
  static FirebasePerformanceWeb get instance {
    return FirebasePerformanceWeb._();
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('performance');
    FirebasePerformancePlatform.instance = FirebasePerformanceWeb.instance;
  }

  @override
  FirebasePerformancePlatform delegateFor({required FirebaseApp app}) {
    return FirebasePerformanceWeb();
  }

  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set mockDelegate(performance_interop.Performance performance) {
    _webPerformance = performance;
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    // Default setting for "dataCollectionEnabled" is `true`. See https://github.com/firebase/firebase-js-sdk/blob/master/packages/performance/src/services/settings_service.ts#L27
    return Future.value(
      _settings == null ? true : _settings!.dataCollectionEnabled,
    );
  }

  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    // TODO - "instrumentationEnabled" is also a setting property on web to be implemented.
    _settings = performance_interop.PerformanceSettings.getInstance(enabled);
  }

  @override
  TracePlatform newTrace(String name) {
    return TraceWeb(_delegate.trace(name));
  }

  @override
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    throw PlatformException(
      code: 'non-existent',
      message:
          "Performance Web does not currently support 'HttpMetric' (custom network tracing).",
    );
  }
}
