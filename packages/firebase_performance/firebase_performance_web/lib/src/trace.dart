import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';

/// Web implementation for TracePlatform.
class TraceWeb extends TracePlatform {
  final firebase.Trace traceDelegate;

  TraceWeb(FirebasePerformancePlatform performance, this.traceDelegate, handle,
      String name)
      : super(performance, handle, name);

  @override
  Future<void> start() async {
    traceDelegate.start();
  }

  @override
  Future<void> stop() async {
    traceDelegate.stop();
  }

  @override
  Future<void> incrementMetric(String name, int value) async {
    traceDelegate.incrementMetric(name, value);
  }

  @override
  Future<void> setMetric(String name, int value) async {
    return;
  }

  @override
  Future<int> getMetric(String name) async {
    return traceDelegate.getMetric(name);
  }

  @override
  Future<void> putAttribute(String name, String value) async {
    traceDelegate.putAttribute(name, value);
  }

  @override
  Future<void> removeAttribute(String name) async {
    traceDelegate.removeAttribute(name);
  }

  @override
  String? getAttribute(String name) {
    return traceDelegate.getAttribute(name);
  }

  @override
  Future<Map<String, String>> getAttributes() async {
    return traceDelegate.getAttributes().cast();
  }
}
