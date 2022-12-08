// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.functions;

import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.functions.FirebaseFunctions;
import com.google.firebase.functions.FirebaseFunctionsException;
import com.google.firebase.functions.HttpsCallableReference;
import com.google.firebase.functions.HttpsCallableResult;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.io.IOException;
import java.io.InterruptedIOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

public class FlutterFirebaseFunctionsPlugin
    implements FlutterPlugin, FlutterFirebasePlugin, MethodCallHandler {

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_functions";
  private MethodChannel channel;

  /**
   * Default Constructor.
   *
   * <p>Use this when adding the plugin to your FlutterEngine
   */
  public FlutterFirebaseFunctionsPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
  }

  private FirebaseFunctions getFunctions(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    String region = (String) Objects.requireNonNull(arguments.get("region"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseFunctions.getInstance(app, region);
  }

  private Task<Object> httpsFunctionCall(Map<String, Object> arguments) {
    TaskCompletionSource<Object> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {

            FirebaseFunctions firebaseFunctions = getFunctions(arguments);

            String functionName = (String) Objects.requireNonNull(arguments.get("functionName"));
            String origin = (String) arguments.get("origin");
            Integer timeout = (Integer) arguments.get("timeout");
            Object parameters = arguments.get("parameters");

            if (origin != null) {
              Uri originUri = Uri.parse(origin);
              firebaseFunctions.useEmulator(originUri.getHost(), originUri.getPort());
            }

            HttpsCallableReference httpsCallableReference =
                firebaseFunctions.getHttpsCallable(functionName);

            if (timeout != null) {
              httpsCallableReference.setTimeout(timeout.longValue(), TimeUnit.MILLISECONDS);
            }

            HttpsCallableResult result = Tasks.await(httpsCallableReference.call(parameters));
            taskCompletionSource.setResult(result.getData());

          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull final Result result) {
    if (!call.method.equals("FirebaseFunctions#call")) {
      result.notImplemented();
      return;
    }

    httpsFunctionCall(call.arguments())
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success(task.getResult());
              } else {
                Exception exception = task.getException();
                result.error(
                    "firebase_functions",
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
    Object additionalData = null;

    if (exception.getCause() instanceof FirebaseFunctionsException) {
      FirebaseFunctionsException functionsException =
          (FirebaseFunctionsException) exception.getCause();
      code = functionsException.getCode().name();
      message = functionsException.getMessage();
      additionalData = functionsException.getDetails();

      if (functionsException.getCause() instanceof IOException
          && "Canceled".equals(functionsException.getCause().getMessage())) {
        // return DEADLINE_EXCEEDED for IOException cancel errors, to match iOS & Web
        code = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name();
        message = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name();
      } else if (functionsException.getCause() instanceof InterruptedIOException
          // return DEADLINE_EXCEEDED for InterruptedIOException errors, to match iOS & Web
          && "timeout".equals(functionsException.getCause().getMessage())) {
        code = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name();
        message = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name();
      } else if (functionsException.getCause() instanceof IOException) {
        // return UNAVAILABLE for network io errors, to match iOS & Web
        code = FirebaseFunctionsException.Code.UNAVAILABLE.name();
        message = FirebaseFunctionsException.Code.UNAVAILABLE.name();
      }
    }

    details.put("code", code.replace("_", "-").toLowerCase());
    details.put("message", message);

    if (additionalData != null) {
      details.put("additionalData", additionalData);
    }

    return details;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(() -> taskCompletionSource.setResult(null));

    return taskCompletionSource.getTask();
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(() -> taskCompletionSource.setResult(null));

    return taskCompletionSource.getTask();
  }
}
