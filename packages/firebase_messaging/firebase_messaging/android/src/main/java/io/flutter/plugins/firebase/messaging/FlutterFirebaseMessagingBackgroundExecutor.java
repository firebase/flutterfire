// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.firebase.messaging.RemoteMessage;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterShellArgs;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterCallbackInformation;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * An background execution abstraction which handles initializing a background isolate running a
 * callback dispatcher, used to invoke Dart callbacks while backgrounded.
 */
public class FlutterFirebaseMessagingBackgroundExecutor implements MethodCallHandler {
  private static final String TAG = "FLTFireBGExecutor";
  private static final String CALLBACK_HANDLE_KEY = "callback_handle";
  private static final String USER_CALLBACK_HANDLE_KEY = "user_callback_handle";

  private final AtomicBoolean isCallbackDispatcherReady = new AtomicBoolean(false);
  /**
   * The {@link MethodChannel} that connects the Android side of this plugin with the background
   * Dart isolate that was created by this plugin.
   */
  private MethodChannel backgroundChannel;

  private FlutterEngine backgroundFlutterEngine;

  /**
   * Sets the Dart callback handle for the Dart method that is responsible for initializing the
   * background Dart isolate, preparing it to receive Dart callback tasks requests.
   */
  public static void setCallbackDispatcher(long callbackHandle) {
    Context context = ContextHolder.getApplicationContext();
    SharedPreferences prefs =
        context.getSharedPreferences(FlutterFirebaseMessagingUtils.SHARED_PREFERENCES_KEY, 0);
    prefs.edit().putLong(CALLBACK_HANDLE_KEY, callbackHandle).apply();
  }

  /**
   * Returns true when the background isolate has started and is ready to handle background
   * messages.
   */
  public boolean isNotRunning() {
    return !isCallbackDispatcherReady.get();
  }

  private void onInitialized() {
    isCallbackDispatcherReady.set(true);
    FlutterFirebaseMessagingBackgroundService.onInitialized();
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    String method = call.method;
    try {
      if (method.equals("MessagingBackground#initialized")) {
        // This message is sent by the background method channel as soon as the background isolate
        // is running. From this point forward, the Android side of this plugin can send
        // callback handles through the background method channel, and the Dart side will execute
        // the Dart methods corresponding to those callback handles.
        onInitialized();
        result.success(true);
      } else {
        result.notImplemented();
      }
    } catch (PluginRegistrantException e) {
      result.error("error", "Flutter FCM error: " + e.getMessage(), null);
    }
  }

  /**
   * Starts running a background Dart isolate within a new {@link FlutterEngine} using a previously
   * used entrypoint.
   *
   * <p>The isolate is configured as follows:
   *
   * <ul>
   *   <li>Bundle Path: {@code io.flutter.view.FlutterMain.findAppBundlePath(context)}.
   *   <li>Entrypoint: The Dart method used the last time this plugin was initialized in the
   *       foreground.
   *   <li>Run args: none.
   * </ul>
   *
   * <p>Preconditions:
   *
   * <ul>
   *   <li>The given callback must correspond to a registered Dart callback. If the handle does not
   *       resolve to a Dart callback then this method does nothing.
   * </ul>
   */
  public void startBackgroundIsolate() {
    if (isNotRunning()) {
      long callbackHandle = getPluginCallbackHandle();
      if (callbackHandle != 0) {
        startBackgroundIsolate(callbackHandle, null);
      }
    }
  }

