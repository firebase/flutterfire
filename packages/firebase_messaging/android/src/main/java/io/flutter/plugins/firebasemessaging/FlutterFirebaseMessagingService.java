// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemessaging;

import android.app.ActivityManager;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Process;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterCallbackInformation;
import io.flutter.view.FlutterMain;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;

public class FlutterFirebaseMessagingService extends FirebaseMessagingService {

  public static final String ACTION_REMOTE_MESSAGE =
      "io.flutter.plugins.firebasemessaging.NOTIFICATION";
  public static final String EXTRA_REMOTE_MESSAGE = "notification";

  public static final String ACTION_TOKEN = "io.flutter.plugins.firebasemessaging.TOKEN";
  public static final String EXTRA_TOKEN = "token";

  private static final String SHARED_PREFERENCES_KEY = "io.flutter.android_fcm_plugin";
  private static final String BACKGROUND_SETUP_CALLBACK_HANDLE_KEY = "background_setup_callback";
  private static final String BACKGROUND_MESSAGE_CALLBACK_HANDLE_KEY =
      "background_message_callback";

  /** Background Dart execution context. */
  @Nullable private FlutterEngine backgroundEngine;

  @Nullable private MethodChannel backgroundChannel;

  private static Long backgroundMessageHandle;

  private final List<RemoteMessage> backgroundMessageQueue =
      Collections.synchronizedList(new LinkedList<RemoteMessage>());

  private static final String TAG = "FlutterFcmService";

  @Override
  public void onCreate() {
    super.onCreate();

    FlutterMain.ensureInitializationComplete(this, null);

    if (maybeStartIsolate()) {
      Log.d(TAG, "Background isolate has been started.");
    }
  }

  @Override
  public void onDestroy() {
    super.onDestroy();

    if (backgroundChannel != null) {
      backgroundChannel.setMethodCallHandler(null);
      backgroundChannel = null;
    }

    if (backgroundEngine != null) {
      backgroundEngine.destroy();
      backgroundEngine = null;
    }
  }

  /**
   * Called when message is received.
   *
   * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
   */
  @Override
  public void onMessageReceived(@NonNull final RemoteMessage remoteMessage) {
    // If application is running in the foreground use local broadcast to handle message.
    // Otherwise use the background isolate to handle message.
    if (isApplicationForeground(this)) {
      Intent intent = new Intent(ACTION_REMOTE_MESSAGE);
      intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
      LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    } else {
      // If background isolate is not running yet, put message in queue and it will be handled
      // when the isolate starts.
      if (backgroundEngine == null) {
        backgroundMessageQueue.add(remoteMessage);

        maybeStartIsolate();
      } else {
        final CountDownLatch latch = new CountDownLatch(1);
        new Handler(getMainLooper())
            .post(
                new Runnable() {
                  @Override
                  public void run() {
                    executeDartCallbackInBackgroundIsolate(
                        FlutterFirebaseMessagingService.this, remoteMessage, latch);
                  }
                });
        try {
          latch.await();
        } catch (InterruptedException ex) {
          Log.i(TAG, "Exception waiting to execute Dart callback", ex);
        }
      }
    }
  }

  /**
   * Called when a new token for the default Firebase project is generated.
   *
   * @param token The token used for sending messages to this application instance. This token is
   *     the same as the one retrieved by getInstanceId().
   */
  @Override
  public void onNewToken(@NonNull String token) {
    Intent intent = new Intent(ACTION_TOKEN);
    intent.putExtra(EXTRA_TOKEN, token);
    LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
  }

  /**
   * Only start the isolate if we have background details.
   *
   * @return Whether the isolate has been start or is running already.
   */
  private boolean maybeStartIsolate() {
    // If background isolate is not running start it.
    SharedPreferences p = getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
    long callbackHandle = p.getLong(BACKGROUND_SETUP_CALLBACK_HANDLE_KEY, 0);

    if (backgroundEngine != null) {
      return true;
    }
    if (callbackHandle != 0) {
      startBackgroundIsolate(this, callbackHandle);
      return true;
    }

    return false;
  }

  /**
   * Setup the background isolate that would allow background messages to be handled on the Dart
   * side. Called either by the plugin when the app is starting up or when the app receives a
   * message while it is inactive.
   *
   * @param context Registrar or FirebaseMessagingService context.
   * @param callbackHandle Handle used to retrieve the Dart function that sets up background
   *     handling on the dart side.
   */
  private void startBackgroundIsolate(Context context, long callbackHandle) {
    FlutterMain.ensureInitializationComplete(context, null);
    String appBundlePath = FlutterMain.findAppBundlePath();
    FlutterCallbackInformation flutterCallback =
        FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);

    backgroundEngine = new FlutterEngine(context);

    final DartExecutor executor = backgroundEngine.getDartExecutor();

