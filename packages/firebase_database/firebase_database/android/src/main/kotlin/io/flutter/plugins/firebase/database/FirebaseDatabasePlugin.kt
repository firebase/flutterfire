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

class FirebaseDatabasePlugin : FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
    
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

    private fun setCachedFirebaseDatabaseInstanceForKey(database: FirebaseDatabase, key: String) {
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
        methodChannel.setMethodCallHandler(this)
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
        val database = if (databaseURL.isNotEmpty()) {
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

    private fun runTransaction(arguments: Map<String, Any>): Task<Map<String, Any>> {
        val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

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

    private fun queryGet(arguments: Map<String, Any>): Task<Map<String, Any>> {
        val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

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
                val streamHandler = EventStreamHandler(
                    query,
                    object : OnDispose {
                        override fun run() {
                            eventChannel.setStreamHandler(null)
                        }
                    }
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

                val onDisconnectTask = when (priority) {
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

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val methodCallTask: Task<*>?
        val arguments = (call.arguments() as? Map<String, Any>) ?: emptyMap()

        methodCallTask = when (call.method) {
            "FirebaseDatabase#goOnline" -> goOnline(arguments)
            "FirebaseDatabase#goOffline" -> goOffline(arguments)
            "FirebaseDatabase#purgeOutstandingWrites" -> purgeOutstandingWrites(arguments)
            "DatabaseReference#set" -> setValue(arguments)
            "DatabaseReference#setWithPriority" -> setValueWithPriority(arguments)
            "DatabaseReference#update" -> update(arguments)
            "DatabaseReference#setPriority" -> setPriority(arguments)
            "DatabaseReference#runTransaction" -> runTransaction(arguments)
            "OnDisconnect#set" -> setOnDisconnect(arguments)
            "OnDisconnect#setWithPriority" -> setWithPriorityOnDisconnect(arguments)
            "OnDisconnect#update" -> updateOnDisconnect(arguments)
            "OnDisconnect#cancel" -> cancelOnDisconnect(arguments)
            "Query#get" -> queryGet(arguments)
            "Query#keepSynced" -> queryKeepSynced(arguments)
            "Query#observe" -> observe(arguments)
            else -> {
                result.notImplemented()
                return
            }
        }

        methodCallTask.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val r = task.result
                result.success(r)
            } else {
                val exception = task.exception
                val e: FlutterFirebaseDatabaseException

                e = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e(
                            "firebase_database",
                            "An unknown error occurred handling native method call ${call.method}",
                            exception
                        )
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }

                result.error(e.code, e.errorMessage, e.additionalData)
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        initPluginInstance(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
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
}