  /**
   * Starts running a background Dart isolate within a new {@link FlutterEngine}.
   *
   * <p>The isolate is configured as follows:
   *
   * <ul>
   *   <li>Bundle Path: {@code io.flutter.view.FlutterMain.findAppBundlePath(context)}.
   *   <li>Entrypoint: The Dart method represented by {@code callbackHandle}.
   *   <li>Run args: none.
   * </ul>
   *
   * <p>Preconditions:
   *
   * <ul>
   *   <li>The given {@code callbackHandle} must correspond to a registered Dart callback. If the
   *       handle does not resolve to a Dart callback then this method does nothing.
   * </ul>
   */
  public void startBackgroundIsolate(long callbackHandle, FlutterShellArgs shellArgs) {
    if (backgroundFlutterEngine != null) {
      Log.e(TAG, "Background isolate already started.");
      return;
    }

    FlutterLoader loader = new FlutterLoader();
    Handler mainHandler = new Handler(Looper.getMainLooper());
    Runnable myRunnable =
        () -> {
          loader.startInitialization(ContextHolder.getApplicationContext());
          loader.ensureInitializationCompleteAsync(
              ContextHolder.getApplicationContext(),
              null,
              mainHandler,
              () -> {
                String appBundlePath = loader.findAppBundlePath();
                AssetManager assets = ContextHolder.getApplicationContext().getAssets();
                if (isNotRunning()) {
                  if (shellArgs != null) {
                    Log.i(
                        TAG,
                        "Creating background FlutterEngine instance, with args: "
                            + Arrays.toString(shellArgs.toArray()));
                    backgroundFlutterEngine =
                        new FlutterEngine(
                            ContextHolder.getApplicationContext(), shellArgs.toArray());
                  } else {
                    Log.i(TAG, "Creating background FlutterEngine instance.");
                    backgroundFlutterEngine =
                        new FlutterEngine(ContextHolder.getApplicationContext());
                  }
                  // We need to create an instance of `FlutterEngine` before looking up the
                  // callback. If we don't, the callback cache won't be initialized and the
                  // lookup will fail.
                  FlutterCallbackInformation flutterCallback =
                      FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);
                  DartExecutor executor = backgroundFlutterEngine.getDartExecutor();
                  initializeMethodChannel(executor);
                  DartCallback dartCallback =
                      new DartCallback(assets, appBundlePath, flutterCallback);

                  executor.executeDartCallback(dartCallback);
                }
              });
        };
    mainHandler.post(myRunnable);
  }

  boolean isDartBackgroundHandlerRegistered() {
    return getPluginCallbackHandle() != 0;
  }

  /**
   * Executes the desired Dart callback in a background Dart isolate.
   *
   * <p>The given {@code intent} should contain a {@code long} extra called "callbackHandle", which
   * corresponds to a callback registered with the Dart VM.
   */
  public void executeDartCallbackInBackgroundIsolate(Intent intent, final CountDownLatch latch) {
    if (backgroundFlutterEngine == null) {
      Log.i(
          TAG,
          "A background message could not be handled in Dart as no onBackgroundMessage handler has been registered.");
      return;
    }

    Result result = null;
    if (latch != null) {
      result =
          new Result() {
            @Override
            public void success(Object result) {
              // If another thread is waiting, then wake that thread when the callback returns a result.
              latch.countDown();
            }

            @Override
            public void error(String errorCode, String errorMessage, Object errorDetails) {
              latch.countDown();
            }

            @Override
            public void notImplemented() {
              latch.countDown();
            }
          };
    }

    // Handle the message event in Dart.
    RemoteMessage remoteMessage =
        intent.getParcelableExtra(FlutterFirebaseMessagingUtils.EXTRA_REMOTE_MESSAGE);
    if (remoteMessage != null) {
      Map<String, Object> remoteMessageMap =
          FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage);
      backgroundChannel.invokeMethod(
          "MessagingBackground#onMessage",
          new HashMap<String, Object>() {
            {
              put("userCallbackHandle", getUserCallbackHandle());
              put("message", remoteMessageMap);
            }
          },
          result);
    } else {
      Log.e(TAG, "RemoteMessage instance not found in Intent.");
    }
  }

  /**
   * Get the users registered Dart callback handle for background messaging. Returns 0 if not set.
   */
  private long getUserCallbackHandle() {
    SharedPreferences prefs =
        ContextHolder.getApplicationContext()
            .getSharedPreferences(FlutterFirebaseMessagingUtils.SHARED_PREFERENCES_KEY, 0);
    return prefs.getLong(USER_CALLBACK_HANDLE_KEY, 0);
  }

  /**
   * Sets the Dart callback handle for the users Dart handler that is responsible for handling
   * messaging events in the background.
   */
  public static void setUserCallbackHandle(long callbackHandle) {
    Context context = ContextHolder.getApplicationContext();
    SharedPreferences prefs =
        context.getSharedPreferences(FlutterFirebaseMessagingUtils.SHARED_PREFERENCES_KEY, 0);
    prefs.edit().putLong(USER_CALLBACK_HANDLE_KEY, callbackHandle).apply();
  }

  /** Get the registered Dart callback handle for the messaging plugin. Returns 0 if not set. */
  private long getPluginCallbackHandle() {
    SharedPreferences prefs =
        ContextHolder.getApplicationContext()
            .getSharedPreferences(FlutterFirebaseMessagingUtils.SHARED_PREFERENCES_KEY, 0);
    return prefs.getLong(CALLBACK_HANDLE_KEY, 0);
  }

  private void initializeMethodChannel(BinaryMessenger isolate) {
    // backgroundChannel is the channel responsible for receiving the following messages from
    // the background isolate that was setup by this plugin method call:
    // - "FirebaseBackgroundMessaging#initialized"
    //
    // This channel is also responsible for sending requests from Android to Dart to execute Dart
    // callbacks in the background isolate.
    backgroundChannel =
        new MethodChannel(isolate, "plugins.flutter.io/firebase_messaging_background");
    backgroundChannel.setMethodCallHandler(this);
  }
}
