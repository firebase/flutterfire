// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore

import android.annotation.SuppressLint
import android.app.Activity
import android.util.Log
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.firestore.AggregateField
import com.google.firebase.firestore.AggregateQuery as FirestoreAggregateQuery
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldPath
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreSettings
import com.google.firebase.firestore.MemoryCacheSettings
import com.google.firebase.firestore.PersistentCacheSettings
import com.google.firebase.firestore.SetOptions
import com.google.firebase.firestore.Source as FirestoreSource
import com.google.firebase.firestore.Transaction
import com.google.firebase.firestore.WriteBatch
import com.google.firebase.firestore.remote.FirestoreChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.StandardMethodCodec
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import io.flutter.plugins.firebase.firestore.streamhandler.DocumentSnapshotsStreamHandler
import io.flutter.plugins.firebase.firestore.streamhandler.LoadBundleStreamHandler
import io.flutter.plugins.firebase.firestore.streamhandler.OnTransactionResultListener
import io.flutter.plugins.firebase.firestore.streamhandler.QuerySnapshotsStreamHandler
import io.flutter.plugins.firebase.firestore.streamhandler.SnapshotsInSyncStreamHandler
import io.flutter.plugins.firebase.firestore.streamhandler.TransactionStreamHandler
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter
import io.flutter.plugins.firebase.firestore.utils.PigeonParser
import io.flutter.plugins.firebase.firestore.utils.PipelineParser
import java.util.Locale
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicReference

