// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.inappmessaging;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.firebase.FirebaseApp;
import com.google.firebase.inappmessaging.FirebaseInAppMessaging;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.Map;
import java.util.Objects;

/** FirebaseInAppMessagingPlugin */
public class FirebaseInAppMessagingPlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    BinaryMessenger binaryMessenger = binding.getBinaryMessenger();
    channel = new MethodChannel(binaryMessenger, "plugins.flutter.io/firebase_in_app_messaging");
    channel.setMethodCallHandler(new FirebaseInAppMessagingPlugin());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "FirebaseInAppMessaging#triggerEvent":
        {
          String eventName = Objects.requireNonNull(call.argument("eventName"));
          FirebaseInAppMessaging.getInstance().triggerEvent(eventName);
          result.success(null);
          break;
        }
      case "FirebaseInAppMessaging#setMessagesSuppressed":
        {
          Boolean suppress = Objects.requireNonNull(call.argument("suppress"));
          FirebaseInAppMessaging.getInstance().setMessagesSuppressed(suppress);
          result.success(null);
          break;
        }
      case "FirebaseInAppMessaging#setAutomaticDataCollectionEnabled":
        {
          Boolean enabled = (Boolean) call.argument("enabled");
          FirebaseInAppMessaging.getInstance().setAutomaticDataCollectionEnabled(enabled);
          result.success(null);
          break;
        }
      default:
        {
          result.notImplemented();
          break;
        }
    }
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

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
}
