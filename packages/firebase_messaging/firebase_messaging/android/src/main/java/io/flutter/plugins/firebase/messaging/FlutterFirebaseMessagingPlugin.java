// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationManagerCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.android.gms.tasks.Task;
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
public class FlutterFirebaseMessagingPlugin extends BroadcastReceiver
    implements FlutterFirebasePlugin,
        MethodCallHandler,
        NewIntentListener,
        FlutterPlugin,
        ActivityAware {

  private final HashMap<String, Boolean> consumedInitialMessages = new HashMap<>();
  private MethodChannel channel;
  private Activity mainActivity;
  private RemoteMessage initialMessage;

  private void initInstance(BinaryMessenger messenger) {
    String channelName = "plugins.flutter.io/firebase_messaging";
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);

    // Register broadcast receiver
    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(FlutterFirebaseMessagingUtils.ACTION_TOKEN);
    intentFilter.addAction(FlutterFirebaseMessagingUtils.ACTION_REMOTE_MESSAGE);
    LocalBroadcastManager manager =
        LocalBroadcastManager.getInstance(ContextHolder.getApplicationContext());
    manager.registerReceiver(this, intentFilter);

    registerPlugin(channelName, this);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (binding.getApplicationContext() != null) {
      LocalBroadcastManager.getInstance(binding.getApplicationContext()).unregisterReceiver(this);
    }
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
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

  // BroadcastReceiver implementation.
  @Override
  public void onReceive(Context context, Intent intent) {
    String action = intent.getAction();

    if (action == null) {
      return;
    }

    if (action.equals(FlutterFirebaseMessagingUtils.ACTION_TOKEN)) {
      String token = intent.getStringExtra(FlutterFirebaseMessagingUtils.EXTRA_TOKEN);
      channel.invokeMethod("Messaging#onTokenRefresh", token);
    } else if (action.equals(FlutterFirebaseMessagingUtils.ACTION_REMOTE_MESSAGE)) {
      RemoteMessage message =
          intent.getParcelableExtra(FlutterFirebaseMessagingUtils.EXTRA_REMOTE_MESSAGE);
      if (message == null) return;
      Map<String, Object> content = FlutterFirebaseMessagingUtils.remoteMessageToMap(message);
      channel.invokeMethod("Messaging#onMessage", content);
    }
  }

  private Task<Void> deleteToken() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Tasks.await(FirebaseMessaging.getInstance().deleteToken());
          return null;
        });
  }

  private Task<Map<String, Object>> getToken() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          String token = Tasks.await(FirebaseMessaging.getInstance().getToken());
          return new HashMap<String, Object>() {
            {
              put("token", token);
            }
          };
        });
  }

  private Task<Void> subscribeToTopic(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging =
              FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
          String topic = (String) Objects.requireNonNull(arguments.get("topic"));
          Tasks.await(firebaseMessaging.subscribeToTopic(topic));
          return null;
        });
  }

  private Task<Void> unsubscribeFromTopic(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging =
              FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
          String topic = (String) Objects.requireNonNull(arguments.get("topic"));
          Tasks.await(firebaseMessaging.unsubscribeFromTopic(topic));
          return null;
        });
  }

  private Task<Void> sendMessage(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging =
              FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
          RemoteMessage remoteMessage =
              FlutterFirebaseMessagingUtils.getRemoteMessageForArguments(arguments);
          firebaseMessaging.send(remoteMessage);
          return null;
        });
  }

  private Task<Map<String, Object>> setAutoInitEnabled(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging =
              FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
          Boolean enabled = (Boolean) Objects.requireNonNull(arguments.get("enabled"));
          firebaseMessaging.setAutoInitEnabled(enabled);
          return new HashMap<String, Object>() {
            {
              put(
                  FlutterFirebaseMessagingUtils.IS_AUTO_INIT_ENABLED,
                  firebaseMessaging.isAutoInitEnabled());
            }
          };
        });
  }

  private Task<Map<String, Object>> getInitialMessage(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          if (initialMessage != null) {
            Map<String, Object> remoteMessageMap =
                FlutterFirebaseMessagingUtils.remoteMessageToMap(initialMessage);
            initialMessage = null;
            return remoteMessageMap;
          }

          if (mainActivity == null) {
            return null;
          }

          Intent intent = mainActivity.getIntent();

          if (intent == null || intent.getExtras() == null) {
            return null;
          }

          // Remote Message ID can be either one of the following...
          String messageId = intent.getExtras().getString("google.message_id");
          if (messageId == null) messageId = intent.getExtras().getString("message_id");

          // We only want to handle non-consumed initial messages.
          if (messageId == null || consumedInitialMessages.get(messageId) != null) {
            return null;
          }

          RemoteMessage remoteMessage =
              FlutterFirebaseMessagingReceiver.notifications.get(messageId);

          // If we can't find a copy of the remote message in memory then check from our persisted store.
          if (remoteMessage == null) {
            remoteMessage =
                FlutterFirebaseMessagingStore.getInstance().getFirebaseMessage(messageId);
            FlutterFirebaseMessagingStore.getInstance().removeFirebaseMessage(messageId);
          }

          if (remoteMessage == null) {
            return null;
          }

          consumedInitialMessages.put(messageId, true);
          return FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage);
        });
  }

  private Task<Map<String, Integer>> getPermissions() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          final Map<String, Integer> permissions = new HashMap<>();
          final boolean areNotificationsEnabled =
              NotificationManagerCompat.from(mainActivity).areNotificationsEnabled();
          permissions.put("authorizationStatus", areNotificationsEnabled ? 1 : 0);
          return permissions;
        });
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

        long pluginCallbackHandle = 0;
        long userCallbackHandle = 0;

        Object arg1 = arguments.get("pluginCallbackHandle");
        Object arg2 = arguments.get("userCallbackHandle");

        if (arg1 instanceof Long) {
          pluginCallbackHandle = (Long) arg1;
        } else {
          pluginCallbackHandle = Long.valueOf((Integer) arg1);
        }

        if (arg2 instanceof Long) {
          userCallbackHandle = (Long) arg2;
        } else {
          userCallbackHandle = Long.valueOf((Integer) arg2);
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
        methodCallTask = getInitialMessage(call.arguments());
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
      case "Messaging#requestPermission":
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
  public boolean onNewIntent(Intent intent) {
    if (intent == null || intent.getExtras() == null) {
      return false;
    }

    // Remote Message ID can be either one of the following...
    String messageId = intent.getExtras().getString("google.message_id");
    if (messageId == null) messageId = intent.getExtras().getString("message_id");
    if (messageId == null) {
      return false;
    }

    RemoteMessage remoteMessage = FlutterFirebaseMessagingReceiver.notifications.get(messageId);

    // If we can't find a copy of the remote message in memory then check from our persisted store.
    if (remoteMessage == null) {
      remoteMessage = FlutterFirebaseMessagingStore.getInstance().getFirebaseMessage(messageId);
      // Note we don't remove it here as the user may still call getInitialMessage.
    }

    if (remoteMessage == null) {
      return false;
    }

    // Store this message for later use by getInitialMessage.
    initialMessage = remoteMessage;

    FlutterFirebaseMessagingReceiver.notifications.remove(messageId);
    channel.invokeMethod(
        "Messaging#onMessageOpenedApp",
        FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage));
    mainActivity.setIntent(intent);
    return true;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Map<String, Object> constants = new HashMap<>();
          if (firebaseApp.getName().equals("[DEFAULT]")) {
            FirebaseMessaging firebaseMessaging = FirebaseMessaging.getInstance();
            constants.put("AUTO_INIT_ENABLED", firebaseMessaging.isAutoInitEnabled());
          }
          return constants;
        });
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(cachedThreadPool, () -> null);
  }
}
