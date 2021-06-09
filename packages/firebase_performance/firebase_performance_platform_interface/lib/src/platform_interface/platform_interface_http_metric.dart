import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'platform_interface_firebase_performance.dart';

abstract class HttpMetricPlatform extends PlatformInterface {
  HttpMetricPlatform(this.performance, handle, this.url, this.httpMethod)
      : _handle = handle,
        super(token: _token);

  static final Object _token = Object();

  static void verifyExtends(HttpMetricPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  final FirebasePerformancePlatform performance;

  final int _handle;
  final String url;
  final HttpMethod httpMethod;

  int? _httpResponseCode;
  int? _requestPayloadSize;
  String? _responseContentType;
  int? _responsePayloadSize;

  /// HttpResponse code of the request.
  int? get httpResponseCode => _httpResponseCode;

  /// Size of the request payload.
  int? get requestPayloadSize => _requestPayloadSize;

  /// Content type of the response such as text/html, application/json, etc...
  String? get responseContentType => _responseContentType;

  /// Size of the response payload.
  int? get responsePayloadSize => _responsePayloadSize;

  set httpResponseCode(int? httpResponseCode) {
    throw UnimplementedError('setHttpResponseCode() is not implemented');
  }

  set requestPayloadSize(int? requestPayloadSize) {
    throw UnimplementedError('setRequestPayloadSize() is not implemented');
  }

  set responsePayloadSize(int? responsePayloadSize) {
    throw UnimplementedError('setResponsePayload() is not implemented');
  }

  Future<void> start() {
    throw UnimplementedError('start() is not implemented');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() is not implemented');
  }
}
