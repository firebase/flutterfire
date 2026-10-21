// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import android.os.Handler
import android.os.Looper
import com.google.firebase.functions.StreamResponse
import io.flutter.plugin.common.EventChannel.EventSink
import java.util.concurrent.Executor
import org.reactivestreams.Subscriber
import org.reactivestreams.Subscription

class StreamResponseSubscriber(
    private val eventSink: EventSink?,
    // Injectable so unit tests can run the posted events without a main Looper.
    private val mainThreadExecutor: Executor = mainThreadHandlerExecutor(),
) : Subscriber<StreamResponse> {
  private var subscription: Subscription? = null

  override fun onSubscribe(s: Subscription) {
    this.subscription = s
    subscription!!.request(Long.MAX_VALUE)
  }

  override fun onNext(streamResponse: StreamResponse) {
    val responseMap: MutableMap<String, Any?> = HashMap()
    if (streamResponse is StreamResponse.Message) {
      val message: Any? = (streamResponse).message.data
      responseMap["message"] = message
      mainThreadExecutor.execute { eventSink!!.success(responseMap) }
    } else {
      val result: Any? = (streamResponse as StreamResponse.Result).result.data
      responseMap["result"] = result
      mainThreadExecutor.execute { eventSink!!.success(responseMap) }
    }
  }

  override fun onError(t: Throwable) {
    if (eventSink != null) {
      mainThreadExecutor.execute {
        eventSink.error(
            "firebase_functions", t.message, FlutterFirebaseFunctionsPlugin.getExceptionDetails(t))
        eventSink.endOfStream()
      }
    }
  }

  override fun onComplete() {
    if (eventSink != null) {
      mainThreadExecutor.execute { eventSink.endOfStream() }
    }
  }

  fun cancel() {
    if (subscription != null) {
      subscription!!.cancel()
    }
  }
}

private fun mainThreadHandlerExecutor(): Executor {
  val handler = Handler(Looper.getMainLooper())
  return Executor { handler.post(it) }
}
