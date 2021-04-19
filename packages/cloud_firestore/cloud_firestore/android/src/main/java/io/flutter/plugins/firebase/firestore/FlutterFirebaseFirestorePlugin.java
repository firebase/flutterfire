// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore;

import android.app.Activity;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Source;
import com.google.firebase.firestore.Transaction;
import com.google.firebase.firestore.WriteBatch;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import io.flutter.plugins.firebase.firestore.streamhandler.DocumentSnapshotsStreamHandler;
import io.flutter.plugins.firebase.firestore.streamhandler.OnTransactionResultListener;
import io.flutter.plugins.firebase.firestore.streamhandler.QuerySnapshotsStreamHandler;
import io.flutter.plugins.firebase.firestore.streamhandler.SnapshotsInSyncStreamHandler;
import io.flutter.plugins.firebase.firestore.streamhandler.TransactionStreamHandler;
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

public class FlutterFirebaseFirestorePlugin
    implements FlutterFirebasePlugin, MethodCallHandler, FlutterPlugin, ActivityAware {

  protected static final HashMap<String, FirebaseFirestore> firestoreInstanceCache =
      new HashMap<>();

  public static final String DEFAULT_ERROR_CODE = "firebase_firestore";

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_firestore";

  final StandardMethodCodec MESSAGE_CODEC =
      new StandardMethodCodec(FlutterFirebaseFirestoreMessageCodec.INSTANCE);

  private BinaryMessenger binaryMessenger;
  private MethodChannel channel;

  private final AtomicReference<Activity> activity = new AtomicReference<>(null);

  private final Map<String, Transaction> transactions = new HashMap<>();
  private final Map<String, EventChannel> eventChannels = new HashMap<>();
  private final Map<String, StreamHandler> streamHandlers = new HashMap<>();
  private final Map<String, OnTransactionResultListener> transactionHandlers = new HashMap<>();

  protected static FirebaseFirestore getCachedFirebaseFirestoreInstanceForKey(String key) {
    synchronized (firestoreInstanceCache) {
      FirebaseFirestore existingInstance = firestoreInstanceCache.get(key);
      if (existingInstance != null) {
        return existingInstance;
      }

      return null;
    }
  }

  protected static void setCachedFirebaseFirestoreInstanceForKey(
      FirebaseFirestore firestore, String key) {
    synchronized (firestoreInstanceCache) {
      FirebaseFirestore existingInstance = firestoreInstanceCache.get(key);
      if (existingInstance == null) {
        firestoreInstanceCache.put(key, firestore);
      }
    }
  }

  private static void destroyCachedFirebaseFirestoreInstanceForKey(String key) {
    synchronized (firestoreInstanceCache) {
      FirebaseFirestore existingInstance = firestoreInstanceCache.get(key);
      if (existingInstance != null) {
        firestoreInstanceCache.remove(key);
      }
    }
  }

  public static void registerWith(PluginRegistry.Registrar registrar) {
    FlutterFirebaseFirestorePlugin instance = new FlutterFirebaseFirestorePlugin();
    instance.activity.set(registrar.activity());
    instance.initInstance(registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;

    for (String identifier : eventChannels.keySet()) {
      eventChannels.get(identifier).setStreamHandler(null);
    }
    eventChannels.clear();

    for (String identifier : streamHandlers.keySet()) {
      streamHandlers.get(identifier).onCancel(null);
    }
    streamHandlers.clear();

    transactionHandlers.clear();

    binaryMessenger = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    detachToActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(
      @NonNull ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    detachToActivity();
  }

  private void attachToActivity(ActivityPluginBinding activityPluginBinding) {
    activity.set(activityPluginBinding.getActivity());
  }

  private void detachToActivity() {
    activity.set(null);
  }

  private Task<Void> disableNetwork(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseFirestore firestore =
              (FirebaseFirestore) Objects.requireNonNull(arguments.get("firestore"));
          return Tasks.await(firestore.disableNetwork());
        });
  }

  private Task<Void> enableNetwork(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseFirestore firestore =
              (FirebaseFirestore) Objects.requireNonNull(arguments.get("firestore"));
          return Tasks.await(firestore.enableNetwork());
        });
  }

  private Task<DocumentSnapshot> transactionGet(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          DocumentReference documentReference = (DocumentReference) arguments.get("reference");
          String transactionId = (String) Objects.requireNonNull(arguments.get("transactionId"));

          Transaction transaction = transactions.get(transactionId);

          if (transaction == null) {
            throw new Exception(
                "Transaction.getDocument(): No transaction handler exists for ID: "
                    + transactionId);
          }

          return transaction.get(documentReference);
        });
  }

  private void transactionStoreResult(Map<String, Object> arguments) {
    String transactionId = (String) Objects.requireNonNull(arguments.get("transactionId"));
    @SuppressWarnings("unchecked")
    Map<String, Object> result =
        (Map<String, Object>) Objects.requireNonNull(arguments.get("result"));

    transactionHandlers.get(transactionId).receiveTransactionResponse(result);
  }

  private Task<Void> batchCommit(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          @SuppressWarnings("unchecked")
          List<Map<String, Object>> writes =
              (List<Map<String, Object>>) Objects.requireNonNull(arguments.get("writes"));
          FirebaseFirestore firestore =
              (FirebaseFirestore) Objects.requireNonNull(arguments.get("firestore"));
          WriteBatch batch = firestore.batch();

          for (Map<String, Object> write : writes) {
            String type = (String) Objects.requireNonNull(write.get("type"));
            String path = (String) Objects.requireNonNull(write.get("path"));
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) write.get("data");

            DocumentReference documentReference = firestore.document(path);

            switch (type) {
              case "DELETE":
                batch = batch.delete(documentReference);
                break;
              case "UPDATE":
                batch = batch.update(documentReference, Objects.requireNonNull(data));
                break;
              case "SET":
                @SuppressWarnings("unchecked")
                Map<String, Object> options =
                    (Map<String, Object>) Objects.requireNonNull(write.get("options"));

                if (options.get("merge") != null && (boolean) options.get("merge")) {
                  batch =
                      batch.set(
                          documentReference, Objects.requireNonNull(data), SetOptions.merge());
                } else if (options.get("mergeFields") != null) {
                  @SuppressWarnings("unchecked")
                  List<FieldPath> fieldPathList =
                      (List<FieldPath>) Objects.requireNonNull(options.get("mergeFields"));
                  batch =
                      batch.set(
                          documentReference,
                          Objects.requireNonNull(data),
                          SetOptions.mergeFieldPaths(fieldPathList));
                } else {
                  batch = batch.set(documentReference, Objects.requireNonNull(data));
                }
                break;
            }
          }

          return Tasks.await(batch.commit());
        });
  }

  private Task<QuerySnapshot> queryGet(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Source source = getSource(arguments);
          Query query = (Query) arguments.get("query");

          if (query == null) {
            throw new IllegalArgumentException(
                "An error occurred while parsing query arguments, see native logs for more information. Please report this issue.");
          }

          return Tasks.await(query.get(source));
        });
  }

  private Task<DocumentSnapshot> documentGet(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          Source source = getSource(arguments);
          DocumentReference documentReference =
              (DocumentReference) Objects.requireNonNull(arguments.get("reference"));
          return Tasks.await(documentReference.get(source));
        });
  }

  private Task<Void> documentSet(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          DocumentReference documentReference =
              (DocumentReference) Objects.requireNonNull(arguments.get("reference"));

          @SuppressWarnings("unchecked")
          Map<String, Object> data =
              (Map<String, Object>) Objects.requireNonNull(arguments.get("data"));
          @SuppressWarnings("unchecked")
          Map<String, Object> options =
              (Map<String, Object>) Objects.requireNonNull(arguments.get("options"));

          Task<Void> setTask;

          if (options.get("merge") != null && (boolean) options.get("merge")) {
            setTask = documentReference.set(data, SetOptions.merge());
          } else if (options.get("mergeFields") != null) {
            @SuppressWarnings("unchecked")
            List<FieldPath> fieldPathList =
                (List<FieldPath>) Objects.requireNonNull(options.get("mergeFields"));
            setTask = documentReference.set(data, SetOptions.mergeFieldPaths(fieldPathList));
          } else {
            setTask = documentReference.set(data);
          }

          return Tasks.await(setTask);
        });
  }

  private Task<Void> documentUpdate(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          DocumentReference documentReference =
              (DocumentReference) Objects.requireNonNull(arguments.get("reference"));
          @SuppressWarnings("unchecked")
          Map<String, Object> data =
              (Map<String, Object>) Objects.requireNonNull(arguments.get("data"));

          return Tasks.await(documentReference.update(data));
        });
  }

  private Task<Void> documentDelete(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          DocumentReference documentReference =
              (DocumentReference) Objects.requireNonNull(arguments.get("reference"));
          return Tasks.await(documentReference.delete());
        });
  }

  private Task<Void> clearPersistence(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseFirestore firestore =
              (FirebaseFirestore) Objects.requireNonNull(arguments.get("firestore"));
          return Tasks.await(firestore.clearPersistence());
        });
  }

  private Task<Void> terminate(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseFirestore firestore =
              (FirebaseFirestore) Objects.requireNonNull(arguments.get("firestore"));
          Tasks.await(firestore.terminate());
          destroyCachedFirebaseFirestoreInstanceForKey(firestore.getApp().getName());
          return null;
        });
  }

  private Task<Void> waitForPendingWrites(Map<String, Object> arguments) {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          FirebaseFirestore firestore =
              (FirebaseFirestore) Objects.requireNonNull(arguments.get("firestore"));
          return Tasks.await(firestore.waitForPendingWrites());
        });
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull final MethodChannel.Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "Firestore#disableNetwork":
        methodCallTask = disableNetwork(call.arguments());
        break;
      case "Firestore#enableNetwork":
        methodCallTask = enableNetwork(call.arguments());
        break;
      case "Transaction#get":
        methodCallTask = transactionGet(call.arguments());
        break;
      case "Transaction#create":
        final String transactionId = UUID.randomUUID().toString().toLowerCase(Locale.US);
        final TransactionStreamHandler handler =
            new TransactionStreamHandler(
                activity, transaction -> transactions.put(transactionId, transaction));

        registerEventChannel(METHOD_CHANNEL_NAME + "/transaction", transactionId, handler);
        transactionHandlers.put(transactionId, handler);
        result.success(transactionId);
        return;
      case "Transaction#storeResult":
        transactionStoreResult(call.arguments());
        result.success(null);
        return;
      case "WriteBatch#commit":
        methodCallTask = batchCommit(call.arguments());
        break;
      case "Query#get":
        methodCallTask = queryGet(call.arguments());
        break;
      case "Query#snapshots":
        result.success(
            registerEventChannel(
                METHOD_CHANNEL_NAME + "/query", new QuerySnapshotsStreamHandler()));
        return;
      case "DocumentReference#snapshots":
        result.success(
            registerEventChannel(
                METHOD_CHANNEL_NAME + "/document", new DocumentSnapshotsStreamHandler()));
        return;
      case "SnapshotsInSync#setup":
        result.success(
            registerEventChannel(
                METHOD_CHANNEL_NAME + "/snapshotsInSync", new SnapshotsInSyncStreamHandler()));
        return;

      case "DocumentReference#get":
        methodCallTask = documentGet(call.arguments());
        break;
      case "DocumentReference#set":
        methodCallTask = documentSet(call.arguments());
        break;
      case "DocumentReference#update":
        methodCallTask = documentUpdate(call.arguments());
        break;
      case "DocumentReference#delete":
        methodCallTask = documentDelete(call.arguments());
        break;
      case "Firestore#clearPersistence":
        methodCallTask = clearPersistence(call.arguments());
        break;
      case "Firestore#terminate":
        methodCallTask = terminate(call.arguments());
        break;
      case "Firestore#waitForPendingWrites":
        methodCallTask = waitForPendingWrites(call.arguments());
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
            Map<String, String> exceptionDetails = ExceptionConverter.createDetails(exception);
            result.error(
                DEFAULT_ERROR_CODE,
                exception != null ? exception.getMessage() : null,
                exceptionDetails);
          }
        });
  }

  private void initInstance(BinaryMessenger messenger) {
    binaryMessenger = messenger;

    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME, MESSAGE_CODEC);
    channel.setMethodCallHandler(this);

    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this);
  }

  private Source getSource(Map<String, Object> arguments) {
    String source = (String) Objects.requireNonNull(arguments.get("source"));

    switch (source) {
      case "server":
        return Source.SERVER;
      case "cache":
        return Source.CACHE;
      default:
        return Source.DEFAULT;
    }
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(cachedThreadPool, () -> null);
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(
        cachedThreadPool,
        () -> {
          // Context is ignored by API so we don't send it over even though annotated non-null.

          for (FirebaseApp app : FirebaseApp.getApps(null)) {
            FirebaseFirestore firestore = FirebaseFirestore.getInstance(app);
            Tasks.await(firestore.terminate());
            FlutterFirebaseFirestorePlugin.destroyCachedFirebaseFirestoreInstanceForKey(
                app.getName());
          }
          return null;
        });
  }

  /**
   * Registers a unique event channel based on a channel prefix.
   *
   * <p>Once registered, the plugin will take care of removing the stream handler and cleaning up,
   * if the engine is detached.
   *
   * <p>This function generates a random ID.
   *
   * @param prefix Channel prefix onto which the unique ID will be appended on. The convention is
   *     "namespace/component" whereas the last / is added internally.
   * @param handler The handler object for responding to channel events and submitting data.
   * @return The generated identifier.
   * @see #registerEventChannel(String, String, StreamHandler)
   */
  private String registerEventChannel(String prefix, StreamHandler handler) {
    String identifier = UUID.randomUUID().toString().toLowerCase(Locale.US);
    return registerEventChannel(prefix, identifier, handler);
  }

  /**
   * Registers a unique event channel based on a channel prefix.
   *
   * <p>Once registered, the plugin will take care of removing the stream handler and cleaning up,
   * if the engine is detached.
   *
   * @param prefix Channel prefix onto which the unique ID will be appended on. The convention is
   *     "namespace/component" whereas the last / is added internally.
   * @param identifier A identifier which will be appended to the prefix.
   * @param handler The handler object for responding to channel events and submitting data.
   * @return The passed identifier.
   */
  private String registerEventChannel(String prefix, String identifier, StreamHandler handler) {
    final String channelName = prefix + "/" + identifier;

    EventChannel channel = new EventChannel(binaryMessenger, channelName, MESSAGE_CODEC);
    channel.setStreamHandler(handler);
    eventChannels.put(identifier, channel);
    streamHandlers.put(identifier, handler);

    return identifier;
  }
}
