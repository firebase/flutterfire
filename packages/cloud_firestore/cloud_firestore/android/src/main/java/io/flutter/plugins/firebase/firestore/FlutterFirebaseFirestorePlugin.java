// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore;

import static com.google.firebase.firestore.AggregateField.average;
import static com.google.firebase.firestore.AggregateField.count;
import static com.google.firebase.firestore.AggregateField.sum;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.firestore.AggregateField;
import com.google.firebase.firestore.AggregateQuery;
import com.google.firebase.firestore.AggregateQuerySnapshot;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreSettings;
import com.google.firebase.firestore.MemoryCacheSettings;
import com.google.firebase.firestore.PersistentCacheIndexManager;
import com.google.firebase.firestore.PersistentCacheSettings;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Source;
import com.google.firebase.firestore.Transaction;
import com.google.firebase.firestore.WriteBatch;
import com.google.firebase.firestore.remote.FirestoreChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;
import io.flutter.plugins.firebase.firestore.streamhandler.DocumentSnapshotsStreamHandler;
import io.flutter.plugins.firebase.firestore.streamhandler.LoadBundleStreamHandler;
import io.flutter.plugins.firebase.firestore.streamhandler.OnTransactionResultListener;
import io.flutter.plugins.firebase.firestore.streamhandler.QuerySnapshotsStreamHandler;
import io.flutter.plugins.firebase.firestore.streamhandler.SnapshotsInSyncStreamHandler;
import io.flutter.plugins.firebase.firestore.streamhandler.TransactionStreamHandler;
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter;
import io.flutter.plugins.firebase.firestore.utils.PigeonParser;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

