// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.core

import android.content.Context
import android.os.Looper
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.Companion.cachedThreadPool

/**
 * Flutter plugin implementation controlling the entrypoint for the Firebase SDK.
 *
 * Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
class FlutterFirebaseCorePlugin : FlutterPlugin,
    FirebaseCoreHostApi,
    FirebaseAppHostApi {

    private var applicationContext: Context? = null
    private var coreInitialized = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        FirebaseCoreHostApi.setUp(binding.binaryMessenger, this)
        FirebaseAppHostApi.setUp(binding.binaryMessenger, this)
        applicationContext = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        FirebaseCoreHostApi.setUp(binding.binaryMessenger, null)
        FirebaseAppHostApi.setUp(binding.binaryMessenger, null)
    }

    private fun firebaseOptionsToMap(options: FirebaseOptions): CoreFirebaseOptions {
        return CoreFirebaseOptions(
            apiKey = options.apiKey,
            appId = options.applicationId,
            messagingSenderId = options.gcmSenderId ?: "",
            projectId = options.projectId ?: "",
            authDomain = null,
            databaseURL = options.databaseUrl,
            storageBucket = options.storageBucket,
            measurementId = null,
            trackingId = options.gaTrackingId,
            deepLinkURLScheme = null,
            androidClientId = null,
            iosClientId = null,
            iosBundleId = null,
            appGroupId = null
        )
    }

    private fun firebaseAppToMap(firebaseApp: FirebaseApp): CoreInitializeResponse {
        val pluginConstants: Map<String?, Any?> = try {
            val constants = Tasks.await(FlutterFirebasePluginRegistry.getPluginConstantsForFirebaseApp(firebaseApp))
            constants.mapKeys { it.key as String? }
        } catch (e: Exception) {
            emptyMap()
        }

        return CoreInitializeResponse(
            name = firebaseApp.name,
            options = firebaseOptionsToMap(firebaseApp.options),
            isAutomaticDataCollectionEnabled = firebaseApp.isDataCollectionDefaultEnabled,
            pluginConstants = pluginConstants
        )
    }

    override fun initializeApp(
        appName: String,
        initializeAppRequest: CoreFirebaseOptions,
        callback: (Result<CoreInitializeResponse>) -> Unit
    ) {
        cachedThreadPool.execute {
            try {
                val options = FirebaseOptions.Builder()
                    .setApiKey(initializeAppRequest.apiKey)
                    .setApplicationId(initializeAppRequest.appId)
                    .setDatabaseUrl(initializeAppRequest.databaseURL)
                    .setGcmSenderId(initializeAppRequest.messagingSenderId)
                    .setProjectId(initializeAppRequest.projectId)
                    .setStorageBucket(initializeAppRequest.storageBucket)
                    .setGaTrackingId(initializeAppRequest.trackingId)
                    .build()

                // TODO(Salakar) hacky workaround a bug with FirebaseInAppMessaging causing the error:
                //    Can't create handler inside thread Thread[pool-3-thread-1,5,main] that has not called Looper.prepare()
                //     at com.google.firebase.inappmessaging.internal.ForegroundNotifier.<init>(ForegroundNotifier.java:61)
                try {
                    Looper.prepare()
                } catch (e: Exception) {
                    // do nothing
                }

                initializeAppRequest.authDomain?.let {
                    customAuthDomain[appName] = it
                }

                val context = applicationContext ?: throw IllegalStateException("Application context is null")
                val firebaseApp = FirebaseApp.initializeApp(context, options, appName)
                val response = firebaseAppToMap(firebaseApp)
                callback(Result.success(response))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun initializeCore(callback: (Result<List<CoreInitializeResponse>>) -> Unit) {
        cachedThreadPool.execute {
            try {
                if (!coreInitialized) {
                    coreInitialized = true
                } else {
                    Tasks.await(FlutterFirebasePluginRegistry.didReinitializeFirebaseCore())
                }

                val context = applicationContext ?: throw IllegalStateException("Application context is null")
                val firebaseApps = FirebaseApp.getApps(context)
                val firebaseAppsList = firebaseApps.map { firebaseApp ->
                    firebaseAppToMap(firebaseApp)
                }

                callback(Result.success(firebaseAppsList))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun optionsFromResource(callback: (Result<CoreFirebaseOptions>) -> Unit) {
        cachedThreadPool.execute {
            try {
                val context = applicationContext ?: throw IllegalStateException("Application context is null")
                val options = FirebaseOptions.fromResource(context)
                if (options == null) {
                    callback(Result.failure(
                        Exception("Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly.")
                    ))
                    return@execute
                }
                callback(Result.success(firebaseOptionsToMap(options)))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun setAutomaticDataCollectionEnabled(
        appName: String,
        enabled: Boolean,
        callback: (Result<Unit>) -> Unit
    ) {
        cachedThreadPool.execute {
            try {
                val firebaseApp = FirebaseApp.getInstance(appName)
                firebaseApp.setDataCollectionDefaultEnabled(enabled)
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun setAutomaticResourceManagementEnabled(
        appName: String,
        enabled: Boolean,
        callback: (Result<Unit>) -> Unit
    ) {
        // Unsupported on Android - just succeed
        callback(Result.success(Unit))
    }

    override fun delete(appName: String, callback: (Result<Unit>) -> Unit) {
        cachedThreadPool.execute {
            try {
                val firebaseApp = FirebaseApp.getInstance(appName)
                try {
                    firebaseApp.delete()
                } catch (appNotFoundException: IllegalStateException) {
                    // Ignore app not found exceptions.
                }
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    companion object {
        @JvmField
        val customAuthDomain: MutableMap<String, String> = mutableMapOf()
    }
}
