// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebaseMlVisionPlugin */
public class FirebaseMlVisionPlugin implements FlutterPlugin {
  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_ml_vision";

  private MethodChannel channel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FirebaseMlVisionHandler(registrar.context()));
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FirebaseMlVisionHandler(binding.getApplicationContext()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