class FlutterFirebaseFirestorePlugin :
    FlutterFirebasePlugin, FlutterPlugin, ActivityAware, FirebaseFirestoreHostApi {
  private val messageCodec = StandardMethodCodec(GeneratedAndroidFirebaseFirestorePigeonCodec())
  private var binaryMessenger: BinaryMessenger? = null
  private val activity = AtomicReference<Activity?>(null)

  // Written from Firestore's transaction worker threads and read from the plugin's
  // cached thread pool, so this must be a thread-safe map (see #18417).
  private val transactions: MutableMap<String, Transaction> = ConcurrentHashMap()
  private val eventChannels: MutableMap<String, EventChannel> = HashMap()
  private val streamHandlers: MutableMap<String, StreamHandler> = HashMap()
  private val transactionHandlers: MutableMap<String, OnTransactionResultListener> = HashMap()

  @SuppressLint("RestrictedApi")
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    initInstance(binding.binaryMessenger)
    FirestoreChannel.setClientLanguage("gl-dart/" + BuildConfig.LIBRARY_VERSION)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    val messenger = binaryMessenger
    if (messenger != null) {
      FirebaseFirestoreHostApi.setUp(messenger, null)
    }
    removeEventListeners()
    binaryMessenger = null
  }

  override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
    attachToActivity(activityPluginBinding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    detachToActivity()
  }

  override fun onReattachedToActivityForConfigChanges(
      activityPluginBinding: ActivityPluginBinding
  ) {
    attachToActivity(activityPluginBinding)
  }

  override fun onDetachedFromActivity() {
    detachToActivity()
  }

  private fun attachToActivity(activityPluginBinding: ActivityPluginBinding) {
    activity.set(activityPluginBinding.activity)
  }

  private fun detachToActivity() {
    activity.set(null)
  }

  private fun initInstance(messenger: BinaryMessenger) {
    binaryMessenger = messenger
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this)
    FirebaseFirestoreHostApi.setUp(messenger, this)
  }

  override fun getPluginConstantsForFirebaseApp(
      firebaseApp: FirebaseApp
  ): Task<MutableMap<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<MutableMap<String, Any>>()
    cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }
    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      try {
        synchronized(firestoreInstanceCache) {
          val firestoresToTerminate = ArrayList(firestoreInstanceCache.keys)
          for (firestore in firestoresToTerminate) {
            Tasks.await(firestore.terminate())
            destroyCachedFirebaseFirestoreInstanceForKey(firestore)
          }
        }
        removeEventListeners()
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }
    return taskCompletionSource.task
  }

  /**
   * Registers a unique event channel based on a channel prefix.
   *
   * Once registered, the plugin will take care of removing the stream handler and cleaning up, if
   * the engine is detached.
   *
   * This function generates a random ID.
   */
  private fun registerEventChannel(prefix: String, handler: StreamHandler): String {
    val identifier = UUID.randomUUID().toString().lowercase(Locale.US)
    return registerEventChannel(prefix, identifier, handler)
  }

  /**
   * Registers a unique event channel based on a channel prefix.
   *
   * Once registered, the plugin will take care of removing the stream handler and cleaning up, if
   * the engine is detached.
   */
  private fun registerEventChannel(
      prefix: String,
      identifier: String,
      handler: StreamHandler
  ): String {
    val channelName = "$prefix/$identifier"
    val channel = EventChannel(binaryMessenger, channelName, messageCodec)
    val wrappingHandler =
        object : StreamHandler {
          override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            handler.onListen(arguments, events)
          }

          override fun onCancel(arguments: Any?) {
            handler.onCancel(arguments)
            unregisterEventChannel(identifier)
          }
        }
    channel.setStreamHandler(wrappingHandler)
    synchronized(eventChannels) { eventChannels[identifier] = channel }
    synchronized(streamHandlers) { streamHandlers[identifier] = wrappingHandler }
    return identifier
  }

  private fun unregisterEventChannel(identifier: String) {
    synchronized(streamHandlers) { streamHandlers.remove(identifier) }
    synchronized(eventChannels) { eventChannels.remove(identifier)?.setStreamHandler(null) }
  }

  private fun removeTransaction(transactionId: String) {
    transactions.remove(transactionId)
    transactionHandlers.remove(transactionId)
    unregisterEventChannel(transactionId)
  }

  private fun removeEventListeners() {
    val handlers: List<StreamHandler>
    synchronized(streamHandlers) {
      handlers = streamHandlers.values.toList()
      streamHandlers.clear()
    }
    val channels: List<EventChannel>
    synchronized(eventChannels) {
      channels = eventChannels.values.toList()
      eventChannels.clear()
    }
    for (handler in handlers) {
      handler.onCancel(null)
    }
    for (channel in channels) {
      channel.setStreamHandler(null)
    }
    transactions.clear()
    transactionHandlers.clear()
  }

  override fun loadBundle(
      app: FirestorePigeonFirebaseApp,
      bundle: ByteArray,
      callback: (Result<String>) -> Unit
  ) {
    callback(
        Result.success(
            registerEventChannel(
                "$METHOD_CHANNEL_NAME/loadBundle",
                LoadBundleStreamHandler(getFirestoreFromPigeon(app), bundle))))
  }

  override fun namedQueryGet(
      app: FirestorePigeonFirebaseApp,
      name: String,
      options: InternalGetOptions,
      callback: (Result<InternalQuerySnapshot>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val firestore = getFirestoreFromPigeon(app)
        val query = Tasks.await(firestore.getNamedQuery(name))
        if (query == null) {
          callback(
              Result.failure(
                  NullPointerException(
                      "Named query has not been found. Please check it has been loaded properly via" +
                          " loadBundle().")))
          return@execute
        }
        val querySnapshot = Tasks.await(query.get(PigeonParser.parsePigeonSource(options.source)))
        callback(
            Result.success(
                PigeonParser.toPigeonQuerySnapshot(
                    querySnapshot,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        options.serverTimestampBehavior))))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun clearPersistence(app: FirestorePigeonFirebaseApp, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        Tasks.await(getFirestoreFromPigeon(app).clearPersistence())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun disableNetwork(app: FirestorePigeonFirebaseApp, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        Tasks.await(getFirestoreFromPigeon(app).disableNetwork())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun enableNetwork(app: FirestorePigeonFirebaseApp, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        Tasks.await(getFirestoreFromPigeon(app).enableNetwork())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun terminate(app: FirestorePigeonFirebaseApp, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        val firestore = getFirestoreFromPigeon(app)
        Tasks.await(firestore.terminate())
        destroyCachedFirebaseFirestoreInstanceForKey(firestore)
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun waitForPendingWrites(
      app: FirestorePigeonFirebaseApp,
      callback: (Result<Unit>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        Tasks.await(getFirestoreFromPigeon(app).waitForPendingWrites())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  @Suppress("DEPRECATION")
  override fun setIndexConfiguration(
      app: FirestorePigeonFirebaseApp,
      indexConfiguration: String,
      callback: (Result<Unit>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        Tasks.await(getFirestoreFromPigeon(app).setIndexConfiguration(indexConfiguration))
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun persistenceCacheIndexManagerRequest(
      app: FirestorePigeonFirebaseApp,
      request: PersistenceCacheIndexManagerRequest,
      callback: (Result<Unit>) -> Unit
  ) {
    cachedThreadPool.execute {
      val indexManager = getFirestoreFromPigeon(app).persistentCacheIndexManager
      if (indexManager != null) {
        when (request) {
          PersistenceCacheIndexManagerRequest.ENABLE_INDEX_AUTO_CREATION ->
              indexManager.enableIndexAutoCreation()
          PersistenceCacheIndexManagerRequest.DISABLE_INDEX_AUTO_CREATION ->
              indexManager.disableIndexAutoCreation()
          PersistenceCacheIndexManagerRequest.DELETE_ALL_INDEXES -> indexManager.deleteAllIndexes()
        }
      } else {
        Log.d(TAG, "`PersistentCacheIndexManager` is not available.")
      }
      callback(Result.success(Unit))
    }
  }

  override fun setLoggingEnabled(loggingEnabled: Boolean, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        FirebaseFirestore.setLoggingEnabled(loggingEnabled)
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun snapshotsInSyncSetup(
      app: FirestorePigeonFirebaseApp,
      callback: (Result<String>) -> Unit
  ) {
    val firestore = getFirestoreFromPigeon(app)
    callback(
        Result.success(
            registerEventChannel(
                "$METHOD_CHANNEL_NAME/snapshotsInSync", SnapshotsInSyncStreamHandler(firestore))))
  }

  override fun transactionCreate(
      app: FirestorePigeonFirebaseApp,
      timeout: Long,
      maxAttempts: Long,
      callback: (Result<String>) -> Unit
  ) {
    val firestore = getFirestoreFromPigeon(app)
    val transactionId = UUID.randomUUID().toString().lowercase(Locale.US)
    val handler =
        TransactionStreamHandler(
            { transaction -> transactions[transactionId] = transaction },
            { id -> removeTransaction(id) },
            firestore,
            transactionId,
            timeout,
            maxAttempts)
    registerEventChannel("$METHOD_CHANNEL_NAME/transaction", transactionId, handler)
    transactionHandlers[transactionId] = handler
    callback(Result.success(transactionId))
  }

  override fun transactionStoreResult(
      transactionId: String,
      resultType: InternalTransactionResult,
      commands: List<InternalTransactionCommand?>?,
      callback: (Result<Unit>) -> Unit
  ) {
    val handler = transactionHandlers[transactionId]
    if (handler == null) {
      callback(Result.success(Unit))
      return
    }
    handler.receiveTransactionResponse(resultType, commands)
    callback(Result.success(Unit))
  }

  override fun transactionGet(
      app: FirestorePigeonFirebaseApp,
      transactionId: String,
      path: String,
      callback: (Result<InternalDocumentSnapshot>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val documentReference = getFirestoreFromPigeon(app).document(path)
        val transaction = transactions[transactionId]
        if (transaction == null) {
          callback(
              Result.failure(
                  Exception(
                      "Transaction.getDocument(): No transaction handler exists for ID: " +
                          transactionId)))
          return@execute
        }
        callback(
            Result.success(
                PigeonParser.toPigeonDocumentSnapshot(
                    transaction.get(documentReference),
                    DocumentSnapshot.ServerTimestampBehavior.NONE)))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun documentReferenceSet(
      app: FirestorePigeonFirebaseApp,
      request: DocumentReferenceRequest,
      callback: (Result<Unit>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val documentReference = getFirestoreFromPigeon(app).document(request.path)
        val data = requireNotNull(request.data)
        val option = requireNotNull(request.option)
        val setTask: Task<Void> =
            when {
              option.merge == true -> documentReference.set(data, SetOptions.merge())
              option.mergeFields != null ->
                  documentReference.set(
                      data,
                      SetOptions.mergeFieldPaths(PigeonParser.parseFieldPath(option.mergeFields!!)))
              else -> documentReference.set(data)
            }
        Tasks.await(setTask)
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun documentReferenceUpdate(
      app: FirestorePigeonFirebaseApp,
      request: DocumentReferenceRequest,
      callback: (Result<Unit>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val documentReference = getFirestoreFromPigeon(app).document(request.path)
        val dataWithString = requireNotNull(request.data)
        val data = HashMap<FieldPath, Any?>()
        for (key in dataWithString.keys) {
          when (key) {
            is String -> data[FieldPath.of(key)] = dataWithString[key]
            is FieldPath -> data[key] = dataWithString[key]
            else ->
                throw IllegalArgumentException(
                    "Invalid key type in update data. Supported types are String and FieldPath.")
          }
        }
        val firstFieldPath = data.keys.iterator().next()
        val firstObject = data[firstFieldPath]
        val flattenData = ArrayList<Any?>()
        for (fieldPath in data.keys) {
          if (fieldPath == firstFieldPath) continue
          flattenData.add(fieldPath)
          flattenData.add(data[fieldPath])
        }
        Tasks.await(
            documentReference.update(firstFieldPath, firstObject, *flattenData.toTypedArray()))
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun documentReferenceGet(
      app: FirestorePigeonFirebaseApp,
      request: DocumentReferenceRequest,
      callback: (Result<InternalDocumentSnapshot>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val source: FirestoreSource = PigeonParser.parsePigeonSource(requireNotNull(request.source))
        val documentReference = getFirestoreFromPigeon(app).document(request.path)
        val documentSnapshot = Tasks.await(documentReference.get(source))
        callback(
            Result.success(
                PigeonParser.toPigeonDocumentSnapshot(
                    documentSnapshot,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        requireNotNull(request.serverTimestampBehavior)))))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun documentReferenceDelete(
      app: FirestorePigeonFirebaseApp,
      request: DocumentReferenceRequest,
      callback: (Result<Unit>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        Tasks.await(getFirestoreFromPigeon(app).document(request.path).delete())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun queryGet(
      app: FirestorePigeonFirebaseApp,
      path: String,
      isCollectionGroup: Boolean,
      parameters: InternalQueryParameters,
      options: InternalGetOptions,
      callback: (Result<InternalQuerySnapshot>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val source = PigeonParser.parsePigeonSource(options.source)
        val query =
            PigeonParser.parseQuery(
                getFirestoreFromPigeon(app), path, isCollectionGroup, parameters)
        if (query == null) {
          callback(
              Result.failure(
                  FlutterError(
                      "invalid_query",
                      "An error occurred while parsing query arguments, see native logs for more" +
                          " information. Please report this issue.",
                      null)))
          return@execute
        }
        val querySnapshot = Tasks.await(query.get(source))
        callback(
            Result.success(
                PigeonParser.toPigeonQuerySnapshot(
                    querySnapshot,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        options.serverTimestampBehavior))))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun aggregateQuery(
      app: FirestorePigeonFirebaseApp,
      path: String,
      parameters: InternalQueryParameters,
      source: AggregateSource,
      queries: List<AggregateQuery?>,
      isCollectionGroup: Boolean,
      callback: (Result<List<AggregateQueryResponse?>>) -> Unit
  ) {
    val query =
        PigeonParser.parseQuery(getFirestoreFromPigeon(app), path, isCollectionGroup, parameters)
    val aggregateFields = ArrayList<AggregateField>()
    for (queryRequest in queries) {
      if (queryRequest == null) continue
      when (queryRequest.type) {
        AggregateType.COUNT -> aggregateFields.add(AggregateField.count())
        AggregateType.SUM ->
            aggregateFields.add(AggregateField.sum(requireNotNull(queryRequest.field)))
        AggregateType.AVERAGE ->
            aggregateFields.add(AggregateField.average(requireNotNull(queryRequest.field)))
      }
    }

    val aggregateQuery: FirestoreAggregateQuery =
        query!!.aggregate(
            aggregateFields[0], *aggregateFields.subList(1, aggregateFields.size).toTypedArray())

    cachedThreadPool.execute {
      try {
        val aggregateQuerySnapshot =
            Tasks.await(aggregateQuery.get(PigeonParser.parseAggregateSource(source)))
        val aggregateResponse = ArrayList<AggregateQueryResponse?>()
        for (queryRequest in queries) {
          if (queryRequest == null) continue
          when (queryRequest.type) {
            AggregateType.COUNT ->
                aggregateResponse.add(
                    AggregateQueryResponse(
                        type = AggregateType.COUNT,
                        value = aggregateQuerySnapshot.count.toDouble()))
            AggregateType.SUM -> {
              val field = requireNotNull(queryRequest.field)
              aggregateResponse.add(
                  AggregateQueryResponse(
                      type = AggregateType.SUM,
                      field = field,
                      value =
                          (requireNotNull(aggregateQuerySnapshot.get(AggregateField.sum(field)))
                                  as Number)
                              .toDouble()))
            }
            AggregateType.AVERAGE -> {
              val field = requireNotNull(queryRequest.field)
              aggregateResponse.add(
                  AggregateQueryResponse(
                      type = AggregateType.AVERAGE,
                      field = field,
                      value = aggregateQuerySnapshot.get(AggregateField.average(field))))
            }
          }
        }
        callback(Result.success(aggregateResponse))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun writeBatchCommit(
      app: FirestorePigeonFirebaseApp,
      writes: List<InternalTransactionCommand?>,
      callback: (Result<Unit>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val firestore = getFirestoreFromPigeon(app)
        var batch: WriteBatch = firestore.batch()
        for (write in writes) {
          if (write == null) continue
          val documentReference = firestore.document(write.path)
          when (write.type) {
            InternalTransactionType.DELETE_TYPE -> batch = batch.delete(documentReference)
            InternalTransactionType.UPDATE -> {
              val rawData = requireNotNull(write.data)
              val updateData = HashMap<FieldPath, Any?>()
              for (key in rawData.keys) {
                when (key) {
                  is String -> updateData[FieldPath.of(key)] = rawData[key]
                  is FieldPath -> updateData[key] = rawData[key]
                }
              }
              val firstFieldPath = updateData.keys.iterator().next()
              val firstObject = updateData[firstFieldPath]
              val flattenData = ArrayList<Any?>()
              for (fieldPath in updateData.keys) {
                if (fieldPath == firstFieldPath) continue
                flattenData.add(fieldPath)
                flattenData.add(updateData[fieldPath])
              }
              batch =
                  batch.update(
                      documentReference, firstFieldPath, firstObject, *flattenData.toTypedArray())
            }
            InternalTransactionType.SET -> {
              @Suppress("UNCHECKED_CAST")
              val setData = requireNotNull(write.data) as Map<String, Any>
              val options = requireNotNull(write.option)
              batch =
                  when {
                    options.merge == true ->
                        batch.set(documentReference, setData, SetOptions.merge())
                    options.mergeFields != null ->
                        batch.set(
                            documentReference,
                            setData,
                            SetOptions.mergeFieldPaths(
                                PigeonParser.parseFieldPath(options.mergeFields!!)))
                    else -> batch.set(documentReference, setData)
                  }
            }
            InternalTransactionType.GET -> {}
          }
        }
        Tasks.await(batch.commit())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  override fun querySnapshot(
      app: FirestorePigeonFirebaseApp,
      path: String,
      isCollectionGroup: Boolean,
      parameters: InternalQueryParameters,
      options: InternalGetOptions,
      includeMetadataChanges: Boolean,
      source: ListenSource,
      callback: (Result<String>) -> Unit
  ) {
    val query =
        PigeonParser.parseQuery(getFirestoreFromPigeon(app), path, isCollectionGroup, parameters)
    if (query == null) {
      callback(
          Result.failure(
              FlutterError(
                  "invalid_query",
                  "An error occurred while parsing query arguments, see native logs for more" +
                      " information. Please report this issue.",
                  null)))
      return
    }
    callback(
        Result.success(
            registerEventChannel(
                "$METHOD_CHANNEL_NAME/query",
                QuerySnapshotsStreamHandler(
                    query,
                    includeMetadataChanges,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        options.serverTimestampBehavior),
                    PigeonParser.parseListenSource(source),
                    cachedThreadPool))))
  }

  override fun documentReferenceSnapshot(
      app: FirestorePigeonFirebaseApp,
      parameters: DocumentReferenceRequest,
      includeMetadataChanges: Boolean,
      source: ListenSource,
      callback: (Result<String>) -> Unit
  ) {
    val firestore = getFirestoreFromPigeon(app)
    val documentReference = firestore.document(parameters.path)
    callback(
        Result.success(
            registerEventChannel(
                "$METHOD_CHANNEL_NAME/document",
                DocumentSnapshotsStreamHandler(
                    firestore,
                    documentReference,
                    includeMetadataChanges,
                    PigeonParser.parsePigeonServerTimestampBehavior(
                        parameters.serverTimestampBehavior),
                    PigeonParser.parseListenSource(source)))))
  }

  @Suppress("UNCHECKED_CAST")
  override fun executePipeline(
      app: FirestorePigeonFirebaseApp,
      stages: List<Map<String?, Any?>?>,
      options: Map<String?, Any?>?,
      callback: (Result<InternalPipelineSnapshot>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        val firestore = getFirestoreFromPigeon(app)
        val typedStages = stages.filterNotNull().map { it as Map<String, Any> }
        val snapshot =
            PipelineParser.executePipeline(firestore, typedStages, options as Map<String, Any>?)
        val pipelineResults = ArrayList<InternalPipelineResult?>()
        for (pipelineResult in snapshot.results) {
          pipelineResults.add(
              InternalPipelineResult(
                  documentPath = pipelineResult.ref?.path,
                  createTime = pipelineResult.createTime?.toDate()?.time,
                  updateTime = pipelineResult.updateTime?.toDate()?.time,
                  data = pipelineResult.getData() as Map<String?, Any?>?))
        }
        callback(
            Result.success(
                InternalPipelineSnapshot(
                    results = pipelineResults,
                    executionTime = snapshot.executionTime?.toDate()?.time ?: 0L)))
      } catch (e: Exception) {
        ExceptionConverter.sendErrorToFlutter(callback, e)
      }
    }
  }

  companion object {
    val firestoreInstanceCache = HashMap<FirebaseFirestore, FlutterFirebaseFirestoreExtension>()
    const val TAG = "FlutterFirestorePlugin"
    const val DEFAULT_ERROR_CODE = "firebase_firestore"
    private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_firestore"

    val serverTimestampBehaviorHashMap = HashMap<Int, DocumentSnapshot.ServerTimestampBehavior>()

    fun getCachedFirebaseFirestoreInstanceForKey(
        firestore: FirebaseFirestore
    ): FlutterFirebaseFirestoreExtension {
      synchronized(firestoreInstanceCache) {
        return firestoreInstanceCache[firestore]!!
      }
    }

    fun setCachedFirebaseFirestoreInstanceForKey(
        firestore: FirebaseFirestore,
        databaseURL: String
    ) {
      synchronized(firestoreInstanceCache) {
        if (firestoreInstanceCache[firestore] == null) {
          firestoreInstanceCache[firestore] =
              FlutterFirebaseFirestoreExtension(firestore, databaseURL)
        }
      }
    }

    fun getFirestoreInstanceByNameAndDatabaseUrl(
        appName: String,
        databaseURL: String
    ): FirebaseFirestore? {
      synchronized(firestoreInstanceCache) {
        for ((key, value) in firestoreInstanceCache) {
          if (value.instance.app.name == appName && value.databaseURL == databaseURL) {
            return key
          }
        }
      }
      return null
    }

    private fun destroyCachedFirebaseFirestoreInstanceForKey(firestore: FirebaseFirestore) {
      synchronized(firestoreInstanceCache) { firestoreInstanceCache.remove(firestore) }
    }

    fun getSettingsFromPigeon(pigeonApp: FirestorePigeonFirebaseApp): FirebaseFirestoreSettings {
      val builder = FirebaseFirestoreSettings.Builder()
      if (pigeonApp.settings.host != null) {
        builder.setHost(pigeonApp.settings.host!!)
      }
      if (pigeonApp.settings.sslEnabled != null) {
        builder.setSslEnabled(pigeonApp.settings.sslEnabled!!)
      }
      if (pigeonApp.settings.persistenceEnabled != null) {
        if (pigeonApp.settings.persistenceEnabled!!) {
          val receivedCacheSizeBytes = pigeonApp.settings.cacheSizeBytes
          var cacheSizeBytes = 104857600L
          if (receivedCacheSizeBytes != null && receivedCacheSizeBytes != -1L) {
            cacheSizeBytes = receivedCacheSizeBytes
          }
          builder.setLocalCacheSettings(
              PersistentCacheSettings.newBuilder().setSizeBytes(cacheSizeBytes).build())
        } else {
          builder.setLocalCacheSettings(MemoryCacheSettings.newBuilder().build())
        }
      }
      return builder.build()
    }

    fun getFirestoreFromPigeon(pigeonApp: FirestorePigeonFirebaseApp): FirebaseFirestore {
      synchronized(firestoreInstanceCache) {
        val cachedFirestoreInstance =
            getFirestoreInstanceByNameAndDatabaseUrl(pigeonApp.appName, pigeonApp.databaseURL)
        if (cachedFirestoreInstance != null) {
          return cachedFirestoreInstance
        }
        val app = FirebaseApp.getInstance(pigeonApp.appName)
        val firestore = FirebaseFirestore.getInstance(app, pigeonApp.databaseURL)
        firestore.firestoreSettings = getSettingsFromPigeon(pigeonApp)
        setCachedFirebaseFirestoreInstanceForKey(firestore, pigeonApp.databaseURL)
        return firestore
      }
    }
  }
}
