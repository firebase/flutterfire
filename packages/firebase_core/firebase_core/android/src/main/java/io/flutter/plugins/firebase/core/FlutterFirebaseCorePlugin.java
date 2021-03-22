// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.core;

import static io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool;

import android.content.Context;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Flutter plugin implementation controlling the entrypoint for the Firebase SDK.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class FlutterFirebaseCorePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  private static final String KEY_API_KEY = "apiKey";
  private static final String KEY_APP_NAME = "appName";
  private static final String KEY_APP_ID = "appId";
  private static final String KEY_MESSAGING_SENDER_ID = "messagingSenderId";
  private static final String KEY_PROJECT_ID = "projectId";
  private static final String KEY_DATABASE_URL = "databaseURL";
  private static final String KEY_STORAGE_BUCKET = "storageBucket";
  private static final String KEY_OPTIONS = "options";
  private static final String KEY_NAME = "name";
  private static final String KEY_TRACKING_ID = "trackingId";
  private static final String KEY_ENABLED = "enabled";
  private static final String KEY_IS_AUTOMATIC_DATA_COLLECTION_ENABLED =
      "isAutomaticDataCollectionEnabled";
  private static final String KEY_PLUGIN_CONSTANTS = "pluginConstants";

  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_core";

  private MethodChannel channel;
  private Context applicationContext;
  private boolean coreInitialized = false;

  /**
   * Default Constructor.
   *
   * <p>Use this constructor in an add to app scenario to gracefully handle activity and context
   * changes.
   */
  public FlutterFirebaseCorePlugin() {}

  private FlutterFirebaseCorePlugin(Context applicationContext) {
    this.applicationContext = applicationContext;
  }

  /**
   * Registers a plugin with the v1 embedding api {@code io.flutter.plugin.common}.
   *
   * <p>Calling this will register the plugin with the passed registrar. However plugins initialized
   * this way won't react to changes in activity or context, unlike {@link
   * FlutterFirebaseCorePlugin}.
   */
  @SuppressWarnings("unused")
  public static void registerWith(PluginRegistry.Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FlutterFirebaseCorePlugin(registrar.context()));
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    applicationContext = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    applicationContext = null;
  }

  private Task<Map<String, Object>> firebaseAppToMap(FirebaseApp firebaseApp) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Map<String, Object> appMap = new HashMap<>();
          Map<String, String> optionsMap = new HashMap<>();
          FirebaseOptions options = firebaseApp.getOptions();

          optionsMap.put(KEY_API_KEY, options.getApiKey());
          optionsMap.put(KEY_APP_ID, options.getApplicationId());

          if (options.getGcmSenderId() != null) {
            optionsMap.put(KEY_MESSAGING_SENDER_ID, options.getGcmSenderId());
          }

          if (options.getProjectId() != null) {
            optionsMap.put(KEY_PROJECT_ID, options.getProjectId());
          }

          if (options.getDatabaseUrl() != null) {
            optionsMap.put(KEY_DATABASE_URL, options.getDatabaseUrl());
          }

          if (options.getStorageBucket() != null) {
            optionsMap.put(KEY_STORAGE_BUCKET, options.getStorageBucket());
          }

          if (options.getGaTrackingId() != null) {
            optionsMap.put(KEY_TRACKING_ID, options.getGaTrackingId());
          }

          appMap.put(KEY_NAME, firebaseApp.getName());
          appMap.put(KEY_OPTIONS, optionsMap);

          appMap.put(
              KEY_IS_AUTOMATIC_DATA_COLLECTION_ENABLED,
              firebaseApp.isDataCollectionDefaultEnabled());
          appMap.put(
              KEY_PLUGIN_CONSTANTS,
              Tasks.await(
                  FlutterFirebasePluginRegistry.getPluginConstantsForFirebaseApp(firebaseApp)));

          return appMap;
        });
  }

  private Task<Map<String, Object>> initializeApp(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String name = (String) Objects.requireNonNull(arguments.get(KEY_APP_NAME));

          @SuppressWarnings("unchecked")
          Map<String, String> optionsMap =
              (Map<String, String>) Objects.requireNonNull(arguments.get(KEY_OPTIONS));

          FirebaseOptions options =
              new FirebaseOptions.Builder()
                  .setApiKey(Objects.requireNonNull(optionsMap.get(KEY_API_KEY)))
                  .setApplicationId(Objects.requireNonNull(optionsMap.get(KEY_APP_ID)))
                  .setDatabaseUrl(optionsMap.get(KEY_DATABASE_URL))
                  .setGcmSenderId(optionsMap.get(KEY_MESSAGING_SENDER_ID))
                  .setProjectId(optionsMap.get(KEY_PROJECT_ID))
                  .setStorageBucket(optionsMap.get(KEY_STORAGE_BUCKET))
                  .setGaTrackingId(optionsMap.get(KEY_TRACKING_ID))
                  .build();

          FirebaseApp firebaseApp = FirebaseApp.initializeApp(applicationContext, options, name);
          return Tasks.await(firebaseAppToMap(firebaseApp));
        });
  }

  private Task<List<Map<String, Object>>> initializeCore() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          if (!coreInitialized) {
            coreInitialized = true;
          } else {
            Tasks.await(FlutterFirebasePluginRegistry.didReinitializeFirebaseCore());
          }

          List<FirebaseApp> firebaseApps = FirebaseApp.getApps(applicationContext);
          List<Map<String, Object>> firebaseAppsList = new ArrayList<>(firebaseApps.size());

          for (FirebaseApp firebaseApp : firebaseApps) {
            firebaseAppsList.add(Tasks.await(firebaseAppToMap(firebaseApp)));
          }

          return firebaseAppsList;
        });
  }

  private Task<Void> setAutomaticDataCollectionEnabled(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String appName = (String) Objects.requireNonNull(arguments.get(KEY_APP_NAME));
          boolean enabled = (boolean) Objects.requireNonNull(arguments.get(KEY_ENABLED));
          FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
          firebaseApp.setDataCollectionDefaultEnabled(enabled);
          return null;
        });
  }

  private Task<Void> setAutomaticResourceManagementEnabled(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String appName = (String) Objects.requireNonNull(arguments.get(KEY_APP_NAME));
          boolean enabled = (boolean) Objects.requireNonNull(arguments.get(KEY_ENABLED));
          FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
          firebaseApp.setAutomaticResourceManagementEnabled(enabled);
          return null;
        });
  }

  private Task<Void> deleteApp(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String appName = (String) Objects.requireNonNull(arguments.get(KEY_APP_NAME));
          FirebaseApp firebaseApp = FirebaseApp.getInstance(appName);
          try {
            firebaseApp.delete();
          } catch (IllegalStateException appNotFoundException) {
            // Ignore app not found exceptions.
          }

          return null;
        });
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull final MethodChannel.Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "Firebase#initializeApp":
        methodCallTask = initializeApp(call.arguments());
        break;
      case "Firebase#initializeCore":
        methodCallTask = initializeCore();
        break;
      case "FirebaseApp#setAutomaticDataCollectionEnabled":
        methodCallTask = setAutomaticDataCollectionEnabled(call.arguments());
        break;
      case "FirebaseApp#setAutomaticResourceManagementEnabled":
        methodCallTask = setAutomaticResourceManagementEnabled(call.arguments());
        break;
      case "FirebaseApp#delete":
        methodCallTask = deleteApp(call.arguments());
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
            result.error("firebase_core", exception != null ? exception.getMessage() : null, null);
          }
        });
  }
}
