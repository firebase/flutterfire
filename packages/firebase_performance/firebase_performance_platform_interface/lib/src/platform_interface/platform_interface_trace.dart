import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'platform_interface_firebase_performance.dart';

abstract class TracePlatform extends PlatformInterface {
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
  final Map<String, String> _attributes = <String, String>{};

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

  Future<void> putAttribute(String name, String value) {
    throw UnimplementedError('putAttribute() is not implemented');
  }

  Future<void> removeAttribute(String name) {
    throw UnimplementedError('removeAttribute() is not implemented');
  }

  String? getAttribute(String name) => _attributes[name];

  Future<Map<String, String>> getAttributes() {
    throw UnimplementedError('getAttributes() is not implemented');
  }
}
