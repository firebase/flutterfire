// Copyright 2025 The Chromium Authors. All rights reserved.
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
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.util.Objects

/** FlutterFirebaseCrashlyticsPlugin  */
class FlutterFirebaseCrashlyticsPlugin

  : FlutterFirebasePlugin, FlutterPlugin, CrashlyticsHostApi {
  private var channel: MethodChannel? = null
  private var messenger: BinaryMessenger? = null

  private fun initInstance(messenger: BinaryMessenger) {
    val channelName = "plugins.flutter.io/firebase_crashlytics"
    channel = MethodChannel(messenger, channelName)
    CrashlyticsHostApi.setUp(messenger, this)
    FlutterFirebasePluginRegistry.registerPlugin(channelName, this)
    this.messenger = messenger
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)

    checkNotNull(messenger)
    CrashlyticsHostApi.setUp(messenger!!, null)

    channel = null
    messenger = null
  }

  private fun crash() {
    Handler(Looper.myLooper()!!)
      .postDelayed(
        {
          throw FirebaseCrashlyticsTestCrash()
        },
        50
      )
  }

  /**
   * Extract StackTraceElement from Dart stack trace element.
   *
   * @param errorElement Map representing the parts of a Dart error.
   * @return Stack trace element to be used as part of an Exception stack trace.
   */
  private fun generateStackTraceElement(errorElement: Map<String, String>): StackTraceElement? {
    try {
      val fileName = errorElement[Constants.FILE]
      val lineNumber = errorElement[Constants.LINE]
      val className = errorElement[Constants.CLASS]
      val methodName = errorElement[Constants.METHOD]

      return StackTraceElement(
        className ?: "",
        methodName,
        fileName,
        lineNumber?.toInt() ?: 0
      )
    } catch (e: Exception) {
      Log.e(TAG, "Unable to generate stack trace element from Dart error.")
      return null
    }
  }

  private fun getCrashlyticsSharedPrefs(context: Context): SharedPreferences {
    return context.getSharedPreferences("com.google.firebase.crashlytics", 0)
  }

  // TODO remove once Crashlytics public API supports isCrashlyticsCollectionEnabled
  /**
   * Firebase Crashlytics SDK doesn't provide a way to read current enabled status. So we read it
   * ourselves from shared preferences instead.
   */
  private fun isCrashlyticsCollectionEnabled(app: FirebaseApp): Boolean {
    val enabled: Boolean
    val crashlyticsSharedPrefs =
      getCrashlyticsSharedPrefs(app.applicationContext)

    if (crashlyticsSharedPrefs.contains(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED)) {
      enabled = crashlyticsSharedPrefs.getBoolean(FIREBASE_CRASHLYTICS_COLLECTION_ENABLED, true)
    } else {
      val manifestEnabled =
        readCrashlyticsDataCollectionEnabledFromManifest(app.applicationContext)

      FirebaseCrashlytics.getInstance().isCrashlyticsCollectionEnabled = manifestEnabled
      enabled = manifestEnabled
    }

    return enabled
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val result = if (firebaseApp.name == "[DEFAULT]") {
          mapOf(
            Constants.IS_CRASHLYTICS_COLLECTION_ENABLED to isCrashlyticsCollectionEnabled(FirebaseApp.getInstance())
          )
        } else {
          emptyMap()
        }
        taskCompletionSource.setResult(result)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  companion object {
    const val TAG: String = "FLTFirebaseCrashlytics"
    private const val FIREBASE_CRASHLYTICS_COLLECTION_ENABLED =
      "firebase_crashlytics_collection_enabled"

    private fun readCrashlyticsDataCollectionEnabledFromManifest(
      applicationContext: Context
    ): Boolean {
      try {
        val packageManager = applicationContext.packageManager
        if (packageManager != null) {
          val applicationInfo =
            packageManager.getApplicationInfo(
              applicationContext.packageName, PackageManager.GET_META_DATA
            )
          if (applicationInfo.metaData != null && applicationInfo.metaData.containsKey(
              FIREBASE_CRASHLYTICS_COLLECTION_ENABLED
            )
          ) {
            return applicationInfo.metaData.getBoolean(
              FIREBASE_CRASHLYTICS_COLLECTION_ENABLED
            )
          }
        }
      } catch (e: PackageManager.NameNotFoundException) {
        // This shouldn't happen since it's this app's package, but fall through to default
        // if so.
        Logger.getLogger().e("Could not read data collection permission from manifest", e)
      }
      return true
    }
  }

  override fun recordError(arguments: Map<String, Any?>, callback: (Result<Unit>) -> Unit) {

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val crashlytics = FirebaseCrashlytics.getInstance()

        val dartExceptionMessage =
          Objects.requireNonNull(arguments[Constants.EXCEPTION]) as String
        val reason =
          arguments[Constants.REASON] as String?
        val information =
          Objects.requireNonNull(arguments[Constants.INFORMATION]) as String
        val fatal =
          Objects.requireNonNull(arguments[Constants.FATAL]) as Boolean
        val buildId =
          Objects.requireNonNull(arguments[Constants.BUILD_ID]) as String
        val loadingUnits =
          Objects.requireNonNull(arguments[Constants.LOADING_UNITS]) as List<String?>

        if (buildId.isNotEmpty()) {
          FlutterFirebaseCrashlyticsInternal.setFlutterBuildId(
            buildId
          )
        }

        FlutterFirebaseCrashlyticsInternal.setLoadingUnits(
          loadingUnits
        )

        val exception: Exception
        if (reason != null) {
          // Set a "reason" (to match iOS) to show where the exception was thrown.
          crashlytics.setCustomKey(
            Constants.FLUTTER_ERROR_REASON,
            "thrown $reason"
          )
          exception =
            FirebaseCrashlyticsFlutterError("$dartExceptionMessage. Error thrown $reason.")
        } else {
          exception = FirebaseCrashlyticsFlutterError(dartExceptionMessage)
        }

        crashlytics.setCustomKey(
          Constants.FLUTTER_ERROR_EXCEPTION,
          dartExceptionMessage
        )

        val elements: MutableList<StackTraceElement> =
          ArrayList()
        val errorElements =
          Objects.requireNonNull(arguments[Constants.STACK_TRACE_ELEMENTS]) as List<Map<String, String>>

        for (errorElement in errorElements) {
          val stackTraceElement = generateStackTraceElement(errorElement)
          if (stackTraceElement != null) {
            elements.add(stackTraceElement)
          }
        }
        exception.setStackTrace(elements.toTypedArray<StackTraceElement>())

        // Log information.
        if (information.isNotEmpty()) {
          crashlytics.log(information)
        }

        if (fatal) {
          FlutterFirebaseCrashlyticsInternal.recordFatalException(
            exception
          )
        } else {
          crashlytics.recordException(exception)
        }
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun setCustomKey(arguments: Map<String, Any?>, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val key =
          Objects.requireNonNull(arguments[Constants.KEY]) as String
        val value =
          Objects.requireNonNull(arguments[Constants.VALUE]) as String
        FirebaseCrashlytics.getInstance().setCustomKey(key, value)
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun setUserIdentifier(arguments: Map<String, Any?>, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val identifier =
          Objects.requireNonNull(arguments[Constants.IDENTIFIER]) as String
        FirebaseCrashlytics.getInstance().setUserId(identifier)
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun log(arguments: Map<String, Any?>, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val message =
          Objects.requireNonNull(arguments[Constants.MESSAGE]) as String
        FirebaseCrashlytics.getInstance().log(message)
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun setCrashlyticsCollectionEnabled(
    arguments: Map<String, Boolean>,
    callback: (Result<Map<String, Boolean>?>) -> Unit
  ) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val enabled =
          Objects.requireNonNull(arguments[Constants.ENABLED]) as Boolean
        FirebaseCrashlytics.getInstance().isCrashlyticsCollectionEnabled = enabled

        callback(Result.success(

          mapOf(
            Constants.IS_CRASHLYTICS_COLLECTION_ENABLED to
              isCrashlyticsCollectionEnabled(FirebaseApp.getInstance())
          )

        ))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun checkForUnsentReports(callback: (Result<Map<String, Any?>>) -> Unit) {

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val unsentReports =
          Tasks.await(
            FirebaseCrashlytics.getInstance().checkForUnsentReports()
          )

        callback(Result.success(mapOf(Constants.UNSENT_REPORTS to unsentReports)))
      } catch (e: Exception) {
       handleFailure(callback, e)
      }
    }
  }

  override fun sendUnsentReports(callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().sendUnsentReports()
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun deleteUnsentReports(callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        FirebaseCrashlytics.getInstance().deleteUnsentReports()
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun didCrashOnPreviousExecution(callback: (Result<Map<String, Any?>>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val didCrashOnPreviousExecution =
          FirebaseCrashlytics.getInstance().didCrashOnPreviousExecution()
        callback(Result.success(mapOf( Constants.DID_CRASH_ON_PREVIOUS_EXECUTION to
          didCrashOnPreviousExecution)))

      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun crash(callback: (Result<Unit>) -> Unit) {
    crash()
  }

  private fun <T> handleFailure(
    callback: (Result<T>) -> Unit,
    e: Exception
  ) {
    val message = e.message ?: "An unknown error occurred"
    callback(Result.failure(FlutterError("firebase_crashlytics", message, null)))
  }
}
