import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';

/// Web implementation for HttpMetricPlatform. Custom request metrics are not
/// supported for Web apps, so this class is a dummy.
class HttpMetricWeb extends HttpMetricPlatform {
  HttpMetricWeb(String url, HttpMethod httpMethod) : super(url, httpMethod);

  /// HttpResponse code of the request.
  @override
  int? get httpResponseCode {
    return null;
  }

  /// Size of the request payload.
  @override
  int? get requestPayloadSize {
    return null;
  }

  /// Content type of the response such as text/html, application/json, etc...
  @override
  String? get responseContentType {
    return null;
  }

  /// Size of the response payload.
  @override
  int? get responsePayloadSize {
    return null;
  }

  @override
  set httpResponseCode(int? httpResponseCode) {
    return;
  }

  @override
  set requestPayloadSize(int? requestPayloadSize) {
    return;
  }

  @override
  set responsePayloadSize(int? responsePayloadSize) {
    return;
  }

  @override
  Future<void> start() async {
    return;
  }

  @override
  Future<void> stop() async {
    return;
  }

  @override
  Future<void> putAttribute(String name, String value) async {
    return;
  }

  @override
  Future<void> removeAttribute(String name) async {
    return;
  }

  @override
  String? getAttribute(String name) {
    return null;
  }

  @override
  Future<Map<String, String>> getAttributes() async {
    return {};
  }
}
