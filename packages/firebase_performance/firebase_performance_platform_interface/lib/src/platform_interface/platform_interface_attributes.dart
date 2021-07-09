import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class PerformanceAttributesPlatform extends PlatformInterface {
  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

  PerformanceAttributesPlatform() : super(token: Object());

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
}
