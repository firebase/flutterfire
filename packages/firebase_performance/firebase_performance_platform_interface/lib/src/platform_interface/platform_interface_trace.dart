import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class TracePlatform extends PlatformInterface {
  TracePlatform(this.name) : super(token: Object());

  static void verifyExtends(TracePlatform instance) {
    PlatformInterface.verifyToken(instance, Object());
  }

  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

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

  Future<void> putAttribute(String name, String value) {
    throw UnimplementedError('putAttribute() is not implemented');
  }

  Future<void> removeAttribute(String name) {
    throw UnimplementedError('removeAttribute() is not implemented');
  }

  String? getAttribute(String name) {
    throw UnimplementedError('getAttribute() is not implemented');
  }

  Future<Map<String, String>> getAttributes() {
    throw UnimplementedError('getAttributes() is not implemented');
  }

  Future<int> getMetric(String name) {
    throw UnimplementedError('getMetric() is not implemented');
  }
}
