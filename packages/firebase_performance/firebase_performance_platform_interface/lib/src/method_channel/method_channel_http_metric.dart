import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';

class MethodChannelHttpMetric extends HttpMetricPlatform {
  MethodChannelHttpMetric(this._handle, String url, HttpMethod httpMethod)
      : super(url, httpMethod);

  final int _handle;

  int? _httpResponseCode;
  int? _requestPayloadSize;
  String? _responseContentType;
  int? _responsePayloadSize;

  bool _hasStopped = false;

  final Map<String, String> _attributes = <String, String>{};

  @override
  int? get httpResponseCode => _httpResponseCode;

  @override
  int? get requestPayloadSize => _requestPayloadSize;

  @override
  String? get responseContentType => _responseContentType;

  @override
  int? get responsePayloadSize => _responsePayloadSize;

  @override
  set httpResponseCode(int? httpResponseCode) {
    if (_hasStopped) return;

    _httpResponseCode = httpResponseCode;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#httpResponseCode',
      <String, Object?>{
        'handle': _handle,
        'httpResponseCode': httpResponseCode,
      },
    );
  }

  @override
  set requestPayloadSize(int? requestPayloadSize) {
    if (_hasStopped) return;

    _requestPayloadSize = requestPayloadSize;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#requestPayloadSize',
      <String, Object?>{
        'handle': _handle,
        'requestPayloadSize': requestPayloadSize,
      },
    );
  }

  @override
  set responseContentType(String? responseContentType) {
    if (_hasStopped) return;

    _responseContentType = responseContentType;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#responseContentType',
      <String, Object?>{
        'handle': _handle,
        'responseContentType': responseContentType,
      },
    );
  }

  @override
  set responsePayloadSize(int? responsePayloadSize) {
    if (_hasStopped) return;

    _responsePayloadSize = responsePayloadSize;
    MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#responsePayloadSize',
      <String, Object?>{
        'handle': _handle,
        'responsePayloadSize': responsePayloadSize,
      },
    );
  }

  @override
  Future<void> start() {
    if (_hasStopped) return Future<void>.value();

    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#start',
      <String, Object?>{'handle': _handle},
    );
  }

  @override
  Future<void> stop() {
    if (_hasStopped) return Future<void>.value();

    _hasStopped = true;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#stop',
      <String, Object?>{'handle': _handle},
    );
  }

  @override
  Future<void> putAttribute(String name, String value) {
    if (_hasStopped ||
        name.length > HttpMetricPlatform.maxAttributeKeyLength ||
        value.length > HttpMetricPlatform.maxAttributeValueLength ||
        _attributes.length == HttpMetricPlatform.maxCustomAttributes) {
      return Future<void>.value();
    }

    _attributes[name] = value;
    return MethodChannelFirebasePerformance.channel.invokeMethod<void>(
      'HttpMetric#putAttribute',
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
      'HttpMetric#removeAttribute',
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
      'HttpMetric#getAttributes',
      <String, Object?>{'handle': _handle},
    );
    return attributes ?? {};
  }
}
