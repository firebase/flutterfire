// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firebaseremoteconfig;

import android.content.Context;
import android.content.SharedPreferences;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

/** FirebaseRemoteConfigPlugin */
public class FirebaseRemoteConfigPlugin implements FlutterFirebasePlugin, MethodChannel.MethodCallHandler, FlutterPlugin {

  static final String TAG = "FirebaseRemoteConfigPlugin";
  static final String METHOD_CHANNEL = "plugins.flutter.io/firebase_remote_config";

  private MethodChannel channel;

  public static void registerWith(Registrar registrar) {
    FirebaseRemoteConfigPlugin plugin = new FirebaseRemoteConfigPlugin();
    plugin.setupChannel(registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupChannel(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    tearDownChannel();
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(final FirebaseApp firebaseApp) {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.getInstance(firebaseApp);
    return Tasks.call(cachedThreadPool, () -> parseParameters(remoteConfig.getAll()));
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(() -> null);
  }

  private void setupChannel(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL);
    channel.setMethodCallHandler(this);
  }

  private void tearDownChannel() {
    channel.setMethodCallHandler(null);
    channel = null;
  }

  private FirebaseRemoteConfig getRemoteConfig(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseRemoteConfig.getInstance(app);
  }

  @Override
  public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
    Task<?> methodCallTask;
    FirebaseRemoteConfig remoteConfig = getRemoteConfig(call.arguments());

    switch (call.method) {
      case "RemoteConfig#ensureInitialized":
      {
        methodCallTask = remoteConfig.ensureInitialized();
        break;
      }
      case "RemoteConfgi#activate":
      {
        methodCallTask = remoteConfig.activate();
        break;
      }
      case "RemoteConfgi#getAll":
      {
        methodCallTask = Tasks.forResult(parseParameters(remoteConfig.getAll()));
        break;
      }
      case "RemoteConfig#fetch":
      {
        methodCallTask = remoteConfig.fetch();
        break;
      }
      case "RemoteConfig#fetchAndActivate":
      {
        methodCallTask = remoteConfig.fetchAndActivate();
        break;
      }
      case "RemoteConfig#setConfigSettings":
      {
        int fetchTimeout = call.argument("fetchTimeout");
        int minimumFetchInterval = call.argument("minimumFetchInterval");
        FirebaseRemoteConfigSettings settings = new FirebaseRemoteConfigSettings.Builder()
          .setFetchTimeoutInSeconds(fetchTimeout)
          .setMinimumFetchIntervalInSeconds(minimumFetchInterval)
          .build();
        methodCallTask = remoteConfig.setConfigSettingsAsync(settings);
        break;
      }
      case "RemoteConfig#setDefaults":
      {
        Map<String, Object> defaults = call.argument("defaults");
        methodCallTask = remoteConfig.setDefaultsAsync(defaults);
        break;
      }
      default:
      {
        result.notImplemented();
        return;
      }
    }

    methodCallTask.addOnCompleteListener(
      task -> {
        if (task.isSuccessful()) {
          result.success(task.getResult());
        } else {
          Exception exception = task.getException();
          result.error(
            "firebase_remote_config",
            exception != null ? exception.getMessage() : null,
            // TODO(kroikie): Add exception details to errorDetails
            null);
        }
      }
    );
  }

  private Map<String, Object> parseParameters(Map<String, FirebaseRemoteConfigValue> parameters) {
    Map<String, Object> parsedParameters = new HashMap<>();
    for (String key : parameters.keySet()) {
      parsedParameters.put(key, createRemoteConfigValueMap(parameters.get(key)));
    }
    return parsedParameters;
  }

  private Map<String, Object> createRemoteConfigValueMap(
    FirebaseRemoteConfigValue remoteConfigValue) {
    Map<String, Object> valueMap = new HashMap<>();
    valueMap.put("value", remoteConfigValue.asByteArray());
    valueMap.put("source", mapValueSource(remoteConfigValue.getSource()));
    return valueMap;
  }

  private String mapLastFetchStatus(int status) {
    switch (status) {
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_SUCCESS:
        return "success";
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_FAILURE:
        return "failure";
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_THROTTLED:
        return "throttled";
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_NO_FETCH_YET:
        return "noFetchYet";
      default:
        return "failure";
    }
  }

  private String mapValueSource(int source) {
    switch (source) {
      case FirebaseRemoteConfig.VALUE_SOURCE_STATIC:
        return "static";
      case FirebaseRemoteConfig.VALUE_SOURCE_DEFAULT:
        return "default";
      case FirebaseRemoteConfig.VALUE_SOURCE_REMOTE:
        return "remote";
      default:
        return "static";
    }
  }
}
