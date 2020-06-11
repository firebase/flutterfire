// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.package io.flutter.plugins.firebaseml;

package io.flutter.plugins.firebaseml;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.common.modeldownload.FirebaseRemoteModel;
import com.google.firebase.ml.custom.FirebaseCustomRemoteModel;

/** FirebaseMLPlugin */
public class FirebaseMLPlugin implements FlutterPlugin, MethodCallHandler {

  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_ml";

  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FirebaseMLPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("downloadRemoteModel")) {
      result.success("I reach all the way here");
    } else if (call.method.equals("deleteDownloadedModels")) {
      result.notImplemented();
    } else if (call.method.equals("getDownloadedModels")) {
      result.notImplemented();
    } else if (call.method.equals("getLatestModelFile")) {
      result.notImplemented();
    } else if (call.method.equals("isModelDownloaded")) {
      result.notImplemented();
    } else if (call.method.equals("runInterpreter")) {
      result.notImplemented();
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
