// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import android.net.Uri
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.functions.FirebaseFunctionsException
import com.google.firebase.functions.HttpsCallableOptions
import com.google.firebase.functions.HttpsCallableReference
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import java.io.IOException
import java.io.InterruptedIOException
import java.net.URL
import java.util.Locale
import java.util.Objects
import java.util.concurrent.TimeUnit

class FlutterFirebaseFunctionsPlugin

  : FlutterPlugin, FlutterFirebasePlugin, CloudFunctionsHostApi {
  private var channel: MethodChannel? = null
  private var pluginBinding: FlutterPluginBinding? = null
  private var messenger: BinaryMessenger? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    pluginBinding = binding
    messenger = binding.binaryMessenger
    channel = MethodChannel(messenger!!, METHOD_CHANNEL_NAME)
    CloudFunctionsHostApi.setUp(messenger!!, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    checkNotNull(messenger)
    CloudFunctionsHostApi.setUp(messenger!!, null)
    channel = null
    messenger = null
  }

  private fun getFunctions(arguments: Map<String, Any>): FirebaseFunctions {
    val appName = Objects.requireNonNull(arguments["appName"]) as String
    val region = Objects.requireNonNull(arguments["region"]) as String
    val app = FirebaseApp.getInstance(appName)
    return FirebaseFunctions.getInstance(app, region)
  }

  private fun httpsFunctionCall(arguments: Map<String, Any>): Task<Any> {
    val taskCompletionSource = TaskCompletionSource<Any>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val firebaseFunctions = getFunctions(arguments)

        val functionName = arguments["functionName"] as String?
        val functionUri = arguments["functionUri"] as String?
        val origin = arguments["origin"] as String?
        val timeout = (arguments["timeout"] as Number?)?.toInt()
        val limitedUseAppCheckToken =
          Objects.requireNonNull(arguments["limitedUseAppCheckToken"]) as Boolean
        val parameters = arguments["parameters"]

        if (origin != null) {
          val originUri = Uri.parse(origin)
          firebaseFunctions.useEmulator(originUri.host!!, originUri.port)
        }

        val httpsCallableReference: HttpsCallableReference
        val options: HttpsCallableOptions =
          HttpsCallableOptions.Builder()
            .setLimitedUseAppCheckTokens(limitedUseAppCheckToken)
            .build()

        httpsCallableReference = if (functionName != null) {
          firebaseFunctions.getHttpsCallable(functionName, options)
        } else if (functionUri != null) {
          firebaseFunctions.getHttpsCallableFromUrl(URL(functionUri), options)
        } else {
          throw IllegalArgumentException("Either functionName or functionUri must be set")
        }

        if (timeout != null) {
          httpsCallableReference.setTimeout(
            timeout.toLong(),
            TimeUnit.MILLISECONDS
          )
        }

        val result = Tasks.await(httpsCallableReference.call(parameters))
        taskCompletionSource.setResult(result.data)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun getExceptionDetails(exception: Exception?): Map<String, Any?> {
    val details: MutableMap<String, Any?> = HashMap()

    if (exception == null) {
      return details
    }

    var code = "UNKNOWN"
    var message = exception.message
    var additionalData: Any? = null

    if (exception.cause is FirebaseFunctionsException) {
      val functionsException =
        exception.cause as FirebaseFunctionsException?
      code = functionsException!!.code.name
      message = functionsException.message
      additionalData = functionsException.details

      if (functionsException.cause is IOException
        && "Canceled" == (functionsException.cause as IOException).message
      ) {
        // return DEADLINE_EXCEEDED for IOException cancel errors, to match iOS & Web
        code = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name
        message = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name
      } else if (functionsException.cause is InterruptedIOException // return DEADLINE_EXCEEDED for InterruptedIOException errors, to match iOS & Web
        && "timeout" == (functionsException.cause as InterruptedIOException).message
      ) {
        code = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name
        message = FirebaseFunctionsException.Code.DEADLINE_EXCEEDED.name
      } else if (functionsException.cause is IOException) {
        // return UNAVAILABLE for network io errors, to match iOS & Web
        code = FirebaseFunctionsException.Code.UNAVAILABLE.name
        message = FirebaseFunctionsException.Code.UNAVAILABLE.name
      }
    }

    details["code"] = code.replace("_", "-").lowercase(Locale.getDefault())
    details["message"] = message

    if (additionalData != null) {
      details["additionalData"] = additionalData
    }

    return details
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

    FlutterFirebasePlugin.cachedThreadPool.execute { taskCompletionSource.setResult(null) }

    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    FlutterFirebasePlugin.cachedThreadPool.execute { taskCompletionSource.setResult(null) }

    return taskCompletionSource.task
  }

  companion object {
    private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_functions"
  }

  override fun call(arguments: Map<String, Any?>, callback: (Result<Any?>) -> Unit) {
    httpsFunctionCall(arguments as Map<String, Any>)
      .addOnCompleteListener { task ->
        if (task.isSuccessful){
          callback(Result.success(task.result))
        }
        else {
          val exception = task.exception
          callback(Result.failure(FlutterError(
            "firebase_functions",
            exception?.message,
            getExceptionDetails(exception)
          )))
        }

    }
  }

  override fun registerEventChannel(arguments: Map<String, Any>, callback: (Result<Unit>) -> Unit) {
    val eventId = Objects.requireNonNull(arguments["eventChannelId"]) as String
    val eventChannelName = "$METHOD_CHANNEL_NAME/$eventId"
    val eventChannel =
      EventChannel(pluginBinding!!.binaryMessenger, eventChannelName)
    val functions = getFunctions(arguments)
    val streamHandler = FirebaseFunctionsStreamHandler(functions)
    eventChannel.setStreamHandler(streamHandler)
    callback(Result.success(Unit))
  }
}
