import 'package:firebase_performance_platform_interface/src/platform_interface/platform_interface_attributes.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_interface_firebase_performance.dart';

abstract class HttpMetricPlatform extends PerformanceAttributesPlatform {
  HttpMetricPlatform(this.url, this.httpMethod);

  static void verifyExtends(HttpMetricPlatform instance) {
    PlatformInterface.verifyToken(instance, Object);
  }

  final String url;
  final HttpMethod httpMethod;

  /// HttpResponse code of the request.
  int? get httpResponseCode {
    throw UnimplementedError('getHttpResponseCode() is not implemented');
  }

  /// Size of the request payload.
  int? get requestPayloadSize {
    throw UnimplementedError('getRequestPayloadSize() is not implemented');
  }

  /// Content type of the response such as text/html, application/json, etc...
  String? get responseContentType {
    throw UnimplementedError('getResponseContentType() is not implemented');
  }

  /// Size of the response payload.
  int? get responsePayloadSize {
    throw UnimplementedError('getResponsePayloadSize() is not implemented');
  }

  set httpResponseCode(int? httpResponseCode) {
    throw UnimplementedError('setHttpResponseCode() is not implemented');
  }

  set requestPayloadSize(int? requestPayloadSize) {
    throw UnimplementedError('setRequestPayloadSize() is not implemented');
  }

  set responsePayloadSize(int? responsePayloadSize) {
    throw UnimplementedError('setResponsePayload() is not implemented');
  }

  set responseContentType(String? responseContentType) {
    throw UnimplementedError('setResponseContentType() is not implemented');
  }

  Future<void> start() {
    throw UnimplementedError('start() is not implemented');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() is not implemented');
  }
}
