// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.firebaseremoteconfig

import android.os.Handler
import android.os.Looper
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.remoteconfig.ConfigUpdate
import com.google.firebase.remoteconfig.ConfigUpdateListener
import com.google.firebase.remoteconfig.ConfigUpdateListenerRegistration
import com.google.firebase.remoteconfig.CustomSignals
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import com.google.firebase.remoteconfig.FirebaseRemoteConfigClientException
import com.google.firebase.remoteconfig.FirebaseRemoteConfigException
import com.google.firebase.remoteconfig.FirebaseRemoteConfigFetchThrottledException
import com.google.firebase.remoteconfig.FirebaseRemoteConfigServerException
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings
import com.google.firebase.remoteconfig.FirebaseRemoteConfigValue
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.util.Objects

/** FirebaseRemoteConfigPlugin  */
class FirebaseRemoteConfigPlugin

  : FlutterFirebasePlugin, FlutterPlugin,
  EventChannel.StreamHandler, FirebaseRemoteConfigHostApi {

  private val listenersMap: MutableMap<String, ConfigUpdateListenerRegistration> = HashMap()
  private var eventChannel: EventChannel? = null
  private val mainThreadHandler = Handler(Looper.getMainLooper())
  private var messenger: BinaryMessenger? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    setupChannel(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    tearDownChannel()
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val remoteConfig = FirebaseRemoteConfig.getInstance(firebaseApp)
        val configProperties = getConfigProperties(remoteConfig)
        val configValues: MutableMap<String, Any> =
          HashMap(configProperties)
        configValues["parameters"] = parseParameters(remoteConfig.all)

        taskCompletionSource.setResult(configValues)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun getConfigProperties(remoteConfig: FirebaseRemoteConfig): Map<String, Any> {
    val configProperties: MutableMap<String, Any> = HashMap()
    configProperties["fetchTimeout"] = remoteConfig.info.configSettings.fetchTimeoutInSeconds
    configProperties["minimumFetchInterval"] =
      remoteConfig.info.configSettings.minimumFetchIntervalInSeconds
    configProperties["lastFetchTime"] = remoteConfig.info.fetchTimeMillis
    configProperties["lastFetchStatus"] = mapLastFetchStatus(remoteConfig.info.lastFetchStatus)
    return configProperties
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        removeEventListeners()
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun setupChannel(messenger: BinaryMessenger) {
    FirebaseRemoteConfigHostApi.setUp(messenger, this)
    FlutterFirebasePluginRegistry.registerPlugin(
      METHOD_CHANNEL,
      this
    )

    eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    eventChannel!!.setStreamHandler(this)
    this.messenger = messenger
  }

  private fun tearDownChannel() {
    checkNotNull(messenger)
    FirebaseRemoteConfigHostApi.setUp(messenger!!, null)

    messenger = null
    eventChannel!!.setStreamHandler(null)
    eventChannel = null
    removeEventListeners()
  }

  private fun getRemoteConfig(appName: String): FirebaseRemoteConfig {
    val app = FirebaseApp.getInstance(appName)
    return FirebaseRemoteConfig.getInstance(app)
  }

  private fun setCustomSignals(
    remoteConfig: FirebaseRemoteConfig, customSignalsArguments: Map<String, Any?>
  ): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val customSignals = CustomSignals.Builder()
        for ((key, value) in customSignalsArguments) {
          if (value is String) {
            customSignals.put(key, value)
          } else if (value is Long) {
            customSignals.put(key, value)
          } else if (value is Int) {
            customSignals.put(key, value.toLong())
          } else if (value is Double) {
            customSignals.put(key, value)
          } else if (value == null) {
            customSignals.put(key, null)
          }
        }
        Tasks.await(remoteConfig.setCustomSignals(customSignals.build()))
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }
    return taskCompletionSource.task
  }

  private fun parseParameters(parameters: Map<String, FirebaseRemoteConfigValue>): Map<String, Any> {
    val parsedParameters: MutableMap<String, Any> = HashMap()
    for (key in parameters.keys) {
      parsedParameters[key] = createRemoteConfigValueMap(
          parameters[key]!!
      )
    }
    return parsedParameters
  }

  private fun createRemoteConfigValueMap(
    remoteConfigValue: FirebaseRemoteConfigValue
  ): Map<String, Any> {
    val valueMap: MutableMap<String, Any> = HashMap()
    valueMap["value"] = remoteConfigValue.asByteArray()
    valueMap["source"] = mapValueSource(remoteConfigValue.source)
    return valueMap
  }

  private fun mapLastFetchStatus(status: Int): String {
    return when (status) {
      FirebaseRemoteConfig.LAST_FETCH_STATUS_SUCCESS -> "success"
      FirebaseRemoteConfig.LAST_FETCH_STATUS_THROTTLED -> "throttled"
      FirebaseRemoteConfig.LAST_FETCH_STATUS_NO_FETCH_YET -> "noFetchYet"
      FirebaseRemoteConfig.LAST_FETCH_STATUS_FAILURE -> "failure"
      else -> "failure"
    }
  }

  private fun mapValueSource(source: Int): String {
    return when (source) {
      FirebaseRemoteConfig.VALUE_SOURCE_DEFAULT -> "default"
      FirebaseRemoteConfig.VALUE_SOURCE_REMOTE -> "remote"
      FirebaseRemoteConfig.VALUE_SOURCE_STATIC -> "static"
      else -> "static"
    }
  }

  override fun onListen(arguments: Any, events: EventSink) {
    val argumentsMap = arguments as Map<String, Any>
    val appName = Objects.requireNonNull(argumentsMap["appName"]) as String
    val remoteConfig = getRemoteConfig(appName)

    listenersMap[appName] = remoteConfig.addOnConfigUpdateListener(
      object : ConfigUpdateListener {
        override fun onUpdate(configUpdate: ConfigUpdate) {
          val updatedKeys = ArrayList(configUpdate.updatedKeys)
          mainThreadHandler.post { events.success(updatedKeys) }
        }

        override fun onError(error: FirebaseRemoteConfigException) {
          events.error("firebase_remote_config", error.message, null)
        }
      })
  }

  override fun onCancel(arguments: Any?) {
    // arguments will be null on hot restart, so we will clean up listeners in didReinitializeFirebaseCore()
    val argumentsMap = arguments as? Map<String, Any>
      ?: return
    val appName = Objects.requireNonNull(argumentsMap["appName"]) as String

    val listener = listenersMap[appName]
    if (listener != null) {
      listener.remove()
      listenersMap.remove(appName)
    }
  }

  /** Remove all registered listeners.  */
  private fun removeEventListeners() {
    for (listener in listenersMap.values) {
      listener.remove()
    }
    listenersMap.clear()
  }

  private fun <T> handleFailure (callback: (Result<T>) -> Unit, exception: Exception?) {
    val details: MutableMap<String, Any?> =
      HashMap()
    if (exception is FirebaseRemoteConfigFetchThrottledException) {
      details["code"] = "throttled"
      details["message"] = "frequency of requests exceeds throttled limits"
    } else if (exception is FirebaseRemoteConfigClientException) {
      details["code"] = "internal"
      details["message"] = "internal remote config fetch error"
    } else if (exception is FirebaseRemoteConfigServerException) {
      details["code"] = "remote-config-server-error"
      details["message"] = exception.message

      val cause = exception.cause
      if (cause != null) {
        val causeMessage = cause.message
        if (causeMessage != null && causeMessage.contains("Forbidden")) {
          // Specific error code for 403 status code to indicate the request was forbidden.
          details["code"] = "forbidden"
        }
      }
    } else {
      details["code"] = "unknown"
      details["message"] = "unknown remote config error"
    }
    callback(Result.failure(FlutterError(  "firebase_remote_config",
      exception?.message,
      details)))
  }

  companion object {
    const val TAG: String = "FRCPlugin"
    const val METHOD_CHANNEL: String = "plugins.flutter.io/firebase_remote_config"
    const val EVENT_CHANNEL: String = "plugins.flutter.io/firebase_remote_config_updated"
  }

  override fun fetch(appName: String, callback: (Result<Unit>) -> Unit) {
    getRemoteConfig(appName).fetch().addOnCompleteListener { task ->
      if(task.isSuccessful){
        callback(Result.success(Unit))
      }
      else {
        handleFailure(callback, task.exception)
      }
    }
  }

  override fun fetchAndActivate(appName: String, callback: (Result<Boolean>) -> Unit) {
    getRemoteConfig(appName).fetchAndActivate().addOnCompleteListener { task ->
      if(task.isSuccessful){
        callback(Result.success(task.result))
      }
      else {
        handleFailure(callback, task.exception)
      }
    }
  }

  override fun activate(appName: String, callback: (Result<Boolean>) -> Unit) {
    getRemoteConfig(appName).activate().addOnCompleteListener { task ->
      if(task.isSuccessful){
        callback(Result.success(task.result))
      }
      else {
        handleFailure(callback, task.exception)
      }
    }
  }

  override fun setConfigSettings(
    appName: String,
    settings: RemoteConfigPigeonSettings,
    callback: (Result<Unit>) -> Unit
  ) {
    val configSettings =
      FirebaseRemoteConfigSettings.Builder()
        .setFetchTimeoutInSeconds(settings.fetchTimeoutSeconds)
        .setMinimumFetchIntervalInSeconds(settings.minimumFetchIntervalSeconds)
        .build()
    getRemoteConfig(appName).setConfigSettingsAsync(configSettings).addOnCompleteListener { task ->
      if(task.isSuccessful){
        callback(Result.success(Unit))
      }
      else {
        handleFailure(callback, task.exception)
      }
    }
  }

  override fun setDefaults(appName: String, defaultParameters: Map<String, Any?>, callback: (Result<Unit>) -> Unit) {
    getRemoteConfig(
      appName
    ).setDefaultsAsync(defaultParameters).addOnCompleteListener { task ->
      if(task.isSuccessful){
        callback(Result.success(Unit))
      }
      else {
        handleFailure(callback, task.exception)
      }
    }
  }

  override fun ensureInitialized(appName: String, callback: (Result<Unit>) -> Unit) {
    getRemoteConfig(appName).ensureInitialized().addOnCompleteListener { task ->
      if(task.isSuccessful){
        callback(Result.success(Unit))
      }
      else {
        handleFailure(callback, task.exception)
      }
    }
  }

  override fun setCustomSignals(appName: String, customSignals: Map<String, Any?>, callback: (Result<Unit>) -> Unit) {
    val remoteConfig = getRemoteConfig(appName)
    setCustomSignals(remoteConfig, customSignals).addOnCompleteListener {task->
      if(task.isSuccessful){
        callback(Result.success(Unit))
      }
      else {
        handleFailure(callback, task.exception)
      }
    }
  }

  override fun getAll(appName: String, callback: (Result<Map<String, Any?>>) -> Unit) {
    val remoteConfig = getRemoteConfig(appName)
    callback(Result.success(parseParameters(remoteConfig.all)))
  }

  override fun getProperties(
    appName: String,
    callback: (Result<Map<String, Any>>) -> Unit
  ) {
    val remoteConfig = getRemoteConfig(appName)
    val configProperties = getConfigProperties(remoteConfig)
    callback(Result.success(configProperties))
  }
}
