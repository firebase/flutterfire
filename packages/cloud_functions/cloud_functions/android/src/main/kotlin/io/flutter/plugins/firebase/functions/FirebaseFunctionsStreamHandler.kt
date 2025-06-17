// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import android.net.Uri
import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.functions.HttpsCallableOptions
import com.google.firebase.functions.HttpsCallableReference
import com.google.firebase.functions.StreamResponse
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import org.reactivestreams.Publisher
import java.net.URL
import java.util.Objects
import java.util.concurrent.TimeUnit

class FirebaseFunctionsStreamHandler(private val firebaseFunctions: FirebaseFunctions) :
  EventChannel.StreamHandler {
  private var subscriber: StreamResponseSubscriber? = null

  override fun onListen(arguments: Any, events: EventSink) {
    val argumentsMap = arguments as Map<String, Any>
    httpsStreamCall(argumentsMap, events)
  }

  override fun onCancel(arguments: Any) {
    subscriber!!.cancel()
  }

  private fun httpsStreamCall(arguments: Map<String, Any>, events: EventSink) {
    try {
      val functionName = arguments["functionName"] as String?
      val functionUri = arguments["functionUri"] as String?
      val origin = arguments["origin"] as String?
      val timeout = arguments["timeout"] as Int?
      val parameters = arguments["parameters"]
      val limitedUseAppCheckToken =
        Objects.requireNonNull(arguments["limitedUseAppCheckToken"]) as Boolean

      if (origin != null) {
        val originUri = Uri.parse(origin)
        firebaseFunctions.useEmulator(originUri.host!!, originUri.port)
      }

      val httpsCallableReference: HttpsCallableReference
      val options: HttpsCallableOptions =HttpsCallableOptions.Builder()
          .setLimitedUseAppCheckTokens(limitedUseAppCheckToken)
          .build()

      val publisher: Publisher<StreamResponse>
      if (functionName != null) {
        httpsCallableReference = firebaseFunctions.getHttpsCallable(functionName, options)
        publisher = httpsCallableReference.stream(parameters)
      } else if (functionUri != null) {
        httpsCallableReference =
          firebaseFunctions.getHttpsCallableFromUrl(URL(functionUri), options)
        publisher = httpsCallableReference.stream()
      } else {
        throw IllegalArgumentException("Either functionName or functionUri must be set")
      }

      if (timeout != null) {
        httpsCallableReference.setTimeout(timeout.toLong(), TimeUnit.MILLISECONDS)
      }
      subscriber = StreamResponseSubscriber(events)
      publisher.subscribe(subscriber)
    } catch (e: Exception) {
      events.error("firebase_functions", e.message, null)
    }
  }
}
