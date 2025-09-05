// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database

import android.util.Log
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.database.DatabaseException
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.Logger
import com.google.firebase.database.OnDisconnect
import com.google.firebase.database.Query
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class FirebaseDatabaseHostApiImpl : FirebaseDatabaseHostApi {
    companion object {
        private val databaseInstanceCache = HashMap<String, FirebaseDatabase>()
        private val cachedThreadPool: ExecutorService = Executors.newCachedThreadPool()
    }

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

    private fun getDatabase(app: FirebaseApp): FirebaseDatabase {
        val appName = app.name
        val instanceKey = appName

        // Check for an existing pre-configured instance and return it if it exists.
        val existingInstance = getCachedFirebaseDatabaseInstanceForKey(instanceKey)
        if (existingInstance != null) {
            return existingInstance
        }

        val database = FirebaseDatabase.getInstance(app)

        try {
            // Note: Configuration should be done through the app parameter
            // The Pigeon FirebaseApp class contains the configuration
        } catch (e: DatabaseException) {
            val message = e.message
            if (message != null && !message.contains("must be made before any other usage of FirebaseDatabase")) {
                throw e
            }
        }

        setCachedFirebaseDatabaseInstanceForKey(database, instanceKey)
        return database
    }

    private fun getDatabaseFromPigeonApp(app: io.flutter.plugins.firebase.database.FirebaseApp): FirebaseDatabase {
        val appName = app.appName
        val databaseURL = app.databaseURL
        val instanceKey = appName + (databaseURL ?: "")

        // Check for an existing pre-configured instance and return it if it exists.
        val existingInstance = getCachedFirebaseDatabaseInstanceForKey(instanceKey)
        if (existingInstance != null) {
            return existingInstance
        }

        val firebaseApp = com.google.firebase.FirebaseApp.getInstance(appName)
        val database = if (databaseURL != null && databaseURL.isNotEmpty()) {
            FirebaseDatabase.getInstance(firebaseApp, databaseURL)
        } else {
            FirebaseDatabase.getInstance(firebaseApp)
        }

        try {
            app.loggingEnabled?.let { enabled ->
                database.setLogLevel(if (enabled) Logger.Level.DEBUG else Logger.Level.NONE)
            }

            if (app.emulatorHost != null && app.emulatorPort != null) {
                database.useEmulator(app.emulatorHost, app.emulatorPort.toInt())
            }

            app.persistenceEnabled?.let { enabled ->
                database.setPersistenceEnabled(enabled)
            }

            app.cacheSizeBytes?.let { size ->
                database.setPersistenceCacheSizeBytes(size)
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

    private fun getReference(database: FirebaseDatabase, path: String): DatabaseReference {
        return database.getReference(path)
    }

    @Suppress("UNCHECKED_CAST")
    private fun getQuery(database: FirebaseDatabase, path: String, modifiers: List<Map<String, Any?>>): Query {
        val ref = getReference(database, path)
        return QueryBuilder(ref, modifiers as List<Map<String, Any>>).build()
    }

    override fun set(options: SetOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                // For now, we'll use the default app since we don't have app context in SetOptions
                // This should be enhanced to include app information in the options
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                Tasks.await(ref.setValue(options.value))
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in set", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun setWithPriority(options: SetOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                Tasks.await(ref.setValue(options.value, options.priority))
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in setWithPriority", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun update(options: UpdateOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                Tasks.await(ref.updateChildren(options.value))
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in update", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun setPriority(options: SetPriorityOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                Tasks.await(ref.setPriority(options.priority))
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in setPriority", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun remove(options: RemoveOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                Tasks.await(ref.removeValue())
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in remove", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun runTransaction(options: TransactionOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                
                // Note: This is a simplified implementation
                // The full transaction handling would need to be implemented
                // to work with the existing TransactionHandler system
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in runTransaction", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun goOnline(app: io.flutter.plugins.firebase.database.FirebaseApp, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = getDatabaseFromPigeonApp(app)
                database.goOnline()
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in goOnline", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun goOffline(app: io.flutter.plugins.firebase.database.FirebaseApp, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = getDatabaseFromPigeonApp(app)
                database.goOffline()
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in goOffline", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun purgeOutstandingWrites(app: io.flutter.plugins.firebase.database.FirebaseApp, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = getDatabaseFromPigeonApp(app)
                database.purgeOutstandingWrites()
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in purgeOutstandingWrites", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun cancel(app: io.flutter.plugins.firebase.database.FirebaseApp, callback: (Result<Unit>) -> Unit) {
        // This method doesn't have a direct Firebase equivalent
        // It might be used for canceling operations
        callback(Result.success(Unit))
    }

    override fun observe(observer: EventObserver, callback: (Result<String>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<String>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val query = getQuery(database, observer.path, observer.modifiers)
                
                // This would need to be integrated with the existing EventStreamHandler system
                // For now, we'll return a placeholder channel name
                val eventChannelName = "${observer.eventChannelNamePrefix}#${System.currentTimeMillis()}"
                taskCompletionSource.setResult(eventChannelName)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(task.result))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in observe", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun get(options: GetOptions, callback: (Result<DataSnapshot>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Map<String, Any?>>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val query = getQuery(database, options.path, options.modifiers)
                val snapshot = Tasks.await(query.get())
                val payload = FlutterDataSnapshotPayload(snapshot)
                taskCompletionSource.setResult(payload.toMap())
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val result = DataSnapshot(task.result)
                callback(Result.success(result))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in get", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun keepSynced(options: KeepSyncedOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val query = getQuery(database, options.path, options.modifiers)
                query.keepSynced(options.value)
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in keepSynced", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun onDisconnectSet(options: OnDisconnectOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                val onDisconnect = ref.onDisconnect()
                Tasks.await(onDisconnect.setValue(options.value))
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in onDisconnectSet", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun onDisconnectSetWithPriority(options: OnDisconnectOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                val onDisconnect = ref.onDisconnect()
                
                val onDisconnectTask = when (options.priority) {
                    is Double -> onDisconnect.setValue(options.value, options.priority)
                    is String -> onDisconnect.setValue(options.value, options.priority)
                    null -> onDisconnect.setValue(options.value, null as String?)
                    else -> throw Exception("Invalid priority value for OnDisconnect.setWithPriority")
                }

                Tasks.await(onDisconnectTask)
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in onDisconnectSetWithPriority", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun onDisconnectUpdate(options: UpdateOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                val task = ref.onDisconnect().updateChildren(options.value)
                Tasks.await(task)
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in onDisconnectUpdate", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun onDisconnectRemove(options: RemoveOptions, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, options.path)
                Tasks.await(ref.onDisconnect().removeValue())
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in onDisconnectRemove", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }

    override fun onDisconnectCancel(reference: io.flutter.plugins.firebase.database.DatabaseReference, callback: (Result<Unit>) -> Unit) {
        val taskCompletionSource = TaskCompletionSource<Void>()

        cachedThreadPool.execute {
            try {
                val database = FirebaseDatabase.getInstance()
                val ref = getReference(database, reference.path)
                Tasks.await(ref.onDisconnect().cancel())
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        taskCompletionSource.task.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                callback(Result.success(Unit))
            } else {
                val exception = task.exception
                val flutterException = when (exception) {
                    is FlutterFirebaseDatabaseException -> exception
                    is DatabaseException -> FlutterFirebaseDatabaseException.fromDatabaseException(exception)
                    else -> {
                        Log.e("firebase_database", "Error in onDisconnectCancel", exception)
                        FlutterFirebaseDatabaseException.fromException(exception)
                    }
                }
                callback(Result.failure(flutterException))
            }
        }
    }
}
