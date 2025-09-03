// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.performance

import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.firebase.FirebaseApp
import com.google.firebase.perf.FirebasePerformance
import com.google.firebase.perf.metrics.HttpMetric
import com.google.firebase.perf.metrics.Trace
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry

/**
 * Flutter plugin accessing Firebase Performance API.
 *
 *
 * Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
class FlutterFirebasePerformancePlugin
  : FlutterFirebasePlugin, FlutterPlugin, FirebasePerformanceHostApi {
  private var binaryMessenger: BinaryMessenger? = null

  private fun initInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(
      METHOD_CHANNEL_NAME,
      this
    )
    binaryMessenger = messenger
    FirebasePerformanceHostApi.setUp(messenger, this)
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    binaryMessenger = null
    FirebasePerformanceHostApi.setUp(binding.binaryMessenger, null)
  }

  override fun setPerformanceCollectionEnabled(enabled: Boolean, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        FirebasePerformance.getInstance().isPerformanceCollectionEnabled = enabled
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun isPerformanceCollectionEnabled(callback: (Result<Boolean>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val result = FirebasePerformance.getInstance().isPerformanceCollectionEnabled
        callback(Result.success(result))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun startTrace(name: String, callback: (Result<Long>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val trace = FirebasePerformance.getInstance().newTrace(name)
        trace.start()
        val traceHandle = _traceHandle++
        _traces[traceHandle] = trace
        callback(Result.success(traceHandle.toLong()))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun stopTrace(handle: Long, attributes: TraceAttributes, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val trace = _traces[handle.toInt()]
        if (trace == null) {
          callback(Result.success(Unit))
          return@execute
        }

        attributes.attributes?.forEach { (key, value) ->
          trace.putAttribute(key, value)
        }

        attributes.metrics?.forEach { (key, value) ->
          trace.putMetric(key, value)
        }

        trace.stop()
        _traces.remove(handle.toInt())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun startHttpMetric(options: HttpMetricOptions, callback: (Result<Long>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val httpMethod = parseHttpMethod(options.httpMethod)
        val httpMetric = FirebasePerformance.getInstance().newHttpMetric(
          options.url,
          httpMethod
        )
        httpMetric.start()
        val httpMetricHandle = _httpMetricHandle++
        _httpMetrics[httpMetricHandle] = httpMetric
        callback(Result.success(httpMetricHandle.toLong()))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  override fun stopHttpMetric(handle: Long, attributes: HttpMetricAttributes, callback: (Result<Unit>) -> Unit) {
    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        val httpMetric = _httpMetrics[handle.toInt()]
        if (httpMetric == null) {
          callback(Result.success(Unit))
          return@execute
        }

        attributes.httpResponseCode?.let { httpMetric.setHttpResponseCode(it.toInt()) }
        attributes.requestPayloadSize?.let { httpMetric.setRequestPayloadSize(it) }
        attributes.responseContentType?.let { httpMetric.setResponseContentType(it) }
        attributes.responsePayloadSize?.let { httpMetric.setResponsePayloadSize(it) }

        attributes.attributes?.forEach { (key, value) ->
          httpMetric.putAttribute(key, value)
        }

        httpMetric.stop()
        _httpMetrics.remove(handle.toInt())
        callback(Result.success(Unit))
      } catch (e: Exception) {
        handleFailure(callback, e)
      }
    }
  }

  private fun <T> handleFailure (callback: (Result<T>) -> Unit, exception: Exception?) {
    val message =
      if (exception != null) exception.message else "An unknown error occurred"
    callback(Result.failure(FlutterError("firebase_performance", message, null)))
  }

  override fun getPluginConstantsForFirebaseApp(firebaseApp: FirebaseApp): Task<Map<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<Map<String, Any>>()

    FlutterFirebasePlugin.cachedThreadPool.execute {
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

    FlutterFirebasePlugin.cachedThreadPool.execute {
      try {
        for (trace in _traces.values) {
          trace.stop()
        }
        _traces.clear()
        for (httpMetric in _httpMetrics.values) {
          httpMetric.stop()
        }
        _httpMetrics.clear()

        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  companion object {
    private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_performance"

    val _httpMetrics: HashMap<Int, HttpMetric> = HashMap()
    val _traces: HashMap<Int, Trace> = HashMap()
    var _traceHandle: Int = 0
    var _httpMetricHandle: Int = 0

    private fun parseHttpMethod(httpMethod: HttpMethod): String {
      return when (httpMethod) {
        HttpMethod.CONNECT -> FirebasePerformance.HttpMethod.CONNECT
        HttpMethod.DELETE -> FirebasePerformance.HttpMethod.DELETE
        HttpMethod.GET -> FirebasePerformance.HttpMethod.GET
        HttpMethod.HEAD -> FirebasePerformance.HttpMethod.HEAD
        HttpMethod.OPTIONS -> FirebasePerformance.HttpMethod.OPTIONS
        HttpMethod.PATCH -> FirebasePerformance.HttpMethod.PATCH
        HttpMethod.POST -> FirebasePerformance.HttpMethod.POST
        HttpMethod.PUT -> FirebasePerformance.HttpMethod.PUT
        HttpMethod.TRACE -> FirebasePerformance.HttpMethod.TRACE
      }
    }
  }
}
