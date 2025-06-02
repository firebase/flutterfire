// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.analytics

import android.content.Context
import android.os.Bundle
import android.os.Parcelable
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.FirebaseAnalytics.ConsentStatus
import com.google.firebase.analytics.FirebaseAnalytics.ConsentType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.util.Objects

class FlutterFirebaseAnalyticsPlugin : FlutterFirebasePlugin,
  FlutterPlugin, FirebaseAnalyticsHostApi {
  private lateinit var analytics: FirebaseAnalytics
  private var channel: MethodChannel? = null

  private var messenger: BinaryMessenger? = null


  private fun initInstance(messenger: BinaryMessenger, context: Context) {
    analytics = FirebaseAnalytics.getInstance(context)
    val channelName = "plugins.flutter.io/firebase_analytics"
    channel = MethodChannel(messenger, channelName)
    FirebaseAnalyticsHostApi.setUp(messenger, this)
    FlutterFirebasePluginRegistry.registerPlugin(channelName, this)
    this.messenger = messenger
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp?): Task<MutableMap<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<MutableMap<String, Any>>()

    cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(HashMap())
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
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    initInstance(binding.binaryMessenger, binding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)

    checkNotNull(messenger)
    FirebaseAnalyticsHostApi.setUp(messenger!!, null)

    channel = null
    messenger = null
  }

  private fun handleGetSessionId(): Task<Long> {
    val taskCompletionSource = TaskCompletionSource<Long>()

    cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(
          Tasks.await(
            analytics.sessionId
          )
        )
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleLogEvent(arguments: Map<String, Any?>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val eventName =
          Objects.requireNonNull(arguments[Constants.EVENT_NAME]) as String
        val map =
          arguments[Constants.PARAMETERS] as Map<String, Any>?
        val parameterBundle: Bundle? =
          createBundleFromMap(
            map
          )
        analytics.logEvent(eventName, parameterBundle)
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleSetUserId(userId: String?): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        analytics.setUserId(userId)
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleSetAnalyticsCollectionEnabled(enabled: Boolean): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        analytics.setAnalyticsCollectionEnabled(enabled)
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleSetSessionTimeoutDuration(milliseconds: Long): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        analytics.setSessionTimeoutDuration(milliseconds)
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleSetUserProperty(name: String, value: String?): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        analytics.setUserProperty(name, value)
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleResetAnalyticsData(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        analytics.resetAnalyticsData()
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleSetConsent(arguments: Map<String, Boolean?>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        val adStorageGranted =
          arguments[Constants.AD_STORAGE_CONSENT_GRANTED]
        val analyticsStorageGranted =
          arguments[Constants.ANALYTICS_STORAGE_CONSENT_GRANTED]
        val adPersonalizationSignalsGranted =
          arguments[Constants.AD_PERSONALIZATION_SIGNALS_CONSENT_GRANTED]
        val adUserDataGranted =
          arguments[Constants.AD_USER_DATA_CONSENT_GRANTED]
        val parameters =
          java.util.HashMap<ConsentType, ConsentStatus>()

        if (adStorageGranted != null) {
          parameters[ConsentType.AD_STORAGE] = if (adStorageGranted)
            ConsentStatus.GRANTED
          else
            ConsentStatus.DENIED
        }

        if (analyticsStorageGranted != null) {
          parameters[ConsentType.ANALYTICS_STORAGE] = if (analyticsStorageGranted)
            ConsentStatus.GRANTED
          else
            ConsentStatus.DENIED
        }

        if (adPersonalizationSignalsGranted != null) {
          parameters[ConsentType.AD_PERSONALIZATION] =
            if (adPersonalizationSignalsGranted)
              ConsentStatus.GRANTED
            else
              ConsentStatus.DENIED
        }

        if (adUserDataGranted != null) {
          parameters[ConsentType.AD_USER_DATA] = if (adUserDataGranted)
            ConsentStatus.GRANTED
          else
            ConsentStatus.DENIED
        }

        analytics.setConsent(parameters)
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleSetDefaultEventParameters(parameters: Map<String, Any?>?): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        analytics.setDefaultEventParameters(
          createBundleFromMap(
            parameters
          )
        )
        taskCompletionSource.setResult(null)
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun handleGetAppInstanceId(): Task<String> {
    val taskCompletionSource = TaskCompletionSource<String>()

    cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(
          Tasks.await(
            analytics.appInstanceId
          )
        )
      } catch (e: java.lang.Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun createBundleFromMap(map: Map<String, Any?>?): Bundle? {
    if (map == null) {
      return null
    }

    val bundle = Bundle()
    for ((key, value) in map) {
      if (value is String) {
        bundle.putString(key, value)
      } else if (value is Int) {
        // FirebaseAnalytics default event parameters only support long and double types, so we convert the int to a long.
        bundle.putLong(key, value.toLong())
      } else if (value is Long) {
        bundle.putLong(key, value)
      } else if (value is Double) {
        bundle.putDouble(key, value)
      } else if (value is Boolean) {
        bundle.putBoolean(key, value)
      } else if (value == null) {
        bundle.putString(key, null)
      } else if (value is Iterable<*>) {
        val list = ArrayList<Parcelable?>()

        for (item in value) {
          if (item is Map<*, *>) {
            list.add(createBundleFromMap(item as Map<String, Any>))
          } else {
            if (item != null) {
              throw IllegalArgumentException(
                ("Unsupported value type: "
                  + item.javaClass.canonicalName
                  + " in list at key "
                  + key)
              )
            }
          }
        }

        bundle.putParcelableArrayList(key, list)
      } else if (value is Map<*, *>) {
        bundle.putParcelable(key, createBundleFromMap(value as Map<String, Any>))
      } else {
        throw IllegalArgumentException(
          "Unsupported value type: " + value.javaClass.canonicalName
        )
      }
    }
    return bundle
  }

  private fun handleVoidTaskResult(
    task: Task<Void?>,
    callback: (Result<Unit>) -> Unit
  ) {
    if (task.isSuccessful) {
      callback(Result.success(Unit))
    } else {
      val message = task.exception?.message ?: "An unknown error occurred"
      callback(Result.failure(FlutterError("firebase_analytics", message, null)))
    }
  }

  private fun <T> handleTypedTaskResult(
    task: Task<T>,
    callback: (Result<T?>) -> Unit
  ) {
    if (task.isSuccessful) {
      callback(Result.success(task.result))
    } else {
      val message = task.exception?.message ?: "An unknown error occurred"
      callback(Result.failure(FlutterError("firebase_analytics", message, null)))
    }
  }

  override fun logEvent(event: Map<String, Any?>, callback: (Result<Unit>) -> Unit) {
    handleLogEvent(event).addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }
  }


  override fun setUserId(userId: String?, callback: (Result<Unit>) -> Unit) {
    handleSetUserId(userId).addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }
  }

  override fun setUserProperty(name: String, value: String?, callback: (Result<Unit>) -> Unit) {
    handleSetUserProperty(name, value).addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }
  }

  override fun setAnalyticsCollectionEnabled(enabled: Boolean, callback: (Result<Unit>) -> Unit) {
    handleSetAnalyticsCollectionEnabled(enabled).addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }
  }

  override fun resetAnalyticsData(callback: (Result<Unit>) -> Unit) {
    handleResetAnalyticsData().addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }
  }

  override fun setSessionTimeoutDuration(timeout: Long, callback: (Result<Unit>) -> Unit) {
    handleSetSessionTimeoutDuration(timeout).addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }
  }

  override fun setConsent(consent: Map<String, Boolean?>, callback: (Result<Unit>) -> Unit) {
    handleSetConsent(consent).addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }

  }

  override fun setDefaultEventParameters(
    parameters: Map<String, Any?>?,
    callback: (Result<Unit>) -> Unit
  ) {
    handleSetDefaultEventParameters(parameters).addOnCompleteListener { task ->
      handleVoidTaskResult(task, callback)
    }
  }


  override fun getAppInstanceId(callback: (Result<String?>) -> Unit) {
    handleGetAppInstanceId().addOnCompleteListener { task ->
      handleTypedTaskResult(task, callback)
    }
  }

  override fun getSessionId(callback: (Result<Long?>) -> Unit) {
    handleGetSessionId().addOnCompleteListener { task ->
      handleTypedTaskResult(task, callback)
    }
  }

  override fun initiateOnDeviceConversionMeasurement(
    arguments: Map<String, String?>,
    callback: (Result<Unit>) -> Unit
  ) {
    callback(
      Result.failure(
        FlutterError(
          "unimplemented",
          "initiateOnDeviceConversionMeasurement is only available on iOS.",
          null
        )
      )
    )
  }
}
