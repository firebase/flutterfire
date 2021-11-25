import 'package:flutter/services.dart';

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/trace.dart';
import 'src/interop/performance.dart' as performance_interop;

/// Web implementation for [FirebasePerformancePlatform]
class FirebasePerformanceWeb extends FirebasePerformancePlatform {
  /// Instance of Performance from the web plugin.
  performance_interop.Performance? _webPerformance;

  /// Lazily initialize [_webRemoteConfig] on first method call
  performance_interop.Performance get _delegate {
    return _webPerformance ??= performance_interop.getPerformanceInstance();
  }

  /// Builds an instance of [FirebasePerformanceWeb] with an optional [FirebaseApp] instance
  /// Performance web currently only supports the default app instance
  FirebasePerformanceWeb({performance_interop.Performance? performance})
      : _webPerformance = performance,
        super();

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebasePerformancePlatform.instance = FirebasePerformanceWeb();
  }

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  static void registerWithForTest(
    FirebasePerformancePlatform firebasePerformancePlatform,
  ) {
    FirebasePerformancePlatform.instance = firebasePerformancePlatform;
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    return _delegate.dataCollectionEnabled;
  }

  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    _delegate.setPerformanceCollection(enabled);
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
