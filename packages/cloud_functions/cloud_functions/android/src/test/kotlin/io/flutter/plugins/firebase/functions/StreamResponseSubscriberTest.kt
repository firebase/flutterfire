// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import com.google.firebase.functions.FirebaseFunctionsException
import io.flutter.plugin.common.EventChannel.EventSink
import java.io.IOException
import java.util.concurrent.Executor
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class StreamResponseSubscriberTest {
  private class RecordingEventSink : EventSink {
    val events = mutableListOf<List<Any?>>()

    override fun success(event: Any?) {
      events.add(listOf("success", event))
    }

    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
      events.add(listOf("error", errorCode, errorMessage, errorDetails))
    }

    override fun endOfStream() {
      events.add(listOf("endOfStream"))
    }
  }

  private val eventSink = RecordingEventSink()
  private val subscriber = StreamResponseSubscriber(eventSink, Executor { it.run() })

  @Test
  fun onError_sendsFunctionsErrorThenEndsStream() {
    val message = "The function must be called while authenticated."

    subscriber.onError(
        TestFunctionsExceptions.create(
            message, FirebaseFunctionsException.Code.UNAUTHENTICATED, mapOf("foo" to "bar"), null))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                message,
                mapOf(
                    "code" to "unauthenticated",
                    "message" to message,
                    "additionalData" to mapOf("foo" to "bar"))),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onError_mapsNetworkFailuresLikeCallableErrors() {
    subscriber.onError(
        TestFunctionsExceptions.create(
            "INTERNAL",
            FirebaseFunctionsException.Code.INTERNAL,
            null,
            IOException("Failed to connect")))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "INTERNAL",
                mapOf("code" to "unavailable", "message" to "UNAVAILABLE")),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onError_reportsOtherThrowablesAsUnknown() {
    subscriber.onError(IllegalStateException("boom"))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "boom",
                mapOf("code" to "unknown", "message" to "boom")),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onComplete_endsStream() {
    subscriber.onComplete()

    assertEquals(listOf(listOf<Any?>("endOfStream")), eventSink.events)
  }
}
