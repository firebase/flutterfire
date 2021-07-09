import 'package:firebase_performance_platform_interface/src/platform_interface/platform_interface_attributes.dart';

import 'method_channel_firebase_performance.dart';

class MethodChannelPerformanceAttributes extends PerformanceAttributesPlatform {
  MethodChannelPerformanceAttributes(this._handle);

  final Map<String, String> _attributes = <String, String>{};

  bool _hasStopped = false;

  final int _handle;

  @override
  Future<void> putAttribute(String name, String value) {
    if (_hasStopped ||
        name.length > PerformanceAttributesPlatform.maxAttributeKeyLength ||
        value.length > PerformanceAttributesPlatform.maxAttributeValueLength ||
        _attributes.length ==
            PerformanceAttributesPlatform.maxCustomAttributes) {
      return Future<void>.value();
    }

    _attributes[name] = value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'PerformanceAttributes#putAttribute',
      <String, Object?>{
        'handle': _handle,
        'name': name,
        'value': value,
      },
    );
  }

  @override
  Future<void> removeAttribute(String name) {
    if (_hasStopped) return Future<void>.value();

    _attributes.remove(name);
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'PerformanceAttributes#removeAttribute',
      <String, Object?>{'handle': _handle, 'name': name},
    );
  }

  @override
  String? getAttribute(String name) => _attributes[name];

  @override
  Future<Map<String, String>> getAttributes() async {
    if (_hasStopped) {
      return Future<Map<String, String>>.value(
        Map<String, String>.unmodifiable(_attributes),
      );
    }

    final attributes = await MethodChannelFirebasePerformance.channel
        .invokeMapMethod<String, String>(
      'PerformanceAttributes#getAttributes',
      <String, Object?>{'handle': _handle},
    );
    return attributes ?? {};
  }
}
