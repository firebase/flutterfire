// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.performance;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.firebase.FirebaseApp;
import com.google.firebase.perf.FirebasePerformance;
import com.google.firebase.perf.metrics.HttpMetric;
import com.google.firebase.perf.metrics.Trace;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * Flutter plugin accessing Firebase Performance API.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class FlutterFirebasePerformancePlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_performance";

  static final HashMap<Integer, HttpMetric> _httpMetrics = new HashMap<>();
  static final HashMap<Integer, Trace> _traces = new HashMap<>();
  static int _traceHandle = 0;
  static int _httpMetricHandle = 0;
  private MethodChannel channel;

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  private static String parseHttpMethod(String httpMethod) {
    switch (httpMethod) {
      case "HttpMethod.Connect":
        return FirebasePerformance.HttpMethod.CONNECT;
      case "HttpMethod.Delete":
        return FirebasePerformance.HttpMethod.DELETE;
      case "HttpMethod.Get":
        return FirebasePerformance.HttpMethod.GET;
      case "HttpMethod.Head":
        return FirebasePerformance.HttpMethod.HEAD;
      case "HttpMethod.Options":
        return FirebasePerformance.HttpMethod.OPTIONS;
      case "HttpMethod.Patch":
        return FirebasePerformance.HttpMethod.PATCH;
      case "HttpMethod.Post":
        return FirebasePerformance.HttpMethod.POST;
      case "HttpMethod.Put":
        return FirebasePerformance.HttpMethod.PUT;
      case "HttpMethod.Trace":
        return FirebasePerformance.HttpMethod.TRACE;
      default:
        throw new IllegalArgumentException(String.format("No HttpMethod for: %s", httpMethod));
    }
  }

  private Task<Boolean> isPerformanceCollectionEnabled() {
    TaskCompletionSource<Boolean> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            taskCompletionSource.setResult(
                FirebasePerformance.getInstance().isPerformanceCollectionEnabled());
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @SuppressWarnings("ConstantConditions")
  private Task<Void> setPerformanceCollectionEnabled(MethodCall call) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Boolean enable = call.argument("enable");
            FirebasePerformance.getInstance().setPerformanceCollectionEnabled(enable);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @SuppressWarnings("ConstantConditions")
  private Task<Integer> traceStart(MethodCall call) {
    TaskCompletionSource<Integer> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final String name = call.argument("name");
            final Trace trace = FirebasePerformance.getInstance().newTrace(name);
            trace.start();
            final int traceHandle = _traceHandle++;
            _traces.put(traceHandle, trace);
            taskCompletionSource.setResult(traceHandle);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @SuppressWarnings("ConstantConditions")
  private Task<Void> traceStop(MethodCall call) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final int traceHandle = Objects.requireNonNull(call.argument("handle"));
            final Map<String, Object> attributes =
                Objects.requireNonNull((call.argument("attributes")));
            final Map<String, Object> metrics = Objects.requireNonNull((call.argument("metrics")));
            final Trace trace = _traces.get(traceHandle);

            for (String key : attributes.keySet()) {
              String attributeValue = (String) attributes.get(key);

              trace.putAttribute(key, attributeValue);
            }

            for (String key : metrics.keySet()) {
              Integer metricValue = (Integer) metrics.get(key);

              trace.putMetric(key, metricValue);
            }

            trace.stop();

            _traces.remove(traceHandle);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Integer> httpMetricStart(MethodCall call) {
    TaskCompletionSource<Integer> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final String url = Objects.requireNonNull(call.argument("url"));
            final String httpMethod = Objects.requireNonNull(call.argument("httpMethod"));

            final HttpMetric httpMetric =
                FirebasePerformance.getInstance().newHttpMetric(url, parseHttpMethod(httpMethod));
            httpMetric.start();
            final int httpMetricHandle = _httpMetricHandle++;
            _httpMetrics.put(httpMetricHandle, httpMetric);
            taskCompletionSource.setResult(httpMetricHandle);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @SuppressWarnings("ConstantConditions")
  private Task<Void> httpMetricStop(MethodCall call) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final int httpMetricHandle = Objects.requireNonNull(call.argument("handle"));
            final Map<String, Object> attributes =
                Objects.requireNonNull((call.argument("attributes")));
            final Integer httpResponseCode = call.argument("httpResponseCode");
            final Integer requestPayloadSize = call.argument("requestPayloadSize");
            final String responseContentType = call.argument("responseContentType");
            final Integer responsePayloadSize = call.argument("responsePayloadSize");

            final HttpMetric httpMetric = _httpMetrics.get(httpMetricHandle);

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
            _httpMetrics.remove(httpMetricHandle);

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "FirebasePerformance#isPerformanceCollectionEnabled":
        methodCallTask = isPerformanceCollectionEnabled();
        break;
      case "FirebasePerformance#setPerformanceCollectionEnabled":
        methodCallTask = setPerformanceCollectionEnabled(call);
        break;
      case "FirebasePerformance#httpMetricStart":
        methodCallTask = httpMetricStart(call);
        break;
      case "FirebasePerformance#httpMetricStop":
        methodCallTask = httpMetricStop(call);
        break;
      case "FirebasePerformance#traceStart":
        methodCallTask = traceStart(call);
        break;
      case "FirebasePerformance#traceStop":
        methodCallTask = traceStop(call);
        break;
      default:
        result.notImplemented();
        return;
    }

    methodCallTask.addOnCompleteListener(
        task -> {
          if (task.isSuccessful()) {
            result.success(task.getResult());
          } else {
            Exception exception = task.getException();
            String message =
                exception != null ? exception.getMessage() : "An unknown error occurred";
            result.error("firebase_crashlytics", message, null);
          }
        });
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            taskCompletionSource.setResult(new HashMap<String, Object>() {});
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            for (Trace trace : _traces.values()) {
              trace.stop();
            }
            _traces.clear();
            for (HttpMetric httpMetric : _httpMetrics.values()) {
              httpMetric.stop();
            }
            _httpMetrics.clear();

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }
}
