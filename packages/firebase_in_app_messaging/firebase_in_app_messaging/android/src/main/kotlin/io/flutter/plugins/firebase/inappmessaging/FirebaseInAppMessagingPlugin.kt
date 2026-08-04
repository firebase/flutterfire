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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin

/** FirebaseInAppMessagingPlugin */
class FirebaseInAppMessagingPlugin : FlutterFirebasePlugin, FlutterPlugin, MethodCallHandler {
  private var channel: MethodChannel? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    channel =
        MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME).also {
          it.setMethodCallHandler(this)
        }
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "FirebaseInAppMessaging#triggerEvent" -> {
        val eventName = requireNotNull(call.argument<String>("eventName"))
        FirebaseInAppMessaging.getInstance().triggerEvent(eventName)
        result.success(null)
      }
      "FirebaseInAppMessaging#setMessagesSuppressed" -> {
        val suppress = requireNotNull(call.argument<Boolean>("suppress"))
        FirebaseInAppMessaging.getInstance().setMessagesSuppressed(suppress)
        result.success(null)
      }
      "FirebaseInAppMessaging#setAutomaticDataCollectionEnabled" -> {
        val enabled = call.argument<Boolean>("enabled")
        FirebaseInAppMessaging.getInstance().setAutomaticDataCollectionEnabled(enabled)
        result.success(null)
      }
      else -> result.notImplemented()
    }
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
