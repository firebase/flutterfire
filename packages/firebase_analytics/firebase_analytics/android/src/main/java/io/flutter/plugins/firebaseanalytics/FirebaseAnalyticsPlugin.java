// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseanalytics;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Parcelable;
import androidx.annotation.NonNull;
import com.google.firebase.FirebaseApp;
import com.google.firebase.analytics.FirebaseAnalytics;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.Map;

/** Flutter plugin for Firebase Analytics. */
public class FirebaseAnalyticsPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
  private FirebaseAnalytics firebaseAnalytics;
  private MethodChannel methodChannel;
  // Only set registrar for v1 embedder.
  private PluginRegistry.Registrar registrar;
  // Only set activity for v2 embedder. Always access activity from getActivity() method.
  private Activity activity;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    FirebaseAnalyticsPlugin instance = new FirebaseAnalyticsPlugin();
    instance.registrar = registrar;
    instance.onAttachedToEngine(registrar.context(), registrar.messenger());
  }

  // Only access activity with this method.
  private Activity getActivity() {
    return registrar != null ? registrar.activity() : activity;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  private void onAttachedToEngine(Context applicationContext, BinaryMessenger binaryMessenger) {
    FirebaseApp.initializeApp(applicationContext);
    firebaseAnalytics = FirebaseAnalytics.getInstance(applicationContext);
    methodChannel = new MethodChannel(binaryMessenger, "plugins.flutter.io/firebase_analytics");
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    firebaseAnalytics = null;
    methodChannel = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {}

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "logEvent":
        handleLogEvent(call, result);
        break;
      case "setUserId":
        handleSetUserId(call, result);
        break;
      case "setCurrentScreen":
        handleSetCurrentScreen(call, result);
        break;
      case "setAnalyticsCollectionEnabled":
        handleSetAnalyticsCollectionEnabled(call, result);
        break;
      case "setSessionTimeoutDuration":
        handleSetSessionTimeoutDuration(call, result);
        break;
      case "setUserProperty":
        handleSetUserProperty(call, result);
        break;
      case "resetAnalyticsData":
        handleResetAnalyticsData(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void setActivity(Activity activity) {
    this.activity = activity;
  }

  private void handleLogEvent(MethodCall call, Result result) {

    final String eventName = call.argument("name");
    final Map<String, Object> map = call.argument("parameters");
    final Bundle parameterBundle = createBundleFromMap(map);
    firebaseAnalytics.logEvent(eventName, parameterBundle);
    result.success(null);
  }

  private void handleSetUserId(MethodCall call, Result result) {
    final String id = (String) call.arguments;
    firebaseAnalytics.setUserId(id);
    result.success(null);
  }

  private void handleSetCurrentScreen(MethodCall call, Result result) {
    if (getActivity() == null) {
      result.error("no_activity", "handleSetCurrentScreen requires a foreground activity", null);
      return;
    }

    final String screenName = call.argument("screenName");
    final String screenClassOverride = call.argument("screenClassOverride");

    firebaseAnalytics.setCurrentScreen(getActivity(), screenName, screenClassOverride);
    result.success(null);
  }

  private void handleSetAnalyticsCollectionEnabled(MethodCall call, Result result) {
    final Boolean enabled = call.arguments();
    firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
    result.success(null);
  }

  private void handleSetSessionTimeoutDuration(MethodCall call, Result result) {
    final Integer milliseconds = call.arguments();
    firebaseAnalytics.setSessionTimeoutDuration(milliseconds);
    result.success(null);
  }

  private void handleSetUserProperty(MethodCall call, Result result) {
    final String name = call.argument("name");
    final String value = call.argument("value");

    firebaseAnalytics.setUserProperty(name, value);
    result.success(null);
  }

  private void handleResetAnalyticsData(Result result) {
    firebaseAnalytics.resetAnalyticsData();
    result.success(null);
  }

  private static Bundle createBundleFromMap(Map<String, Object> map) {
    if (map == null) {
      return null;
    }

    Bundle bundle = new Bundle();
    for (Map.Entry<String, Object> jsonParam : map.entrySet()) {
      final Object value = jsonParam.getValue();
      final String key = jsonParam.getKey();
      if (value instanceof String) {
        bundle.putString(key, (String) value);
      } else if (value instanceof Integer) {
        bundle.putInt(key, (Integer) value);
      } else if (value instanceof Long) {
        bundle.putLong(key, (Long) value);
      } else if (value instanceof Double) {
        bundle.putDouble(key, (Double) value);
      } else if (value instanceof Boolean) {
        bundle.putBoolean(key, (Boolean) value);
      } else if (value instanceof Iterable<?>) {
        ArrayList<Parcelable> list = new ArrayList<Parcelable>();

        for (Object item : (Iterable<?>) value) {
          if (item instanceof Map) {
            list.add(createBundleFromMap((Map<String, Object>) item));
          } else {
            throw new IllegalArgumentException(
              "Unsupported value type: "
                + value.getClass().getCanonicalName()
                + " in list at key "
                + key);
          }
        }

        bundle.putParcelableArrayList(key, list);
      } else if (value instanceof Map<?, ?>) {
        bundle.putParcelable(key, createBundleFromMap((Map<String, Object>) value));
      } else {
        throw new IllegalArgumentException(
            "Unsupported value type: " + value.getClass().getCanonicalName());
      }
    }
    return bundle;
  }
}
