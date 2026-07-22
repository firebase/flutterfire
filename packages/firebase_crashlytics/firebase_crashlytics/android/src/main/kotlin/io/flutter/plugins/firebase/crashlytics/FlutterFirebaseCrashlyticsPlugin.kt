// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics

import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.crashlytics.FlutterFirebaseCrashlyticsInternal
import com.google.firebase.crashlytics.internal.Logger
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry

/** FlutterFirebaseCrashlyticsPlugin */
class FlutterFirebaseCrashlyticsPlugin :
    FlutterFirebasePlugin,
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {
  private var channel: MethodChannel? = null
  private var testEventChannel: EventChannel? = null
  private var testEventSink: EventChannel.EventSink? = null
  private lateinit var applicationContext: Context

  // Cached ELF build ID read from libapp.so at startup. This is the build ID that the
  // firebase-crashlytics-buildtools JAR extracts from .symbols files during upload, so using
  // it ensures crash reports match uploaded symbols (even when the Dart VM's internal snapshot
  // build ID differs, which happens with AAB + flavor + obfuscation builds).
  private var elfBuildId: String? = null

  private fun initInstance(messenger: BinaryMessenger) {
    channel = MethodChannel(messenger, CHANNEL_NAME).also { it.setMethodCallHandler(this) }
    FlutterFirebasePluginRegistry.registerPlugin(CHANNEL_NAME, this)
    testEventChannel =
        EventChannel(messenger, TEST_EVENT_CHANNEL_NAME).also { it.setStreamHandler(this) }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = binding.applicationContext
    elfBuildId = ElfBuildIdReader.readBuildId(applicationContext)
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
    testEventChannel?.setStreamHandler(null)
    testEventChannel = null
  }

  private fun checkForUnsentReports(): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()
    cachedThreadPool.execute {
      try {
        val unsentReports = Tasks.await(FirebaseCrashlytics.getInstance().checkForUnsentReports())
        taskCompletionSource.setResult(mapOf(Constants.UNSENT_REPORTS to unsentReports))
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun crash() {
    Handler(Looper.myLooper()!!).postDelayed({ throw FirebaseCrashlyticsTestCrash() }, 50)
  }

  private fun deleteUnsentReports(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().deleteUnsentReports()
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun didCrashOnPreviousExecution(): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()
    cachedThreadPool.execute {
      try {
        val didCrash = FirebaseCrashlytics.getInstance().didCrashOnPreviousExecution()
        taskCompletionSource.setResult(mapOf(Constants.DID_CRASH_ON_PREVIOUS_EXECUTION to didCrash))
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun recordError(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    val mainHandler = Handler(Looper.getMainLooper())
    cachedThreadPool.execute {
      try {
        val crashlytics = FirebaseCrashlytics.getInstance()
        val dartExceptionMessage = arguments[Constants.EXCEPTION]!! as String
        val reason = arguments[Constants.REASON] as String?
        val information = arguments[Constants.INFORMATION]!! as String
        val fatal = arguments[Constants.FATAL]!! as Boolean
        val dartBuildId = arguments[Constants.BUILD_ID]!! as String
        @Suppress("UNCHECKED_CAST")
        val loadingUnits = arguments[Constants.LOADING_UNITS]!! as List<String>

        // Prefer the ELF build ID from libapp.so over the Dart VM's snapshot build ID.
        // The firebase-crashlytics-buildtools JAR uses the ELF build ID when uploading symbols,
        // so we must report the same ID for Crashlytics to match them.
        val effectiveBuildId = elfBuildId ?: dartBuildId
        if (effectiveBuildId.isNotEmpty()) {
          FlutterFirebaseCrashlyticsInternal.setFlutterBuildId(effectiveBuildId)
        }
        FlutterFirebaseCrashlyticsInternal.setLoadingUnits(loadingUnits)

        val exception =
            if (reason != null) {
              val crashlyticsErrorReason = "thrown $reason"
              testEventSink?.let { sink ->
                mainHandler.post { sink.success(crashlyticsErrorReason) }
              }
              crashlytics.setCustomKey(Constants.FLUTTER_ERROR_REASON, crashlyticsErrorReason)
              FlutterError("$dartExceptionMessage. Error thrown $reason.")
            } else {
              FlutterError(dartExceptionMessage)
            }

        crashlytics.setCustomKey(Constants.FLUTTER_ERROR_EXCEPTION, dartExceptionMessage)
        @Suppress("UNCHECKED_CAST")
        val errorElements = arguments[Constants.STACK_TRACE_ELEMENTS]!! as List<Map<String, String>>
        exception.stackTrace = errorElements.mapNotNull(::generateStackTraceElement).toTypedArray()

        if (information.isNotEmpty()) {
          crashlytics.log(information)
        }
        if (fatal) {
          FlutterFirebaseCrashlyticsInternal.recordFatalException(exception)
        } else {
          crashlytics.recordException(exception)
        }
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun log(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      try {
        val message = arguments[Constants.MESSAGE]!! as String
        FirebaseCrashlytics.getInstance().log(message)
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun sendUnsentReports(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().sendUnsentReports()
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun setCrashlyticsCollectionEnabled(arguments: Map<String, Any>): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()
    cachedThreadPool.execute {
      try {
        val enabled = arguments[Constants.ENABLED]!! as Boolean
        FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(enabled)
        taskCompletionSource.setResult(
            mapOf(
                Constants.IS_CRASHLYTICS_COLLECTION_ENABLED to
                    isCrashlyticsCollectionEnabled(FirebaseApp.getInstance())))
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun setUserIdentifier(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      try {
        val identifier = arguments[Constants.IDENTIFIER]!! as String
        FirebaseCrashlytics.getInstance().setUserId(identifier)
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  private fun setCustomKey(arguments: Map<String, Any>): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      try {
        val key = arguments[Constants.KEY]!! as String
        val value = arguments[Constants.VALUE]!! as String
        FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val task: Task<*> =
        when (call.method) {
          "Crashlytics#checkForUnsentReports" -> checkForUnsentReports()
          "Crashlytics#crash" -> {
            crash()
            return
          }
          "Crashlytics#deleteUnsentReports" -> deleteUnsentReports()
          "Crashlytics#didCrashOnPreviousExecution" -> didCrashOnPreviousExecution()
          "Crashlytics#recordError" -> recordError(call.arguments<Map<String, Any>>()!!)
          "Crashlytics#log" -> log(call.arguments<Map<String, Any>>()!!)
          "Crashlytics#sendUnsentReports" -> sendUnsentReports()
          "Crashlytics#setCrashlyticsCollectionEnabled" ->
              setCrashlyticsCollectionEnabled(call.arguments<Map<String, Any>>()!!)
          "Crashlytics#setUserIdentifier" -> setUserIdentifier(call.arguments<Map<String, Any>>()!!)
          "Crashlytics#setCustomKey" -> setCustomKey(call.arguments<Map<String, Any>>()!!)
          else -> {
            result.notImplemented()
            return
          }
        }

    task.addOnCompleteListener { completedTask ->
      if (completedTask.isSuccessful) {
        result.success(completedTask.result)
      } else {
        val message = completedTask.exception?.message ?: "An unknown error occurred"
        result.error("firebase_crashlytics", message, null)
      }
    }
  }

  /** Extracts a StackTraceElement from a Dart stack trace element. */
  private fun generateStackTraceElement(errorElement: Map<String, String>): StackTraceElement? =
      try {
        StackTraceElement(
            errorElement[Constants.CLASS] ?: "",
            errorElement[Constants.METHOD],
            errorElement[Constants.FILE],
            errorElement[Constants.LINE]!!.toInt())
      } catch (_: Exception) {
        Log.e(TAG, "Unable to generate stack trace element from Dart error.")
        null
      }

  private fun getCrashlyticsSharedPrefs(context: Context): SharedPreferences =
      context.getSharedPreferences("com.google.firebase.crashlytics", 0)

  // TODO remove once Crashlytics public API supports isCrashlyticsCollectionEnabled
  private fun isCrashlyticsCollectionEnabled(app: FirebaseApp): Boolean {
    val sharedPreferences = getCrashlyticsSharedPrefs(app.applicationContext)
    if (sharedPreferences.contains(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED)) {
      return sharedPreferences.getBoolean(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED, true)
    }

    val manifestEnabled = readCrashlyticsDataCollectionEnabledFromManifest(app.applicationContext)
    FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(manifestEnabled)
    return manifestEnabled
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()
    cachedThreadPool.execute {
      try {
        val constants = HashMap<String, Any>()
        if (firebaseApp.name == "[DEFAULT]") {
          constants[Constants.IS_CRASHLYTICS_COLLECTION_ENABLED] =
              isCrashlyticsCollectionEnabled(FirebaseApp.getInstance())
        }
        taskCompletionSource.setResult(constants)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()
    cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(null)
      } catch (exception: Exception) {
        taskCompletionSource.setException(exception)
      }
    }
    return taskCompletionSource.task
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    testEventSink = events
  }

  override fun onCancel(arguments: Any?) {
    testEventSink = null
  }

  companion object {
    const val TAG = "FLTFirebaseCrashlytics"
    private const val CHANNEL_NAME = "plugins.flutter.io/firebase_crashlytics"
    private const val TEST_EVENT_CHANNEL_NAME =
        "plugins.flutter.io/firebase_crashlytics_test_stream"
    private const val FIREBASE_CRASHLYTICS_COLLECTION_ENABLED =
        "firebase_crashlytics_collection_enabled"

    private fun readCrashlyticsDataCollectionEnabledFromManifest(
        applicationContext: Context
    ): Boolean {
      try {
        val packageManager = applicationContext.packageManager
        val applicationInfo =
            packageManager.getApplicationInfo(
                applicationContext.packageName, PackageManager.GET_META_DATA)
        val metadata = applicationInfo.metaData
        if (metadata != null && metadata.containsKey(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED)) {
          return metadata.getBoolean(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED)
        }
      } catch (exception: PackageManager.NameNotFoundException) {
        Logger.getLogger().e("Could not read data collection permission from manifest", exception)
      }
      return true
    }
  }
}
