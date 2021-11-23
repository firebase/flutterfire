import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';

/// Web implementation for HttpMetricPlatform. Custom request metrics are not
/// supported for Web apps, so this class is a dummy.
class HttpMetricWeb extends HttpMetricPlatform {
  HttpMetricWeb(String url, HttpMethod httpMethod) : super(url, httpMethod);

  /// HttpResponse code of the request.
  @override
  int? get httpResponseCode {
    // ignore: avoid_returning_null
    return null;
  }

  /// Size of the request payload.
  @override
  int? get requestPayloadSize {
    // ignore: avoid_returning_null
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
    // ignore: avoid_returning_null
    return null;
  }

  @override
  Future<void> setHttpResponseCode(int? httpResponseCode) async {
    return;
  }

  @override
  Future<void> setRequestPayloadSize(int? requestPayloadSize) async {
    return;
  }

  @override
  Future<void> setResponsePayloadSize(int? responsePayloadSize) async {
    return;
  }

  @override
  Future<void> setResponseContentType(String? responseContentType) async {
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
  Map<String, String> getAttributes() {
    return {};
  }
}
