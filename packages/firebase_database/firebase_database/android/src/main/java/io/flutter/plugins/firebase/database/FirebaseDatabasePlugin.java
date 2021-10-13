// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseException;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Logger;
import com.google.firebase.database.OnDisconnect;
import com.google.firebase.database.Query;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;

/**
 * FirebaseDatabasePlugin
 */
public class FirebaseDatabasePlugin implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler, ActivityAware {
  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_database";

  private MethodChannel methodChannel;
  private BinaryMessenger messenger;

  private final HashMap<EventChannel, StreamHandler> streamHandlers = new HashMap<>();
  private final Set<String> eventChannels = new HashSet<>();
  private Activity activity;

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }

  // Only access activity with this method.
  @Nullable
  private Activity getActivity() {
    return activity;
  }

  private void initInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    this.messenger = messenger;

    methodChannel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    methodChannel.setMethodCallHandler(this);
  }

  FirebaseDatabase getDatabase(Map<String, Object> arguments) {
    final FirebaseDatabase database;
    final String appName = (String) arguments.get(Constants.APP_NAME);
    final String databaseURL = (String) arguments.get(Constants.DATABASE_URL);
    FirebaseApp app;

    if (appName == null) {
      app = FirebaseApp.getInstance();
    } else {
      app = FirebaseApp.getInstance(appName);
    }

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

  @SuppressWarnings("unchecked")
  private Query getQuery(Map<String, Object> arguments) {
    final DatabaseReference ref = getReference(arguments);
    final QueryBuilder qb = new QueryBuilder(ref);

    final Object params = arguments.get(Constants.PARAMETERS);
    final Map<String, Object> queryParams = (Map<String, Object>) Objects.requireNonNull(params);
    return qb.build(queryParams);
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

        @SuppressWarnings("unchecked")
        final Map<String, Object> value = (Map<String, Object>) arguments.get(Constants.VALUE);
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

        final int transactionKey = (int) Objects.requireNonNull(arguments.get(Constants.TRANSACTION_KEY));
        final int transactionTimeout = (int) Objects.requireNonNull(arguments.get(Constants.TRANSACTION_TIMEOUT));
        final TransactionHandler handler = new TransactionHandler(methodChannel, transactionKey, activity);

        ref.runTransaction(handler);

        Tasks.await(handler.getTask(), transactionTimeout, TimeUnit.MILLISECONDS);

        return Tasks.await(handler.getTask());
      });
  }

  private Task<Map<String, Object>> queryGet(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final Query query = getQuery(arguments);
        final DataSnapshot snapshot = Tasks.await(query.get());
        final FlutterDataSnapshotPayload payload = new FlutterDataSnapshotPayload(snapshot);

        return payload.withChildKeys().toMap();
      });
  }

  private Task<Void> queryKeepSynced(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final Query query = getQuery(arguments);
        final boolean keepSynced = (Boolean) Objects.requireNonNull(arguments.get(Constants.VALUE));
        query.keepSynced(keepSynced);

        return null;
      });
  }

  @SuppressWarnings("unchecked")
  private Task<String> observe(Map<String, Object> arguments) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final Query query = getQuery(arguments);
        final String path = (String) arguments.get(Constants.PATH);

        final Map<String, Object> parameters = (Map<String, Object>) arguments.get(Constants.PARAMETERS);
        final String queryParams = QueryBuilder.buildQueryParams(parameters);

        String eventChannelName = METHOD_CHANNEL_NAME + "/" + path;

        if (queryParams.length() > 0) {
          eventChannelName = eventChannelName + "?" + queryParams;
        }

        Log.d("firebase_database", "Channel name: " + eventChannelName);

        if (eventChannels.contains(eventChannelName)) {
          Log.d("firebase_database", "got from cache");
          return eventChannelName;
        }

        Log.d("firebase_database", "created new");

        final StreamHandler streamHandler = new EventStreamHandler(query);
        final EventChannel eventChannel = new EventChannel(messenger, eventChannelName);
        eventChannel.setStreamHandler(streamHandler);

        streamHandlers.put(eventChannel, streamHandler);

        Log.d("firebase_database", "add " + eventChannelName + " to eventChannels map");
        eventChannels.add(eventChannelName);

        return eventChannelName;
      });
  }

  @SuppressWarnings("unchecked")
  private Task<Void> setOnDisconnect(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      final Object value = arguments.get(Constants.VALUE);
      final Object priority = arguments.get(Constants.PRIORITY);

      Task<Void> onDisconnectTask;
      final OnDisconnect onDisconnect = getReference(arguments).onDisconnect();

      if (priority instanceof Double) {
        onDisconnectTask = onDisconnect.setValue(value, ((Number) priority).doubleValue());
      } else if (priority instanceof String) {
        onDisconnectTask = onDisconnect.setValue(value, (String) priority);
      } else {
        final TaskCompletionSource<Void> tcs = new TaskCompletionSource<>();
        onDisconnectTask = tcs.getTask();

        onDisconnect.setValue(value, (Map<String, Object>) priority, (error, ref) -> {
          if (error != null) {
            tcs.setException(error.toException());
          } else {
            tcs.setResult(null);
          }
        });
      }

      Tasks.await(onDisconnectTask);
      return null;
    });
  }

  private Task<Void> updateOnDisconnect(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      final DatabaseReference ref = getReference(arguments);

      @SuppressWarnings("unchecked") final Map<String, Object> value = (Map<String, Object>) arguments.get(Constants.VALUE);

      final Task<Void> task = ref.onDisconnect().updateChildren(value);
      Tasks.await(task);
      return null;
    });
  }

  private Task<Void> cancelOnDisconnect(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      final DatabaseReference ref = getReference(arguments);
      Tasks.await(ref.onDisconnect().cancel());
      return null;
    });
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    final Task<?> methodCallTask;
    final Map<String, Object> arguments = call.arguments();

    Log.d("firebase_database", call.method + arguments);

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
        methodCallTask = setOnDisconnect(arguments);
        break;
      case "OnDisconnect#update":
        methodCallTask = updateOnDisconnect(arguments);
        break;
      case "OnDisconnect#cancel":
        methodCallTask = cancelOnDisconnect(arguments);
        break;
      case "Query#get":
        methodCallTask = queryGet(arguments);
        break;
      case "Query#keepSynced":
        methodCallTask = queryKeepSynced(arguments);
        break;
      case "Query#observe":
        methodCallTask = observe(arguments);
        break;
      default:
        result.notImplemented();
        return;
    }

    methodCallTask.addOnCompleteListener(
      task -> {
        if (task.isSuccessful()) {
          final Object r = task.getResult();
          Log.d("firebase_database", r == null ? "null" : r.toString());
          result.success(r);
        } else {
          Exception exception = task.getException();

          FlutterFirebaseDatabaseException e;

          if (exception instanceof FlutterFirebaseDatabaseException) {
            e = (FlutterFirebaseDatabaseException) exception;
          } else if (exception instanceof DatabaseException) {
            e = FlutterFirebaseDatabaseException.fromDatabaseException((DatabaseException) exception);
          } else {
            e = FlutterFirebaseDatabaseException.fromException(exception);
          }

          result.error(e.getCode(), e.getMessage(), e.getAdditionalData());
        }
      });
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    cleanup();
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(
      cachedThreadPool,
      HashMap::new);
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
    for (EventChannel eventChannel : streamHandlers.keySet()) {
      StreamHandler streamHandler = Objects.requireNonNull(streamHandlers.get(eventChannel));
      streamHandler.onCancel(null);
      eventChannel.setStreamHandler(null);
    }

    streamHandlers.clear();
    eventChannels.clear();
  }
}
