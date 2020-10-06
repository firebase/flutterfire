@JS('firebase.analytics')
library firebase.performance_interop;

import 'package:js/js.dart';

@JS('Performance')
abstract class PerformanceJsImpl {
  external TraceJsImpl trace(String traceName);
}

@JS('Trace')
@anonymous
class TraceJsImpl {
  external String getAttribute(String attr);
  external Object getAttributes();
  external int getMetric(String metricName);
  external void incrementMetric(String metricName, [int num]);
  external void putAttribute(String attr, String value);
  external void removeAttribute(String attr);
  external void start();
  external void stop();
}
