// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.inappmessaging

import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.firebase.FirebaseApp
import com.google.firebase.inappmessaging.FirebaseInAppMessaging
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry

/** FirebaseInAppMessagingPlugin */
class FirebaseInAppMessagingPlugin :
    FlutterFirebasePlugin, FlutterPlugin, FirebaseInAppMessagingHostApi {
  private var binaryMessenger: BinaryMessenger? = null

  private fun initInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this)
    binaryMessenger = messenger
    FirebaseInAppMessagingHostApi.setUp(messenger, this)
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    binaryMessenger = null
    FirebaseInAppMessagingHostApi.setUp(binding.binaryMessenger, null)
  }

  override fun triggerEvent(appName: String, eventName: String, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        FirebaseInAppMessaging.getInstance().triggerEvent(eventName)
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun setMessagesSuppressed(
      appName: String,
      suppress: Boolean,
      callback: (Result<Unit>) -> Unit
  ) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        FirebaseInAppMessaging.getInstance().setMessagesSuppressed(suppress)
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun setAutomaticDataCollectionEnabled(
      appName: String,
      enabled: Boolean,
      callback: (Result<Unit>) -> Unit
  ) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        FirebaseInAppMessaging.getInstance().setAutomaticDataCollectionEnabled(enabled)
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  private fun <T> handleFailure(callback: (Result<T>) -> Unit, exception: Exception?) {
    val message = exception?.message ?: "An unknown error occurred"
    callback(Result.failure(FlutterError("firebase_in_app_messaging", message, null)))
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>?> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>?>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(null)
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

  companion object {
    private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_in_app_messaging"
  }
}
