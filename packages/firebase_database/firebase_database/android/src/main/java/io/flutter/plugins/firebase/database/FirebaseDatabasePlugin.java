// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements FlutterPlugin {

  private MethodChannel channel;
  private MethodCallHandlerImpl methodCallHandler;

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
