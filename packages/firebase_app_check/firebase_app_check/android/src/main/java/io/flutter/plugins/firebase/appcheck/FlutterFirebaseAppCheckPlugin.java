// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.appcheck;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.appcheck.AppCheckTokenResult;
import com.google.firebase.appcheck.FirebaseAppCheck;
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory;
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory;
import com.google.firebase.appcheck.safetynet.SafetyNetAppCheckProviderFactory;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class FlutterFirebaseAppCheckPlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_app_check";
  private final Map<EventChannel, TokenChannelStreamHandler> streamHandlers = new HashMap<>();
  private final String TAG = "FLTAppCheckPlugin";

  private final String debugProvider = "debug";
  private final String safetyNetProvider = "safetyNet";
  private final String playIntegrity = "playIntegrity";

  @Nullable private BinaryMessenger messenger;

  private MethodChannel channel;

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);

    this.messenger = messenger;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    messenger = null;

    removeEventListeners();
  }

  private FirebaseAppCheck getAppCheck(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseAppCheck.getInstance(app);
  }

  private Map<String, Object> tokenResultToMap(AppCheckTokenResult result) {
    Map<String, Object> output = new HashMap<>();
    output.put("token", result.getToken());
    return output;
  }

  private Task<Void> activate(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            String provider = (String) Objects.requireNonNull(arguments.get("androidProvider"));

            switch (provider) {
              case debugProvider:
                {
                  FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.getInstance();
                  firebaseAppCheck.installAppCheckProviderFactory(
                      DebugAppCheckProviderFactory.getInstance());
                  break;
                }
              case safetyNetProvider:
                {
                  FirebaseAppCheck firebaseAppCheck = getAppCheck(arguments);
                  firebaseAppCheck.installAppCheckProviderFactory(
                      SafetyNetAppCheckProviderFactory.getInstance());
                  break;
                }
              case playIntegrity:
                {
                  FirebaseAppCheck firebaseAppCheck = getAppCheck(arguments);
                  firebaseAppCheck.installAppCheckProviderFactory(
                      PlayIntegrityAppCheckProviderFactory.getInstance());
                  break;
                }
            }
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> getToken(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAppCheck firebaseAppCheck = getAppCheck(arguments);
            Boolean forceRefresh = (Boolean) Objects.requireNonNull(arguments.get("forceRefresh"));
            AppCheckTokenResult tokenResult = Tasks.await(firebaseAppCheck.getToken(forceRefresh));

            taskCompletionSource.setResult(tokenResultToMap(tokenResult));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setTokenAutoRefreshEnabled(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseAppCheck firebaseAppCheck = getAppCheck(arguments);
            Boolean isTokenAutoRefreshEnabled =
                (Boolean) Objects.requireNonNull(arguments.get("isTokenAutoRefreshEnabled"));
            firebaseAppCheck.setTokenAutoRefreshEnabled(isTokenAutoRefreshEnabled);

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<String> registerTokenListener(Map<String, Object> arguments) {
    TaskCompletionSource<String> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            String appName = (String) Objects.requireNonNull(arguments.get("appName"));
            FirebaseAppCheck firebaseAppCheck = getAppCheck(arguments);

            final TokenChannelStreamHandler handler =
                new TokenChannelStreamHandler(firebaseAppCheck);
            final String name = METHOD_CHANNEL_NAME + "/token/" + appName;
            final EventChannel channel = new EventChannel(messenger, name);
            channel.setStreamHandler(handler);
            streamHandlers.put(channel, handler);

            taskCompletionSource.setResult(name);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull final Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "FirebaseAppCheck#activate":
        methodCallTask = activate(call.arguments());
        break;
      case "FirebaseAppCheck#getToken":
        methodCallTask = getToken(call.arguments());
        break;
      case "FirebaseAppCheck#setTokenAutoRefreshEnabled":
        methodCallTask = setTokenAutoRefreshEnabled(call.arguments());
        break;
      case "FirebaseAppCheck#registerTokenListener":
        methodCallTask = registerTokenListener(call.arguments());
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
            result.error(
                "firebase_app_check",
                exception != null ? exception.getMessage() : null,
                getExceptionDetails(exception));
          }
        });
  }

  private Map<String, Object> getExceptionDetails(@Nullable Exception exception) {
    Map<String, Object> details = new HashMap<>();
    details.put("code", "unknown");
    if (exception != null) {
      details.put("message", exception.getMessage());
    } else {
      details.put("message", "An unknown error has occurred.");
    }
    return details;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

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

  private void removeEventListeners() {
    for (EventChannel eventChannel : streamHandlers.keySet()) {
      EventChannel.StreamHandler streamHandler = streamHandlers.get(eventChannel);
      streamHandler.onCancel(null);
      eventChannel.setStreamHandler(null);
    }
    streamHandlers.clear();
  }
}
