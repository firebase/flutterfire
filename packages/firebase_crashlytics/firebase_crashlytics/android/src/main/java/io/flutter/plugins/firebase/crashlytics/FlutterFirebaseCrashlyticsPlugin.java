// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.crashlytics.FirebaseCrashlytics;
import com.google.firebase.crashlytics.FlutterFirebaseCrashlyticsInternal;
import com.google.firebase.crashlytics.internal.Logger;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** FlutterFirebaseCrashlyticsPlugin */
public class FlutterFirebaseCrashlyticsPlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  public static final String TAG = "FLTFirebaseCrashlytics";
  private MethodChannel channel;
  private EventChannel testEventChannel;
  private EventChannel.EventSink testEventSink;

  private static final String FIREBASE_CRASHLYTICS_COLLECTION_ENABLED =
      "firebase_crashlytics_collection_enabled";

  private void initInstance(BinaryMessenger messenger) {
    String channelName = "plugins.flutter.io/firebase_crashlytics";
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);
    FlutterFirebasePluginRegistry.registerPlugin(channelName, this);
    testEventChannel =
        new EventChannel(messenger, "plugins.flutter.io/firebase_crashlytics_test_stream");
    testEventChannel.setStreamHandler(this);
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
    if (testEventChannel != null) {
      testEventChannel.setStreamHandler(null);
      testEventChannel = null;
    }
  }

  private Task<Map<String, Object>> checkForUnsentReports() {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final boolean unsentReports =
                Tasks.await(FirebaseCrashlytics.getInstance().checkForUnsentReports());

            taskCompletionSource.setResult(
                new HashMap<String, Object>() {
                  {
                    put(Constants.UNSENT_REPORTS, unsentReports);
                  }
                });
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private void crash() {
    new Handler(Looper.myLooper())
        .postDelayed(
            () -> {
              throw new FirebaseCrashlyticsTestCrash();
            },
            50);
  }

  private Task<Void> deleteUnsentReports() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseCrashlytics.getInstance().deleteUnsentReports();
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> didCrashOnPreviousExecution() {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final boolean didCrashOnPreviousExecution =
                FirebaseCrashlytics.getInstance().didCrashOnPreviousExecution();

            taskCompletionSource.setResult(
                new HashMap<String, Object>() {
                  {
                    put(Constants.DID_CRASH_ON_PREVIOUS_EXECUTION, didCrashOnPreviousExecution);
                  }
                });
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> recordError(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();
    Handler mainHandler = new Handler(Looper.getMainLooper());

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseCrashlytics crashlytics = FirebaseCrashlytics.getInstance();

            final String dartExceptionMessage =
                (String) Objects.requireNonNull(arguments.get(Constants.EXCEPTION));
            final String reason = (String) arguments.get(Constants.REASON);
            final String information =
                (String) Objects.requireNonNull(arguments.get(Constants.INFORMATION));
            final boolean fatal = (boolean) Objects.requireNonNull(arguments.get(Constants.FATAL));
            final String buildId =
                (String) Objects.requireNonNull(arguments.get(Constants.BUILD_ID));
            @SuppressWarnings("unchecked")
            final List<String> loadingUnits =
                (List<String>) Objects.requireNonNull(arguments.get(Constants.LOADING_UNITS));

            if (buildId.length() > 0) {
              FlutterFirebaseCrashlyticsInternal.setFlutterBuildId(buildId);
            }

            FlutterFirebaseCrashlyticsInternal.setLoadingUnits(loadingUnits);

            Exception exception;
            if (reason != null) {
              final String crashlyticsErrorReason = "thrown " + reason;
              if (testEventSink != null) {
                mainHandler.post(() -> testEventSink.success(crashlyticsErrorReason));
              }
              // Set a "reason" (to match iOS) to show where the exception was thrown.
              crashlytics.setCustomKey(Constants.FLUTTER_ERROR_REASON, crashlyticsErrorReason);
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

            if (fatal) {
              FlutterFirebaseCrashlyticsInternal.recordFatalException(exception);
            } else {
              crashlytics.recordException(exception);
            }

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> log(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            String message = (String) Objects.requireNonNull(arguments.get(Constants.MESSAGE));
            FirebaseCrashlytics.getInstance().log(message);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> sendUnsentReports() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseCrashlytics.getInstance().sendUnsentReports();
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> setCrashlyticsCollectionEnabled(
      final Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            Boolean enabled = (Boolean) Objects.requireNonNull(arguments.get(Constants.ENABLED));
            FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(enabled);

            taskCompletionSource.setResult(
                new HashMap<String, Object>() {
                  {
                    put(
                        Constants.IS_CRASHLYTICS_COLLECTION_ENABLED,
                        isCrashlyticsCollectionEnabled(FirebaseApp.getInstance()));
                  }
                });
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setUserIdentifier(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            String identifier =
                (String) Objects.requireNonNull(arguments.get(Constants.IDENTIFIER));
            FirebaseCrashlytics.getInstance().setUserId(identifier);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setCustomKey(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            String key = (String) Objects.requireNonNull(arguments.get(Constants.KEY));
            String value = (String) Objects.requireNonNull(arguments.get(Constants.VALUE));
            FirebaseCrashlytics.getInstance().setCustomKey(key, value);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
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

    if (crashlyticsSharedPrefs.contains(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED)) {
      enabled = crashlyticsSharedPrefs.getBoolean(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED, true);
    } else {

      Boolean manifestEnabled =
          readCrashlyticsDataCollectionEnabledFromManifest(app.getApplicationContext());

      FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(manifestEnabled);
      enabled = manifestEnabled;
    }

    return enabled;
  }

  private static Boolean readCrashlyticsDataCollectionEnabledFromManifest(
      Context applicationContext) {
    try {
      final PackageManager packageManager = applicationContext.getPackageManager();
      if (packageManager != null) {
        final ApplicationInfo applicationInfo =
            packageManager.getApplicationInfo(
                applicationContext.getPackageName(), PackageManager.GET_META_DATA);
        if (applicationInfo != null
            && applicationInfo.metaData != null
            && applicationInfo.metaData.containsKey(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED)) {
          return applicationInfo.metaData.getBoolean(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED);
        }
      }
    } catch (PackageManager.NameNotFoundException e) {
      // This shouldn't happen since it's this app's package, but fall through to default
      // if so.
      Logger.getLogger().e("Could not read data collection permission from manifest", e);
    }
    return true;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            taskCompletionSource.setResult(
                new HashMap<String, Object>() {
                  {
                    if (firebaseApp.getName().equals("[DEFAULT]"))
                      put(
                          Constants.IS_CRASHLYTICS_COLLECTION_ENABLED,
                          isCrashlyticsCollectionEnabled(FirebaseApp.getInstance()));
                  }
                });
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
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    testEventSink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    testEventSink = null;
  }
}
