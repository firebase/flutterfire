// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import android.os.Handler;
import android.util.Log;
import android.util.SparseArray;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseException;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.Query;
import com.google.firebase.database.Transaction;
import com.google.firebase.database.ValueEventListener;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements FlutterPlugin {

  private MethodChannel channel;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    FirebaseDatabasePlugin plugin = new FirebaseDatabasePlugin();
    plugin.setupMethodChannel(registrar.messenger());
  }

  private void setupMethodChannel(BinaryMessenger messenger) {
    channel =
            new MethodChannel(messenger, "plugins.flutter.io/firebase_database");
    MethodCallHandlerImpl handler = new MethodCallHandlerImpl(channel);
    channel.setMethodCallHandler(handler);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setupMethodChannel(binding.getFlutterEngine().getDartExecutor());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
