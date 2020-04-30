// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firebaseremoteconfig;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebaseRemoteConfigPlugin */
public class FirebaseRemoteConfigPlugin implements FlutterPlugin {

  static final String TAG = "FirebaseRemoteConfigPlugin";
  static final String PREFS_NAME =
      "io.flutter.plugins.firebase.firebaseremoteconfig.FirebaseRemoteConfigPlugin";
  static final String METHOD_CHANNEL = "plugins.flutter.io/firebase_remote_config";

  private MethodChannel channel;

  public static void registerWith(Registrar registrar) {
    FirebaseRemoteConfigPlugin plugin = new FirebaseRemoteConfigPlugin();
    plugin.setupChannel(registrar.messenger(), registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupChannel(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    tearDownChannel();
  }

  private void setupChannel(BinaryMessenger messenger, Context context) {
    MethodCallHandlerImpl handler =
        new MethodCallHandlerImpl(context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE));
    channel = new MethodChannel(messenger, METHOD_CHANNEL);
    channel.setMethodCallHandler(handler);
  }

  private void tearDownChannel() {
    channel.setMethodCallHandler(null);
    channel = null;
  }
}
