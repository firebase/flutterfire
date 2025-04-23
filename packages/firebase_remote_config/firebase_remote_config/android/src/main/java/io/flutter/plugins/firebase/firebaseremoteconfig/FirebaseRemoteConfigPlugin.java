// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firebaseremoteconfig;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.remoteconfig.ConfigUpdate;
import com.google.firebase.remoteconfig.ConfigUpdateListener;
import com.google.firebase.remoteconfig.ConfigUpdateListenerRegistration;
import com.google.firebase.remoteconfig.CustomSignals;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigClientException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigFetchThrottledException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigServerException;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
// Pigeon imports
import io.flutter.plugins.firebase.firebaseremoteconfig.GeneratedAndroidFirebaseRemoteConfig.FirebaseRemoteConfigHostApi;
import io.flutter.plugins.firebase.firebaseremoteconfig.GeneratedAndroidFirebaseRemoteConfig.PigeonConfigSettings;
import io.flutter.plugins.firebase.firebaseremoteconfig.GeneratedAndroidFirebaseRemoteConfig.PigeonFirebaseRemoteConfigValue;
import io.flutter.plugins.firebase.firebaseremoteconfig.GeneratedAndroidFirebaseRemoteConfig.PigeonFirebaseSettings;
import io.flutter.plugins.firebase.firebaseremoteconfig.GeneratedAndroidFirebaseRemoteConfig.PigeonRemoteConfigFetchStatus;
import io.flutter.plugins.firebase.firebaseremoteconfig.GeneratedAndroidFirebaseRemoteConfig.PigeonValueSource;
import io.flutter.plugins.firebase.firebaseremoteconfig.GeneratedAndroidFirebaseRemoteConfig.Result;
// FlutterError import
import io.flutter.plugin.common.FlutterError;
// Remove unused MethodChannel imports
// import io.flutter.plugin.common.MethodCall;
// import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/** FirebaseRemoteConfigPlugin */
public class FirebaseRemoteConfigPlugin
    implements FlutterFirebasePlugin,
        // Replace MethodCallHandler with Pigeon Host API
        FirebaseRemoteConfigHostApi,
        FlutterPlugin,
        EventChannel.StreamHandler {

  static final String TAG = "FRCPlugin";
  // Remove METHOD_CHANNEL constant
  // static final String METHOD_CHANNEL = "plugins.flutter.io/firebase_remote_config";
  static final String EVENT_CHANNEL = "plugins.flutter.io/firebase_remote_config_updated";

  // Remove channel variable
  // private MethodChannel channel;

  private final Map<String, ConfigUpdateListenerRegistration> listenersMap = new HashMap<>();
  private EventChannel eventChannel;
  private final Handler mainThreadHandler = new Handler(Looper.getMainLooper());

  private BinaryMessenger binaryMessenger; // Store messenger for teardown

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    binaryMessenger = binding.getBinaryMessenger();
    registerPlugin(binaryMessenger.toString(), this); // Use unique key for plugin registry
    // Setup Pigeon Host API
    GeneratedAndroidFirebaseRemoteConfig.FirebaseRemoteConfigHostApi.setUp(binaryMessenger, this);

    // Keep EventChannel setup
    eventChannel = new EventChannel(binaryMessenger, EVENT_CHANNEL);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // Teardown Pigeon Host API
    GeneratedAndroidFirebaseRemoteConfig.FirebaseRemoteConfigHostApi.setUp(binaryMessenger, null);

    // Keep EventChannel teardown
    eventChannel.setStreamHandler(null);
    eventChannel = null;
    removeEventListeners();
    binaryMessenger = null;
  }

  // Remove setupChannel and tearDownChannel methods
  // private void setupChannel(BinaryMessenger messenger) { ... }
  // private void tearDownChannel() { ... }


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
            removeEventListeners();
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  // Renamed from getRemoteConfig to match Pigeon usage (appName only)
  private FirebaseRemoteConfig getRemoteConfig(String appName) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseRemoteConfig.getInstance(app);
  }

  private Task<Void> setCustomSignals(
      FirebaseRemoteConfig remoteConfig, Map<String, Object> customSignalsArguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          try {
            CustomSignals.Builder customSignals = new CustomSignals.Builder();
            for (Map.Entry<String, Object> entry : customSignalsArguments.entrySet()) {
              Object value = entry.getValue();
              if (value instanceof String) {
                customSignals.put(entry.getKey(), (String) value);
              } else if (value instanceof Long) {
                customSignals.put(entry.getKey(), (Long) value);
              } else if (value instanceof Integer) {
                customSignals.put(entry.getKey(), ((Integer) value).longValue());
              } else if (value instanceof Double) {
                customSignals.put(entry.getKey(), (Double) value);
              } else if (value == null) {
                customSignals.put(entry.getKey(), null);
              }
            }
            Tasks.await(remoteConfig.setCustomSignals(customSignals.build()));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });
    return taskCompletionSource.getTask();
  }

  // Remove onMethodCall
  // @Override
  // public void onMethodCall(MethodCall call, @NonNull final MethodChannel.Result result) { ... }

  // Helper to convert Exception to FlutterError for Pigeon results
  private FlutterError exceptionToFlutterError(@NonNull Exception exception) {
    String code = "unknown";
    String message = exception.getMessage();
    Map<String, Object> details = new HashMap<>();

    if (exception instanceof FirebaseRemoteConfigFetchThrottledException) {
      code = "throttled";
      message = "frequency of requests exceeds throttled limits";
    } else if (exception instanceof FirebaseRemoteConfigClientException) {
      code = "internal";
      message = "internal remote config fetch error";
    } else if (exception instanceof FirebaseRemoteConfigServerException) {
      code = "remote-config-server-error";
      Throwable cause = exception.getCause();
      if (cause != null) {
        String causeMessage = cause.getMessage();
        if (causeMessage != null && causeMessage.contains("Forbidden")) {
          // Specific error code for 403 status code to indicate the request was forbidden.
          code = "forbidden";
        }
      }
    }
    // Add more specific exception checks if needed

    details.put("code", code);
    details.put("message", message);
    // You might want to add more details from the exception if needed
    // details.put("nativeErrorMessage", exception.getMessage());

    return new FlutterError(code, message, details);
  }


  // Adapt helper methods for Pigeon types
  private Map<String, PigeonFirebaseRemoteConfigValue> parseParameters(Map<String, FirebaseRemoteConfigValue> parameters) {
    Map<String, PigeonFirebaseRemoteConfigValue> parsedParameters = new HashMap<>();
    for (String key : parameters.keySet()) {
      parsedParameters.put(
          key, createPigeonRemoteConfigValue(Objects.requireNonNull(parameters.get(key))));
    }
    return parsedParameters;
  }

  // Renamed and returns Pigeon type
  private PigeonFirebaseRemoteConfigValue createPigeonRemoteConfigValue(
      FirebaseRemoteConfigValue remoteConfigValue) {
    PigeonFirebaseRemoteConfigValue.Builder builder = new PigeonFirebaseRemoteConfigValue.Builder();
    builder.setValue(remoteConfigValue.asByteArray());
    builder.setSource(mapValueSource(remoteConfigValue.getSource()));
    return builder.build();
  }

  // Returns Pigeon enum
  private PigeonRemoteConfigFetchStatus mapLastFetchStatus(int status) {
    switch (status) {
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_SUCCESS:
        return PigeonRemoteConfigFetchStatus.SUCCESS;
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_THROTTLED:
        return PigeonRemoteConfigFetchStatus.THROTTLE; // Check Pigeon enum name
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_NO_FETCH_YET:
        return PigeonRemoteConfigFetchStatus.NOFETCHYET;
      case FirebaseRemoteConfig.LAST_FETCH_STATUS_FAILURE:
      default:
        return PigeonRemoteConfigFetchStatus.FAILURE;
    }
  }

  // Returns Pigeon enum
  private PigeonValueSource mapValueSource(int source) {
    switch (source) {
      case FirebaseRemoteConfig.VALUE_SOURCE_DEFAULT:
        return PigeonValueSource.DEFAULTVALUE; // Check Pigeon enum name
      case FirebaseRemoteConfig.VALUE_SOURCE_REMOTE:
        return PigeonValueSource.REMOTE;
      case FirebaseRemoteConfig.VALUE_SOURCE_STATIC:
      default:
        return PigeonValueSource.STATIC;
    }
  }

  // FirebaseRemoteConfigHostApi implementation

  @Override
  public void ensureInitialized(
      @NonNull String appName, @NonNull Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            Tasks.await(remoteConfig.ensureInitialized());
            result.success(null);
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  @Override
  public void activate(
      @NonNull String appName, @NonNull Result<Boolean> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            boolean activated = Tasks.await(remoteConfig.activate());
            result.success(activated);
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  @Override
  public void fetch(
      @NonNull String appName, @NonNull Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            Tasks.await(remoteConfig.fetch());
            result.success(null);
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  @Override
  public void fetchAndActivate(
      @NonNull String appName, @NonNull Result<Boolean> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            boolean activated = Tasks.await(remoteConfig.fetchAndActivate());
            result.success(activated);
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  @Override
  public void getAll(
      @NonNull String appName,
      @NonNull Result<Map<String, PigeonFirebaseRemoteConfigValue>> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            result.success(parseParameters(remoteConfig.getAll()));
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  @Override
  public void setConfigSettings(
      @NonNull String appName,
      @NonNull PigeonFirebaseSettings settings,
      @NonNull Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            FirebaseRemoteConfigSettings nativeSettings =
                new FirebaseRemoteConfigSettings.Builder()
                    // Pigeon uses Long, SDK uses long
                    .setFetchTimeoutInSeconds(settings.getFetchTimeout())
                    .setMinimumFetchIntervalInSeconds(settings.getMinimumFetchInterval())
                    .build();
            Tasks.await(remoteConfig.setConfigSettingsAsync(nativeSettings));
            result.success(null);
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  @Override
  public void setDefaults(
      @NonNull String appName,
      @NonNull Map<String, Object> defaults,
      @NonNull Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            Tasks.await(remoteConfig.setDefaultsAsync(defaults));
            result.success(null);
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  @Override
  public void getProperties(
      @NonNull String appName, @NonNull Result<PigeonConfigSettings> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            FirebaseRemoteConfigSettings nativeSettings = remoteConfig.getInfo().getConfigSettings();
            PigeonConfigSettings.Builder pigeonSettings = new PigeonConfigSettings.Builder();
            pigeonSettings.setFetchTimeout(nativeSettings.getFetchTimeoutInSeconds());
            pigeonSettings.setMinimumFetchInterval(nativeSettings.getMinimumFetchIntervalInSeconds());
            pigeonSettings.setLastFetchTimeMillis(remoteConfig.getInfo().getFetchTimeMillis());
            pigeonSettings.setLastFetchStatus(mapLastFetchStatus(remoteConfig.getInfo().getLastFetchStatus()));

            result.success(pigeonSettings.build());
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

 @Override
  public void setCustomSignals(
      @NonNull String appName,
      @NonNull Map<String, Object> customSignals,
      @NonNull Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);
            CustomSignals.Builder customSignalsBuilder = new CustomSignals.Builder();

            for (Map.Entry<String, Object> entry : customSignals.entrySet()) {
              Object value = entry.getValue();
              if (value instanceof String) {
                customSignalsBuilder.put(entry.getKey(), (String) value);
              } else if (value instanceof Long) {
                customSignalsBuilder.put(entry.getKey(), (Long) value);
              } else if (value instanceof Integer) {
                customSignalsBuilder.put(entry.getKey(), ((Integer) value).longValue());
              } else if (value instanceof Double) {
                customSignalsBuilder.put(entry.getKey(), (Double) value);
              } else if (value == null) {
                // Handle null if necessary, depending on SDK capabilities
              }
            }

            Tasks.await(remoteConfig.setCustomSignals(customSignalsBuilder.build()));
            result.success(null);
          } catch (Exception e) {
            result.error(exceptionToFlutterError(e));
          }
        });
  }

  // EventChannel methods remain mostly unchanged
  @SuppressWarnings("unchecked")
  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    // Use updated helper method
    String appName = (String) Objects.requireNonNull(argumentsMap.get("appName"));
    FirebaseRemoteConfig remoteConfig = getRemoteConfig(appName);

    listenersMap.put(
        appName,
        remoteConfig.addOnConfigUpdateListener(
            new ConfigUpdateListener() {
              @Override
              public void onUpdate(@NonNull ConfigUpdate configUpdate) {
                ArrayList<String> updatedKeys = new ArrayList<>(configUpdate.getUpdatedKeys());
                mainThreadHandler.post(() -> events.success(updatedKeys));
              }

              @Override
              public void onError(@NonNull FirebaseRemoteConfigException error) {
                events.error("firebase_remote_config", error.getMessage(), null);
              }
            }));
  }

  @SuppressWarnings("unchecked")
  @Override
  public void onCancel(Object arguments) {
    // arguments will be null on hot restart, so we will clean up listeners in didReinitializeFirebaseCore()
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    if (argumentsMap == null) {
      return;
    }
    String appName = (String) Objects.requireNonNull(argumentsMap.get("appName"));

    ConfigUpdateListenerRegistration listener = listenersMap.get(appName);
    if (listener != null) {
      listener.remove();
      listenersMap.remove(appName);
    }
  }

  /** Remove all registered listeners. */
  private void removeEventListeners() {
    for (ConfigUpdateListenerRegistration listener : listenersMap.values()) {
      listener.remove();
    }
    listenersMap.clear();
  }
}
