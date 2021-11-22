// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_web/firebase_core_web_interop.dart' hide jsify;
import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'interop/performance.dart' as performance_interop;
import 'internals.dart';

/// Web implementation for TracePlatform.
class TraceWeb extends TracePlatform {
  final performance_interop.Trace traceDelegate;

  final Map<String, String> _attributes = <String, String>{};
  final Map<String, int> _metrics = <String, int>{};

  bool _hasStarted = false;
  bool _hasStopped = false;

  TraceWeb(this.traceDelegate, String name) : super(name);

  @override
  Future<void> start() async {
    await guard(traceDelegate.start);
  }

  @override
  Future<void> stop() async {
    await guard(traceDelegate.stop);
  }

  @override
  Future<void> incrementMetric(String name, int value) async {
    await guard(() => traceDelegate.incrementMetric(name, value));
    _metrics[name] = value;
  }

  @override
  Future<void> setMetric(String name, int value) async {
    await guard(() => traceDelegate.putMetric(name, value));
  }

  @override
  int getMetric(String name) {
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
  Map<String, String> getAttributes() {
    return traceDelegate.getAttributes();
  }
}
