// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.ViewDestroyListener;
import io.flutter.view.FlutterNativeView;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements FlutterPlugin {

  private MethodChannel channel;
  private MethodCallHandlerImpl methodCallHandler;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final FirebaseDatabasePlugin plugin = new FirebaseDatabasePlugin();
    plugin.setupMethodChannel(registrar.messenger());

    registrar.addViewDestroyListener(
        new ViewDestroyListener() {
          @Override
          public boolean onViewDestroy(FlutterNativeView view) {
            plugin.cleanup();
            return false;
          }
        });
  }

  private void setupMethodChannel(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "plugins.flutter.io/firebase_database");
    methodCallHandler = new MethodCallHandlerImpl(channel);
    channel.setMethodCallHandler(methodCallHandler);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupMethodChannel(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    cleanup();
  }

  private void cleanup() {
    methodCallHandler.cleanup();
    methodCallHandler = null;
    channel.setMethodCallHandler(null);
  }
}
