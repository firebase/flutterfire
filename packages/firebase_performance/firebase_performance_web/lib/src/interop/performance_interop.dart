// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS('firebase_performance')
library firebase.performance_interop;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external PerformanceJsImpl getPerformance([AppJsImpl? app]);

@JS()
@staticInterop
external PerformanceJsImpl initializePerformance(
  AppJsImpl app, [
  PerformanceSettingsJsImpl? settings,
]);

@JS()
@staticInterop
external TraceJsImpl trace(PerformanceJsImpl performance, JSString traceName);

@JS('Performance')
@staticInterop
abstract class PerformanceJsImpl {}

extension PerformanceJsImplExtension on PerformanceJsImpl {
  external AppJsImpl get app;
  external JSBoolean dataCollectionEnabled;
  external JSBoolean instrumentationEnabled;
}

@JS('Trace')
@staticInterop
@anonymous
class TraceJsImpl {}

extension TraceJsImplExtension on TraceJsImpl {
  external JSString getAttribute(JSString attr);
  external JSAny getAttributes();
  external JSNumber getMetric(JSString metricName);
  external void incrementMetric(JSString metricName, [JSNumber? num]);
  external void putMetric(JSString metricName, JSNumber num);
  external void putAttribute(JSString attr, JSString value);
  external void removeAttribute(JSString attr);
  external void start();
  external void record(
    JSNumber number,
    JSNumber duration, [
    RecordOptions? options,
  ]);
  external void stop();
}

@JS()
@staticInterop
@anonymous
class RecordOptions {
  external factory RecordOptions({JSAny? metrics, JSAny? attributes});
}

extension RecordOptionsExtension on RecordOptions {
  /* map of metrics */
  external JSAny? get metrics;
  /* map of attributes */
  external JSAny? get attributes;
}

@JS()
@staticInterop
@anonymous
class PerformanceSettingsJsImpl {
  external factory PerformanceSettingsJsImpl({
    JSBoolean? dataCollectionEnabled,
    JSBoolean? instrumentationEnabled,
  });
}

extension PerformanceSettingsJsImplExtension on PerformanceSettingsJsImpl {
  external JSBoolean? get dataCollectionEnabled;
  external set dataCollectionEnabled(JSBoolean? b);
  external JSBoolean? get instrumentationEnabled;
  external set instrumentationEnabled(JSBoolean? b);
}
