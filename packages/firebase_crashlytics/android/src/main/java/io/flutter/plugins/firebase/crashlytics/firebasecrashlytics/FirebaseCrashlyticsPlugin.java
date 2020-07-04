// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics.firebasecrashlytics;

import android.content.Context;
import android.util.Log;
import com.google.firebase.crashlytics.FirebaseCrashlytics;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** FirebaseCrashlyticsPlugin */
public class FirebaseCrashlyticsPlugin implements FlutterPlugin, MethodCallHandler {
  public static final String TAG = "CrashlyticsPlugin";
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    BinaryMessenger binaryMessenger = binding.getBinaryMessenger();
    channel = setup(binaryMessenger, binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  private static MethodChannel setup(BinaryMessenger binaryMessenger, Context context) {
    final MethodChannel channel =
        new MethodChannel(binaryMessenger, "plugins.flutter.io/firebase_crashlytics");
    channel.setMethodCallHandler(new FirebaseCrashlyticsPlugin());
    return channel;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    setup(registrar.messenger(), registrar.context());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.getInstance();
    if (call.method.equals("Crashlytics#onError")) {
      // Report crash.
      final String dartExceptionMessage = (String) call.argument("exception");
      final Exception exception = new Exception(dartExceptionMessage);
      final List<Map<String, String>> errorElements = call.argument("stackTraceElements");
      final List<StackTraceElement> elements = new ArrayList<>();
      for (Map<String, String> errorElement : errorElements) {
        final StackTraceElement stackTraceElement = generateStackTraceElement(errorElement);
        if (stackTraceElement != null) {
          elements.add(stackTraceElement);
        }
      }
      exception.setStackTrace(elements.toArray(new StackTraceElement[elements.size()]));

      crashlytics.setCustomKey("exception", (String) call.argument("exception"));

      // Set a "reason" (to match iOS) to show where the exception was thrown.
      final String context = call.argument("context");
      if (context != null) crashlytics.setCustomKey("reason", "thrown " + context);

      // Log information.
      final String information = call.argument("information");
      if (information != null && !information.isEmpty()) crashlytics.log(information);

      crashlytics.recordException(exception);
      result.success("Error reported to Crashlytics.");
    } else if (call.method.equals("Crashlytics#setUserIdentifier")) {
      crashlytics.setUserId((String) call.argument("identifier"));
      result.success(null);
    } else if (call.method.equals("Crashlytics#setKey")) {
      final String key = (String) call.argument("key");
      final String value = (String) call.argument("value");
      crashlytics.setCustomKey(key, value);
      result.success(null);
    } else if (call.method.equals("Crashlytics#log")) {
      final String msg = (String) call.argument("log");
      crashlytics.log(msg);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  /**
   * Extract StackTraceElement from Dart stack trace element.
   *
   * @param errorElement Map representing the parts of a Dart error.
   * @return Stack trace element to be used as part of an Exception stack trace.
   */
  private StackTraceElement generateStackTraceElement(Map<String, String> errorElement) {
    try {
      String fileName = errorElement.get("file");
      String lineNumber = errorElement.get("line");
      String className = errorElement.get("class");
      String methodName = errorElement.get("method");

      return new StackTraceElement(
          className == null ? "" : className, methodName, fileName, Integer.parseInt(lineNumber));
    } catch (Exception e) {
      Log.e(TAG, "Unable to generate stack trace element from Dart side error.");
      return null;
    }
  }
}
