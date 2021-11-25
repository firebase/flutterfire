// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.performance;

import com.google.firebase.perf.metrics.Trace;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;
import java.util.Objects;

class FlutterTrace implements MethodChannel.MethodCallHandler {
  private final FlutterFirebasePerformancePlugin plugin;
  private final Trace trace;

  FlutterTrace(FlutterFirebasePerformancePlugin plugin, final Trace trace) {
    this.plugin = plugin;
    this.trace = trace;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "Trace#start":
        start(result);
        break;
      case "Trace#stop":
        stop(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void start(MethodChannel.Result result) {
    trace.start();
    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void stop(MethodCall call, MethodChannel.Result result) {
    final Map<String, Object> attributes = Objects.requireNonNull((call.argument("attributes")));
    final Map<String, Object> metrics = Objects.requireNonNull((call.argument("metrics")));

    for (String key : attributes.keySet()) {
      String attributeValue = (String) attributes.get(key);

      trace.putAttribute(key, attributeValue);
    }

    for (String key : metrics.keySet()) {
      Integer metricValue = (Integer) metrics.get(key);

      trace.putMetric(key, metricValue);
    }

    trace.stop();

    final Integer handle = call.argument("handle");
    plugin.removeHandler(handle);

    result.success(null);
  }
}
