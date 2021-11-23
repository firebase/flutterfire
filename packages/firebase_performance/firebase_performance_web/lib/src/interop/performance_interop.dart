// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS('firebase.performance')
library firebase.performance_interop;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS('Performance')
abstract class PerformanceJsImpl {
  external AppJsImpl get app;
  external TraceJsImpl trace(String traceName);
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
  external void putMetric(String metricName, [int num]);
  external void putAttribute(String attr, String value);
  external void removeAttribute(String attr);
  external void start();
  external void stop();
}
