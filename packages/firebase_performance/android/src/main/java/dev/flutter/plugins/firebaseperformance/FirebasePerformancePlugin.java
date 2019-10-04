// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.firebaseperformance;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebasePerformancePlugin */
public class FirebasePerformancePlugin implements FlutterPlugin {
  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_performance";

  MethodChannel channel;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new io.flutter.plugins.firebaseperformance.FirebasePerformancePlugin());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    channel = new MethodChannel(
        binding.getFlutterEngine().getDartExecutor(),
        CHANNEL_NAME);
    channel.setMethodCallHandler(new FirebasePerformancePluginHandler());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
