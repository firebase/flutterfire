// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.installations.firebase_app_installations

import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.installations.FirebaseInstallations
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry

/** FirebaseInstallationsPlugin */
class FirebaseInstallationsPlugin :
    FlutterFirebasePlugin, FlutterPlugin, FirebaseAppInstallationsHostApi {
  private var messenger: BinaryMessenger? = null
  private val streamHandlers = mutableMapOf<EventChannel, EventChannel.StreamHandler>()

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    messenger = binding.binaryMessenger
    FirebaseAppInstallationsHostApi.setUp(binding.binaryMessenger, this)
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    FirebaseAppInstallationsHostApi.setUp(binding.binaryMessenger, null)
    messenger = null
    removeEventListeners()
  }

  private fun getInstallations(appName: String): FirebaseInstallations {
    return FirebaseInstallations.getInstance(FirebaseApp.getInstance(appName))
  }

  override fun delete(appName: String, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        Tasks.await(getInstallations(appName).delete())
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        callback(
            Result.failure(
                FlutterError(
                    "firebase_app_installations",
                    exception.message,
                    getExceptionDetails(exception))))
      }
    }
  }

  override fun getId(appName: String, callback: (Result<String>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        callback(Result.success(Tasks.await(getInstallations(appName).id)))
      } catch (exception: Exception) {
        callback(
            Result.failure(
                FlutterError(
                    "firebase_app_installations",
                    exception.message,
                    getExceptionDetails(exception))))
      }
    }
  }

  override fun getToken(
      appName: String,
      forceRefresh: Boolean,
      callback: (Result<String>) -> Unit
  ) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val tokenResult = Tasks.await(getInstallations(appName).getToken(forceRefresh))
        callback(Result.success(tokenResult.token))
      } catch (exception: Exception) {
        callback(
            Result.failure(
                FlutterError(
                    "firebase_app_installations",
                    exception.message,
                    getExceptionDetails(exception))))
      }
    }
  }

  override fun registerIdChangeListener(appName: String, callback: (Result<String>) -> Unit) {
    try {
      val handler = TokenChannelStreamHandler(getInstallations(appName))
      val name = "$METHOD_CHANNEL_NAME/token/$appName"
      val eventChannel = EventChannel(requireNotNull(messenger), name)
      eventChannel.setStreamHandler(handler)
      streamHandlers[eventChannel] = handler
      callback(Result.success(name))
    } catch (exception: Exception) {
      callback(
          Result.failure(
              FlutterError(
                  "firebase_app_installations", exception.message, getExceptionDetails(exception))))
    }
  }

  private fun getExceptionDetails(exception: Exception?): Map<String, Any?> {
    return mapOf(
        "code" to "unknown",
        "message" to if (exception != null) exception.message else "An unknown error has occurred.",
    )
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(emptyMap())
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }

    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
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

  companion object {
    private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_app_installations"
  }
}
