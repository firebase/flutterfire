import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_interface_firebase_performance.dart';

abstract class HttpMetricPlatform extends PlatformInterface {
  HttpMetricPlatform(this.url, this.httpMethod) : super(token: Object());

  static void verifyExtends(HttpMetricPlatform instance) {
    PlatformInterface.verifyToken(instance, Object);
  }

  /// Maximum allowed length of a key passed to [putAttribute].
  static const int maxAttributeKeyLength = 40;

  /// Maximum allowed length of a value passed to [putAttribute].
  static const int maxAttributeValueLength = 100;

  /// Maximum allowed number of attributes that can be added.
  static const int maxCustomAttributes = 5;

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
