// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.performance;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.util.SparseArray;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.Map;

/**
 * Flutter plugin accessing Firebase Performance API.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class FlutterFirebasePerformancePlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_performance";

  private final SparseArray<MethodCallHandler> handlers = new SparseArray<>();
  private MethodChannel channel;

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
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

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (getHandler(call) == null) {
      final Integer handle = call.argument("handle");
      addHandler(handle, new FlutterFirebasePerformance(this));
    }

    final MethodChannel.MethodCallHandler handler = getHandler(call);
    handler.onMethodCall(call, result);
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(() -> new HashMap<String, Object>() {});
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(() -> null);
  }
}
