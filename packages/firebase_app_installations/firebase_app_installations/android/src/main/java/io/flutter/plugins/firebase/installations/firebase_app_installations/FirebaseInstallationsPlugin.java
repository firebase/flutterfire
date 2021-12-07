// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.installations.firebase_app_installations;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.installations.FirebaseInstallations;
import com.google.firebase.installations.InstallationTokenResult;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/** FirebaseInstallationsPlugin */
public class FirebaseInstallationsPlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_app_installations";
  private final Map<EventChannel, EventChannel.StreamHandler> streamHandlers = new HashMap<>();

  @Nullable private BinaryMessenger messenger;

  private MethodChannel setup(BinaryMessenger binaryMessenger) {
    final MethodChannel channel = new MethodChannel(binaryMessenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    this.messenger = binaryMessenger;
    return channel;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    BinaryMessenger binaryMessenger = flutterPluginBinding.getBinaryMessenger();
    channel = setup(binaryMessenger);

    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    messenger = null;

    removeEventListeners();
  }

  private FirebaseInstallations getInstallations(Map<String, Object> arguments) {
    @NonNull String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseInstallations.getInstance(app);
  }

  private Task<String> getId(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> Tasks.await(getInstallations(arguments).getId()));
  }

  private Task<String> getToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseInstallations firebaseInstallations = getInstallations(arguments);
          Boolean forceRefresh = (Boolean) Objects.requireNonNull(arguments.get("forceRefresh"));
          InstallationTokenResult tokenResult =
              Tasks.await(firebaseInstallations.getToken(forceRefresh));
          return tokenResult.getToken();
        });
  }

  private Task<String> registerIdChangeListener(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String appName = (String) Objects.requireNonNull(arguments.get("appName"));
          FirebaseInstallations firebaseInstallations = getInstallations(arguments);

          io.flutter.plugins.firebase.installations.firebase_app_installations
                  .TokenChannelStreamHandler
              handler =
                  new io.flutter.plugins.firebase.installations.firebase_app_installations
                      .TokenChannelStreamHandler(firebaseInstallations);

          final String name = METHOD_CHANNEL_NAME + "/token/" + appName;
          final EventChannel channel = new EventChannel(messenger, name);
          channel.setStreamHandler(handler);
          streamHandlers.put(channel, handler);

          return name;
        });
  }

  private Task<Void> deleteId(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> Tasks.await(getInstallations(arguments).delete()));
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "FirebaseInstallations#getId":
        methodCallTask = getId(call.arguments());
        break;
      case "FirebaseInstallations#getToken":
        methodCallTask = getToken(call.arguments());
        break;
      case "FirebaseInstallations#delete":
        methodCallTask = deleteId(call.arguments());
        break;
      case "FirebaseInstallations#registerIdChangeListener":
        methodCallTask = registerIdChangeListener(call.arguments());
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
                "firebase_app_installations",
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
    return Tasks.call(cachedThreadPool, () -> null);
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(cachedThreadPool, () -> null);
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
