import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/trace.dart';
import 'src/http_metric.dart';

/// Web implementation for [FirebasePerformancePlatform]
class FirebasePerformanceWeb extends FirebasePerformancePlatform {
  /// Instance of Performance from the web plugin.
  final firebase.Performance _performance;

  /// A constructor that allows tests to override the firebase.Performance object.
  FirebasePerformanceWeb({firebase.Performance? performance})
      : _performance = performance ?? firebase.performance(),
        super();

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebasePerformancePlatform.instance = FirebasePerformanceWeb();
  }

  @visibleForTesting
  static void registerWithForTest(
      FirebasePerformancePlatform firebasePerformancePlatform) {
    FirebasePerformancePlatform.instance = firebasePerformancePlatform;
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() async {
    return true;
  }

  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    return;
  }

  @override
  TracePlatform newTrace(String name) {
    return TraceWeb(_performance.trace(name), name);
  }

  @override
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    return HttpMetricWeb('', HttpMethod.Get);
  }
}
