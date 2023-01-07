// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.analytics;

import android.content.Context;
import android.os.Bundle;
import android.os.Parcelable;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.analytics.FirebaseAnalytics;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/** Flutter plugin for Firebase Analytics. */
public class FlutterFirebaseAnalyticsPlugin
    implements FlutterFirebasePlugin, MethodCallHandler, FlutterPlugin {
  private FirebaseAnalytics analytics;
  private MethodChannel channel;

  private void initInstance(BinaryMessenger messenger, Context context) {
    analytics = FirebaseAnalytics.getInstance(context);
    String channelName = "plugins.flutter.io/firebase_analytics";
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);
    FlutterFirebasePluginRegistry.registerPlugin(channelName, this);
  }

  @SuppressWarnings("unchecked")
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
        // FirebaseAnalytics default event parameters only support long and double types, so we convert the int to a long.
        bundle.putLong(key, (Integer) value);
      } else if (value instanceof Long) {
        bundle.putLong(key, (Long) value);
      } else if (value instanceof Double) {
        bundle.putDouble(key, (Double) value);
      } else if (value instanceof Boolean) {
        bundle.putBoolean(key, (Boolean) value);
      } else if (value == null) {
        bundle.putString(key, null);
      } else if (value instanceof Iterable<?>) {
        ArrayList<Parcelable> list = new ArrayList<>();

        for (Object item : (Iterable<?>) value) {
          if (item instanceof Map) {
            //noinspection unchecked
            list.add(createBundleFromMap((Map<String, Object>) item));
          } else {
            throw new IllegalArgumentException(
                "Unsupported value type: "
                    + item.getClass().getCanonicalName()
                    + " in list at key "
                    + key);
          }
        }

        bundle.putParcelableArrayList(key, list);
      } else if (value instanceof Map<?, ?>) {
        //noinspection unchecked
        bundle.putParcelable(key, createBundleFromMap((Map<String, Object>) value));
      } else {
        throw new IllegalArgumentException(
            "Unsupported value type: " + value.getClass().getCanonicalName());
      }
    }
    return bundle;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "Analytics#logEvent":
        methodCallTask = handleLogEvent(call.arguments());
        break;
      case "Analytics#setUserId":
        methodCallTask = handleSetUserId(call.arguments());
        break;
      case "Analytics#setAnalyticsCollectionEnabled":
        methodCallTask = handleSetAnalyticsCollectionEnabled(call.arguments());
        break;
      case "Analytics#setSessionTimeoutDuration":
        methodCallTask = handleSetSessionTimeoutDuration(call.arguments());
        break;
      case "Analytics#setUserProperty":
        methodCallTask = handleSetUserProperty(call.arguments());
        break;
      case "Analytics#resetAnalyticsData":
        methodCallTask = handleResetAnalyticsData();
        break;
      case "Analytics#setConsent":
        methodCallTask = setConsent(call.arguments());
        break;
      case "Analytics#setDefaultEventParameters":
        methodCallTask = setDefaultEventParameters(call.arguments());
        break;
      case "Analytics#getAppInstanceId":
        methodCallTask = handleGetAppInstanceId();
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
            result.error("firebase_analytics", message, null);
          }
        });
  }

  private Task<Void> handleLogEvent(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final String eventName =
                (String) Objects.requireNonNull(arguments.get(Constants.EVENT_NAME));
            @SuppressWarnings("unchecked")
            final Map<String, Object> map =
                (Map<String, Object>) arguments.get(Constants.PARAMETERS);
            final Bundle parameterBundle = createBundleFromMap(map);
            analytics.logEvent(eventName, parameterBundle);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> handleSetUserId(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final String id = (String) arguments.get(Constants.USER_ID);
            analytics.setUserId(id);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> handleSetAnalyticsCollectionEnabled(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Boolean enabled =
                (Boolean) Objects.requireNonNull(arguments.get(Constants.ENABLED));
            analytics.setAnalyticsCollectionEnabled(enabled);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> handleSetSessionTimeoutDuration(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Integer milliseconds =
                (Integer) Objects.requireNonNull(arguments.get(Constants.MILLISECONDS));
            analytics.setSessionTimeoutDuration(milliseconds);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> handleSetUserProperty(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final String name = (String) Objects.requireNonNull(arguments.get(Constants.NAME));
            final String value = (String) arguments.get(Constants.VALUE);
            analytics.setUserProperty(name, value);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> handleResetAnalyticsData() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            analytics.resetAnalyticsData();
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setConsent(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Boolean adStorageGranted =
                (Boolean) arguments.get(Constants.AD_STORAGE_CONSENT_GRANTED);
            final Boolean analyticsStorageGranted =
                (Boolean) arguments.get(Constants.ANALYTICS_STORAGE_CONSENT_GRANTED);
            HashMap<FirebaseAnalytics.ConsentType, FirebaseAnalytics.ConsentStatus> parameters =
                new HashMap<>();

            if (adStorageGranted != null) {
              parameters.put(
                  FirebaseAnalytics.ConsentType.AD_STORAGE,
                  adStorageGranted
                      ? FirebaseAnalytics.ConsentStatus.GRANTED
                      : FirebaseAnalytics.ConsentStatus.DENIED);
            }

            if (analyticsStorageGranted != null) {
              parameters.put(
                  FirebaseAnalytics.ConsentType.ANALYTICS_STORAGE,
                  analyticsStorageGranted
                      ? FirebaseAnalytics.ConsentStatus.GRANTED
                      : FirebaseAnalytics.ConsentStatus.DENIED);
            }

            analytics.setConsent(parameters);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setDefaultEventParameters(final Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            analytics.setDefaultEventParameters(createBundleFromMap(arguments));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<String> handleGetAppInstanceId() {
    TaskCompletionSource<String> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            taskCompletionSource.setResult(Tasks.await(analytics.getAppInstanceId()));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
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
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }
}
