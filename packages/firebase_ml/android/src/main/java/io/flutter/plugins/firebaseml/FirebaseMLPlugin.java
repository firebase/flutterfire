// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.package io.flutter.plugins.firebaseml;

package io.flutter.plugins.firebaseml;

import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.custom.FirebaseCustomRemoteModel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

/** A flutter plugin for accessing the FirebaseML API. */
public class FirebaseMLPlugin implements FlutterPlugin, MethodCallHandler {

  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_ml";

  private MethodChannel channel;

  /**
   * Registers a plugin with the v1 embedding api {@code io.flutter.plugin.common}.
   *
   * <p>Calling this will register the plugin with the passed registrar. However, plugins
   * initialized this way won't react to changes in activity or context.
   *
   * @param registrar connects this plugin's {@link
   *     io.flutter.plugin.common.MethodChannel.MethodCallHandler} to its {@link
   *     io.flutter.plugin.common.BinaryMessenger}.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FirebaseMLPlugin());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    final FirebaseCustomRemoteModel remoteModel;
    String modelName;

    switch (call.method) {
      case "FirebaseModelManager#download":
        assert (call.argument("model") != null);
        assert (call.argument("conditions") != null);

        modelName = call.argument("model");
        Map<String, Boolean> conditionsToMap = call.argument("conditions");
        remoteModel = new FirebaseCustomRemoteModel.Builder(modelName).build();
        FirebaseModelDownloadConditions.Builder conditionsBuilder =
            new FirebaseModelDownloadConditions.Builder();
        if (conditionsToMap.get("requireCharging")) conditionsBuilder.requireCharging();
        if (conditionsToMap.get("requireDeviceIdle")) conditionsBuilder.requireDeviceIdle();
        if (conditionsToMap.get("requireWifi")) conditionsBuilder.requireWifi();

        FirebaseModelDownloadConditions conditions = conditionsBuilder.build();
        FirebaseModelManager.getInstance()
            .download(remoteModel, conditions)
            .addOnCompleteListener(
                new OnCompleteListener<Void>() {
                  @Override
                  public void onComplete(@NonNull Task<Void> task) {
                    result.success(remoteModelToMap(remoteModel));
                  }
                });
        break;
      case "FirebaseModelManager#getLatestModelFile":
        assert (call.argument("model") != null);

        modelName = call.argument("model");

        remoteModel = new FirebaseCustomRemoteModel.Builder(modelName).build();

        FirebaseModelManager.getInstance()
            .getLatestModelFile(remoteModel)
            .addOnCompleteListener(
                new OnCompleteListener<File>() {
                  @Override
                  public void onComplete(@NonNull Task<File> task) {
                    File modelFile = task.getResult();
                    if (modelFile != null) result.success(modelFile.getAbsolutePath());
                    else task.getException().printStackTrace();
                  }
                });
        break;
      case "FirebaseModelManager#isModelDownloaded":
        assert (call.argument("model") != null);
        modelName = call.argument("model");

        remoteModel = new FirebaseCustomRemoteModel.Builder(modelName).build();

        FirebaseModelManager.getInstance()
            .isModelDownloaded(remoteModel)
            .addOnCompleteListener(
                new OnCompleteListener<Boolean>() {
                  @Override
                  public void onComplete(@NonNull Task<Boolean> task) {
                    Boolean isModelDownloaded = task.getResult();
                    if (isModelDownloaded != null) result.success(isModelDownloaded);
                    else task.getException().printStackTrace();
                  }
                });
        break;
      default:
        result.notImplemented();
    }
  }

  private Map<String, String> remoteModelToMap(FirebaseCustomRemoteModel model) {
    Map remoteModelToMap = new HashMap<String, String>();
    remoteModelToMap.put("modelName", model.getModelName());
    remoteModelToMap.put("modelHash", model.getModelHash());
    return remoteModelToMap;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
