import '../../firebase_performance_platform_interface.dart';
import 'method_channel_firebase_performance.dart';
import 'method_channel_performance_attributes.dart';

class MethodChannelHttpMetric extends HttpMetricPlatform {
  MethodChannelHttpMetric(this._handle, String url, HttpMethod httpMethod)
      : super(url, httpMethod);

  final int _handle;

  int? _httpResponseCode;
  int? _requestPayloadSize;
  String? _responseContentType;
  int? _responsePayloadSize;

  bool _hasStopped = false;

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
    return MethodChannelPerformanceAttributes(_handle)
        .putAttribute(name, value);
  }

  @override
  Future<void> removeAttribute(String name) {
    return MethodChannelPerformanceAttributes(_handle).removeAttribute(name);
  }

  @override
  String? getAttribute(String name) {
    return MethodChannelPerformanceAttributes(_handle).getAttribute(name);
  }

  @override
  Future<Map<String, String>> getAttributes() {
    return MethodChannelPerformanceAttributes(_handle).getAttributes();
  }
}
