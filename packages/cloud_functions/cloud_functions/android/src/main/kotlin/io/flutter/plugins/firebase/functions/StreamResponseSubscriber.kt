// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import android.os.Handler
import android.os.Looper
import com.google.firebase.functions.StreamResponse
import io.flutter.plugin.common.EventChannel.EventSink
import org.reactivestreams.Subscriber
import org.reactivestreams.Subscription

class StreamResponseSubscriber(private val eventSink: EventSink?) :
  Subscriber<StreamResponse> {
  private var subscription: Subscription? = null

  private val mainThreadHandler = Handler(Looper.getMainLooper())

  override fun onSubscribe(s: Subscription) {
    this.subscription = s
    subscription!!.request(Long.MAX_VALUE)
  }

  override fun onNext(streamResponse: StreamResponse) {
    val responseMap: MutableMap<String, Any?> = HashMap()
    if (streamResponse is StreamResponse.Message) {
      val message: Any? = (streamResponse).message.data
      responseMap["message"] = message
      mainThreadHandler.post { eventSink!!.success(responseMap) }
    } else {
      val result: Any? = (streamResponse as StreamResponse.Result).result.data
      responseMap["result"] = result
      mainThreadHandler.post { eventSink!!.success(responseMap) }
    }
  }

  override fun onError(t: Throwable) {
    if (eventSink != null) {
      mainThreadHandler.post { eventSink.endOfStream() }
    }
  }

  override fun onComplete() {
    if (eventSink != null) {
      mainThreadHandler.post { eventSink.endOfStream() }
    }
  }

  fun cancel() {
    if (subscription != null) {
      subscription!!.cancel()
    }
  }
}
