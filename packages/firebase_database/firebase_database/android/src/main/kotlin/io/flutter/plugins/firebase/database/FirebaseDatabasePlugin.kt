// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database

import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseException
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.Logger
import com.google.firebase.database.OnDisconnect
import com.google.firebase.database.Query
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.Result as KotlinResult

class FirebaseDatabasePlugin :
  FlutterFirebasePlugin,
  FlutterPlugin,
  FirebaseDatabaseHostApi {
  companion object {
    private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_database"
    private val databaseInstanceCache = HashMap<String, FirebaseDatabase>()
  }

  private var listenerCount = 0
  private val streamHandlers = HashMap<EventChannel, StreamHandler>()
  private lateinit var methodChannel: MethodChannel
  private lateinit var messenger: BinaryMessenger

  private val cachedThreadPool: ExecutorService = Executors.newCachedThreadPool()

  private fun getCachedFirebaseDatabaseInstanceForKey(key: String): FirebaseDatabase? {
    synchronized(databaseInstanceCache) {
      return databaseInstanceCache[key]
    }
  }

  private fun setCachedFirebaseDatabaseInstanceForKey(
    database: FirebaseDatabase,
    key: String,
  ) {
    synchronized(databaseInstanceCache) {
      val existingInstance = databaseInstanceCache[key]
      if (existingInstance == null) {
        databaseInstanceCache[key] = database
      }
    }
  }

  private fun initPluginInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this)
    this.messenger = messenger

    methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)

    // Set up Pigeon HostApi
    FirebaseDatabaseHostApi.setUp(messenger, this)
  }

  private fun getDatabase(arguments: Map<String, Any>): FirebaseDatabase {
    val appName = arguments[Constants.APP_NAME] as String? ?: "[DEFAULT]"
    val databaseURL = arguments[Constants.DATABASE_URL] as String? ?: ""
    val instanceKey = appName + databaseURL

    // Check for an existing pre-configured instance and return it if it exists.
    val existingInstance = getCachedFirebaseDatabaseInstanceForKey(instanceKey)
    if (existingInstance != null) {
      return existingInstance
    }

    val app = FirebaseApp.getInstance(appName)
    val database =
      if (databaseURL.isNotEmpty()) {
        FirebaseDatabase.getInstance(app, databaseURL)
      } else {
        FirebaseDatabase.getInstance(app)
      }

    val loggingEnabled = arguments[Constants.DATABASE_LOGGING_ENABLED] as Boolean?
    val persistenceEnabled = arguments[Constants.DATABASE_PERSISTENCE_ENABLED] as Boolean?
    val emulatorHost = arguments[Constants.DATABASE_EMULATOR_HOST] as String?
    val emulatorPort = arguments[Constants.DATABASE_EMULATOR_PORT] as Int?
    val cacheSizeBytes = arguments[Constants.DATABASE_CACHE_SIZE_BYTES]

    try {
      loggingEnabled?.let { enabled ->
        database.setLogLevel(if (enabled) Logger.Level.DEBUG else Logger.Level.NONE)
      }

      if (emulatorHost != null && emulatorPort != null) {
        database.useEmulator(emulatorHost, emulatorPort)
      }

      persistenceEnabled?.let { enabled ->
        database.setPersistenceEnabled(enabled)
      }

      cacheSizeBytes?.let { size ->
        when (size) {
          is Long -> database.setPersistenceCacheSizeBytes(size)
          is Int -> database.setPersistenceCacheSizeBytes(size.toLong())
        }
      }
    } catch (e: DatabaseException) {
      val message = e.message
      if (message != null && !message.contains("must be made before any other usage of FirebaseDatabase")) {
        throw e
      }
    }

    setCachedFirebaseDatabaseInstanceForKey(database, instanceKey)
    return database
  }

  private fun getReference(arguments: Map<String, Any>): DatabaseReference {
    val database = getDatabase(arguments)
    val path = arguments[Constants.PATH] as String
    return database.getReference(path)
  }

  @Suppress("UNCHECKED_CAST")
  private fun getQuery(arguments: Map<String, Any>): Query {
    val ref = getReference(arguments)
    val modifiers = arguments[Constants.MODIFIERS] as List<Map<String, Any>>
    return QueryBuilder(ref, modifiers).build()
  }

  private fun goOnline(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val database = getDatabase(arguments)
        database.goOnline()
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun goOffline(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val database = getDatabase(arguments)
        database.goOffline()
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun purgeOutstandingWrites(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val database = getDatabase(arguments)
        database.purgeOutstandingWrites()
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun setValue(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val ref = getReference(arguments)
        val value = arguments[Constants.VALUE]
        Tasks.await(ref.setValue(value))
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun setValueWithPriority(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val ref = getReference(arguments)
        val value = arguments[Constants.VALUE]
        val priority = arguments[Constants.PRIORITY]
        Tasks.await(ref.setValue(value, priority))
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun update(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val ref = getReference(arguments)

        @Suppress("UNCHECKED_CAST")
        val value = arguments[Constants.VALUE] as Map<String, Any>
        Tasks.await(ref.updateChildren(value))
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun setPriority(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val ref = getReference(arguments)
        val priority = arguments[Constants.PRIORITY]
        Tasks.await(ref.setPriority(priority))
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun runTransaction(arguments: Map<String, Any>): Task<Map<String, Any?>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any?>>()

    cachedThreadPool.execute {
      try {
        val ref = getReference(arguments)
        val transactionKey = arguments[Constants.TRANSACTION_KEY] as Int
        val transactionApplyLocally = arguments[Constants.TRANSACTION_APPLY_LOCALLY] as Boolean

        val handler = TransactionHandler(methodChannel, transactionKey)
        ref.runTransaction(handler, transactionApplyLocally)

        val result = Tasks.await(handler.getTask())
        taskCompletionSource.setResult(result)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun queryGet(arguments: Map<String, Any>): Task<Map<String, Any?>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any?>>()

    cachedThreadPool.execute {
      try {
        val query = getQuery(arguments)
        val snapshot = Tasks.await(query.get())
        val payload = FlutterDataSnapshotPayload(snapshot)
        taskCompletionSource.setResult(payload.toMap())
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun queryKeepSynced(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val query = getQuery(arguments)
        val keepSynced = arguments[Constants.VALUE] as Boolean
        query.keepSynced(keepSynced)
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun observe(arguments: Map<String, Any>): Task<String> {
    val taskCompletionSource = TaskCompletionSource<String>()

    cachedThreadPool.execute {
      try {
        val query = getQuery(arguments)
        val eventChannelNamePrefix = arguments[Constants.EVENT_CHANNEL_NAME_PREFIX] as String
        val eventChannelName = "$eventChannelNamePrefix#${listenerCount++}"

        val eventChannel = EventChannel(messenger, eventChannelName)
        val streamHandler =
          EventStreamHandler(
            query,
            object : OnDispose {
              override fun run() {
                eventChannel.setStreamHandler(null)
              }
            },
          )

        eventChannel.setStreamHandler(streamHandler)
        streamHandlers[eventChannel] = streamHandler

        taskCompletionSource.setResult(eventChannelName)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun setOnDisconnect(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val value = arguments[Constants.VALUE]
        val onDisconnect = getReference(arguments).onDisconnect()
        Tasks.await(onDisconnect.setValue(value))
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun setWithPriorityOnDisconnect(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val value = arguments[Constants.VALUE]
        val priority = arguments[Constants.PRIORITY]
        val onDisconnect = getReference(arguments).onDisconnect()

        val onDisconnectTask =
          when (priority) {
            is Double -> onDisconnect.setValue(value, priority)
            is String -> onDisconnect.setValue(value, priority)
            null -> onDisconnect.setValue(value, null as String?)
            else -> throw Exception("Invalid priority value for OnDisconnect.setWithPriority")
          }

        Tasks.await(onDisconnectTask)
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun updateOnDisconnect(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val ref = getReference(arguments)

        @Suppress("UNCHECKED_CAST")
        val value = arguments[Constants.VALUE] as Map<String, Any>
        val task = ref.onDisconnect().updateChildren(value)
        Tasks.await(task)
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun cancelOnDisconnect(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val ref = getReference(arguments)
        Tasks.await(ref.onDisconnect().cancel())
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    initPluginInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(
    @NonNull binding: FlutterPluginBinding,
  ) {
    methodChannel.setMethodCallHandler(null)
    cleanup()
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

    cachedThreadPool.execute {
      try {
        val constants = HashMap<String, Any>()
        taskCompletionSource.setResult(constants)
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
        cleanup()
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun cleanup() {
    removeEventStreamHandlers()
    databaseInstanceCache.clear()
  }

  private fun removeEventStreamHandlers() {
    for ((eventChannel, streamHandler) in streamHandlers) {
      streamHandler?.onCancel(null)
      eventChannel.setStreamHandler(null)
    }
    streamHandlers.clear()
  }

  // Pigeon HostApi implementations
  override fun goOnline(app: DatabasePigeonFirebaseApp, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      database.goOnline()
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun goOffline(app: DatabasePigeonFirebaseApp, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      database.goOffline()
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun setPersistenceEnabled(app: DatabasePigeonFirebaseApp, enabled: Boolean, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      database.setPersistenceEnabled(enabled)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun setPersistenceCacheSizeBytes(app: DatabasePigeonFirebaseApp, cacheSize: Long, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      database.setPersistenceCacheSizeBytes(cacheSize)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun setLoggingEnabled(app: DatabasePigeonFirebaseApp, enabled: Boolean, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      database.setLogLevel(if (enabled) Logger.Level.DEBUG else Logger.Level.NONE)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun useDatabaseEmulator(app: DatabasePigeonFirebaseApp, host: String, port: Long, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      database.useEmulator(host, port.toInt())
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun ref(app: DatabasePigeonFirebaseApp, path: String?, callback: (KotlinResult<DatabaseReferencePlatform>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = if (path.isNullOrEmpty()) database.reference else database.getReference(path)
      val platformRef = DatabaseReferencePlatform(path = reference.key ?: "/")
      callback(KotlinResult.success(platformRef))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun refFromURL(app: DatabasePigeonFirebaseApp, url: String, callback: (KotlinResult<DatabaseReferencePlatform>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReferenceFromUrl(url)
      val platformRef = DatabaseReferencePlatform(path = reference.key ?: "/")
      callback(KotlinResult.success(platformRef))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun purgeOutstandingWrites(app: DatabasePigeonFirebaseApp, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      database.purgeOutstandingWrites()
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun databaseReferenceSet(app: DatabasePigeonFirebaseApp, request: DatabaseReferenceRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      reference.setValue(request.value)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun databaseReferenceSetWithPriority(app: DatabasePigeonFirebaseApp, request: DatabaseReferenceRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      reference.setValue(request.value, request.priority)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun databaseReferenceUpdate(app: DatabasePigeonFirebaseApp, request: UpdateRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      reference.updateChildren(request.value)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun databaseReferenceSetPriority(app: DatabasePigeonFirebaseApp, request: DatabaseReferenceRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      Tasks.await(reference.setPriority(request.priority))
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun databaseReferenceRunTransaction(app: DatabasePigeonFirebaseApp, request: TransactionRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      
      // Store the transaction request for later retrieval
      transactionRequests[request.transactionKey] = request
      
      // Start the transaction
      reference.runTransaction(object : com.google.firebase.database.Transaction.Handler {
        override fun doTransaction(mutableData: com.google.firebase.database.MutableData): com.google.firebase.database.Transaction.Result {
          try {
            // Call the Flutter transaction handler
            val flutterApi = FirebaseDatabaseFlutterApi(messenger)
            val taskCompletionSource = TaskCompletionSource<TransactionHandlerResult>()
            
            flutterApi.callTransactionHandler(request.transactionKey, mutableData.value) { result ->
              result.fold(
                onSuccess = { taskCompletionSource.setResult(it) },
                onFailure = { taskCompletionSource.setException(it) }
              )
            }

            val handlerResult = Tasks.await(taskCompletionSource.task)
            
            if (handlerResult.aborted || handlerResult.exception) {
              return com.google.firebase.database.Transaction.abort()
            }
            
            mutableData.value = handlerResult.value
            return com.google.firebase.database.Transaction.success(mutableData)
          } catch (e: Exception) {
            // If there's an error, abort the transaction
            return com.google.firebase.database.Transaction.abort()
          }
        }
        
        override fun onComplete(error: com.google.firebase.database.DatabaseError?, committed: Boolean, currentData: com.google.firebase.database.DataSnapshot?) {          
          // Store the transaction result for later retrieval
          val result = mapOf(
            "committed" to committed,
            "snapshot" to mapOf(
              "value" to currentData?.value,
              "key" to currentData?.key,
              "exists" to currentData?.exists()
            )
          )
          transactionResults[request.transactionKey] = result
        }
      })
      
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun databaseReferenceGetTransactionResult(app: DatabasePigeonFirebaseApp, transactionKey: Long, callback: (KotlinResult<Map<String, Any?>>) -> Unit) {
    try {
      // Return the stored transaction result
      val result = transactionResults[transactionKey]
      if (result != null) {
        callback(KotlinResult.success(result))
      } else {
        // If no result is available yet, return a default result
        val defaultResult = mapOf(
          "committed" to false,
          "snapshot" to mapOf("value" to null)
        )
        callback(KotlinResult.success(defaultResult))
      }
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun onDisconnectSet(app: DatabasePigeonFirebaseApp, request: DatabaseReferenceRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      val onDisconnect = reference.onDisconnect()
      onDisconnect.setValue(request.value)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun onDisconnectSetWithPriority(app: DatabasePigeonFirebaseApp, request: DatabaseReferenceRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      val onDisconnect = reference.onDisconnect()
      onDisconnect.setValue(request.value, request.priority as? String)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun onDisconnectUpdate(app: DatabasePigeonFirebaseApp, request: UpdateRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      val onDisconnect = reference.onDisconnect()
      onDisconnect.updateChildren(request.value)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun onDisconnectCancel(app: DatabasePigeonFirebaseApp, path: String, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(path)
      val onDisconnect = reference.onDisconnect()
      onDisconnect.cancel()
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun queryObserve(app: DatabasePigeonFirebaseApp, request: QueryRequest, callback: (KotlinResult<String>) -> Unit) {
    try {
      Log.d("FirebaseDatabase", "🔍 Kotlin: Setting up query observe for path=${request.path}")
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      
      // Apply query modifiers if any
      var query: com.google.firebase.database.Query = reference
      for (modifier in request.modifiers) {
        when (modifier["type"] as String) {
          "orderByChild" -> query = query.orderByChild(modifier["value"] as String)
          "orderByKey" -> query = query.orderByKey()
          "orderByValue" -> query = query.orderByValue()
          "orderByPriority" -> query = query.orderByPriority()
          "startAt" -> {
            val value = modifier["value"]
            query = when (value) {
              is String -> query.startAt(value)
              is Double -> query.startAt(value)
              is Boolean -> query.startAt(value)
              else -> query.startAt(value.toString())
            }
          }
          "endAt" -> {
            val value = modifier["value"]
            query = when (value) {
              is String -> query.endAt(value)
              is Double -> query.endAt(value)
              is Boolean -> query.endAt(value)
              else -> query.endAt(value.toString())
            }
          }
          "equalTo" -> {
            val value = modifier["value"]
            query = when (value) {
              is String -> query.equalTo(value)
              is Double -> query.equalTo(value)
              is Boolean -> query.equalTo(value)
              else -> query.equalTo(value.toString())
            }
          }
          "limitToFirst" -> query = query.limitToFirst((modifier["value"] as Number).toInt())
          "limitToLast" -> query = query.limitToLast((modifier["value"] as Number).toInt())
        }
      }
      
      // Generate a unique channel name
      val channelName = "firebase_database_query_${System.currentTimeMillis()}_${request.path.hashCode()}"
      
      // Set up the event channel
      val eventChannel = EventChannel(messenger, channelName)
      val streamHandler = EventStreamHandler(query, object : OnDispose {
        override fun run() {
          // Clean up when the stream is disposed
          streamHandlers.remove(eventChannel)
        }
      })
      eventChannel.setStreamHandler(streamHandler)
      streamHandlers[eventChannel] = streamHandler
      
      callback(KotlinResult.success(channelName))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun queryKeepSynced(app: DatabasePigeonFirebaseApp, request: QueryRequest, callback: (KotlinResult<Unit>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      reference.keepSynced(request.value ?: false)
      callback(KotlinResult.success(Unit))
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  override fun queryGet(app: DatabasePigeonFirebaseApp, request: QueryRequest, callback: (KotlinResult<Map<String, Any?>>) -> Unit) {
    try {
      val database = getDatabaseFromPigeonApp(app)
      val reference = database.getReference(request.path)
      
      // Apply query modifiers if any
      var query: com.google.firebase.database.Query = reference
      for (modifier in request.modifiers) {
        when (modifier["type"] as String) {
          "orderByChild" -> query = query.orderByChild(modifier["value"] as String)
          "orderByKey" -> query = query.orderByKey()
          "orderByValue" -> query = query.orderByValue()
          "orderByPriority" -> query = query.orderByPriority()
          "startAt" -> {
            val value = modifier["value"]
            query = when (value) {
              is String -> query.startAt(value)
              is Double -> query.startAt(value)
              is Boolean -> query.startAt(value)
              else -> query.startAt(value.toString())
            }
          }
          "endAt" -> {
            val value = modifier["value"]
            query = when (value) {
              is String -> query.endAt(value)
              is Double -> query.endAt(value)
              is Boolean -> query.endAt(value)
              else -> query.endAt(value.toString())
            }
          }
          "equalTo" -> {
            val value = modifier["value"]
            query = when (value) {
              is String -> query.equalTo(value)
              is Double -> query.equalTo(value)
              is Boolean -> query.equalTo(value)
              else -> query.equalTo(value.toString())
            }
          }
          "limitToFirst" -> query = query.limitToFirst((modifier["value"] as Number).toInt())
          "limitToLast" -> query = query.limitToLast((modifier["value"] as Number).toInt())
        }
      }
      
      // Get the data
      query.get().addOnCompleteListener { task ->
        if (task.isSuccessful) {
          val snapshot = task.result
          val payload = FlutterDataSnapshotPayload(snapshot)
          callback(KotlinResult.success(payload.toMap()))
        } else {
          callback(KotlinResult.failure(task.exception ?: Exception("Unknown error")))
        }
      }
    } catch (e: Exception) {
      callback(KotlinResult.failure(e))
    }
  }

  // Helper method to get FirebaseDatabase from Pigeon app
  private fun getDatabaseFromPigeonApp(app: DatabasePigeonFirebaseApp): FirebaseDatabase {
    val firebaseApp = FirebaseApp.getInstance(app.appName)
    return if (app.databaseURL != null) {
      FirebaseDatabase.getInstance(firebaseApp, app.databaseURL)
    } else {
      FirebaseDatabase.getInstance(firebaseApp)
    }
  }

  // Store transaction requests for later retrieval
  private val transactionRequests = mutableMapOf<Long, TransactionRequest>()
  
  // Store transaction results for later retrieval
  private val transactionResults = mutableMapOf<Long, Map<String, Any?>>()
}
