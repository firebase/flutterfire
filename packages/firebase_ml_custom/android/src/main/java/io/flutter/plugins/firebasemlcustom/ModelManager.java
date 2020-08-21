package io.flutter.plugins.firebasemlcustom;

import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.custom.FirebaseCustomRemoteModel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import java.io.File;
import java.util.Map;

public final class ModelManager {
  private ModelManager() {}

  @RequiresApi(api = Build.VERSION_CODES.N)
  static void handleModelManager(@NonNull MethodCall call, @NonNull final Result result) {
    switch (call.method) {
      case "FirebaseModelManager#download":
        download(call, result);
        break;
      case "FirebaseModelManager#getLatestModelFile":
        getLatestModelFile(call, result);
        break;
      case "FirebaseModelManager#isModelDownloaded":
        isModelDownloaded(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  static void download(@NonNull MethodCall call, @NonNull final Result result) {
    assert (call.argument("modelName") != null);
    assert (call.argument("conditions") != null);

    String modelName = call.argument("modelName");
    Map<String, Boolean> conditionsToMap = call.argument("conditions");
    final FirebaseCustomRemoteModel remoteModel =
        new FirebaseCustomRemoteModel.Builder(modelName).build();
    FirebaseModelDownloadConditions.Builder conditionsBuilder =
        new FirebaseModelDownloadConditions.Builder();

    if (conditionsToMap.get("androidRequireCharging")) {
      conditionsBuilder.requireCharging();
    }
    if (conditionsToMap.get("androidRequireDeviceIdle")) {
      conditionsBuilder.requireDeviceIdle();
    }
    if (conditionsToMap.get("androidRequireWifi")) {
      conditionsBuilder.requireWifi();
    }

    FirebaseModelDownloadConditions conditions = conditionsBuilder.build();
    FirebaseModelManager.getInstance()
        .download(remoteModel, conditions)
        .addOnSuccessListener(
            new OnSuccessListener<Void>() {
              @Override
              public void onSuccess(Void v) {
                result.success(null);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                result.error("FirebaseModelManager", exception.getLocalizedMessage(), null);
              }
            });
  }

  private static void getLatestModelFile(@NonNull MethodCall call, @NonNull final Result result) {
    assert (call.argument("modelName") != null);
    String modelName = call.argument("modelName");

    final FirebaseCustomRemoteModel remoteModel =
        new FirebaseCustomRemoteModel.Builder(modelName).build();

    FirebaseModelManager.getInstance()
        .getLatestModelFile(remoteModel)
        .addOnCompleteListener(
            new OnCompleteListener<File>() {
              @Override
              public void onComplete(@NonNull Task<File> task) {
                File modelFile = task.getResult();
                if (modelFile != null) {
                  result.success(modelFile.getAbsolutePath());
                } else {
                  String errorMessage =
                      task.getException() == null
                          ? "Please make sure your custom remote model is downloaded."
                          : task.getException().getLocalizedMessage();
                  result.error("FirebaseModelManager", errorMessage, null);
                }
              }
            });
  }

  private static void isModelDownloaded(@NonNull MethodCall call, @NonNull final Result result) {
    assert (call.argument("modelName") != null);
    String modelName = call.argument("modelName");

    final FirebaseCustomRemoteModel remoteModel =
        new FirebaseCustomRemoteModel.Builder(modelName).build();

    FirebaseModelManager.getInstance()
        .isModelDownloaded(remoteModel)
        .addOnCompleteListener(
            new OnCompleteListener<Boolean>() {
              @Override
              public void onComplete(@NonNull Task<Boolean> task) {
                Boolean isModelDownloaded = task.getResult();
                if (isModelDownloaded != null) {
                  result.success(isModelDownloaded);
                } else {
                  result.error(
                      "FirebaseModelManager", task.getException().getLocalizedMessage(), null);
                }
              }
            });
  }
}
