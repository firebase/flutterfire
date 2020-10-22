// Copyright 2017 The Chromium Authors. All rights reserved.
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
import io.flutter.plugin.common.PluginRegistry.Registrar;
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

  private MethodChannel channel;
  private Activity mainActivity;
  private RemoteMessage initialMessage;
  private HashMap<String, Boolean> consumedInitialMessages = new HashMap<>();

  @SuppressWarnings("unused")
  public static void registerWith(Registrar registrar) {
    FlutterFirebaseMessagingPlugin instance = new FlutterFirebaseMessagingPlugin();
    instance.setActivity(registrar.activity());
    registrar.addNewIntentListener(instance);
    instance.initInstance(registrar.messenger());
  }

  private void initInstance(BinaryMessenger messenger) {
    String channelName = "plugins.flutter.io/firebase_messaging";
    channel = new MethodChannel(messenger, channelName);
    channel.setMethodCallHandler(this);

    // Register broadcast receiver
    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(FlutterFirebaseMessagingConstants.ACTION_TOKEN);
    intentFilter.addAction(FlutterFirebaseMessagingConstants.ACTION_REMOTE_MESSAGE);
    LocalBroadcastManager manager =
        LocalBroadcastManager.getInstance(ContextHolder.getApplicationContext());
    manager.registerReceiver(this, intentFilter);

    registerPlugin(channelName, this);
  }

  private void onAttachedToEngine(Context context, BinaryMessenger binaryMessenger) {
    initInstance(binaryMessenger);
  }

  private void setActivity(Activity flutterActivity) {
    this.mainActivity = flutterActivity;
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    LocalBroadcastManager.getInstance(ContextHolder.getApplicationContext())
        .unregisterReceiver(this);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    binding.addOnNewIntentListener(this);
    this.mainActivity = binding.getActivity();
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

    if (action.equals(FlutterFirebaseMessagingConstants.ACTION_TOKEN)) {
      String token = intent.getStringExtra(FlutterFirebaseMessagingConstants.EXTRA_TOKEN);
      channel.invokeMethod("Messaging#onTokenRefresh", token);
    } else if (action.equals(FlutterFirebaseMessagingConstants.ACTION_REMOTE_MESSAGE)) {
      RemoteMessage message =
          intent.getParcelableExtra(FlutterFirebaseMessagingConstants.EXTRA_REMOTE_MESSAGE);
      if (message == null) return;
      Map<String, Object> content = FlutterFirebaseMessagingUtils.remoteMessageToMap(message);
      channel.invokeMethod("Messaging#onMessage", content);
    }
  }

  private Task<Void> deleteToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging =
              FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
          String senderId = (String) arguments.get("senderId");
          Tasks.await(firebaseMessaging.deleteToken());
          return null;
        });
  }

  private Task<String> getToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging =
              FlutterFirebaseMessagingUtils.getFirebaseMessagingForArguments(arguments);
          String senderId = (String) arguments.get("senderId");
          return Tasks.await(firebaseMessaging.getToken());
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
                  FlutterFirebaseMessagingConstants.IS_AUTO_INIT_ENABLED,
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

          // If we can't find a copy of the remote message in memory then check from our temporary store.
          if (remoteMessage == null) {
            // TODO
            // TODO
            // TODO
            // TODO
            // TODO
            // TODO
            // TODO
            //        ReactNativeFirebaseMessagingStore messagingStore = ReactNativeFirebaseMessagingStoreHelper
            //          .getInstance().getMessagingStore();
            //        remoteMessage = messagingStore.getFirebaseMessage(messageId);
            //        messagingStore.clearFirebaseMessage(messageId);
          }

          if (remoteMessage == null) {
            return null;
          }

          consumedInitialMessages.put(messageId, true);
          return FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage);
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
        long pluginCallbackHandle =
            (long) ((Map<String, Object>) call.arguments).get("pluginCallbackHandle");
        @SuppressWarnings("unchecked")
        long userCallbackHandle =
            (long) ((Map<String, Object>) call.arguments).get("userCallbackHandle");

        FlutterShellArgs shellArgs = null;
        if (mainActivity != null) {
          shellArgs =
              ((io.flutter.embedding.android.FlutterActivity) mainActivity).getFlutterShellArgs();
        }

        FlutterFirebaseMessagingBackgroundService.setCallbackDispatcher(pluginCallbackHandle);
        FlutterFirebaseMessagingBackgroundService.setUserCallbackHandle(userCallbackHandle);
        FlutterFirebaseMessagingBackgroundService.startBackgroundIsolate(
            pluginCallbackHandle, shellArgs);
      case "Messaging#getInitialMessage":
        methodCallTask = getInitialMessage(call.arguments());
        break;

        // TODO check / cleanup
        // TODO check / cleanup
        // TODO check / cleanup
        // TODO check / cleanup
        // TODO check / cleanup
      case "Messaging#deleteToken":
        methodCallTask = deleteToken(call.arguments());
        break;
      case "Messaging#getToken":
        methodCallTask = getToken(call.arguments());
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

  private Map<String, Object> getExceptionDetails(Exception exception) {
    Map<String, Object> details = new HashMap<>();
    // TODO implement
    // TODO implement
    // TODO implement
    // TODO implement
    // TODO implement
    // TODO implement
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

          FirebaseMessaging firebaseMessaging = FirebaseMessaging.getInstance();
          constants.put("AUTO_INIT_ENABLED", firebaseMessaging.isAutoInitEnabled());
          return constants;
        });
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(cachedThreadPool, () -> null);
  }
}
