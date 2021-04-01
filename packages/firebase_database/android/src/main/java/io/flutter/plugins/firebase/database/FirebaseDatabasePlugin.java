// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements FlutterPlugin {

  private MethodChannel channel;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    FirebaseDatabasePlugin plugin = new FirebaseDatabasePlugin();
    plugin.setupMethodChannel(registrar.messenger());
  }

  private void setupMethodChannel(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "plugins.flutter.io/firebase_database");
    MethodCallHandlerImpl handler = new MethodCallHandlerImpl(channel);
    channel.setMethodCallHandler(handler);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupMethodChannel(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
