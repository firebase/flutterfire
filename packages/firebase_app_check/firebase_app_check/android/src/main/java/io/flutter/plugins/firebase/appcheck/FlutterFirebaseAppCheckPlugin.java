// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.appcheck;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.appcheck.FirebaseAppCheck;
import com.google.firebase.appcheck.safetynet.SafetyNetAppCheckProviderFactory;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import java.util.HashMap;
import java.util.Map;

public class FlutterFirebaseAppCheckPlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    final String channelName = "plugins.flutter.io/firebase_app_check";
    final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), channelName);
    channel.setMethodCallHandler(this);
    FlutterFirebasePluginRegistry.registerPlugin(channelName, this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // Nothing to cleanup.
  }

  private Task<Void> activate() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.getInstance();
          firebaseAppCheck.installAppCheckProviderFactory(
              SafetyNetAppCheckProviderFactory.getInstance());
          return null;
        });
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull final Result result) {
    if (!call.method.equals("FirebaseAppCheck#activate")) {
      result.notImplemented();
      return;
    }

    activate()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(task.getResult());
              } else {
                Exception exception = task.getException();
                result.error(
                    "firebase_app_check",
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
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(() -> null);
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(() -> null);
  }
}
