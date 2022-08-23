// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import static io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin;

import android.util.Log;
import androidx.annotation.NonNull;
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
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class FirebaseDatabasePlugin
    implements FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  protected static final HashMap<String, FirebaseDatabase> databaseInstanceCache = new HashMap<>();
  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_database";
  private int listenerCount = 0;
  private final Map<EventChannel, StreamHandler> streamHandlers = new HashMap<>();
  private MethodChannel methodChannel;
  private BinaryMessenger messenger;

  private static FirebaseDatabase getCachedFirebaseDatabaseInstanceForKey(String key) {
    synchronized (databaseInstanceCache) {
      return databaseInstanceCache.get(key);
    }
  }

  private static void setCachedFirebaseDatabaseInstanceForKey(
      FirebaseDatabase database, String key) {
    synchronized (databaseInstanceCache) {
      FirebaseDatabase existingInstance = databaseInstanceCache.get(key);
      if (existingInstance == null) {
        databaseInstanceCache.put(key, database);
      }
    }
  }

  private void initPluginInstance(BinaryMessenger messenger) {
    registerPlugin(METHOD_CHANNEL_NAME, this);
    this.messenger = messenger;

    methodChannel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    methodChannel.setMethodCallHandler(this);
  }

  FirebaseDatabase getDatabase(Map<String, Object> arguments) {
    String appName = (String) arguments.get(Constants.APP_NAME);
    if (appName == null) appName = "[DEFAULT]";

    String databaseURL = (String) arguments.get(Constants.DATABASE_URL);
    if (databaseURL == null) databaseURL = "";

    final String instanceKey = appName.concat(databaseURL);

    // Check for an existing pre-configured instance and return it if it exists.
    final FirebaseDatabase existingInstance = getCachedFirebaseDatabaseInstanceForKey(instanceKey);
    if (existingInstance != null) {
      return existingInstance;
    }

    final FirebaseApp app = FirebaseApp.getInstance(appName);
    final FirebaseDatabase database;
    if (!databaseURL.isEmpty()) {
      database = FirebaseDatabase.getInstance(app, databaseURL);
    } else {
      database = FirebaseDatabase.getInstance(app);
    }

    Boolean loggingEnabled = (Boolean) arguments.get(Constants.DATABASE_LOGGING_ENABLED);
    Boolean persistenceEnabled = (Boolean) arguments.get(Constants.DATABASE_PERSISTENCE_ENABLED);
    String emulatorHost = (String) arguments.get(Constants.DATABASE_EMULATOR_HOST);
    Integer emulatorPort = (Integer) arguments.get(Constants.DATABASE_EMULATOR_PORT);
    Object cacheSizeBytes = (Object) arguments.get(Constants.DATABASE_CACHE_SIZE_BYTES);

    try {
      if (loggingEnabled != null) {
        database.setLogLevel(loggingEnabled ? Logger.Level.DEBUG : Logger.Level.NONE);
      }

      if (emulatorHost != null && emulatorPort != null) {
        database.useEmulator(emulatorHost, emulatorPort);
      }

      if (persistenceEnabled != null) {
        database.setPersistenceEnabled(persistenceEnabled);
      }

      if (cacheSizeBytes != null) {
        if (cacheSizeBytes instanceof Long) {
          database.setPersistenceCacheSizeBytes((Long) cacheSizeBytes);
        } else if (cacheSizeBytes instanceof Integer) {
          database.setPersistenceCacheSizeBytes(Long.valueOf((Integer) cacheSizeBytes));
        }
      }
    } catch (DatabaseException e) {
      final String message = e.getMessage();
      if (message == null) throw e;
      if (!message.contains("must be made before any other usage of FirebaseDatabase")) {
        throw e;
      }
    }

    setCachedFirebaseDatabaseInstanceForKey(database, instanceKey);
    return database;
  }

  private DatabaseReference getReference(Map<String, Object> arguments) {
    final FirebaseDatabase database = getDatabase(arguments);
    final String path = (String) Objects.requireNonNull(arguments.get(Constants.PATH));

    return database.getReference(path);
  }

  @SuppressWarnings("unchecked")
  private Query getQuery(Map<String, Object> arguments) {
    DatabaseReference ref = getReference(arguments);
    final List<Map<String, Object>> modifiers =
        (List<Map<String, Object>>) Objects.requireNonNull(arguments.get(Constants.MODIFIERS));

    return new QueryBuilder(ref, modifiers).build();
  }

  private Task<Void> goOnline(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final FirebaseDatabase database = getDatabase(arguments);
            database.goOnline();

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> goOffline(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final FirebaseDatabase database = getDatabase(arguments);
            database.goOffline();

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> purgeOutstandingWrites(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final FirebaseDatabase database = getDatabase(arguments);
            database.purgeOutstandingWrites();

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setValue(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final DatabaseReference ref = getReference(arguments);
            final Object value = arguments.get(Constants.VALUE);
            Tasks.await(ref.setValue(value));

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setValueWithPriority(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final DatabaseReference ref = getReference(arguments);
            final Object value = arguments.get(Constants.VALUE);
            final Object priority = arguments.get(Constants.PRIORITY);
            Tasks.await(ref.setValue(value, priority));

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> update(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final DatabaseReference ref = getReference(arguments);

            @SuppressWarnings("unchecked")
            final Map<String, Object> value =
                (Map<String, Object>) Objects.requireNonNull(arguments.get(Constants.VALUE));
            Tasks.await(ref.updateChildren(value));

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setPriority(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final DatabaseReference ref = getReference(arguments);
            final Object priority = arguments.get(Constants.PRIORITY);
            Tasks.await(ref.setPriority(priority));

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> runTransaction(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final DatabaseReference ref = getReference(arguments);

            final int transactionKey =
                (int) Objects.requireNonNull(arguments.get(Constants.TRANSACTION_KEY));
            final boolean transactionApplyLocally =
                (boolean)
                    Objects.requireNonNull(arguments.get(Constants.TRANSACTION_APPLY_LOCALLY));

            final TransactionHandler handler =
                new TransactionHandler(methodChannel, transactionKey);

            ref.runTransaction(handler, transactionApplyLocally);

            Map<String, Object> result = Tasks.await(handler.getTask());

            taskCompletionSource.setResult(result);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Map<String, Object>> queryGet(Map<String, Object> arguments) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Query query = getQuery(arguments);
            final DataSnapshot snapshot = Tasks.await(query.get());
            final FlutterDataSnapshotPayload payload = new FlutterDataSnapshotPayload(snapshot);

            taskCompletionSource.setResult(payload.toMap());
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> queryKeepSynced(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Query query = getQuery(arguments);
            final boolean keepSynced =
                (Boolean) Objects.requireNonNull(arguments.get(Constants.VALUE));
            query.keepSynced(keepSynced);
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<String> observe(Map<String, Object> arguments) {
    TaskCompletionSource<String> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Query query = getQuery(arguments);
            final String eventChannelNamePrefix =
                (String) arguments.get(Constants.EVENT_CHANNEL_NAME_PREFIX);
            final String eventChannelName = eventChannelNamePrefix + "#" + listenerCount++;

            final EventChannel eventChannel = new EventChannel(messenger, eventChannelName);
            final EventStreamHandler streamHandler =
                new EventStreamHandler(
                    query,
                    () -> {
                      eventChannel.setStreamHandler(null);
                    });

            eventChannel.setStreamHandler(streamHandler);
            streamHandlers.put(eventChannel, streamHandler);

            taskCompletionSource.setResult(eventChannelName);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setOnDisconnect(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Object value = arguments.get(Constants.VALUE);
            final OnDisconnect onDisconnect = getReference(arguments).onDisconnect();
            Tasks.await(onDisconnect.setValue(value));
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> setWithPriorityOnDisconnect(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Object value = arguments.get(Constants.VALUE);
            final Object priority = arguments.get(Constants.PRIORITY);
            final OnDisconnect onDisconnect = getReference(arguments).onDisconnect();

            Task<Void> onDisconnectTask;
            if (priority instanceof Double) {
              onDisconnectTask = onDisconnect.setValue(value, ((Number) priority).doubleValue());
            } else if (priority instanceof String) {
              onDisconnectTask = onDisconnect.setValue(value, (String) priority);
            } else if (priority == null) {
              onDisconnectTask = onDisconnect.setValue(value, (String) null);
            } else {
              throw new Exception("Invalid priority value for OnDisconnect.setWithPriority");
            }

            Tasks.await(onDisconnectTask);

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> updateOnDisconnect(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final DatabaseReference ref = getReference(arguments);

            @SuppressWarnings("unchecked")
            final Map<String, Object> value =
                (Map<String, Object>) Objects.requireNonNull(arguments.get(Constants.VALUE));

            final Task<Void> task = ref.onDisconnect().updateChildren(value);
            Tasks.await(task);

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private Task<Void> cancelOnDisconnect(Map<String, Object> arguments) {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final DatabaseReference ref = getReference(arguments);
            Tasks.await(ref.onDisconnect().cancel());

            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
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
      case "DatabaseReference#set":
        methodCallTask = setValue(arguments);
        break;
      case "DatabaseReference#setWithPriority":
        methodCallTask = setValueWithPriority(arguments);
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
      case "OnDisconnect#setWithPriority":
        methodCallTask = setWithPriorityOnDisconnect(arguments);
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
            result.success(r);
          } else {
            Exception exception = task.getException();

            FlutterFirebaseDatabaseException e;

            if (exception instanceof FlutterFirebaseDatabaseException) {
              e = (FlutterFirebaseDatabaseException) exception;
            } else if (exception instanceof DatabaseException) {
              e =
                  FlutterFirebaseDatabaseException.fromDatabaseException(
                      (DatabaseException) exception);
            } else {
              Log.e(
                  "firebase_database",
                  "An unknown error occurred handling native method call " + call.method,
                  exception);
              e = FlutterFirebaseDatabaseException.fromException(exception);
            }

            result.error(e.getCode(), e.getMessage(), e.getAdditionalData());
          }
        });
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initPluginInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    cleanup();
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            final Map<String, Object> constants = new HashMap<>();
            taskCompletionSource.setResult(constants);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    TaskCompletionSource<Void> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            cleanup();
            taskCompletionSource.setResult(null);
          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
  }

  private void cleanup() {
    removeEventStreamHandlers();
    databaseInstanceCache.clear();
  }

  private void removeEventStreamHandlers() {
    for (EventChannel eventChannel : streamHandlers.keySet()) {
      StreamHandler streamHandler = streamHandlers.get(eventChannel);
      if (streamHandler != null) {
        streamHandler.onCancel(null);
        eventChannel.setStreamHandler(null);
      }
    }
    streamHandlers.clear();
  }
}
