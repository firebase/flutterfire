// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemessaging;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

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

/** FirebaseMessagingPlugin */
public class FirebaseMessagingPlugin extends BroadcastReceiver
    implements FlutterFirebasePlugin,
        MethodCallHandler,
        NewIntentListener,
        FlutterPlugin,
        ActivityAware {

  private static final String CLICK_ACTION_VALUE = "FLUTTER_NOTIFICATION_CLICK";
  private static final String TAG = "FirebaseMessagingPlugin";

  private MethodChannel channel;
  private Context applicationContext;
  private Activity mainActivity;

  public static void registerWith(Registrar registrar) {
    FirebaseMessagingPlugin instance = new FirebaseMessagingPlugin();
    instance.setActivity(registrar.activity());
    registrar.addNewIntentListener(instance);
    instance.onAttachedToEngine(registrar.context(), registrar.messenger());
  }

  private void onAttachedToEngine(Context context, BinaryMessenger binaryMessenger) {
    this.applicationContext = context;
    channel = new MethodChannel(binaryMessenger, "plugins.flutter.io/firebase_messaging");
    final MethodChannel backgroundCallbackChannel =
        new MethodChannel(binaryMessenger, "plugins.flutter.io/firebase_messaging_background");

    channel.setMethodCallHandler(this);
    backgroundCallbackChannel.setMethodCallHandler(this);
    FlutterFirebaseMessagingService.setBackgroundChannel(backgroundCallbackChannel);

    // Register broadcast receiver
    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(FlutterFirebaseMessagingService.ACTION_TOKEN);
    intentFilter.addAction(FlutterFirebaseMessagingService.ACTION_REMOTE_MESSAGE);
    LocalBroadcastManager manager = LocalBroadcastManager.getInstance(applicationContext);
    manager.registerReceiver(this, intentFilter);
  }

  private void setActivity(Activity flutterActivity) {
    this.mainActivity = flutterActivity;
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    LocalBroadcastManager.getInstance(binding.getApplicationContext()).unregisterReceiver(this);
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

    if (action.equals(FlutterFirebaseMessagingService.ACTION_TOKEN)) {
      String token = intent.getStringExtra(FlutterFirebaseMessagingService.EXTRA_TOKEN);
      channel.invokeMethod("onToken", token);
    } else if (action.equals(FlutterFirebaseMessagingService.ACTION_REMOTE_MESSAGE)) {
      RemoteMessage message =
          intent.getParcelableExtra(FlutterFirebaseMessagingService.EXTRA_REMOTE_MESSAGE);
      Map<String, Object> content = parseRemoteMessage(message);
      channel.invokeMethod("onMessage", content);
    }
  }

  @NonNull
  private Map<String, Object> parseRemoteMessage(RemoteMessage message) {
    Map<String, Object> content = new HashMap<>();
    content.put("data", message.getData());

    RemoteMessage.Notification notification = message.getNotification();

    Map<String, Object> notificationMap = new HashMap<>();

    String title = notification != null ? notification.getTitle() : null;
    notificationMap.put("title", title);

    String body = notification != null ? notification.getBody() : null;
    notificationMap.put("body", body);

    content.put("notification", notificationMap);
    return content;
  }

  // Extracted to handle multi-app support in the future
  private FirebaseMessaging getMessaging(Map<String, Object> arguments) {
    return FirebaseMessaging.getInstance();
  }

  // Extracted to handle multi-app support in the future
  private FirebaseInstanceId getIID(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseInstanceId.getInstance(app);
  }

  private RemoteMessage getRemoteMessage(Map<String, Object> arguments) {
    @SuppressWarnings("unchecked")
    Map<String, Object> messageMap =
        (Map<String, Object>) Objects.requireNonNull(arguments.get("message"));

    String to = (String) Objects.requireNonNull(messageMap.get("senderId"));
    RemoteMessage.Builder builder = new RemoteMessage.Builder(to);

    String collapseKey = (String) messageMap.get("collapseKey");
    String messageId = (String) messageMap.get("messageId");
    String messageType = (String) messageMap.get("messageType");
    Integer ttl = (Integer) messageMap.get("ttl");

    @SuppressWarnings("unchecked")
    Map<String, String> data = (Map<String, String>) messageMap.get("data");

    if (collapseKey != null) {
      builder.setCollapseKey(collapseKey);
    }

    if (messageType != null) {
      builder.setMessageId(messageId);
    }

    if (messageId != null) {
      builder.setMessageId(messageId);
    }

    if (ttl != null) {
      builder.setTtl(ttl);
    }

    if (data != null) {
      builder.setData(data);
    }

    return builder.build();
  }

  private Task<Void> deleteToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseInstanceId firebaseInstanceId = getIID(arguments);
          String authorizedEntity = (String) arguments.get("authorizedEntity");
          String scope = (String) arguments.get("scope");
          firebaseInstanceId.deleteToken(authorizedEntity, scope);
          return null;
        });
  }

  private Task<String> getToken(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseInstanceId firebaseInstanceId = getIID(arguments);
          String authorizedEntity = (String) arguments.get("authorizedEntity");
          String scope = (String) arguments.get("scope");
          return firebaseInstanceId.getToken(authorizedEntity, scope);
        });
  }

  private Task<Void> subscribeToTopic(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging = getMessaging(arguments);
          String topic = (String) Objects.requireNonNull(arguments.get("topic"));
          Tasks.await(firebaseMessaging.subscribeToTopic(topic));
          return null;
        });
  }

  private Task<Void> unsubscribeFromTopic(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging = getMessaging(arguments);
          String topic = (String) Objects.requireNonNull(arguments.get("topic"));
          Tasks.await(firebaseMessaging.unsubscribeFromTopic(topic));
          return null;
        });
  }

  private Task<Void> sendMessage(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging = getMessaging(arguments);
          RemoteMessage remoteMessage = getRemoteMessage(arguments);
          firebaseMessaging.send(remoteMessage);
          return null;
        });
  }

  private Task<Void> setAutoInitEnabled(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseMessaging firebaseMessaging = getMessaging(arguments);
          Boolean enabled = (Boolean) Objects.requireNonNull(arguments.get("enabled"));
          firebaseMessaging.setAutoInitEnabled(enabled);
          return null;
        });
  }

  private Task<Boolean> deleteInstanceID(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseInstanceId firebaseInstanceId = getIID(arguments);
          // TODO implement delete - needs main thread?
          return false;
        });
  }

  @Override
  public void onMethodCall(final MethodCall call, @NonNull final Result result) {
    Task<?> methodCallTask;

    /*  Even when the app is not active the `FirebaseMessagingService` extended by
     *  `FlutterFirebaseMessagingService` allows incoming FCM messages to be handled.
     *
     *  `FcmDartService#start` and `FcmDartService#initialized` are the two methods used
     *  to optionally setup handling messages received while the app is not active.
     *
     *  `FcmDartService#start` sets up the plumbing that allows messages received while
     *  the app is not active to be handled by a background isolate.
     *
     *  `FcmDartService#initialized` is called by the Dart side when the plumbing for
     *  background message handling is complete.
     */
    switch (call.method) {
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
      case "Messaging#deleteInstanceID":
        methodCallTask = deleteInstanceID(call.arguments());
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

    //    if ("FcmDartService#start".equals(call.method)) {
    //      long setupCallbackHandle = 0;
    //      long backgroundMessageHandle = 0;
    //      try {
    //        @SuppressWarnings("unchecked")
    //        Map<String, Long> callbacks = ((Map<String, Long>) call.arguments);
    //        setupCallbackHandle = callbacks.get("setupHandle");
    //        backgroundMessageHandle = callbacks.get("backgroundHandle");
    //      } catch (Exception e) {
    //        Log.e(TAG, "There was an exception when getting callback handle from Dart side");
    //        e.printStackTrace();
    //      }
    //      FlutterFirebaseMessagingService.setBackgroundSetupHandle(mainActivity,
    // setupCallbackHandle);
    //      FlutterFirebaseMessagingService.startBackgroundIsolate(mainActivity,
    // setupCallbackHandle);
    //      FlutterFirebaseMessagingService.setBackgroundMessageHandle(
    //          mainActivity, backgroundMessageHandle);
    //      result.success(true);
    //    } else if ("FcmDartService#initialized".equals(call.method)) {
    //      FlutterFirebaseMessagingService.onInitialized();
    //      result.success(true);
    //    } else if ("configure".equals(call.method)) {
    //      FirebaseInstanceId.getInstance()
    //          .getInstanceId()
    //          .addOnCompleteListener(
    //              new OnCompleteListener<InstanceIdResult>() {
    //                @Override
    //                public void onComplete(@NonNull Task<InstanceIdResult> task) {
    //                  if (!task.isSuccessful()) {
    //                    Log.w(TAG, "getToken, error fetching instanceID: ", task.getException());
    //                    return;
    //                  }
    //                  channel.invokeMethod("onToken", task.getResult().getToken());
    //                }
    //              });
    //      if (mainActivity != null) {
    //        sendMessageFromIntent("onLaunch", mainActivity.getIntent());
    //      }
    //      result.success(null);
    //      else if ("deleteInstanceID".equals(call.method)) {
    //      new Thread(
    //              new Runnable() {
    //                @Override
    //                public void run() {
    //                  try {
    //                    FirebaseInstanceId.getInstance().deleteInstanceId();
    //                    if (mainActivity != null) {
    //                      mainActivity.runOnUiThread(
    //                          new Runnable() {
    //                            @Override
    //                            public void run() {
    //                              result.success(true);
    //                            }
    //                          });
    //                    }
    //                  } catch (IOException ex) {
    //                    Log.e(TAG, "deleteInstanceID, error:", ex);
    //                    if (mainActivity != null) {
    //                      mainActivity.runOnUiThread(
    //                          new Runnable() {
    //                            @Override
    //                            public void run() {
    //                              result.success(false);
    //                            }
    //                          });
    //                    }
    //                  }
    //                }
    //              })
    //          .start();
  }

  private Map<String, Object> getExceptionDetails(Exception exception) {
    Map<String, Object> details = new HashMap<>();
    // TODO implement
    return details;
  }

  @Override
  public boolean onNewIntent(Intent intent) {
    boolean res = sendMessageFromIntent("onResume", intent);
    if (res && mainActivity != null) {
      mainActivity.setIntent(intent);
    }
    return res;
  }

  /** @return true if intent contained a message to send. */
  private boolean sendMessageFromIntent(String method, Intent intent) {
    if (CLICK_ACTION_VALUE.equals(intent.getAction())
        || CLICK_ACTION_VALUE.equals(intent.getStringExtra("click_action"))) {
      Map<String, Object> message = new HashMap<>();
      Bundle extras = intent.getExtras();

      if (extras == null) {
        return false;
      }

      Map<String, Object> notificationMap = new HashMap<>();
      Map<String, Object> dataMap = new HashMap<>();

      for (String key : extras.keySet()) {
        Object extra = extras.get(key);
        if (extra != null) {
          dataMap.put(key, extra);
        }
      }

      message.put("notification", notificationMap);
      message.put("data", dataMap);

      channel.invokeMethod(method, message);
      return true;
    }
    return false;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Map<String, Object> constants = new HashMap<>();

          FirebaseMessaging firebaseMessaging = FirebaseMessaging.getInstance();
          constants.put("AUTO_INIT_ENABLED", firebaseMessaging.isAutoInitEnabled());

          // TODO get initial notification, convert to Map

          return constants;
        });
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(cachedThreadPool, () -> null);
  }
}
