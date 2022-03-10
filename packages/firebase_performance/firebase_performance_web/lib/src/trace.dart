// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'interop/performance.dart' as performance_interop;
import 'internals.dart';

/// Web implementation for TracePlatform.
class TraceWeb extends TracePlatform {
  final performance_interop.Trace traceDelegate;

  TraceWeb(this.traceDelegate) : super();

  @override
  Future<void> start() async {
    await convertWebExceptions(traceDelegate.start);
  }

  @override
  Future<void> stop() async {
    await convertWebExceptions(traceDelegate.stop);
  }

  @override
  void incrementMetric(String name, int value) {
    traceDelegate.incrementMetric(name, value);
  }

  @override
  void setMetric(String name, int value) {
    traceDelegate.putMetric(name, value);
  }

  @override
  int getMetric(String name) {
    return traceDelegate.getMetric(name);
  }

  @override
  void putAttribute(String name, String value) {
    traceDelegate.putAttribute(name, value);
  }

  @override
  void removeAttribute(String name) {
    traceDelegate.removeAttribute(name);
  }

  @override
  String? getAttribute(String name) {
    return traceDelegate.getAttribute(name);
  }

  @override
  Map<String, String> getAttributes() {
    return traceDelegate.getAttributes();
  }
}
