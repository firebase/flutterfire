// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Logger;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.Transaction;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.*;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;

/** FirebaseDatabasePlugin */
public class FirebaseDatabasePlugin implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_database";

  private MethodChannel channel;
  private MethodCallHandlerImpl methodCallHandler;

  @SuppressWarnings("unused")
  public static void registerWith(Registrar registrar) {
    final FirebaseDatabasePlugin plugin = new FirebaseDatabasePlugin();
    plugin.initInstance(registrar.messenger());

    registrar.addViewDestroyListener(
      view -> {
        plugin.cleanup();
        return false;
      });
  }

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  FirebaseDatabase getDatabase(Map<String, Object> arguments) {
    final FirebaseDatabase database;
    final String appName = (String) Objects.requireNonNull(arguments.get(Constants.APP_NAME));
    final String databaseURL = (String) arguments.get(Constants.DATABASE_URL);
    final FirebaseApp app = FirebaseApp.getInstance(appName);

    if (databaseURL != null) {
      database = FirebaseDatabase.getInstance(app, databaseURL);
    } else {
      database = FirebaseDatabase.getInstance(app);
    }

    return database;
  }

  private DatabaseReference getReference(Map<String, Object> arguments) {
    final FirebaseDatabase database = getDatabase(arguments);
    final String path = (String) Objects.requireNonNull(arguments.get(Constants.PATH));

    return database.getReference(path);
  }

  private Task<Void> goOnline(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final FirebaseDatabase database = getDatabase(arguments);
        database.goOnline();
        return null;
      });
  }

  private Task<Void> goOffline(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final FirebaseDatabase database = getDatabase(arguments);
        database.goOffline();
        return null;
      });
  }

  private Task<Void> purgeOutstandingWrites(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final FirebaseDatabase database = getDatabase(arguments);
        database.purgeOutstandingWrites();
        return null;
      });
  }

  private Task<Void> setPersistenceEnabled(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final FirebaseDatabase database = getDatabase(arguments);
        final boolean isEnabled = (boolean) Objects.requireNonNull(arguments.get(Constants.ENABLED));

        database.setPersistenceEnabled(isEnabled);
        return null;
      });
  }

  private Task<Void> setPersistenceCacheSizeBytes(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final FirebaseDatabase database = getDatabase(arguments);
        final Object size = Objects.requireNonNull(arguments.get(Constants.CACHE_SIZE));
        Long cacheSize = Constants.DEFAULT_CACHE_SIZE;

        if (size instanceof Long) {
          cacheSize = (Long) size;
        } else if (size instanceof Integer) {
          cacheSize = Long.valueOf((Integer) size);
        }

        database.setPersistenceCacheSizeBytes(cacheSize);
        return null;
      });
  }

  private Task<Void> setLoggingEnabled(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final FirebaseDatabase database = getDatabase(arguments);
        final boolean isEnabled = (boolean) Objects.requireNonNull(arguments.get(Constants.ENABLED));

        final Logger.Level logLevel;

        if (isEnabled) {
          logLevel = Constants.ENABLED_LOG_LEVEL;
        } else {
          logLevel = Constants.DISABLED_LOG_LEVEL;
        }

        database.setLogLevel(logLevel);

        return null;
      });
  }

  private Task<Void> setValue(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final DatabaseReference ref = getReference(arguments);

        final Object value = arguments.get(Constants.VALUE);
        final Object priority = arguments.get(Constants.PRIORITY);

        if (priority != null) {
          Tasks.await(ref.setValue(value, priority));
        } else {
          Tasks.await(ref.setValue(value));
        }

        return null;
      });
  }

  private Task<Void> update(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final DatabaseReference ref = getReference(arguments);

        final Map<String, Object> value;
        value = (Map<String, Object>) Objects.requireNonNull(arguments.get(Constants.VALUE));

        Tasks.await(ref.updateChildren(value));

        return null;
      });
  }

  private Task<Void> setPriority(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final DatabaseReference ref = getReference(arguments);
        final Object priority = Objects.requireNonNull(arguments.get(Constants.PRIORITY));

        Tasks.await(ref.setPriority(priority));

        return null;
      });
  }

  private Task<Map<String, Object>> runTransaction(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final DatabaseReference ref = getReference(arguments);
        final TransactionHandler handler = new TransactionHandler(channel);

        ref.runTransaction(handler);

        return Tasks.await(handler.getTask());
      });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    final Task<?> methodCallTask;
    final Map<String, Object> arguments = call.arguments();

    switch (call.method) {
      case "FirebaseDatabase#goOnline":
        methodCallTask = goOnline(arguments);
        break;
      case "FirebaseDatabase#goOffline":
        methodCallTask = goOffline(arguments);
        break;
      case "FirebaseDatabase#purgeOutstandingWrites":
        methodCallTask = purgeOutstandingWrites(arguments);
        break;
      case "FirebaseDatabase#setPersistenceEnabled":
        methodCallTask = setPersistenceEnabled(arguments);
        break;
      case "FirebaseDatabase#setPersistenceCacheSizeBytes":
        methodCallTask = setPersistenceCacheSizeBytes(arguments);
        break;
      case "FirebaseDatabase#setLoggingEnabled":
        methodCallTask = setLoggingEnabled(arguments);
        break;
      case "DatabaseReference#set":
        methodCallTask = setValue(arguments);
        break;
      case "DatabaseReference#update":
        methodCallTask = update(arguments);
        break;
      case "DatabaseReference#setPriority":
        methodCallTask = setPriority(arguments);
        break;
      case "DatabaseReference#runTransaction":
        methodCallTask = runTransaction(arguments);
        break;
      case "OnDisconnect#set":
        break;
      case "OnDisconnect#update":
        break;
      case "OnDisconnect#cancel":
        break;
      case "Query#get":
        break;
      case "Query#keepSynced":
        break;
      case "Query#observe":
        break;
      case "Query#removeObserver":
        break;
      default:
        result.notImplemented();
        return;
    }

    methodCallTask.addOnCompleteListener(
      task -> {
        if (task.isSuccessful()) {
          result.success(task.getResult());
        } else {
          Exception exception = task.getException();
          result.error(
            "firebase_database",
            "something went wrong",
            new HashMap<String, Object>()
            );
        }
      });
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    cleanup();
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        return new HashMap<>();
      });
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        cleanup();
        return null;
      });
  }

  private void cleanup() {
    methodCallHandler.cleanup();
    methodCallHandler = null;
    channel.setMethodCallHandler(null);
  }
}
