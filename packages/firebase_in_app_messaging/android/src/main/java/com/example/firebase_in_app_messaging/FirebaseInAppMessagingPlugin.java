// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.firebase_in_app_messaging;

import android.support.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import com.google.firebase.inappmessaging.FirebaseInAppMessaging;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.BinaryMessenger;

/** FirebaseInAppMessagingPlugin */
public class FirebaseInAppMessagingPlugin implements FlutterPlugin, MethodCallHandler {
  private final FirebaseInAppMessaging instance;

  private static void setup(BinaryMessenger binaryMessenger) {
    final MethodChannel channel =
    new MethodChannel(binaryMessenger, "plugins.flutter.io/firebase_in_app_messaging");
      channel.setMethodCallHandler(new FirebaseInAppMessagingPlugin());
  }

  public static void registerWith(Registrar registrar) {
    setup(registrar.messenger());
  }

  public FirebaseInAppMessagingPlugin() {
    instance = FirebaseInAppMessaging.getInstance();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    setup(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // TODO: your plugin is no longer attached to a Flutter experience.
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "triggerEvent":
        {
          String eventName = call.argument("eventName");
          instance.triggerEvent(eventName);
          result.success(null);
          break;
        }
      case "setMessagesSuppressed":
        {
          Boolean suppress = (Boolean) call.arguments;
          instance.setMessagesSuppressed(suppress);
          result.success(null);
          break;
        }
      case "setAutomaticDataCollectionEnabled":
        {
          Boolean enabled = (Boolean) call.arguments;
          instance.setAutomaticDataCollectionEnabled(enabled);
          result.success(null);
          break;
        }
      default:
        {
          result.notImplemented();
          break;
        }
    }
  }
}
