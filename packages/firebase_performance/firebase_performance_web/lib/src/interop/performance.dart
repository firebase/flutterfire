// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_web/firebase_core_web_interop.dart' hide jsify;

import 'firebase_interop.dart' as firebase_interop;
import 'performance_interop.dart' as performance_interop;

/// Given an AppJSImp, return the Performance instance. Performance web
/// only works with the default app.
Performance getPerformanceInstance([App? app]) {
  return Performance.getInstance(firebase_interop.performance());
}

class Performance
    extends JsObjectWrapper<performance_interop.PerformanceJsImpl> {
  static final _expando = Expando<Performance>();

  static Performance getInstance(
    performance_interop.PerformanceJsImpl jsObject,
  ) =>
      _expando[jsObject] ??= Performance._fromJsObject(jsObject);

  Performance._fromJsObject(performance_interop.PerformanceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Trace trace(String traceName) =>
      Trace.fromJsObject(jsObject.trace(traceName));

  /// Non-null App for this instance of firestore service.
  App get app => App.getInstance(jsObject.app);

  bool get instrumentationEnabled => jsObject.instrumentationEnabled;
  bool get dataCollectionEnabled => jsObject.dataCollectionEnabled;

  // ignore: use_setters_to_change_properties
  void setPerformanceCollection(bool enableDataCollection) {
    jsObject.dataCollectionEnabled = enableDataCollection;
  }

  // ignore: use_setters_to_change_properties
  void setInstrumentation(bool enableInstrumentation) {
    jsObject.instrumentationEnabled = enableInstrumentation;
  }
}

class Trace extends JsObjectWrapper<performance_interop.TraceJsImpl> {
  Trace.fromJsObject(performance_interop.TraceJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String getAttribute(String attr) => jsObject.getAttribute(attr);

  Map<String, String> getAttributes() {
    return dartify(jsObject.getAttributes()).cast<String, String>();
  }

  int getMetric(String metricName) => jsObject.getMetric(metricName);

  void incrementMetric(String metricName, [int? num]) {
    if (num != null) {
      return jsObject.incrementMetric(metricName, num);
    } else {
      return jsObject.incrementMetric(metricName);
    }
  }

  void putMetric(String metricName, int num) {
    return jsObject.putMetric(metricName, num);
  }

  void putAttribute(String attr, String value) {
    return jsObject.putAttribute(attr, value);
  }

  void removeAttribute(String attr) {
    return jsObject.removeAttribute(attr);
  }

  void start() {
    return jsObject.start();
  }

  void stop() {
    return jsObject.stop();
  }
}
