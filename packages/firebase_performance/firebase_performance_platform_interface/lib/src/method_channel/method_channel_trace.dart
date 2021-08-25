import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';

class MethodChannelTrace extends TracePlatform {
  MethodChannelTrace(this._handle, String name) : super(name);

  final int _handle;

  bool _hasStarted = false;
  bool _hasStopped = false;

  final Map<String, int> _metrics = <String, int>{};
  final Map<String, String> _attributes = <String, String>{};

  static const int maxTraceNameLength = 100;

  @override
  Future<void> start() {
    if (_hasStopped) return Future<void>.value();

    _hasStarted = true;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#start',
      <String, Object?>{'handle': _handle},
    );
  }

  @override
  Future<void> stop() {
    if (_hasStopped) return Future<void>.value();

    _hasStopped = true;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#stop',
      <String, Object?>{'handle': _handle},
    );
  }

  @override
  Future<void> incrementMetric(String name, int value) {
    if (!_hasStarted || _hasStopped) {
      return Future<void>.value();
    }

    _metrics[name] = (_metrics[name] ?? 0) + value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#incrementMetric',
      <String, Object?>{'handle': _handle, 'name': name, 'value': value},
    );
  }

  @override
  Future<void> setMetric(String name, int value) {
    if (!_hasStarted || _hasStopped) return Future<void>.value();

    _metrics[name] = value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#setMetric',
      <String, Object?>{'handle': _handle, 'name': name, 'value': value},
    );
  }

  @override
  Future<int> getMetric(String name) async {
    if (_hasStopped) return Future<int>.value(_metrics[name] ?? 0);

    final metric =
        await MethodChannelFirebasePerformance.channel.invokeMethod<int>(
      'Trace#getMetric',
      <String, Object?>{'handle': _handle, 'name': name},
    );
    return metric ?? 0;
  }

  @override
  Future<void> putAttribute(String name, String value) {
    if (_hasStopped ||
        name.length > TracePlatform.maxAttributeKeyLength ||
        value.length > TracePlatform.maxAttributeValueLength ||
        _attributes.length == TracePlatform.maxCustomAttributes) {
      return Future<void>.value();
    }

    _attributes[name] = value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'Trace#putAttribute',
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
      'Trace#removeAttribute',
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
      'Trace#getAttributes',
      <String, Object?>{'handle': _handle},
    );
    return attributes ?? {};
  }
}
