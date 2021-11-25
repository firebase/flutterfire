import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';

/// Web implementation for HttpMetricPlatform. Custom request metrics are not
/// supported for Web apps, so this class is a dummy.
class HttpMetricWeb extends HttpMetricPlatform {
  HttpMetricWeb() : super();

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
  set responseContentType(String? responseContentType) {
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
  void putAttribute(String name, String value) {
    return;
  }

  @override
  void removeAttribute(String name) {
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
