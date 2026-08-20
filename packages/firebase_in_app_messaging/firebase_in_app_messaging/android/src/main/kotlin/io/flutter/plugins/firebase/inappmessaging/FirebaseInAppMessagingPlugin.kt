// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.inappmessaging

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.firebase.FirebaseApp
import com.google.firebase.inappmessaging.FirebaseInAppMessaging
import com.google.firebase.inappmessaging.FirebaseInAppMessagingClickListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDismissListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplay
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplayCallbacks
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplayErrorListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingImpressionListener
import com.google.firebase.inappmessaging.display.FirebaseInAppMessagingDisplay as FirebaseInAppMessagingDefaultDisplay
import com.google.firebase.inappmessaging.model.Action
import com.google.firebase.inappmessaging.model.CardMessage
import com.google.firebase.inappmessaging.model.InAppMessage
import com.google.firebase.inappmessaging.model.MessageType
import java.lang.ref.WeakReference
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executor

/** FirebaseInAppMessagingPlugin */
class FirebaseInAppMessagingPlugin :
    FlutterFirebasePlugin,
    FlutterPlugin,
    FirebaseInAppMessagingHostApi,
    FirebaseInAppMessagingDisplay {
  private var binaryMessenger: BinaryMessenger? = null
  private var flutterApi: FirebaseInAppMessagingFlutterApi? = null
  private var application: Application? = null
  private var customDisplayEnabled = false
  private var lifecycleRegistered = false
  private var lastActivity: WeakReference<Activity>? = null
  private val pendingDisplays = ConcurrentHashMap<String, PendingDisplay>()
  private val mainHandler = Handler(Looper.getMainLooper())

  private data class PendingDisplay(
      val callbacks: FirebaseInAppMessagingDisplayCallbacks,
      val actions: Map<String, Action>,
  )

  // The listeners below forward events to Dart, which has to happen on the main
  // thread, so they are registered with a main thread executor.
  private val mainThreadExecutor = Executor { command ->
    Handler(Looper.getMainLooper()).post(command)
  }

  private val clickListener = FirebaseInAppMessagingClickListener { inAppMessage, action ->
    flutterApi?.onMessageClicked(
        campaignMetadata(inAppMessage),
        FiamAction(action.actionUrl, action.button?.text?.text),
    ) {}
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

  private val lifecycleCallbacks =
      object : Application.ActivityLifecycleCallbacks {
        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}

        override fun onActivityStarted(activity: Activity) {}

        override fun onActivityResumed(activity: Activity) {
          lastActivity = WeakReference(activity)
          if (customDisplayEnabled) {
            FirebaseInAppMessaging.getInstance().setMessageDisplayComponent(
                this@FirebaseInAppMessagingPlugin,
            )
          }
        }

        override fun onActivityPaused(activity: Activity) {
          if (lastActivity?.get() === activity) {
            lastActivity = null
          }
        }

        override fun onActivityStopped(activity: Activity) {}

        override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

        override fun onActivityDestroyed(activity: Activity) {}
      }

  private fun initInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this)
    binaryMessenger = messenger
    flutterApi = FirebaseInAppMessagingFlutterApi(messenger)
    FirebaseInAppMessagingHostApi.setUp(messenger, this)
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    application = binding.applicationContext as? Application
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    setCustomDisplayEnabledInternal(false)
    removeEventListeners()
    binaryMessenger = null
    flutterApi = null
    FirebaseInAppMessagingHostApi.setUp(binding.binaryMessenger, null)
  }

  override fun displayMessage(
      inAppMessage: InAppMessage,
      callbacks: FirebaseInAppMessagingDisplayCallbacks,
  ) {
    if (!customDisplayEnabled) {
      return
    }

    val message = toDisplayMessage(inAppMessage)
    pendingDisplays[message.campaignMetadata.campaignId] =
        PendingDisplay(callbacks, collectActions(inAppMessage))

    mainHandler.post { flutterApi?.onMessageDisplay(message) {} }
  }

  private fun campaignMetadata(inAppMessage: InAppMessage): FiamCampaignMetadata {
    val metadata = inAppMessage.campaignMetadata
    return FiamCampaignMetadata(
        metadata?.campaignId ?: "",
        metadata?.campaignName ?: "",
        metadata?.isTestMessage ?: false,
    )
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
        addEventListenersInternal()
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
      callback: (Result<Unit>) -> Unit,
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
      callback: (Result<Unit>) -> Unit,
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

  override fun setCustomDisplayEnabled(
      appName: String,
      enabled: Boolean,
      callback: (Result<Unit>) -> Unit,
  ) {
    mainHandler.post {
      try {
        setCustomDisplayEnabledInternal(enabled)
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun reportImpression(campaignId: String, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        pendingDisplays[campaignId]?.callbacks?.impressionDetected()
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun reportClick(
      campaignId: String,
      actionId: String,
      callback: (Result<Unit>) -> Unit,
  ) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val pending = pendingDisplays.remove(campaignId)
        val action = pending?.actions?.get(actionId)
        if (pending != null && action != null) {
          pending.callbacks.messageClicked(action)
        } else {
          pending?.callbacks?.messageDismissed(
              FirebaseInAppMessagingDisplayCallbacks.InAppMessagingDismissType.CLICK,
          )
        }
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun reportDismiss(
      campaignId: String,
      dismissType: String,
      callback: (Result<Unit>) -> Unit,
  ) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val pending = pendingDisplays.remove(campaignId)
        pending?.callbacks?.messageDismissed(toDismissType(dismissType))
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun reportDisplayError(
      campaignId: String,
      reason: String,
      callback: (Result<Unit>) -> Unit,
  ) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val pending = pendingDisplays.remove(campaignId)
        pending?.callbacks?.displayErrorEncountered(toErrorReason(reason))
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  private fun setCustomDisplayEnabledInternal(enabled: Boolean) {
    customDisplayEnabled = enabled
    val fiam = FirebaseInAppMessaging.getInstance()
    if (enabled) {
      fiam.setMessageDisplayComponent(this)
      if (!lifecycleRegistered) {
        application?.registerActivityLifecycleCallbacks(lifecycleCallbacks)
        lifecycleRegistered = true
      }
    } else {
      if (lifecycleRegistered) {
        application?.unregisterActivityLifecycleCallbacks(lifecycleCallbacks)
        lifecycleRegistered = false
      }
      dismissAllPending()
      restoreDefaultDisplay()
    }
  }

  /// Hands rendering back to `firebase-inappmessaging-display`. That SDK
  /// overwrites the display component on activity resume, so we force a
  /// rebind; `onActivityPaused` also calls `removeAllListeners()`, so any
  /// lifecycle listeners attached by this plugin are registered again.
  private fun restoreDefaultDisplay() {
    val activity = lastActivity?.get() ?: return
    val defaultDisplay = FirebaseInAppMessagingDefaultDisplay.getInstance()
    val shouldRestoreListeners = eventListenersAdded
    defaultDisplay.onActivityPaused(activity)
    defaultDisplay.onActivityResumed(activity)
    if (shouldRestoreListeners) {
      eventListenersAdded = false
      addEventListenersInternal()
    }
  }

  private fun addEventListenersInternal() {
    if (eventListenersAdded) {
      return
    }
    FirebaseInAppMessaging.getInstance().apply {
      addClickListener(clickListener, mainThreadExecutor)
      addImpressionListener(impressionListener, mainThreadExecutor)
      addDismissListener(dismissListener, mainThreadExecutor)
      addDisplayErrorListener(displayErrorListener, mainThreadExecutor)
    }
    eventListenersAdded = true
  }

  private fun dismissAllPending() {
    val pending = pendingDisplays.values.toList()
    pendingDisplays.clear()
    for (entry in pending) {
      try {
        entry.callbacks.messageDismissed(
            FirebaseInAppMessagingDisplayCallbacks.InAppMessagingDismissType.AUTO,
        )
      } catch (_: Exception) {}
    }
  }

  private fun toDisplayMessage(message: InAppMessage): FiamDisplayMessage {
    val metadata = campaignMetadata(message)
    val campaignId = metadata.campaignId
    val card = message as? CardMessage
    return FiamDisplayMessage(
        campaignMetadata = metadata,
        messageType = toMessageType(message.messageType),
        title = toFiamText(message.title),
        body = toFiamText(message.body),
        imageUrl =
            card?.portraitImageData?.imageUrl ?: message.imageUrl ?: message.imageData?.imageUrl,
        landscapeImageUrl = card?.landscapeImageData?.imageUrl,
        backgroundHexColor = message.backgroundHexColor,
        action = if (card == null) toDisplayAction("${campaignId}_action", message.action) else null,
        primaryAction = toDisplayAction("${campaignId}_primary", card?.primaryAction),
        secondaryAction = toDisplayAction("${campaignId}_secondary", card?.secondaryAction),
        data = toData(message.data),
    )
  }

  private fun collectActions(message: InAppMessage): Map<String, Action> {
    val campaignId = campaignMetadata(message).campaignId
    val actions = mutableMapOf<String, Action>()
    val card = message as? CardMessage
    if (card != null) {
      actions["${campaignId}_primary"] = card.primaryAction
      card.secondaryAction?.let { actions["${campaignId}_secondary"] = it }
    } else {
      message.action?.let { actions["${campaignId}_action"] = it }
    }
    return actions
  }

  private fun toMessageType(type: MessageType?): String {
    return when (type) {
      MessageType.BANNER -> "BANNER"
      MessageType.MODAL -> "MODAL"
      MessageType.CARD -> "CARD"
      MessageType.IMAGE_ONLY -> "IMAGE_ONLY"
      else -> "UNKNOWN"
    }
  }

  private fun toData(data: Map<String, String>?): Map<String?, String?>? {
    if (data.isNullOrEmpty()) {
      return null
    }
    return HashMap<String?, String?>(data)
  }

  private fun toFiamText(text: com.google.firebase.inappmessaging.model.Text?): FiamText? {
    val value = text?.text ?: return null
    return FiamText(text = value, hexColor = text.hexColor)
  }

  private fun toDisplayAction(id: String, action: Action?): FiamDisplayAction? {
    if (action == null) {
      return null
    }
    val button = action.button
    val url = action.actionUrl
    if (button == null && url.isNullOrEmpty()) {
      return null
    }
    return FiamDisplayAction(
        id = id,
        actionUrl = url,
        buttonText = button?.text?.text,
        buttonTextHexColor = button?.text?.hexColor,
        buttonBackgroundHexColor = button?.buttonHexColor,
    )
  }

  private fun toDismissType(
      dismissType: String,
  ): FirebaseInAppMessagingDisplayCallbacks.InAppMessagingDismissType {
    return when (dismissType) {
      "auto" -> FirebaseInAppMessagingDisplayCallbacks.InAppMessagingDismissType.AUTO
      "swipe" -> FirebaseInAppMessagingDisplayCallbacks.InAppMessagingDismissType.SWIPE
      "unknown" ->
          FirebaseInAppMessagingDisplayCallbacks.InAppMessagingDismissType.UNKNOWN_DISMISS_TYPE
      else -> FirebaseInAppMessagingDisplayCallbacks.InAppMessagingDismissType.CLICK
    }
  }

  private fun toErrorReason(
      reason: String,
  ): FirebaseInAppMessagingDisplayCallbacks.InAppMessagingErrorReason {
    return when (reason) {
      "IMAGE_FETCH_ERROR",
      "imageFetchError" ->
          FirebaseInAppMessagingDisplayCallbacks.InAppMessagingErrorReason.IMAGE_FETCH_ERROR
      "IMAGE_DISPLAY_ERROR",
      "imageDisplayError" ->
          FirebaseInAppMessagingDisplayCallbacks.InAppMessagingErrorReason.IMAGE_DISPLAY_ERROR
      "IMAGE_UNSUPPORTED_FORMAT",
      "imageUnsupportedFormat" ->
          FirebaseInAppMessagingDisplayCallbacks.InAppMessagingErrorReason.IMAGE_UNSUPPORTED_FORMAT
      else ->
          FirebaseInAppMessagingDisplayCallbacks.InAppMessagingErrorReason.UNSPECIFIED_RENDER_ERROR
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
