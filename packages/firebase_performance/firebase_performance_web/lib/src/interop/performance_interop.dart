// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS('firebase_performance')
library firebase.performance_interop;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS()
external PerformanceJsImpl getPerformance([AppJsImpl? app]);

@JS()
external PerformanceJsImpl initializePerformance(
  AppJsImpl app, [
  PerformanceSettingsJsImpl? settings,
]);

@JS()
external TraceJsImpl trace(PerformanceJsImpl performance, String traceName);

@JS('Performance')
abstract class PerformanceJsImpl {
  external AppJsImpl get app;
  external bool dataCollectionEnabled;
  external bool instrumentationEnabled;
}

@JS('Trace')
@anonymous
class TraceJsImpl {
  external String getAttribute(String attr);
  external Object getAttributes();
  external int getMetric(String metricName);
  external void incrementMetric(String metricName, [int? num]);
  external void putMetric(String metricName, int num);
  external void putAttribute(String attr, String value);
  external void removeAttribute(String attr);
  external void start();
  external void record(int number, int duration, [RecordOptions? options]);
  external void stop();
}

@JS()
@anonymous
class RecordOptions {
  /* map of metrics */
  external Object? get metrics;
  /* map of attributes */
  external Object? get attributes;
  external factory RecordOptions({Object? metrics, Object? attributes});
}

@JS()
@anonymous
class PerformanceSettingsJsImpl {
  external bool? get dataCollectionEnabled;
  external set dataCollectionEnabled(bool? b);
  external bool? get instrumentationEnabled;
  external set instrumentationEnabled(bool? b);
  external factory PerformanceSettingsJsImpl({
    bool? dataCollectionEnabled,
    bool? instrumentationEnabled,
  });
}
