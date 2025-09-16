// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.appcheck

import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.AppCheckToken
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry.registerPlugin
import io.flutter.plugins.firebase.firebaseappcheck.AppCheckWebProvider
import io.flutter.plugins.firebase.firebaseappcheck.AppCheckAndroidProvider
import io.flutter.plugins.firebase.firebaseappcheck.AppCheckAppleProvider
import io.flutter.plugins.firebase.firebaseappcheck.FirebaseAppCheckHostApi

class FlutterFirebaseAppCheckPlugin : FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler, FirebaseAppCheckHostApi {

    companion object {
        private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_app_check"
        private const val DEBUG_PROVIDER = "debug"
        private const val PLAY_INTEGRITY = "playIntegrity"
    }

    private val streamHandlers = mutableMapOf<EventChannel, TokenChannelStreamHandler>()

    @Nullable
    private var messenger: BinaryMessenger? = null

    private var channel: MethodChannel? = null

    private fun initInstance(messenger: BinaryMessenger) {
        registerPlugin(METHOD_CHANNEL_NAME, this)
        channel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
        channel?.setMethodCallHandler(this)

        // Set up Pigeon API
        FirebaseAppCheckHostApi.setUp(messenger, this)

        this.messenger = messenger
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        initInstance(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        
        // Clean up Pigeon API
        FirebaseAppCheckHostApi.setUp(binding.binaryMessenger, null)
        
        messenger = null

        removeEventListeners()
    }

    private fun getAppCheck(arguments: Map<String, Any>): FirebaseAppCheck {
        val appName = arguments["appName"] as String
        val app = FirebaseApp.getInstance(appName)
        return FirebaseAppCheck.getInstance(app)
    }

    private fun getLimitedUseAppCheckToken(arguments: Map<String, Any>): Task<String> {
        val taskCompletionSource = TaskCompletionSource<String>()

        cachedThreadPool.execute {
            try {
                val firebaseAppCheck = getAppCheck(arguments)
                val tokenResult = Tasks.await(firebaseAppCheck.limitedUseAppCheckToken)
                taskCompletionSource.setResult(tokenResult.token)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    private fun activate(arguments: Map<String, Any>): Task<Void?> {
        val taskCompletionSource = TaskCompletionSource<Void?>()

        cachedThreadPool.execute {
            try {
                val provider = arguments["androidProvider"] as String

                when (provider) {
                    DEBUG_PROVIDER -> {
                        val firebaseAppCheck = getAppCheck(arguments)
                        firebaseAppCheck.installAppCheckProviderFactory(
                            DebugAppCheckProviderFactory.getInstance()
                        )
                    }
                    PLAY_INTEGRITY -> {
                        val firebaseAppCheck = getAppCheck(arguments)
                        firebaseAppCheck.installAppCheckProviderFactory(
                            PlayIntegrityAppCheckProviderFactory.getInstance()
                        )
                    }
                }
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    private fun getToken(arguments: Map<String, Any>): Task<String> {
        val taskCompletionSource = TaskCompletionSource<String>()

        cachedThreadPool.execute {
            try {
                val firebaseAppCheck = getAppCheck(arguments)
                val forceRefresh = arguments["forceRefresh"] as Boolean
                val tokenResult = Tasks.await(firebaseAppCheck.getAppCheckToken(forceRefresh))

                taskCompletionSource.setResult(tokenResult.token)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    private fun setTokenAutoRefreshEnabled(arguments: Map<String, Any>): Task<Void?> {
        val taskCompletionSource = TaskCompletionSource<Void?>()

        cachedThreadPool.execute {
            try {
                val firebaseAppCheck = getAppCheck(arguments)
                val isTokenAutoRefreshEnabled = arguments["isTokenAutoRefreshEnabled"] as Boolean
                firebaseAppCheck.setTokenAutoRefreshEnabled(isTokenAutoRefreshEnabled)

                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    private fun registerTokenListener(arguments: Map<String, Any>): Task<String> {
        val taskCompletionSource = TaskCompletionSource<String>()

        cachedThreadPool.execute {
            try {
                val appName = arguments["appName"] as String
                val firebaseAppCheck = getAppCheck(arguments)

                val handler = TokenChannelStreamHandler(firebaseAppCheck)
                val name = "$METHOD_CHANNEL_NAME/token/$appName"
                val eventChannel = EventChannel(messenger, name)
                eventChannel.setStreamHandler(handler)
                streamHandlers[eventChannel] = handler

                taskCompletionSource.setResult(name)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    override fun onMethodCall(call: MethodCall, @NonNull result: Result) {
        val arguments = call.arguments<Map<String, Any>>() ?: return
        val methodCallTask: Task<*> = when (call.method) {
            "FirebaseAppCheck#activate" -> activate(arguments)
            "FirebaseAppCheck#getToken" -> getToken(arguments)
            "FirebaseAppCheck#setTokenAutoRefreshEnabled" -> setTokenAutoRefreshEnabled(arguments)
            "FirebaseAppCheck#registerTokenListener" -> registerTokenListener(arguments)
            "FirebaseAppCheck#getLimitedUseAppCheckToken" -> getLimitedUseAppCheckToken(arguments)
            else -> {
                result.notImplemented()
                return
            }
        }

        methodCallTask.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                result.success(task.result)
            } else {
                val exception = task.exception
                result.error(
                    "firebase_app_check",
                    exception?.message,
                    getExceptionDetails(exception)
                )
            }
        }
    }

    private fun getExceptionDetails(@Nullable exception: Exception?): Map<String, Any> {
        val details = mutableMapOf<String, Any>()
        details["code"] = "unknown"
        if (exception != null) {
            details["message"] = exception.message ?: "An unknown error has occurred."
        } else {
            details["message"] = "An unknown error has occurred."
        }
        return details
    }

    override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>?> {
        val taskCompletionSource = TaskCompletionSource<Map<String, Any>?>()

        cachedThreadPool.execute {
            try {
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    override fun didReinitializeFirebaseCore(): Task<Void?> {
        val taskCompletionSource = TaskCompletionSource<Void?>()

        cachedThreadPool.execute {
            try {
                taskCompletionSource.setResult(null)
            } catch (e: Exception) {
                taskCompletionSource.setException(e)
            }
        }

        return taskCompletionSource.task
    }

    private fun removeEventListeners() {
        for ((eventChannel, streamHandler) in streamHandlers) {
            streamHandler.onCancel(null)
            eventChannel.setStreamHandler(null)
        }
        streamHandlers.clear()
    }

    // Pigeon API implementation
    override fun activate(
        appName: String,
        webProvider: AppCheckWebProvider,
        androidProvider: AppCheckAndroidProvider,
        appleProvider: AppCheckAppleProvider,
        callback: (kotlin.Result<Unit>) -> Unit
    ) {
        cachedThreadPool.execute {
            try {
                val app = FirebaseApp.getInstance(appName)
                val firebaseAppCheck = FirebaseAppCheck.getInstance(app)

                when (androidProvider.providerName) {
                    DEBUG_PROVIDER -> {
                        firebaseAppCheck.installAppCheckProviderFactory(
                            DebugAppCheckProviderFactory.getInstance()
                        )
                    }
                    PLAY_INTEGRITY -> {
                        firebaseAppCheck.installAppCheckProviderFactory(
                            PlayIntegrityAppCheckProviderFactory.getInstance()
                        )
                    }
                }
                callback(kotlin.Result.success(Unit))
            } catch (e: Exception) {
                callback(kotlin.Result.failure(e))
            }
        }
    }

    override fun getToken(appName: String, forceRefresh: Boolean, callback: (kotlin.Result<String?>) -> Unit) {
        cachedThreadPool.execute {
            try {
                val app = FirebaseApp.getInstance(appName)
                val firebaseAppCheck = FirebaseAppCheck.getInstance(app)
                val tokenResult = Tasks.await(firebaseAppCheck.getAppCheckToken(forceRefresh))
                callback(kotlin.Result.success(tokenResult.token))
            } catch (e: Exception) {
                callback(kotlin.Result.failure(e))
            }
        }
    }

    override fun setTokenAutoRefreshEnabled(
        appName: String,
        isTokenAutoRefreshEnabled: Boolean,
        callback: (kotlin.Result<Unit>) -> Unit
    ) {
        cachedThreadPool.execute {
            try {
                val app = FirebaseApp.getInstance(appName)
                val firebaseAppCheck = FirebaseAppCheck.getInstance(app)
                firebaseAppCheck.setTokenAutoRefreshEnabled(isTokenAutoRefreshEnabled)
                callback(kotlin.Result.success(Unit))
            } catch (e: Exception) {
                callback(kotlin.Result.failure(e))
            }
        }
    }

    override fun getLimitedUseToken(appName: String, callback: (kotlin.Result<String>) -> Unit) {
        cachedThreadPool.execute {
            try {
                val app = FirebaseApp.getInstance(appName)
                val firebaseAppCheck = FirebaseAppCheck.getInstance(app)
                val tokenResult = Tasks.await(firebaseAppCheck.limitedUseAppCheckToken)
                callback(kotlin.Result.success(tokenResult.token))
            } catch (e: Exception) {
                callback(kotlin.Result.failure(e))
            }
        }
    }
} 