import 'dart:async';

import 'package:firebase_performance_platform_interface/src/platform_interface/platform_interface_attributes.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_interface_firebase_performance.dart';

abstract class TracePlatform extends PlatformInterface
    with PerformanceAttributesPlatform {
  TracePlatform(this.performance, handle, this.name)
      : _handle = handle,
        super(token: _token);

  static final Object _token = Object();

  static void verifyExtends(TracePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  final FirebasePerformancePlatform performance;

  final int _handle;
  final String name;

  Future<void> start() {
    throw UnimplementedError('start() is not implemented');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() is not implemented');
  }

  Future<void> incrementMetric(String name, int value) {
    throw UnimplementedError('incrementMetric() is not implemented');
  }

  /// Only works for native apps. Does nothing for web apps.
  Future<void> setMetric(String name, int value) {
    throw UnimplementedError('setMetric() is not implemented');
  }

  Future<int> getMetric(String name) {
    throw UnimplementedError('getMetric() is not implemented');
  }
}
