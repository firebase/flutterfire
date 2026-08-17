// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.core

import android.content.Context
import android.os.Looper
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool

/**
 * Flutter plugin implementation controlling the entrypoint for the Firebase SDK.
 *
 * Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
class FlutterFirebaseCorePlugin : FlutterPlugin, FirebaseCoreHostApi, FirebaseAppHostApi {
  private var applicationContext: Context? = null
  private var coreInitialized = false

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    FirebaseCoreHostApi.setUp(binding.binaryMessenger, this)
    FirebaseAppHostApi.setUp(binding.binaryMessenger, this)
    applicationContext = binding.applicationContext
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    applicationContext = null
    FirebaseCoreHostApi.setUp(binding.binaryMessenger, null)
    FirebaseAppHostApi.setUp(binding.binaryMessenger, null)
  }

  private fun firebaseOptionsToPigeon(options: FirebaseOptions): CoreFirebaseOptions {
    return CoreFirebaseOptions(
        apiKey = options.apiKey ?: "",
        appId = options.applicationId,
        messagingSenderId = options.gcmSenderId ?: "",
        projectId = options.projectId ?: "",
        databaseURL = options.databaseUrl,
        storageBucket = options.storageBucket,
        trackingId = options.gaTrackingId,
    )
  }

  private fun firebaseAppToPigeon(firebaseApp: FirebaseApp): Task<CoreInitializeResponse> {
    val taskCompletionSource = TaskCompletionSource<CoreInitializeResponse>()

    cachedThreadPool.execute {
      try {
        val pluginConstantsRaw =
            Tasks.await(
                FlutterFirebasePluginRegistry.getPluginConstantsForFirebaseApp(firebaseApp))
                ?: emptyMap()
        val pluginConstants = HashMap<String?, Any?>(pluginConstantsRaw.size)
        for ((key, value) in pluginConstantsRaw) {
          pluginConstants[key] = value
        }
        taskCompletionSource.setResult(
            CoreInitializeResponse(
                name = firebaseApp.name,
                options = firebaseOptionsToPigeon(firebaseApp.options),
                isAutomaticDataCollectionEnabled = firebaseApp.isDataCollectionDefaultEnabled,
                pluginConstants = pluginConstants,
            ))
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun <T> listenToResponse(
      taskCompletionSource: TaskCompletionSource<T>,
      callback: (Result<T>) -> Unit
  ) {
    taskCompletionSource.task.addOnCompleteListener { task ->
      if (task.isSuccessful) {
        @Suppress("UNCHECKED_CAST")
        callback(Result.success(task.result as T))
      } else {
        callback(Result.failure(task.exception ?: Exception("Unknown error")))
      }
    }
  }

  override fun initializeApp(
      appName: String,
      initializeAppRequest: CoreFirebaseOptions,
      callback: (Result<CoreInitializeResponse>) -> Unit
  ) {
    val taskCompletionSource = TaskCompletionSource<CoreInitializeResponse>()
    val context = applicationContext

    cachedThreadPool.execute {
      try {
        if (context == null) {
          throw IllegalStateException("FlutterFirebaseCorePlugin is not attached to an engine")
        }

        val options =
            FirebaseOptions.Builder()
                .setApiKey(initializeAppRequest.apiKey)
                .setApplicationId(initializeAppRequest.appId)
                .setDatabaseUrl(initializeAppRequest.databaseURL)
                .setGcmSenderId(initializeAppRequest.messagingSenderId)
                .setProjectId(initializeAppRequest.projectId)
                .setStorageBucket(initializeAppRequest.storageBucket)
                .setGaTrackingId(initializeAppRequest.trackingId)
                .build()
        // TODO(Salakar) hacky workaround a bug with FirebaseInAppMessaging causing the error:
        //    Can't create handler inside thread Thread[pool-3-thread-1,5,main] that has not
        // called Looper.prepare()
        //     at
        // com.google.firebase.inappmessaging.internal.ForegroundNotifier.<init>(ForegroundNotifier.java:61)
        try {
          Looper.prepare()
        } catch (_: Exception) {
          // do nothing
        }

        val authDomain = initializeAppRequest.authDomain
        if (authDomain != null) {
          FlutterFirebasePlugin.customAuthDomain[appName] = authDomain
        }

        val firebaseApp = FirebaseApp.initializeApp(context, options, appName)
        taskCompletionSource.setResult(Tasks.await(firebaseAppToPigeon(firebaseApp)))
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    listenToResponse(taskCompletionSource, callback)
  }

  override fun initializeCore(callback: (Result<List<CoreInitializeResponse>>) -> Unit) {
    val taskCompletionSource = TaskCompletionSource<List<CoreInitializeResponse>>()
    val context = applicationContext

    cachedThreadPool.execute {
      try {
        if (context == null) {
          throw IllegalStateException("FlutterFirebaseCorePlugin is not attached to an engine")
        }

        if (!coreInitialized) {
          coreInitialized = true
        } else {
          Tasks.await(FlutterFirebasePluginRegistry.didReinitializeFirebaseCore())
        }

        val firebaseApps = FirebaseApp.getApps(context)
        val firebaseAppsList = ArrayList<CoreInitializeResponse>(firebaseApps.size)
        for (firebaseApp in firebaseApps) {
          firebaseAppsList.add(Tasks.await(firebaseAppToPigeon(firebaseApp)))
        }

        taskCompletionSource.setResult(firebaseAppsList)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    listenToResponse(taskCompletionSource, callback)
  }

  override fun optionsFromResource(callback: (Result<CoreFirebaseOptions>) -> Unit) {
    val taskCompletionSource = TaskCompletionSource<CoreFirebaseOptions>()
    val context = applicationContext

    cachedThreadPool.execute {
      try {
        if (context == null) {
          throw IllegalStateException("FlutterFirebaseCorePlugin is not attached to an engine")
        }

        val options = FirebaseOptions.fromResource(context)
        if (options == null) {
          taskCompletionSource.setException(
              Exception(
                  "Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly."))
          return@execute
        }
        taskCompletionSource.setResult(firebaseOptionsToPigeon(options))
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    listenToResponse(taskCompletionSource, callback)
  }

  override fun setAutomaticDataCollectionEnabled(
      appName: String,
      enabled: Boolean,
      callback: (Result<Unit>) -> Unit
  ) {
    val taskCompletionSource = TaskCompletionSource<Unit>()

    cachedThreadPool.execute {
      try {
        val firebaseApp = FirebaseApp.getInstance(appName)
        firebaseApp.setDataCollectionDefaultEnabled(enabled)
        taskCompletionSource.setResult(Unit)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    listenToResponse(taskCompletionSource, callback)
  }

  override fun setAutomaticResourceManagementEnabled(
      appName: String,
      enabled: Boolean,
      callback: (Result<Unit>) -> Unit
  ) {
    val taskCompletionSource = TaskCompletionSource<Unit>()

    cachedThreadPool.execute {
      try {
        val firebaseApp = FirebaseApp.getInstance(appName)
        firebaseApp.setAutomaticResourceManagementEnabled(enabled)
        taskCompletionSource.setResult(Unit)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    listenToResponse(taskCompletionSource, callback)
  }

  override fun delete(appName: String, callback: (Result<Unit>) -> Unit) {
    val taskCompletionSource = TaskCompletionSource<Unit>()

    cachedThreadPool.execute {
      try {
        val firebaseApp = FirebaseApp.getInstance(appName)
        firebaseApp.delete()
        taskCompletionSource.setResult(Unit)
      } catch (_: IllegalStateException) {
        // Ignore app not found exceptions.
        taskCompletionSource.setResult(Unit)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    listenToResponse(taskCompletionSource, callback)
  }
}
