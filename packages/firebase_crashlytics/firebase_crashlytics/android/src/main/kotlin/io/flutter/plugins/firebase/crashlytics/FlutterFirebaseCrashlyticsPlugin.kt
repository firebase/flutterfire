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
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import io.flutter.plugins.firebase.crashlytics.generated.CrashlyticsStackFrame
import io.flutter.plugins.firebase.crashlytics.generated.FirebaseCrashlyticsHostApi
import io.flutter.plugins.firebase.crashlytics.generated.FlutterError as PigeonFlutterError
import io.flutter.plugins.firebase.crashlytics.generated.RecordErrorRequest

/** FlutterFirebaseCrashlyticsPlugin */
class FlutterFirebaseCrashlyticsPlugin :
    FlutterFirebasePlugin, FlutterPlugin, FirebaseCrashlyticsHostApi, EventChannel.StreamHandler {
  private var binaryMessenger: BinaryMessenger? = null
  private var testEventChannel: EventChannel? = null
  private var testEventSink: EventChannel.EventSink? = null
  private lateinit var applicationContext: Context

  // Cached ELF build ID read from libapp.so at startup. This is the build ID that the
  // firebase-crashlytics-buildtools JAR extracts from .symbols files during upload, so using
  // it ensures crash reports match uploaded symbols (even when the Dart VM's internal snapshot
  // build ID differs, which happens with AAB + flavor + obfuscation builds).
  private var elfBuildId: String? = null

  private fun initInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(CHANNEL_NAME, this)
    binaryMessenger = messenger
    FirebaseCrashlyticsHostApi.setUp(messenger, this)
    testEventChannel =
        EventChannel(messenger, TEST_EVENT_CHANNEL_NAME).also { it.setStreamHandler(this) }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = binding.applicationContext
    elfBuildId = ElfBuildIdReader.readBuildId(applicationContext)
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    FirebaseCrashlyticsHostApi.setUp(binding.binaryMessenger, null)
    binaryMessenger = null
    testEventChannel?.setStreamHandler(null)
    testEventChannel = null
  }

  override fun checkForUnsentReports(callback: (Result<Boolean>) -> Unit) {
    cachedThreadPool.execute {
      try {
        val unsentReports = Tasks.await(FirebaseCrashlytics.getInstance().checkForUnsentReports())
        callback(Result.success(unsentReports))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun crash(callback: (Result<Unit>) -> Unit) {
    Handler(Looper.myLooper()!!).postDelayed({ throw FirebaseCrashlyticsTestCrash() }, 50)
  }

  override fun deleteUnsentReports(callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().deleteUnsentReports()
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun didCrashOnPreviousExecution(callback: (Result<Boolean>) -> Unit) {
    cachedThreadPool.execute {
      try {
        val didCrash = FirebaseCrashlytics.getInstance().didCrashOnPreviousExecution()
        callback(Result.success(didCrash))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun recordError(request: RecordErrorRequest, callback: (Result<Unit>) -> Unit) {
    val mainHandler = Handler(Looper.getMainLooper())
    cachedThreadPool.execute {
      try {
        val crashlytics = FirebaseCrashlytics.getInstance()
        val dartExceptionMessage = request.exception
        val reason = request.reason
        val information = request.information
        val fatal = request.fatal
        val dartBuildId = request.buildId
        val loadingUnits = request.loadingUnits

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
        exception.stackTrace =
            request.stackTraceElements.mapNotNull(::generateStackTraceElement).toTypedArray()

        if (information.isNotEmpty()) {
          crashlytics.log(information)
        }
        if (fatal) {
          FlutterFirebaseCrashlyticsInternal.recordFatalException(exception)
        } else {
          crashlytics.recordException(exception)
        }
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun log(message: String, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().log(message)
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun sendUnsentReports(callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().sendUnsentReports()
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun setCrashlyticsCollectionEnabled(
      enabled: Boolean,
      callback: (Result<Boolean>) -> Unit
  ) {
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().setCrashlyticsCollectionEnabled(enabled)
        callback(Result.success(isCrashlyticsCollectionEnabled(FirebaseApp.getInstance())))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun setUserIdentifier(identifier: String, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().setUserId(identifier)
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  override fun setCustomKey(key: String, value: String, callback: (Result<Unit>) -> Unit) {
    cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        callback(Result.success(Unit))
      } catch (exception: Exception) {
        handleFailure(callback, exception)
      }
    }
  }

  private fun <T> handleFailure(callback: (Result<T>) -> Unit, exception: Exception?) {
    val message = exception?.message ?: "An unknown error occurred"
    callback(Result.failure(PigeonFlutterError("firebase_crashlytics", message, null)))
  }

  /** Extracts a StackTraceElement from a Dart stack trace element. */
  private fun generateStackTraceElement(errorElement: CrashlyticsStackFrame): StackTraceElement? =
      try {
        StackTraceElement(
            errorElement.className ?: "",
            errorElement.method,
            errorElement.file,
            errorElement.line.toInt())
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
