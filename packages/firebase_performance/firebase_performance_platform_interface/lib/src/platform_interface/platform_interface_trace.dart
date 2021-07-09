import 'dart:async';

import 'package:firebase_performance_platform_interface/src/platform_interface/platform_interface_attributes.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class TracePlatform extends PerformanceAttributesPlatform {
  TracePlatform(this.name);

  static void verifyExtends(TracePlatform instance) {
    PlatformInterface.verifyToken(instance, Object());
  }

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
