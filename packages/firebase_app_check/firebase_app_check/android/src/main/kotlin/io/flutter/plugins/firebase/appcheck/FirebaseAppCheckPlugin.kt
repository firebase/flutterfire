// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.appcheck

import android.os.Handler
import android.os.Looper
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
import com.google.firebase.appcheck.recaptchaenterprise.RecaptchaEnterpriseAppCheckProviderFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks

class FirebaseAppCheckPlugin :
  FlutterFirebasePlugin, FlutterPlugin, FirebaseAppCheckHostApi {

  private val streamHandlers: MutableMap<String, TokenChannelStreamHandler> = HashMap()
  private val eventChannels: MutableMap<String, EventChannel> = HashMap()
  private val mainThreadHandler = Handler(Looper.getMainLooper())
  private var messenger: BinaryMessenger? = null

  companion object {
    const val METHOD_CHANNEL = "plugins.flutter.io/firebase_app_check"
    const val EVENT_CHANNEL_PREFIX = "plugins.flutter.io/firebase_app_check/token/"
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    messenger = binding.binaryMessenger
    FirebaseAppCheckHostApi.setUp(binding.binaryMessenger, this)
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    FirebaseAppCheckHostApi.setUp(binding.binaryMessenger, null)
    messenger = null
    removeEventListeners()
  }

  private fun getAppCheck(appName: String): FirebaseAppCheck {
    val app = FirebaseApp.getInstance(appName)
    return FirebaseAppCheck.getInstance(app)
  }

  override fun activate(
    appName: String,
    androidProvider: String?,
    appleProvider: String?,
    debugToken: String?,
    recaptchaEnterpriseSiteKey: String?,
    callback: (Result<Unit>) -> Unit
  ) {
    try {
      val firebaseAppCheck = getAppCheck(appName)
      when (androidProvider) {
        "debug" -> {
          FlutterFirebaseAppRegistrar.debugToken = debugToken
          firebaseAppCheck.installAppCheckProviderFactory(
            DebugAppCheckProviderFactory.getInstance()
          )
        }
        "recaptchaEnterprise" -> {
          if (recaptchaEnterpriseSiteKey != null) {
            firebaseAppCheck.installAppCheckProviderFactory(
              RecaptchaEnterpriseAppCheckProviderFactory.getInstance(recaptchaEnterpriseSiteKey)
            )
          } else {
            callback(Result.failure(FlutterError("invalid-argument", "Site key is required for reCAPTCHA Enterprise", null)))
            return
          }
        }
        else -> {
          firebaseAppCheck.installAppCheckProviderFactory(
            PlayIntegrityAppCheckProviderFactory.getInstance()
          )
        }
      }
      callback(Result.success(Unit))
    } catch (e: Exception) {
      callback(Result.failure(FlutterError("unknown", e.message, null)))
    }
  }

  override fun getToken(
    appName: String,
    forceRefresh: Boolean,
    callback: (Result<String?>) -> Unit
  ) {
    val firebaseAppCheck = getAppCheck(appName)
    firebaseAppCheck.getAppCheckToken(forceRefresh).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(task.result?.token))
      } else {
        callback(Result.failure(
          FlutterError("firebase_app_check", task.exception?.message, null)
        ))
      }
    }
  }

  override fun setTokenAutoRefreshEnabled(
    appName: String,
    isTokenAutoRefreshEnabled: Boolean,
    callback: (Result<Unit>) -> Unit
  ) {
    try {
      val firebaseAppCheck = getAppCheck(appName)
      firebaseAppCheck.setTokenAutoRefreshEnabled(isTokenAutoRefreshEnabled)
      callback(Result.success(Unit))
    } catch (e: Exception) {
      callback(Result.failure(FlutterError("unknown", e.message, null)))
    }
  }

  override fun registerTokenListener(
    appName: String,
    callback: (Result<String>) -> Unit
  ) {
    try {
      val firebaseAppCheck = getAppCheck(appName)
      val name = EVENT_CHANNEL_PREFIX + appName

      val handler = TokenChannelStreamHandler(firebaseAppCheck)
      val channel = EventChannel(messenger, name)
      channel.setStreamHandler(handler)
      eventChannels[name] = channel
      streamHandlers[name] = handler

      callback(Result.success(name))
    } catch (e: Exception) {
      callback(Result.failure(FlutterError("unknown", e.message, null)))
    }
  }

  override fun getLimitedUseAppCheckToken(
    appName: String,
    callback: (Result<String>) -> Unit
  ) {
    val firebaseAppCheck = getAppCheck(appName)
    firebaseAppCheck.limitedUseAppCheckToken.addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(task.result?.token ?: ""))
      } else {
        callback(Result.failure(
          FlutterError("firebase_app_check", task.exception?.message, null)
        ))
      }
    }
  }

  override fun getPluginConstantsForFirebaseApp(
    firebaseApp: FirebaseApp
  ): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()
    taskCompletionSource.setResult(HashMap())
    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    removeEventListeners()
    taskCompletionSource.setResult(null)
    return taskCompletionSource.task
  }

  private fun removeEventListeners() {
    for ((name, channel) in eventChannels) {
      channel.setStreamHandler(null)
    }
    for ((name, handler) in streamHandlers) {
      handler.onCancel(null)
    }
    eventChannels.clear()
    streamHandlers.clear()
  }
}
