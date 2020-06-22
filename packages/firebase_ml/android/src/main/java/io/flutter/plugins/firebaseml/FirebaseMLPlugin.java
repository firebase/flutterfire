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

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "downloadRemoteModel":
        result.success("Testing call. Will be removed shortly");
        break;
      case "deleteDownloadedModels":
      case "getDownloadedModels":
      case "getLatestModelFile":
      case "isModelDownloaded":
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
