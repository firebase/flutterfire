/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firebase_ml_model_downloader;

import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.ml.modeldownloader.CustomModel;
import com.google.firebase.ml.modeldownloader.CustomModelDownloadConditions;
import com.google.firebase.ml.modeldownloader.DownloadType;
import com.google.firebase.ml.modeldownloader.FirebaseMlException;
import com.google.firebase.ml.modeldownloader.FirebaseModelDownloader;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class FirebaseModelDownloaderPlugin
    implements FlutterPlugin, MethodCallHandler, FlutterFirebasePlugin {

  private static final String METHOD_CHANNEL_NAME =
      "plugins.flutter.io/firebase_ml_model_downloader";
  private MethodChannel channel;

  public FirebaseModelDownloaderPlugin() {}

  static Map<String, String> getExceptionDetails(Exception exception) {
    Map<String, String> details = new HashMap<>();

    if (exception == null) {
      return details;
    }

    String code = "UNKNOWN";
    String message = exception.getMessage();

    if (exception instanceof FirebaseMlException) {
      FirebaseMlException mlException = (FirebaseMlException) exception.getCause();
      code = exceptionCodeToString(mlException.getCode());
      message = mlException.getMessage();
    }

    details.put("code", code.replace("_", "-").toLowerCase());
    details.put("message", message);

    return details;
  }

  static String exceptionCodeToString(int code) {
    switch (code) {
      case 1:
        return "CANCELLED";
      default:
      case 2:
        return "UNKNOWN";
      case 3:
        return "INVALID_ARGUMENT";
      case 4:
        return "DEADLINE_EXCEEDED";
      case 5:
        return "NOT_FOUND";
      case 6:
        return "ALREADY_EXISTS";
      case 7:
        return "PERMISSION_DENIED";
      case 8:
        return "RESOURCE_EXHAUSTED";
      case 9:
        return "FAILED_PRECONDITION";
      case 10:
        return "ABORTED";
      case 11:
        return "OUT_OF_RANGE";
      case 12:
        return "UNIMPLEMENTED";
      case 13:
        return "INTERNAL";
      case 14:
        return "UNAVAILABLE";
      case 16:
        return "UNAUTHENTICATED";
      case 17:
        return "NO_NETWORK_CONNECTION";
      case 101:
        return "NOT_ENOUGH_SPACE";
      case 102:
        return "MODEL_HASH_MISMATCH";
      case 121:
        return "DOWNLOAD_URL_EXPIRED";
    }
  }

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

  // Returns a FirebaseModelDownloader instance for a given FirebaseApp.
  private FirebaseModelDownloader getFirebaseModelDownloader(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    return FirebaseModelDownloader.getInstance(app);
  }

  // Converts a CustomModel into a Map for Dart.
  private Map<String, Object> customModelToMap(CustomModel model) {
    Map<String, Object> out = new HashMap<>();

    out.put("filePath", model.getLocalFilePath());
    out.put("size", model.getSize());
    out.put("name", model.getName());
    out.put("hash", model.getModelHash());

    return out;
  }

  // Converts the provided Dart string into a DownloadType.
  private DownloadType getDownloadType(String type) {
    switch (type) {
      case "local":
        return DownloadType.LOCAL_MODEL;
      case "local_background":
        return DownloadType.LOCAL_MODEL_UPDATE_IN_BACKGROUND;
      case "latest":
      default:
        return DownloadType.LATEST_MODEL;
    }
  }

  @SuppressWarnings("ConstantConditions")
  @RequiresApi(api = Build.VERSION_CODES.N)
  Task<Map<String, Object>> getModel(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          FirebaseModelDownloader instance = getFirebaseModelDownloader(arguments);
          String modelName = (String) Objects.requireNonNull(arguments.get("modelName"));
          String downloadType = (String) Objects.requireNonNull(arguments.get("downloadType"));
          @SuppressWarnings("unchecked")
          Map<String, Boolean> conditions =
              (Map<String, Boolean>) Objects.requireNonNull(arguments.get("conditions"));

          CustomModelDownloadConditions.Builder conditionsBuilder =
              new CustomModelDownloadConditions.Builder();

          if (conditions.get("androidChargingRequired")) {
            conditionsBuilder.requireCharging();
          }

          if (conditions.get("androidWifiRequired")) {
            conditionsBuilder.requireWifi();
          }

          if (conditions.get("androidDeviceIdleRequired")) {
            conditionsBuilder.requireDeviceIdle();
          }

          try {
            CustomModel model =
                Tasks.await(
                    instance.getModel(
                        modelName, getDownloadType(downloadType), conditionsBuilder.build()));
            taskCompletionSource.setResult(customModelToMap(model));
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  Task<List<Map<String, Object>>> listDownloadedModels(Map<String, Object> arguments) {
    TaskCompletionSource<List<Map<String, Object>>> taskCompletionSource =
        new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          FirebaseModelDownloader instance = getFirebaseModelDownloader(arguments);

          try {
            Set<CustomModel> result = Tasks.await(instance.listDownloadedModels());
            List<Map<String, Object>> models = new ArrayList<>(result.size());

            for (CustomModel model : result) {
              models.add(customModelToMap(model));
            }

            taskCompletionSource.setResult(models);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  Task<Void> deleteDownloadedModel(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          FirebaseModelDownloader instance = getFirebaseModelDownloader(arguments);
          String modelName = (String) Objects.requireNonNull(arguments.get("modelName"));

          try {
            Tasks.await(instance.deleteDownloadedModel(modelName));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "FirebaseModelDownloader#getModel":
        methodCallTask = getModel(call.arguments());
        break;
      case "FirebaseModelDownloader#listDownloadedModels":
        methodCallTask = listDownloadedModels(call.arguments());
        break;
      case "FirebaseModelDownloader#deleteDownloadedModel":
        methodCallTask = deleteDownloadedModel(call.arguments());
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
            Map<String, String> exceptionDetails = getExceptionDetails(exception);

            result.error(
                "firebase_ml_model_downloader",
                exception != null ? exception.getMessage() : null,
                exceptionDetails);
          }
        });
  }

  // Returns a nullable task.
  private <T> Task<T> nullTask() {
    TaskCompletionSource<T> taskCompletionSource = new TaskCompletionSource<>();
    cachedThreadPool.execute(() -> taskCompletionSource.setResult(null));
    return taskCompletionSource.getTask();
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return nullTask();
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return nullTask();
  }
}