public class FlutterFirebaseFirestorePlugin
    implements FlutterFirebasePlugin,
        FlutterPlugin,
        ActivityAware,
        GeneratedAndroidFirebaseFirestore.FirebaseFirestoreHostApi {
  protected static final HashMap<FirebaseFirestore, FlutterFirebaseFirestoreExtension>
      firestoreInstanceCache = new HashMap<>();
  public static final String TAG = "FlutterFirestorePlugin";
  public static final String DEFAULT_ERROR_CODE = "firebase_firestore";

  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_firestore";

  final StandardMethodCodec MESSAGE_CODEC =
      new StandardMethodCodec(
          io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreMessageCodec.INSTANCE);

  private BinaryMessenger binaryMessenger;

  private final AtomicReference<Activity> activity = new AtomicReference<>(null);

  private final Map<String, Transaction> transactions = new HashMap<>();
  private final Map<String, EventChannel> eventChannels = new HashMap<>();
  private final Map<String, StreamHandler> streamHandlers = new HashMap<>();
  private final Map<String, OnTransactionResultListener> transactionHandlers = new HashMap<>();

  // Used in the decoder to know which ServerTimestampBehavior to use
  public static final Map<Integer, DocumentSnapshot.ServerTimestampBehavior>
      serverTimestampBehaviorHashMap = new HashMap<>();

  protected static FlutterFirebaseFirestoreExtension getCachedFirebaseFirestoreInstanceForKey(
      FirebaseFirestore firestore) {
    synchronized (firestoreInstanceCache) {
      return firestoreInstanceCache.get(firestore);
    }
  }

  protected static void setCachedFirebaseFirestoreInstanceForKey(
      FirebaseFirestore firestore, String databaseURL) {
    synchronized (firestoreInstanceCache) {
      FlutterFirebaseFirestoreExtension existingInstance = firestoreInstanceCache.get(firestore);
      if (existingInstance == null) {
        firestoreInstanceCache.put(
            firestore, new FlutterFirebaseFirestoreExtension(firestore, databaseURL));
      }
    }
  }

  protected static FirebaseFirestore getFirestoreInstanceByNameAndDatabaseUrl(
      String appName, String databaseURL) {
    synchronized (firestoreInstanceCache) {
      for (Map.Entry<FirebaseFirestore, FlutterFirebaseFirestoreExtension> entry :
          firestoreInstanceCache.entrySet()) {
        if (entry.getValue().getInstance().getApp().getName().equals(appName)
            && entry.getValue().getDatabaseURL().equals(databaseURL)) {
          return entry.getKey();
        }
      }
    }
    return null;
  }

  private static void destroyCachedFirebaseFirestoreInstanceForKey(FirebaseFirestore firestore) {
    synchronized (firestoreInstanceCache) {
      FlutterFirebaseFirestoreExtension existingInstance = firestoreInstanceCache.get(firestore);
      if (existingInstance != null) {
        firestoreInstanceCache.remove(firestore);
      }
    }
  }

  @SuppressLint("RestrictedApi")
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
    FirestoreChannel.setClientLanguage(
        "gl-dart/" + io.flutter.plugins.firebase.firestore.BuildConfig.LIBRARY_VERSION);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    removeEventListeners();

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

  private void initInstance(BinaryMessenger messenger) {
    binaryMessenger = messenger;

    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this);

    GeneratedAndroidFirebaseFirestore.FirebaseFirestoreHostApi.setup(binaryMessenger, this);
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    TaskCompletionSource<Map<String, Object>> taskCompletionSource = new TaskCompletionSource<>();

    cachedThreadPool.execute(
        () -> {
          try {
            taskCompletionSource.setResult(null);
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
            // Context is ignored by API so we don't send it over even though annotated non-null.
            synchronized (firestoreInstanceCache) {
              for (Map.Entry<FirebaseFirestore, FlutterFirebaseFirestoreExtension> entry :
                  firestoreInstanceCache.entrySet()) {
                FirebaseFirestore firestore = entry.getKey();
                Tasks.await(firestore.terminate());
                FlutterFirebaseFirestorePlugin.destroyCachedFirebaseFirestoreInstanceForKey(
                    firestore);
              }
            }
            removeEventListeners();

            taskCompletionSource.setResult(null);

          } catch (Exception e) {
            taskCompletionSource.setException(e);
          }
        });

    return taskCompletionSource.getTask();
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

  private void removeEventListeners() {
    synchronized (eventChannels) {
      for (String identifier : eventChannels.keySet()) {
        Objects.requireNonNull(eventChannels.get(identifier)).setStreamHandler(null);
      }
      eventChannels.clear();
    }

    synchronized (streamHandlers) {
      for (String identifier : streamHandlers.keySet()) {
        Objects.requireNonNull(streamHandlers.get(identifier)).onCancel(null);
      }
      streamHandlers.clear();
    }

    transactionHandlers.clear();
  }

  static FirebaseFirestoreSettings getSettingsFromPigeon(
      GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp pigeonApp) {
    FirebaseFirestoreSettings.Builder builder = new FirebaseFirestoreSettings.Builder();
    if (pigeonApp.getSettings().getHost() != null) {
      builder.setHost(pigeonApp.getSettings().getHost());
    }
    if (pigeonApp.getSettings().getSslEnabled() != null) {
      builder.setSslEnabled(pigeonApp.getSettings().getSslEnabled());
    }
    if (pigeonApp.getSettings().getPersistenceEnabled() != null) {
      if (pigeonApp.getSettings().getPersistenceEnabled()) {
        Long receivedCacheSizeBytes = pigeonApp.getSettings().getCacheSizeBytes();
        // This is the maximum amount of cache allowed:
        // https://firebase.google.com/docs/firestore/manage-data/enable-offline#configure_cache_size
        long cacheSizeBytes = 104857600L;
        if (receivedCacheSizeBytes != null && receivedCacheSizeBytes != -1) {
          cacheSizeBytes = receivedCacheSizeBytes;
        }
        builder.setLocalCacheSettings(
            PersistentCacheSettings.newBuilder().setSizeBytes(cacheSizeBytes).build());
      } else {
        builder.setLocalCacheSettings(MemoryCacheSettings.newBuilder().build());
      }
    }
    return builder.build();
  }

  public static FirebaseFirestore getFirestoreFromPigeon(
      GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp pigeonApp) {
    synchronized (FlutterFirebaseFirestorePlugin.firestoreInstanceCache) {
      FirebaseFirestore cachedFirestoreInstance =
          FlutterFirebaseFirestorePlugin.getFirestoreInstanceByNameAndDatabaseUrl(
              pigeonApp.getAppName(), pigeonApp.getDatabaseURL());
      if (cachedFirestoreInstance != null) {
        return cachedFirestoreInstance;
      }

      FirebaseApp app = FirebaseApp.getInstance(pigeonApp.getAppName());
      FirebaseFirestore firestore = FirebaseFirestore.getInstance(app, pigeonApp.getDatabaseURL());
      firestore.setFirestoreSettings(getSettingsFromPigeon(pigeonApp));

      FlutterFirebaseFirestorePlugin.setCachedFirebaseFirestoreInstanceForKey(
          firestore, pigeonApp.getDatabaseURL());
      return firestore;
    }
  }

  @Override
  public void loadBundle(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull byte[] bundle,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<String> result) {
    result.success(
        registerEventChannel(
            METHOD_CHANNEL_NAME + "/loadBundle",
            new LoadBundleStreamHandler(getFirestoreFromPigeon(app), bundle)));
  }

  @Override
  public void namedQueryGet(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull String name,
      @NonNull GeneratedAndroidFirebaseFirestore.PigeonGetOptions options,
      @NonNull
          GeneratedAndroidFirebaseFirestore.Result<
                  GeneratedAndroidFirebaseFirestore.PigeonQuerySnapshot>
              result) {

    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            Query query = Tasks.await(firestore.getNamedQuery(name));

            if (query == null) {
              result.error(
                  new NullPointerException(
                      "Named query has not been found. Please check it has been loaded properly via loadBundle()."));
              return;
            }

            final QuerySnapshot querySnapshot =
                Tasks.await(query.get(PigeonParser.parsePigeonSource(options.getSource())));

            result.success(
                PigeonParser.toPigeonQuerySnapshot(
                    querySnapshot,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        options.getServerTimestampBehavior())));
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void clearPersistence(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            Tasks.await(firestore.clearPersistence());
            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void disableNetwork(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            Tasks.await(firestore.disableNetwork());
            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void enableNetwork(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            Tasks.await(firestore.enableNetwork());
            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void terminate(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            Tasks.await(firestore.terminate());
            destroyCachedFirebaseFirestoreInstanceForKey(firestore);
            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void waitForPendingWrites(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            Tasks.await(firestore.waitForPendingWrites());
            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  // Suppressed because we have already annotated the user facing Dart API as deprecated.
  @SuppressWarnings("deprecation")
  public void setIndexConfiguration(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull String indexConfiguration,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            Tasks.await(firestore.setIndexConfiguration(indexConfiguration));

            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void persistenceCacheIndexManagerRequest(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.PersistenceCacheIndexManagerRequest request,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          PersistentCacheIndexManager indexManager =
              getFirestoreFromPigeon(app).getPersistentCacheIndexManager();
          if (indexManager != null) {
            switch (request) {
              case ENABLE_INDEX_AUTO_CREATION:
                indexManager.enableIndexAutoCreation();
                break;
              case DISABLE_INDEX_AUTO_CREATION:
                indexManager.disableIndexAutoCreation();
                break;
              case DELETE_ALL_INDEXES:
                indexManager.deleteAllIndexes();
                break;
            }
          } else {
            Log.d(TAG, "`PersistentCacheIndexManager` is not available.");
          }

          result.success(null);
        });
  }

  @Override
  public void setLoggingEnabled(
      @NonNull Boolean loggingEnabled,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore.setLoggingEnabled(loggingEnabled);

            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void snapshotsInSyncSetup(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<String> result) {
    FirebaseFirestore firestore = getFirestoreFromPigeon(app);

    result.success(
        registerEventChannel(
            METHOD_CHANNEL_NAME + "/snapshotsInSync", new SnapshotsInSyncStreamHandler(firestore)));
  }

  @Override
  public void transactionCreate(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull Long timeout,
      @NonNull Long maxAttempts,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<String> result) {
    FirebaseFirestore firestore = getFirestoreFromPigeon(app);

    final String transactionId = UUID.randomUUID().toString().toLowerCase(Locale.US);
    final TransactionStreamHandler handler =
        new TransactionStreamHandler(
            transaction -> transactions.put(transactionId, transaction),
            firestore,
            transactionId,
            timeout,
            maxAttempts);

    registerEventChannel(METHOD_CHANNEL_NAME + "/transaction", transactionId, handler);
    transactionHandlers.put(transactionId, handler);
    result.success(transactionId);
  }

  @Override
  public void transactionStoreResult(
      @NonNull String transactionId,
      @NonNull GeneratedAndroidFirebaseFirestore.PigeonTransactionResult resultType,
      @Nullable List<GeneratedAndroidFirebaseFirestore.PigeonTransactionCommand> commands,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    Objects.requireNonNull(transactionHandlers.get(transactionId))
        .receiveTransactionResponse(resultType, commands);
    result.success(null);
  }

  @Override
  public void transactionGet(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull String transactionId,
      @NonNull String path,
      @NonNull
          GeneratedAndroidFirebaseFirestore.Result<
                  GeneratedAndroidFirebaseFirestore.PigeonDocumentSnapshot>
              result) {
    cachedThreadPool.execute(
        () -> {
          try {
            DocumentReference documentReference = getFirestoreFromPigeon(app).document(path);

            Transaction transaction = transactions.get(transactionId);

            if (transaction == null) {
              result.error(
                  new Exception(
                      "Transaction.getDocument(): No transaction handler exists for ID: "
                          + transactionId));
              return;
            }

            result.success(
                PigeonParser.toPigeonDocumentSnapshot(
                    transaction.get(documentReference),
                    DocumentSnapshot.ServerTimestampBehavior.NONE));
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void documentReferenceSet(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.DocumentReferenceRequest request,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            DocumentReference documentReference =
                getFirestoreFromPigeon(app).document(request.getPath());

            Map<Object, Object> data = Objects.requireNonNull(request.getData());

            Task<Void> setTask;

            assert request.getOption() != null;
            if (request.getOption().getMerge() != null && request.getOption().getMerge()) {
              setTask = documentReference.set(data, SetOptions.merge());
            } else if (request.getOption().getMergeFields() != null) {
              List<List<String>> fieldList =
                  Objects.requireNonNull(request.getOption().getMergeFields());
              List<FieldPath> fieldPathList = PigeonParser.parseFieldPath(fieldList);
              setTask = documentReference.set(data, SetOptions.mergeFieldPaths(fieldPathList));
            } else {
              setTask = documentReference.set(data);
            }

            result.success(Tasks.await(setTask));
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void documentReferenceUpdate(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.DocumentReferenceRequest request,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            DocumentReference documentReference =
                getFirestoreFromPigeon(app).document(request.getPath());
            Map<Object, Object> dataWithString = Objects.requireNonNull(request.getData());

            Map<FieldPath, Object> data = new HashMap<>();
            for (Object key : dataWithString.keySet()) {
              if (key instanceof String) {
                data.put(FieldPath.of((String) key), dataWithString.get(key));
              } else if (key instanceof FieldPath) {
                data.put((FieldPath) key, dataWithString.get(key));
              } else {
                throw new IllegalArgumentException(
                    "Invalid key type in update data. Supported types are String and FieldPath.");
              }
            }

            // Due to the signature of the function, I extract the first element of the map and
            // pass the rest of the map as an array of alternating keys and values.
            FieldPath firstFieldPath = data.keySet().iterator().next();
            Object firstObject = data.get(firstFieldPath);

            ArrayList<Object> flattenData = new ArrayList<>();
            for (FieldPath fieldPath : data.keySet()) {
              if (fieldPath.equals(firstFieldPath)) {
                continue;
              }
              flattenData.add(fieldPath);
              flattenData.add(data.get(fieldPath));
            }
            result.success(
                Tasks.await(
                    documentReference.update(firstFieldPath, firstObject, flattenData.toArray())));
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void documentReferenceGet(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.DocumentReferenceRequest request,
      @NonNull
          GeneratedAndroidFirebaseFirestore.Result<
                  GeneratedAndroidFirebaseFirestore.PigeonDocumentSnapshot>
              result) {
    cachedThreadPool.execute(
        () -> {
          try {
            assert request.getSource() != null;
            Source source = PigeonParser.parsePigeonSource(request.getSource());
            DocumentReference documentReference =
                getFirestoreFromPigeon(app).document(request.getPath());

            final DocumentSnapshot documentSnapshot = Tasks.await(documentReference.get(source));

            assert request.getServerTimestampBehavior() != null;
            result.success(
                PigeonParser.toPigeonDocumentSnapshot(
                    documentSnapshot,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        request.getServerTimestampBehavior())));
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void documentReferenceDelete(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.DocumentReferenceRequest request,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            DocumentReference documentReference =
                getFirestoreFromPigeon(app).document(request.getPath());

            result.success(Tasks.await(documentReference.delete()));
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void queryGet(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull String path,
      @NonNull Boolean isCollectionGroup,
      @NonNull GeneratedAndroidFirebaseFirestore.PigeonQueryParameters parameters,
      @NonNull GeneratedAndroidFirebaseFirestore.PigeonGetOptions options,
      @NonNull
          GeneratedAndroidFirebaseFirestore.Result<
                  GeneratedAndroidFirebaseFirestore.PigeonQuerySnapshot>
              result) {
    cachedThreadPool.execute(
        () -> {
          try {
            Source source = PigeonParser.parsePigeonSource(options.getSource());
            Query query =
                PigeonParser.parseQuery(
                    getFirestoreFromPigeon(app), path, isCollectionGroup, parameters);

            if (query == null) {
              result.error(
                  new GeneratedAndroidFirebaseFirestore.FlutterError(
                      "invalid_query",
                      "An error occurred while parsing query arguments, see native logs for more information. Please report this issue.",
                      null));
              return;
            }
            final QuerySnapshot querySnapshot = Tasks.await(query.get(source));

            result.success(
                PigeonParser.toPigeonQuerySnapshot(
                    querySnapshot,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        options.getServerTimestampBehavior())));
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void aggregateQuery(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull String path,
      @NonNull GeneratedAndroidFirebaseFirestore.PigeonQueryParameters parameters,
      @NonNull GeneratedAndroidFirebaseFirestore.AggregateSource source,
      @NonNull List<GeneratedAndroidFirebaseFirestore.AggregateQuery> queries,
      @NonNull Boolean isCollectionGroup,
      @NonNull
          GeneratedAndroidFirebaseFirestore.Result<
                  List<GeneratedAndroidFirebaseFirestore.AggregateQueryResponse>>
              result) {
    Query query =
        PigeonParser.parseQuery(getFirestoreFromPigeon(app), path, isCollectionGroup, parameters);

    AggregateQuery aggregateQuery;
    ArrayList<AggregateField> aggregateFields = new ArrayList<>();

    for (GeneratedAndroidFirebaseFirestore.AggregateQuery queryRequest : queries) {
      switch (queryRequest.getType()) {
        case COUNT:
          aggregateFields.add(count());
          break;
        case SUM:
          assert queryRequest.getField() != null;
          aggregateFields.add(sum(queryRequest.getField()));
          break;
        case AVERAGE:
          assert queryRequest.getField() != null;
          aggregateFields.add(average(queryRequest.getField()));
          break;
      }
    }

    assert query != null;
    aggregateQuery =
        query.aggregate(
            aggregateFields.get(0),
            aggregateFields.subList(1, aggregateFields.size()).toArray(new AggregateField[0]));

    cachedThreadPool.execute(
        () -> {
          try {
            AggregateQuerySnapshot aggregateQuerySnapshot =
                Tasks.await(aggregateQuery.get(PigeonParser.parseAggregateSource(source)));

            ArrayList<GeneratedAndroidFirebaseFirestore.AggregateQueryResponse> aggregateResponse =
                new ArrayList<>();
            for (GeneratedAndroidFirebaseFirestore.AggregateQuery queryRequest : queries) {
              switch (queryRequest.getType()) {
                case COUNT:
                  GeneratedAndroidFirebaseFirestore.AggregateQueryResponse.Builder builder =
                      new GeneratedAndroidFirebaseFirestore.AggregateQueryResponse.Builder();
                  builder.setType(GeneratedAndroidFirebaseFirestore.AggregateType.COUNT);
                  builder.setValue((double) aggregateQuerySnapshot.getCount());

                  aggregateResponse.add(builder.build());
                  break;
                case SUM:
                  assert queryRequest.getField() != null;
                  GeneratedAndroidFirebaseFirestore.AggregateQueryResponse.Builder builderSum =
                      new GeneratedAndroidFirebaseFirestore.AggregateQueryResponse.Builder();
                  builderSum.setType(GeneratedAndroidFirebaseFirestore.AggregateType.SUM);
                  builderSum.setValue(
                      ((Number)
                              Objects.requireNonNull(
                                  aggregateQuerySnapshot.get(sum(queryRequest.getField()))))
                          .doubleValue());
                  builderSum.setField(queryRequest.getField());

                  aggregateResponse.add(builderSum.build());
                  break;
                case AVERAGE:
                  assert queryRequest.getField() != null;
                  GeneratedAndroidFirebaseFirestore.AggregateQueryResponse.Builder builderAverage =
                      new GeneratedAndroidFirebaseFirestore.AggregateQueryResponse.Builder();
                  builderAverage.setType(GeneratedAndroidFirebaseFirestore.AggregateType.AVERAGE);
                  builderAverage.setValue(
                      aggregateQuerySnapshot.get(average(queryRequest.getField())));
                  builderAverage.setField(queryRequest.getField());

                  aggregateResponse.add(builderAverage.build());
                  break;
              }
            }

            result.success(aggregateResponse);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void writeBatchCommit(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull List<GeneratedAndroidFirebaseFirestore.PigeonTransactionCommand> writes,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<Void> result) {
    cachedThreadPool.execute(
        () -> {
          try {
            FirebaseFirestore firestore = getFirestoreFromPigeon(app);
            WriteBatch batch = firestore.batch();

            for (GeneratedAndroidFirebaseFirestore.PigeonTransactionCommand write : writes) {
              GeneratedAndroidFirebaseFirestore.PigeonTransactionType type =
                  Objects.requireNonNull(write.getType());
              String path = Objects.requireNonNull(write.getPath());
              Map<String, Object> data = write.getData();

              DocumentReference documentReference = firestore.document(path);

              switch (type) {
                case DELETE_TYPE:
                  batch = batch.delete(documentReference);
                  break;
                case UPDATE:
                  batch = batch.update(documentReference, Objects.requireNonNull(data));
                  break;
                case SET:
                  GeneratedAndroidFirebaseFirestore.PigeonDocumentOption options =
                      Objects.requireNonNull(write.getOption());

                  if (options.getMerge() != null && options.getMerge()) {
                    batch =
                        batch.set(
                            documentReference, Objects.requireNonNull(data), SetOptions.merge());
                  } else if (options.getMergeFields() != null) {
                    List<FieldPath> fieldPathList =
                        PigeonParser.parseFieldPath(
                            Objects.requireNonNull(options.getMergeFields()));
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

            Tasks.await(batch.commit());
            result.success(null);
          } catch (Exception e) {
            ExceptionConverter.sendErrorToFlutter(result, e);
          }
        });
  }

  @Override
  public void querySnapshot(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull String path,
      @NonNull Boolean isCollectionGroup,
      @NonNull GeneratedAndroidFirebaseFirestore.PigeonQueryParameters parameters,
      @NonNull GeneratedAndroidFirebaseFirestore.PigeonGetOptions options,
      @NonNull Boolean includeMetadataChanges,
      @NonNull GeneratedAndroidFirebaseFirestore.ListenSource source,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<String> result) {
    Query query =
        PigeonParser.parseQuery(getFirestoreFromPigeon(app), path, isCollectionGroup, parameters);

    if (query == null) {
      result.error(
          new GeneratedAndroidFirebaseFirestore.FlutterError(
              "invalid_query",
              "An error occurred while parsing query arguments, see native logs for more information. Please report this issue.",
              null));
      return;
    }

    result.success(
        registerEventChannel(
            METHOD_CHANNEL_NAME + "/query",
            new QuerySnapshotsStreamHandler(
                query,
                includeMetadataChanges,
                PigeonParser.parsePigeonServerTimestampBehavior(
                    options.getServerTimestampBehavior()),
                PigeonParser.parseListenSource(source))));
  }

  @Override
  public void documentReferenceSnapshot(
      @NonNull GeneratedAndroidFirebaseFirestore.FirestorePigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseFirestore.DocumentReferenceRequest parameters,
      @NonNull Boolean includeMetadataChanges,
      @NonNull GeneratedAndroidFirebaseFirestore.ListenSource source,
      @NonNull GeneratedAndroidFirebaseFirestore.Result<String> result) {
    FirebaseFirestore firestore = getFirestoreFromPigeon(app);
    DocumentReference documentReference =
        getFirestoreFromPigeon(app).document(parameters.getPath());

    result.success(
        registerEventChannel(
            METHOD_CHANNEL_NAME + "/document",
            new DocumentSnapshotsStreamHandler(
                firestore,
                documentReference,
                includeMetadataChanges,
                PigeonParser.parsePigeonServerTimestampBehavior(
                    parameters.getServerTimestampBehavior()),
                PigeonParser.parseListenSource(source))));
  }
}
