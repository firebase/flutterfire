// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.performance;

import com.google.firebase.perf.metrics.HttpMetric;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;
import java.util.Objects;

class FlutterHttpMetric implements MethodChannel.MethodCallHandler {
  private final FlutterFirebasePerformancePlugin plugin;
  private final HttpMetric httpMetric;

  FlutterHttpMetric(FlutterFirebasePerformancePlugin plugin, final HttpMetric metric) {
    this.plugin = plugin;
    this.httpMetric = metric;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "HttpMetric#start":
        start(result);
        break;
      case "HttpMetric#stop":
        stop(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void start(MethodChannel.Result result) {
    httpMetric.start();
    result.success(null);
  }

  @SuppressWarnings("ConstantConditions")
  private void stop(MethodCall call, MethodChannel.Result result) {
    final Map<String, Object> attributes = Objects.requireNonNull((call.argument("attributes")));
    final Integer httpResponseCode = call.argument("httpResponseCode");
    final Integer requestPayloadSize = call.argument("requestPayloadSize");
    final String responseContentType = call.argument("responseContentType");
    final Integer responsePayloadSize = call.argument("responsePayloadSize");

    if (httpResponseCode != null) {
      httpMetric.setHttpResponseCode(httpResponseCode);
    }
    if (requestPayloadSize != null) {
      httpMetric.setRequestPayloadSize(requestPayloadSize);
    }
    if (responseContentType != null) {
      httpMetric.setResponseContentType(responseContentType);
    }
    if (responsePayloadSize != null) {
      httpMetric.setResponsePayloadSize(responsePayloadSize);
    }

    for (String key : attributes.keySet()) {
      String attributeValue = (String) attributes.get(key);

      httpMetric.putAttribute(key, attributeValue);
    }

    httpMetric.stop();

    final Integer handle = call.argument("handle");
    plugin.removeHandler(handle);

    result.success(null);
  }
}
