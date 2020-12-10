// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.crashlytics.FirebaseCrashlytics;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** FlutterFirebaseCrashlyticsPlugin */
public class FlutterFirebaseCrashlyticsPlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  public static final String TAG = "FLTFirebaseCrashlytics";
  private MethodChannel channel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    FlutterFirebaseCrashlyticsPlugin instance = new FlutterFirebaseCrashlyticsPlugin();
    instance.initInstance(registrar.messenger());
  }

  private void initInstance(BinaryMessenger messenger) {
    String channelName = "plugins.flutter.io/firebase_crashlytics";
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);
    FlutterFirebasePluginRegistry.registerPlugin(channelName, this);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  private Task<Map<String, Object>> checkForUnsentReports() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          final boolean unsentReports =
              Tasks.await(FirebaseCrashlytics.getInstance().checkForUnsentReports());

          return new HashMap<String, Object>() {
            {
              put(Constants.UNSENT_REPORTS, unsentReports);
            }
          };
        });
  }

  private void crash() {
    new Handler()
        .postDelayed(
            () -> {
              throw new FirebaseCrashlyticsTestCrash();
            },
            50);
  }

  private Task<Void> deleteUnsentReports() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseCrashlytics.getInstance().deleteUnsentReports();
          return null;
        });
  }

  private Task<Map<String, Object>> didCrashOnPreviousExecution() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          final boolean didCrashOnPreviousExecution =
              FirebaseCrashlytics.getInstance().didCrashOnPreviousExecution();

          return new HashMap<String, Object>() {
            {
              put(Constants.DID_CRASH_ON_PREVIOUS_EXECUTION, didCrashOnPreviousExecution);
            }
          };
        });
  }

  private Task<Void> recordError(final Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseCrashlytics crashlytics = FirebaseCrashlytics.getInstance();

          final String dartExceptionMessage =
              (String) Objects.requireNonNull(arguments.get(Constants.EXCEPTION));
          final String reason = (String) arguments.get(Constants.REASON);
          final String information =
              (String) Objects.requireNonNull(arguments.get(Constants.INFORMATION));

          Exception exception;
          if (reason != null) {
            // Set a "reason" (to match iOS) to show where the exception was thrown.
            crashlytics.setCustomKey(Constants.FLUTTER_ERROR_REASON, "thrown " + reason);
            exception =
                new FlutterError(dartExceptionMessage + ". " + "Error thrown " + reason + ".");
          } else {
            exception = new FlutterError(dartExceptionMessage);
          }
          crashlytics.setCustomKey(Constants.FLUTTER_ERROR_EXCEPTION, dartExceptionMessage);

          final List<StackTraceElement> elements = new ArrayList<>();
          @SuppressWarnings("unchecked")
          final List<Map<String, String>> errorElements =
              (List<Map<String, String>>)
                  Objects.requireNonNull(arguments.get(Constants.STACK_TRACE_ELEMENTS));

          for (Map<String, String> errorElement : errorElements) {
            final StackTraceElement stackTraceElement = generateStackTraceElement(errorElement);
            if (stackTraceElement != null) {
              elements.add(stackTraceElement);
            }
          }
          exception.setStackTrace(elements.toArray(new StackTraceElement[0]));

          // Log information.
          if (!information.isEmpty()) {
            crashlytics.log(information);
          }

          crashlytics.recordException(exception);
          return null;
        });
  }

  private Task<Void> log(final Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String message = (String) Objects.requireNonNull(arguments.get(Constants.MESSAGE));
          FirebaseCrashlytics.getInstance().log(message);
          return null;
        });
  }

  private Task<Void> sendUnsentReports() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseCrashlytics.getInstance().sendUnsentReports();
          return null;
        });
  }

  private Task<Map<String, Object>> setCrashlyticsCollectionEnabled(
      final Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Boolean enabled = (Boolean) Objects.requireNonNull(arguments.get(Constants.ENABLED));
          FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(enabled);
          return new HashMap<String, Object>() {
            {
              put(
                  Constants.IS_CRASHLYTICS_COLLECTION_ENABLED,
                  isCrashlyticsCollectionEnabled(FirebaseApp.getInstance()));
            }
          };
        });
  }

  private Task<Void> setUserIdentifier(final Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String identifier = (String) Objects.requireNonNull(arguments.get(Constants.IDENTIFIER));
          FirebaseCrashlytics.getInstance().setUserId(identifier);
          return null;
        });
  }

  private Task<Void> setCustomKey(final Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String key = (String) Objects.requireNonNull(arguments.get(Constants.KEY));
          String value = (String) Objects.requireNonNull(arguments.get(Constants.VALUE));
          FirebaseCrashlytics.getInstance().setCustomKey(key, value);
          return null;
        });
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull final MethodChannel.Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "Crashlytics#checkForUnsentReports":
        methodCallTask = checkForUnsentReports();
        break;
      case "Crashlytics#crash":
        crash();
        return;
      case "Crashlytics#deleteUnsentReports":
        methodCallTask = deleteUnsentReports();
        break;
      case "Crashlytics#didCrashOnPreviousExecution":
        methodCallTask = didCrashOnPreviousExecution();
        break;
      case "Crashlytics#recordError":
        methodCallTask = recordError(call.arguments());
        break;
      case "Crashlytics#log":
        methodCallTask = log(call.arguments());
        break;
      case "Crashlytics#sendUnsentReports":
        methodCallTask = sendUnsentReports();
        break;
      case "Crashlytics#setCrashlyticsCollectionEnabled":
        methodCallTask = setCrashlyticsCollectionEnabled(call.arguments());
        break;
      case "Crashlytics#setUserIdentifier":
        methodCallTask = setUserIdentifier(call.arguments());
        break;
      case "Crashlytics#setCustomKey":
        methodCallTask = setCustomKey(call.arguments());
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

  /**
   * Extract StackTraceElement from Dart stack trace element.
   *
   * @param errorElement Map representing the parts of a Dart error.
   * @return Stack trace element to be used as part of an Exception stack trace.
   */
  private StackTraceElement generateStackTraceElement(Map<String, String> errorElement) {
    try {
      String fileName = errorElement.get(Constants.FILE);
      String lineNumber = errorElement.get(Constants.LINE);
      String className = errorElement.get(Constants.CLASS);
      String methodName = errorElement.get(Constants.METHOD);

      return new StackTraceElement(
          className == null ? "" : className,
          methodName,
          fileName,
          Integer.parseInt(Objects.requireNonNull(lineNumber)));
    } catch (Exception e) {
      Log.e(TAG, "Unable to generate stack trace element from Dart error.");
      return null;
    }
  }

  private SharedPreferences getCrashlyticsSharedPrefs(Context context) {
    return context.getSharedPreferences("com.google.firebase.crashlytics", 0);
  }

  // TODO remove once Crashlytics public API supports isCrashlyticsCollectionEnabled
  /**
   * Firebase Crashlytics SDK doesn't provide a way to read current enabled status. So we read it
   * ourselves from shared preferences instead.
   */
  private boolean isCrashlyticsCollectionEnabled(FirebaseApp app) {
    boolean enabled;
    SharedPreferences crashlyticsSharedPrefs =
        getCrashlyticsSharedPrefs(app.getApplicationContext());

    if (crashlyticsSharedPrefs.contains("firebase_crashlytics_collection_enabled")) {
      enabled = crashlyticsSharedPrefs.getBoolean("firebase_crashlytics_collection_enabled", true);
    } else {
      if (app.isDataCollectionDefaultEnabled()) {
        FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(true);
        enabled = true;
      } else {
        enabled = false;
      }
    }

    return enabled;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(
        () ->
            new HashMap<String, Object>() {
              {
                put(
                    Constants.IS_CRASHLYTICS_COLLECTION_ENABLED,
                    isCrashlyticsCollectionEnabled(FirebaseApp.getInstance()));
              }
            });
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(() -> null);
  }
}
