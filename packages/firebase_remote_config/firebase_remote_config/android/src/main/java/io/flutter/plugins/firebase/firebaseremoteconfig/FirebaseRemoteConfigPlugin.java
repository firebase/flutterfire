// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firebaseremoteconfig;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigClientException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigFetchThrottledException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigServerException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/** FirebaseRemoteConfigPlugin */
public class FirebaseRemoteConfigPlugin
    implements FlutterFirebasePlugin, MethodChannel.MethodCallHandler, FlutterPlugin {

  static final String TAG = "FRCPlugin";
  static final String METHOD_CHANNEL = "plugins.flutter.io/firebase_remote_config";

  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupChannel(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    tearDownChannel();
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(final FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.getInstance(firebaseApp);
            Map<String, Object> configProperties = getConfigProperties(remoteConfig);
            Map<String, Object> configValues = new HashMap<>(configProperties);
            configValues.put("parameters", parseParameters(remoteConfig.getAll()));

            taskCompletionSource.setResult(configValues);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Map<String, Object> getConfigProperties(FirebaseRemoteConfig remoteConfig) {
    Map<String, Object> configProperties = new HashMap<>();
    configProperties.put(
        "fetchTimeout", remoteConfig.getInfo().getConfigSettings().getFetchTimeoutInSeconds());
    configProperties.put(
        "minimumFetchInterval",
        remoteConfig.getInfo().getConfigSettings().getMinimumFetchIntervalInSeconds());
    configProperties.put("lastFetchTime", remoteConfig.getInfo().getFetchTimeMillis());
    configProperties.put(
        "lastFetchStatus", mapLastFetchStatus(remoteConfig.getInfo().getLastFetchStatus()));
    Log.d(TAG, "Sending fetchTimeout: " + configProperties.get("fetchTimeout"));
    return configProperties;
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
  public void onMethodCall(MethodCall call, @NonNull final MethodChannel.Result result) {
    Task<?> methodCallTask;
    FirebaseRemoteConfig remoteConfig = getRemoteConfig(call.arguments());

    switch (call.method) {
      case "RemoteConfig#ensureInitialized":
        {
          methodCallTask = Tasks.whenAll(remoteConfig.ensureInitialized());
          break;
        }
      case "RemoteConfig#activate":
        {
          methodCallTask = remoteConfig.activate();
          break;
        }
      case "RemoteConfig#getAll":
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
          int fetchTimeout = Objects.requireNonNull(call.argument("fetchTimeout"));
          int minimumFetchInterval = Objects.requireNonNull(call.argument("minimumFetchInterval"));
          FirebaseRemoteConfigSettings settings =
              new FirebaseRemoteConfigSettings.Builder()
                  .setFetchTimeoutInSeconds(fetchTimeout)
                  .setMinimumFetchIntervalInSeconds(minimumFetchInterval)
                  .build();
          methodCallTask = remoteConfig.setConfigSettingsAsync(settings);
          break;
        }
      case "RemoteConfig#setDefaults":
        {
          Map<String, Object> defaults = Objects.requireNonNull(call.argument("defaults"));
          methodCallTask = remoteConfig.setDefaultsAsync(defaults);
          break;
        }
      case "RemoteConfig#getProperties":
        {
          Map<String, Object> configProperties = getConfigProperties(remoteConfig);
          methodCallTask = Tasks.forResult(configProperties);
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
            Map<String, Object> details = new HashMap<>();
            if (exception instanceof FirebaseRemoteConfigFetchThrottledException) {
              details.put("code", "throttled");
              details.put("message", "frequency of requests exceeds throttled limits");
            } else if (exception instanceof FirebaseRemoteConfigClientException) {
              details.put("code", "internal");
              details.put("message", "internal remote config fetch error");
            } else if (exception instanceof FirebaseRemoteConfigServerException) {
              details.put("code", "remote-config-server-error");
              details.put("message", exception.getMessage());

              Throwable cause = exception.getCause();
              if (cause != null) {
                String causeMessage = cause.getMessage();
                if (causeMessage != null && causeMessage.contains("Forbidden")) {
                  // Specific error code for 403 status code to indicate the request was forbidden.
                  details.put("code", "forbidden");
                }
              }
            } else {
              details.put("code", "unknown");
              details.put("message", "unknown remote config error");
            }
            result.error(
                "firebase_remote_config",
                exception != null ? exception.getMessage() : null,
                details);
          }
        });
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
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_THROTTLED:
        return "throttled";
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_NO_FETCH_YET:
        return "noFetchYet";
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_FAILURE:
      default:
        return "failure";
    }
  }

  private String mapValueSource(int source) {
    switch (source) {
      case FirebaseRemoteConfig.VALUE_SOURCE_DEFAULT:
        return "default";
      case FirebaseRemoteConfig.VALUE_SOURCE_REMOTE:
        return "remote";
      case FirebaseRemoteConfig.VALUE_SOURCE_STATIC:
      default:
        return "static";
    }
  }
}
