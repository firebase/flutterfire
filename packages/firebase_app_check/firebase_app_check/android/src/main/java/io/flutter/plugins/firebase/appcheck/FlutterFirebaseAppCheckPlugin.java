// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.appcheck;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.io.IOException;
import java.io.InterruptedIOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

public class FlutterFirebaseAppCheckPlugin implements FlutterFirebasePlugin, MethodCallHandler {

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
      new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_app_check");
    channel.setMethodCallHandler(
      new FlutterFirebaseAppCheckPlugin());
  }


  private Task<Void> activate(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        // TODO
        return null;
      });
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull final Result result) {
    if (!call.method.equals("FirebaseAppCheck#activate")) {
      result.notImplemented();
      return;
    }

    activate(call.arguments())
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

    if (exception == null) {
      return details;
    }

    String code = "UNKNOWN";
    String message = exception.getMessage();

    // TODO

    details.put("code", code.replace("_", "-").toLowerCase());
    details.put("message", message);



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
