// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.installations.firebase_app_installations;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.installations.FirebaseInstallations;
import com.google.firebase.installations.InstallationTokenResult;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import io.flutter.plugins.firebase.installations.GeneratedAndroidFirebaseAppInstallations;
import io.flutter.plugins.firebase.installations.GeneratedAndroidFirebaseAppInstallations.AppInstallationsPigeonFirebaseApp;
import io.flutter.plugins.firebase.installations.GeneratedAndroidFirebaseAppInstallations.AppInstallationsPigeonSettings;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/** FirebaseInstallationsPlugin */
public class FirebaseInstallationsPlugin
    implements FlutterFirebasePlugin,
        FlutterPlugin,
        GeneratedAndroidFirebaseAppInstallations.FirebaseAppInstallationsHostApi {
  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_app_installations";
  private final Map<EventChannel, EventChannel.StreamHandler> streamHandlers = new HashMap<>();

  @Nullable private BinaryMessenger messenger;

  private void setup(BinaryMessenger binaryMessenger) {
    this.messenger = binaryMessenger;
    // Set up Pigeon host API handlers.
    GeneratedAndroidFirebaseAppInstallations.FirebaseAppInstallationsHostApi.setUp(
        binaryMessenger, this);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    BinaryMessenger binaryMessenger = flutterPluginBinding.getBinaryMessenger();
    setup(binaryMessenger);

    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (messenger != null) {
      GeneratedAndroidFirebaseAppInstallations.FirebaseAppInstallationsHostApi.setUp(
          messenger, null);
    }
    messenger = null;

    removeEventListeners();
  }

  private FirebaseInstallations getInstallations(Map<String, Object> arguments) {
    @NonNull String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseInstallations.getInstance(app);
  }

  private FirebaseInstallations getInstallations(AppInstallationsPigeonFirebaseApp appArg) {
    @NonNull String appName = appArg.getAppName();
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseInstallations.getInstance(app);
  }

  private Task<String> registerIdChangeListener(Map<String, Object> arguments) {
    TaskCompletionSource<String> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
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

            taskCompletionSource.setResult(name);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  // Pigeon FirebaseAppInstallationsHostApi implementation.

  @Override
  public void initializeApp(
      @NonNull AppInstallationsPigeonFirebaseApp app,
      @NonNull AppInstallationsPigeonSettings settings,
      @NonNull GeneratedAndroidFirebaseAppInstallations.VoidResult result) {
    // Currently there is no per-app configurable behavior required on Android for these settings.
    // We execute asynchronously to keep the threading model consistent.
    cachedThreadPool.execute(
        () -> {
          try {
            // Touch the instance to ensure it's initialized.
            getInstallations(app);
            result.success();
          } catch (Exception e) {
            result.error(
                new GeneratedAndroidFirebaseAppInstallations.FlutterError(
                    "firebase_app_installations", e.getMessage(), getExceptionDetails(e)));
          }
        });
  }

  @Override
  public void delete(
      @NonNull AppInstallationsPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAppInstallations.VoidResult result) {
    cachedThreadPool.execute(
        () -> {
          try {
            Tasks.await(getInstallations(app).delete());
            result.success();
          } catch (Exception e) {
            result.error(
                new GeneratedAndroidFirebaseAppInstallations.FlutterError(
                    "firebase_app_installations", e.getMessage(), getExceptionDetails(e)));
          }
        });
  }

  @Override
  public void getId(
      @NonNull AppInstallationsPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAppInstallations.Result<String> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            String id = Tasks.await(getInstallations(app).getId());
            result.success(id);
          } catch (Exception e) {
            result.error(
                new GeneratedAndroidFirebaseAppInstallations.FlutterError(
                    "firebase_app_installations", e.getMessage(), getExceptionDetails(e)));
          }
        });
  }

  @Override
  public void getToken(
      @NonNull AppInstallationsPigeonFirebaseApp app,
      @NonNull Boolean forceRefresh,
      @NonNull GeneratedAndroidFirebaseAppInstallations.Result<String> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseInstallations firebaseInstallations = getInstallations(app);
            InstallationTokenResult tokenResult =
                Tasks.await(firebaseInstallations.getToken(forceRefresh));
            result.success(tokenResult.getToken());
          } catch (Exception e) {
            result.error(
                new GeneratedAndroidFirebaseAppInstallations.FlutterError(
                    "firebase_app_installations", e.getMessage(), getExceptionDetails(e)));
          }
        });
  }

  @Override
  public void onIdChange(
      @NonNull AppInstallationsPigeonFirebaseApp app,
      @NonNull String newId,
      @NonNull GeneratedAndroidFirebaseAppInstallations.VoidResult result) {
    // The Dart side currently uses an EventChannel-based listener, so this Pigeon hook
    // is a no-op placeholder to satisfy the interface.
    result.success();
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

  private void removeEventListeners() {
    for (EventChannel eventChannel : streamHandlers.keySet()) {
      EventChannel.StreamHandler streamHandler = streamHandlers.get(eventChannel);
      streamHandler.onCancel(null);
      eventChannel.setStreamHandler(null);
    }
    streamHandlers.clear();
  }
}
