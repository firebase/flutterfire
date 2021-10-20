// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import android.util.SparseArray;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Flutter plugin accessing Firebase Performance API.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class FirebasePerformancePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_performance";

  private final SparseArray<MethodChannel.MethodCallHandler> handlers = new SparseArray<>();
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (getHandler(call) == null) {
      final Integer handle = call.argument("handle");
      addHandler(handle, new FlutterFirebasePerformance(this));
    }

    final MethodChannel.MethodCallHandler handler = getHandler(call);
    handler.onMethodCall(call, result);
  }

  void addHandler(final int handle, final MethodChannel.MethodCallHandler handler) {
    if (handlers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    handlers.put(handle, handler);
  }

  void removeHandler(final int handle) {
    handlers.remove(handle);
  }

  private MethodChannel.MethodCallHandler getHandler(final MethodCall call) {
    final Integer handle = call.argument("handle");

    if (handle == null) return null;
    return handlers.get(handle);
  }
}