    backgroundChannel =
        new MethodChannel(executor, "plugins.flutter.io/firebase_messaging_background");
    backgroundChannel.setMethodCallHandler(
        new MethodCallHandler() {
          @Override
          public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
            if ("FcmDartService#initialized".equals(call.method)) {
              onInitialized();
              result.success(true);
            } else {
              result.notImplemented();
            }
          }
        });

    final DartCallback dartCallback =
        new DartExecutor.DartCallback(getAssets(), appBundlePath, flutterCallback);

    executor.executeDartCallback(dartCallback);
  }

  /**
   * Acknowledge that background message handling on the Dart side is ready. This is called by the
   * Dart side once all background initialization is complete via `FcmDartService#initialized`.
   */
  public void onInitialized() {
    synchronized (backgroundMessageQueue) {
      // Handle all the messages received before the Dart isolate was
      // initialized, then clear the queue.
      for (RemoteMessage remoteMessage : backgroundMessageQueue) {
        executeDartCallbackInBackgroundIsolate(this, remoteMessage, null);
      }
      backgroundMessageQueue.clear();
    }
  }

  /**
   * Set the background message handle for future use. When background messages need to be handled
   * on the Dart side the handler must be retrieved in the background isolate to allow processing of
   * the incoming message. This method is called by the Dart side via `FcmDartService#start`.
   *
   * @param context Registrar context.
   * @param handle Handle representing the Dart side method that will handle background messages.
   */
  public static void setBackgroundMessageHandle(Context context, Long handle) {
    backgroundMessageHandle = handle;

    // Store background message handle in shared preferences so it can be retrieved
    // by other application instances.
    SharedPreferences prefs = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
    prefs.edit().putLong(BACKGROUND_MESSAGE_CALLBACK_HANDLE_KEY, handle).apply();
  }

  /**
   * Set the background message setup handle for future use. The Dart side of this plugin has a
   * method that sets up the background method channel. When ready to setup the background channel
   * the Dart side needs to be able to retrieve the setup method. This method is called by the Dart
   * side via `FcmDartService#start`.
   *
   * @param context Registrar context.
   * @param setupBackgroundHandle Handle representing the dart side method that will setup the
   *     background method channel.
   */
  public static void setBackgroundSetupHandle(Context context, long setupBackgroundHandle) {
    // Store background setup handle in shared preferences so it can be retrieved
    // by other application instances.
    SharedPreferences prefs = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
    prefs.edit().putLong(BACKGROUND_SETUP_CALLBACK_HANDLE_KEY, setupBackgroundHandle).apply();
  }

  /**
   * Retrieve the background message handle. When a background message is received and must be
   * processed on the dart side the handle representing the Dart side handle is retrieved so the
   * appropriate method can be called to process the message on the Dart side. This method is called
   * by FlutterFirebaseMessagingServcie either when a new background message is received or if
   * background messages were queued up while background message handling was being setup.
   *
   * @param context Application context.
   * @return Dart side background message handle.
   */
  public static Long getBackgroundMessageHandle(Context context) {
    return context
        .getSharedPreferences(SHARED_PREFERENCES_KEY, 0)
        .getLong(BACKGROUND_MESSAGE_CALLBACK_HANDLE_KEY, 0);
  }

  /**
   * Process the incoming message in the background isolate. This method is called only after
   * background method channel is setup, it is called by FlutterFirebaseMessagingServcie either when
   * a new background message is received or after background method channel setup for queued
   * messages received during setup.
   *
   * @param context Application or FirebaseMessagingService context.
   * @param remoteMessage Message received from Firebase Cloud Messaging.
   * @param latch If set will count down when the Dart side message processing is complete. Allowing
   *     any waiting threads to continue.
   */
  private void executeDartCallbackInBackgroundIsolate(
      Context context, RemoteMessage remoteMessage, final CountDownLatch latch) {
    if (backgroundChannel == null) {
      throw new RuntimeException(
          "setBackgroundChannel was not called before messages came in, exiting.");
    }

    // If another thread is waiting, then wake that thread when the callback returns a result.
    MethodChannel.Result result = null;
    if (latch != null) {
      result = new LatchResult(latch).getResult();
    }

    Map<String, Object> args = new HashMap<>();
    Map<String, Object> messageData = new HashMap<>();
    if (backgroundMessageHandle == null) {
      backgroundMessageHandle = getBackgroundMessageHandle(context);
    }
    args.put("handle", backgroundMessageHandle);

    messageData.put("data", remoteMessage.getData());

    if (remoteMessage.getNotification() != null) {
      messageData.put("notification", remoteMessage.getNotification());
    }

    args.put("message", messageData);

    backgroundChannel.invokeMethod("handleBackgroundMessage", args, result);
  }

  /**
   * Identify if the application is currently in a state where user interaction is possible. This
   * method is only called by FlutterFirebaseMessagingService when a message is received to
   * determine how the incoming message should be handled.
   *
   * @param context FlutterFirebaseMessagingService context.
   * @return True if the application is currently in a state where user interaction is possible,
   *     false otherwise.
   */
  // TODO(kroikie): Find a better way to determine application state.
  private static boolean isApplicationForeground(Context context) {
    KeyguardManager keyguardManager =
        (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);

    if (keyguardManager.isKeyguardLocked()) {
      return false;
    }
    int myPid = Process.myPid();

    ActivityManager activityManager =
        (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);

    List<ActivityManager.RunningAppProcessInfo> list;

    if ((list = activityManager.getRunningAppProcesses()) != null) {
      for (ActivityManager.RunningAppProcessInfo aList : list) {
        ActivityManager.RunningAppProcessInfo info;
        if ((info = aList).pid == myPid) {
          return info.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND;
        }
      }
    }
    return false;
  }
}
