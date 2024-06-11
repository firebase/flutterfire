// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationManagerCompat;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/** FlutterFirebaseMessagingPlugin */
public class FlutterFirebaseMessagingPlugin
    implements FlutterFirebasePlugin,
        MethodCallHandler,
        NewIntentListener,
        FlutterPlugin,
        ActivityAware {

  private final HashMap<String, Boolean> consumedInitialMessages = new HashMap<>();
  private MethodChannel channel;
  private Activity mainActivity;

  private final LiveData<RemoteMessage> liveDataRemoteMessage =
      FlutterFirebaseRemoteMessageLiveData.getInstance();
  private Observer<RemoteMessage> remoteMessageObserver;
  private final LiveData<String> liveDataToken = FlutterFirebaseTokenLiveData.getInstance();
  private Observer<String> tokenObserver;

  private RemoteMessage initialMessage;
  // We store the initial notification in a separate variable
  // because we cannot set the notification key in
  // the initialMessage Java Builder
  private Map<String, Object> initialMessageNotification;

  FlutterFirebasePermissionManager permissionManager;

  private void initInstance(BinaryMessenger messenger) {
    String channelName = "plugins.flutter.io/firebase_messaging";
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);
    permissionManager = new FlutterFirebasePermissionManager();

    remoteMessageObserver =
        remoteMessage -> {
          Map<String, Object> content =
              FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage);
          channel.invokeMethod("Messaging#onMessage", content);
        };
    tokenObserver = token -> channel.invokeMethod("Messaging#onTokenRefresh", token);
    // We remove these observers in the onDetachedFromEngine method. Using "observeForever()"
    // allows us to use without a LifecycleOwner.
    liveDataRemoteMessage.observeForever(remoteMessageObserver);
    liveDataToken.observeForever(tokenObserver);

    registerPlugin(channelName, this);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    ContextHolder.setApplicationContext(binding.getApplicationContext());
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    liveDataToken.removeObserver(tokenObserver);
    liveDataRemoteMessage.removeObserver(remoteMessageObserver);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
    binding.addRequestPermissionsResultListener(permissionManager);
    this.mainActivity = binding.getActivity();
    if (mainActivity.getIntent() != null && mainActivity.getIntent().getExtras() != null) {
      if ((mainActivity.getIntent().getFlags() & Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY)
          != Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) {
        onNewIntent(mainActivity.getIntent());
      }
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.mainActivity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
    this.mainActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    this.mainActivity = null;
  }

  private Task<Void> deleteToken() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            Tasks.await(FirebaseMessaging.getInstance().deleteToken());
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> getToken() {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            String token = Tasks.await(FirebaseMessaging.getInstance().getToken());
            taskCompletionSource.setResult(
                new HashMap<String, Object>() {
                  {
                    put("token", token);
                  }
                });
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> subscribeToTopic(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseMessaging firebaseMessaging =
                FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
            String topic = (String) Objects.requireNonNull(arguments.get("topic"));
            Tasks.await(firebaseMessaging.subscribeToTopic(topic));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> unsubscribeFromTopic(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseMessaging firebaseMessaging =
                FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
            String topic = (String) Objects.requireNonNull(arguments.get("topic"));
            Tasks.await(firebaseMessaging.unsubscribeFromTopic(topic));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }
  // This API will be removed in a future release. Slated to be removed by June 2024 by Firebase.
  // https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/FirebaseMessaging#send
  @SuppressWarnings("deprecation")
  private Task<Void> sendMessage(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseMessaging firebaseMessaging =
                FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
            RemoteMessage remoteMessage =
                FlutterFirebaseMessagingUtils.getRemoteMessageForArguments(arguments);
            firebaseMessaging.send(remoteMessage);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> setAutoInitEnabled(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseMessaging firebaseMessaging =
                FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
            Boolean enabled = (Boolean) Objects.requireNonNull(arguments.get("enabled"));
            firebaseMessaging.setAutoInitEnabled(enabled);
            taskCompletionSource.setResult(
                new HashMap<String, Object>() {
                  {
                    put(
                        FlutterFirebaseMessagingUtils.IS_AUTO_INIT_ENABLED,
                        firebaseMessaging.isAutoInitEnabled());
                  }
                });
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setDeliveryMetricsExportToBigQuery(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseMessaging firebaseMessaging =
                FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
            Boolean enabled = (Boolean) Objects.requireNonNull(arguments.get("enabled"));
            firebaseMessaging.setDeliveryMetricsExportToBigQuery(enabled);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> getInitialMessage() {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            if (initialMessage != null) {
              Map<String, Object> remoteMessageMap =
                  FlutterFirebaseMessagingUtils.remoteMessageToMap(initialMessage);
              if (initialMessageNotification != null) {
                remoteMessageMap.put("notification", initialMessageNotification);
              }
              taskCompletionSource.setResult(remoteMessageMap);
              initialMessage = null;
              initialMessageNotification = null;
              return;
            }

            if (mainActivity == null) {
              taskCompletionSource.setResult(null);
              return;
            }

            Intent intent = mainActivity.getIntent();

            if (intent == null || intent.getExtras() == null) {
              taskCompletionSource.setResult(null);
              return;
            }

            // Remote Message ID can be either one of the following...
            String messageId = intent.getExtras().getString("google.message_id");
            if (messageId == null) messageId = intent.getExtras().getString("message_id");

            // We only want to handle non-consumed initial messages.
            if (messageId == null || consumedInitialMessages.get(messageId) != null) {
              taskCompletionSource.setResult(null);
              return;
            }

            RemoteMessage remoteMessage =
                FlutterFirebaseMessagingReceiver.notifications.get(messageId);
            Map<String, Object> notificationMap = null;

            // If we can't find a copy of the remote message in memory then check from our persisted store.
            if (remoteMessage == null) {
              Map<String, Object> messageMap =
                  FlutterFirebaseMessagingStore.getInstance().getFirebaseMessageMap(messageId);
              if (messageMap != null) {
                remoteMessage =
                    FlutterFirebaseMessagingUtils.getRemoteMessageForArguments(messageMap);

                if (messageMap.get("notification") != null) {
                  // noinspection
                  notificationMap =
                      (Map<String, Object>) uncheckedCastToMap(messageMap.get("notification"));
                }
              }
              FlutterFirebaseMessagingStore.getInstance().removeFirebaseMessage(messageId);
            }

            if (remoteMessage == null) {
              taskCompletionSource.setResult(null);
              return;
            }

            consumedInitialMessages.put(messageId, true);

            Map<String, Object> remoteMessageMap =
                FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage);

            // If no notification map is available in the remote message we override with the one we got
            if (remoteMessage.getNotification() == null && notificationMap != null) {
              remoteMessageMap.put("notification", notificationMap);
            }

            taskCompletionSource.setResult(remoteMessageMap);

          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @RequiresApi(api = 33)
  private Task<Map<String, Integer>> requestPermissions() {
    TaskCompletionSource<Map<String, Integer>> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(
        () -> {
          final Map<String, Integer> permissions = new HashMap<>();
          try {
            final boolean areNotificationsEnabled = checkPermissions();

            if (!areNotificationsEnabled) {
              permissionManager.requestPermissions(
                  mainActivity,
                  (notificationsEnabled) -> {
                    permissions.put("authorizationStatus", notificationsEnabled);
                    taskCompletionSource.setResult(permissions);
                  },
                  (String errorDescription) ->
                      taskCompletionSource.setException(new Exception(errorDescription)));
            } else {
              permissions.put("authorizationStatus", 1);
              taskCompletionSource.setResult(permissions);
            }

          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @RequiresApi(api = 33)
  private Boolean checkPermissions() {
    return ContextHolder.getApplicationContext()
            .checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)
        == PackageManager.PERMISSION_GRANTED;
  }

  private Task<Map<String, Integer>> getPermissions() {
    TaskCompletionSource<Map<String, Integer>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Map<String, Integer> permissions = new HashMap<>();
            final boolean areNotificationsEnabled;
            if (Build.VERSION.SDK_INT >= 33) {
              areNotificationsEnabled = checkPermissions();
            } else {
              areNotificationsEnabled =
                  NotificationManagerCompat.from(mainActivity).areNotificationsEnabled();
            }
            permissions.put("authorizationStatus", areNotificationsEnabled ? 1 : 0);
            taskCompletionSource.setResult(permissions);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public void onMethodCall(final MethodCall call, @NonNull final Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
        // This message is sent when the Dart side of this plugin is told to initialize.
        // In response, this (native) side of the plugin needs to spin up a background
        // Dart isolate by using the given pluginCallbackHandle, and then setup a background
        // method channel to communicate with the new background isolate. Once completed,
        // this onMethodCall() method will receive messages from both the primary and background
        // method channels.
      case "Messaging#startBackgroundIsolate":
        @SuppressWarnings("unchecked")
        Map<String, Object> arguments = ((Map<String, Object>) call.arguments);

        long pluginCallbackHandle;
        long userCallbackHandle;

        Object arg1 = arguments.get("pluginCallbackHandle");
        Object arg2 = arguments.get("userCallbackHandle");

        if (arg1 instanceof Long) {
          pluginCallbackHandle = (Long) arg1;
        } else if (arg1 instanceof Integer) {
          pluginCallbackHandle = Long.valueOf((Integer) arg1);
        } else {
          throw new IllegalArgumentException(
              "Expected 'Long' or 'Integer' type for 'pluginCallbackHandle'.");
        }

        if (arg2 instanceof Long) {
          userCallbackHandle = (Long) arg2;
        } else if (arg2 instanceof Integer) {
          userCallbackHandle = Long.valueOf((Integer) arg2);
        } else {
          throw new IllegalArgumentException(
              "Expected 'Long' or 'Integer' type for 'userCallbackHandle'.");
        }

        FlutterShellArgs shellArgs = null;
        if (mainActivity != null) {
          // Supports both Flutter Activity types:
          //    io.flutter.embedding.android.FlutterFragmentActivity
          //    io.flutter.embedding.android.FlutterActivity
          // We could use `getFlutterShellArgs()` but this is only available on `FlutterActivity`.
          shellArgs = FlutterShellArgs.fromIntent(mainActivity.getIntent());
        }

        FlutterFirebaseMessagingBackgroundService.setCallbackDispatcher(pluginCallbackHandle);
        FlutterFirebaseMessagingBackgroundService.setUserCallbackHandle(userCallbackHandle);
        FlutterFirebaseMessagingBackgroundService.startBackgroundIsolate(
            pluginCallbackHandle, shellArgs);
        methodCallTask = Tasks.forResult(null);
        break;
      case "Messaging#getInitialMessage":
        methodCallTask = getInitialMessage();
        break;
      case "Messaging#deleteToken":
        methodCallTask = deleteToken();
        break;
      case "Messaging#getToken":
        methodCallTask = getToken();
        break;
      case "Messaging#subscribeToTopic":
        methodCallTask = subscribeToTopic(call.arguments());
        break;
      case "Messaging#unsubscribeFromTopic":
        methodCallTask = unsubscribeFromTopic(call.arguments());
        break;
      case "Messaging#sendMessage":
        methodCallTask = sendMessage(call.arguments());
        break;
      case "Messaging#setAutoInitEnabled":
        methodCallTask = setAutoInitEnabled(call.arguments());
        break;
      case "Messaging#setDeliveryMetricsExportToBigQuery":
        methodCallTask = setDeliveryMetricsExportToBigQuery(call.arguments());
        break;
      case "Messaging#requestPermission":
        if (Build.VERSION.SDK_INT >= 33) {
          // Android version >= Android 13 requires user input if notification permission not set/granted
          methodCallTask = requestPermissions();
        } else {
          // Android version < Android 13 doesn't require asking for runtime permissions.
          methodCallTask = getPermissions();
        }
        break;
      case "Messaging#getNotificationSettings":
        methodCallTask = getPermissions();
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
                "firebase_messaging",
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
  public boolean onNewIntent(@NonNull Intent intent) {
    if (intent.getExtras() == null) {
      return false;
    }

    // Remote Message ID can be either one of the following...
    String messageId = intent.getExtras().getString("google.message_id");
    if (messageId == null) messageId = intent.getExtras().getString("message_id");
    if (messageId == null) {
      return false;
    }

    RemoteMessage remoteMessage = FlutterFirebaseMessagingReceiver.notifications.get(messageId);
    Map<String, Object> notificationMap = null;

    // If we can't find a copy of the remote message in memory then check from our persisted store.
    if (remoteMessage == null) {
      Map<String, Object> messageMap =
          FlutterFirebaseMessagingStore.getInstance().getFirebaseMessageMap(messageId);
      if (messageMap != null) {
        remoteMessage = FlutterFirebaseMessagingUtils.getRemoteMessageForArguments(messageMap);
        notificationMap =
            FlutterFirebaseMessagingUtils.getRemoteMessageNotificationForArguments(messageMap);
      }
      // Note we don't remove it here as the user may still call getInitialMessage.
    }

    if (remoteMessage == null) {
      return false;
    }

    // Store this message for later use by getInitialMessage.
    initialMessage = remoteMessage;
    initialMessageNotification = notificationMap;

    FlutterFirebaseMessagingReceiver.notifications.remove(messageId);
    Map<String, Object> message = FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage);

    if (remoteMessage.getNotification() == null && initialMessageNotification != null) {
      message.put("notification", initialMessageNotification);
    }

    channel.invokeMethod("Messaging#onMessageOpenedApp", message);
    mainActivity.setIntent(intent);
    return true;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            Map<String, Object> constants = new HashMap<>();
            if (firebaseApp.getName().equals("[DEFAULT]")) {
              FirebaseMessaging firebaseMessaging = FirebaseMessaging.getInstance();
              constants.put("AUTO_INIT_ENABLED", firebaseMessaging.isAutoInitEnabled());
            }
            taskCompletionSource.setResult(constants);

          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(() -> taskCompletionSource.setResult(null));

    return taskCompletionSource.getTask();
  }

  private Map<String, Object> uncheckedCastToMap(Object obj) {
    @SuppressWarnings("unchecked")
    Map<String, Object> result = (Map<String, Object>) obj;
    return result;
  }
}
