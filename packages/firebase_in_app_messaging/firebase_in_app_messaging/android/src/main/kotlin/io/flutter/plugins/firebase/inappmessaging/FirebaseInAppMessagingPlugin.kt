// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.inappmessaging

import android.os.Handler
import android.os.Looper
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.firebase.FirebaseApp
import com.google.firebase.inappmessaging.FirebaseInAppMessaging
import com.google.firebase.inappmessaging.FirebaseInAppMessagingClickListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDismissListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplayErrorListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingImpressionListener
import com.google.firebase.inappmessaging.model.InAppMessage
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.util.concurrent.Executor

/** FirebaseInAppMessagingPlugin */
class FirebaseInAppMessagingPlugin :
    FlutterFirebasePlugin, FlutterPlugin, FirebaseInAppMessagingHostApi {
  private var binaryMessenger: BinaryMessenger? = null
  private var flutterApi: FirebaseInAppMessagingFlutterApi? = null

  // The listeners below forward events to Dart, which has to happen on the main
  // thread, so they are registered with a main thread executor.
  private val mainThreadExecutor = Executor { command ->
    Handler(Looper.getMainLooper()).post(command)
  }

  private val clickListener = FirebaseInAppMessagingClickListener { inAppMessage, action ->
    flutterApi?.onMessageClicked(
        campaignMetadata(inAppMessage), FiamAction(action.actionUrl, action.button?.text?.text)) {}
  }

  private val impressionListener = FirebaseInAppMessagingImpressionListener { inAppMessage ->
    flutterApi?.onMessageImpression(campaignMetadata(inAppMessage)) {}
  }

  private val dismissListener = FirebaseInAppMessagingDismissListener { inAppMessage ->
    // The Android SDK does not report how a message was dismissed.
    flutterApi?.onMessageDismissed(campaignMetadata(inAppMessage), FiamDismissType.UNKNOWN) {}
  }

  private val displayErrorListener =
      FirebaseInAppMessagingDisplayErrorListener { inAppMessage, errorReason ->
        flutterApi?.onMessageDisplayError(campaignMetadata(inAppMessage), errorReason.name) {}
      }

  private var eventListenersAdded = false

  private fun initInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this)
    binaryMessenger = messenger
    flutterApi = FirebaseInAppMessagingFlutterApi(messenger)
    FirebaseInAppMessagingHostApi.setUp(messenger, this)
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    removeEventListeners()
    binaryMessenger = null
    flutterApi = null
    FirebaseInAppMessagingHostApi.setUp(binding.binaryMessenger, null)
  }

  private fun campaignMetadata(inAppMessage: InAppMessage): FiamCampaignMetadata {
    val metadata = inAppMessage.campaignMetadata
    return FiamCampaignMetadata(
        metadata?.campaignId ?: "", metadata?.campaignName ?: "", metadata?.isTestMessage ?: false)
  }

  private fun removeEventListeners() {
    if (!eventListenersAdded) return
    eventListenersAdded = false

    FirebaseInAppMessaging.getInstance().apply {
      removeClickListener(clickListener)
      removeImpressionListener(impressionListener)
      removeDismissListener(dismissListener)
      removeDisplayErrorListener(displayErrorListener)
    }
  }

  override fun addEventListeners(appName: String, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        if (!eventListenersAdded) {
          FirebaseInAppMessaging.getInstance().apply {
            addClickListener(clickListener, mainThreadExecutor)
            addImpressionListener(impressionListener, mainThreadExecutor)
            addDismissListener(dismissListener, mainThreadExecutor)
            addDisplayErrorListener(displayErrorListener, mainThreadExecutor)
          }
          eventListenersAdded = true
        }
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
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
