// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import com.google.firebase.functions.FirebaseFunctionsException
import java.io.IOException
import java.net.SocketTimeoutException
import java.util.concurrent.Executor
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class StreamResponseSubscriberTest {
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

  // PublisherStream reports an error event from the function as INTERNAL, with the decoded error
  // as details and its toString() as message.
  private fun streamErrorEvent(error: Map<String, Any?>) =
      TestFunctionsExceptions.create(
          error.toString(), FirebaseFunctionsException.Code.INTERNAL, error, null)

  @Test
  fun onError_reportsTheCodeAndMessageTheFunctionSent() {
    subscriber.onError(
        streamErrorEvent(
            mapOf(
                "status" to "INVALID_ARGUMENT",
                "message" to "Invalid test requested.",
                "details" to mapOf("field" to "type"))))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "Invalid test requested.",
                mapOf(
                    "code" to "invalid-argument",
                    "message" to "Invalid test requested.",
                    "additionalData" to mapOf("field" to "type"))),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onError_reportsAnUnknownStatusAsInternal() {
    subscriber.onError(
        streamErrorEvent(
            mapOf(
                "status" to "NOT_A_CODE",
                "message" to "Something went wrong.",
                "details" to mapOf("field" to "type"))))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "INTERNAL",
                mapOf("code" to "internal", "message" to "INTERNAL")),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onError_keepsTheMessageWhenTheFunctionSentNoStatus() {
    subscriber.onError(streamErrorEvent(mapOf("message" to "Something went wrong.")))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "Something went wrong.",
                mapOf("code" to "internal", "message" to "Something went wrong.")),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onError_usesTheCodeNameWhenTheFunctionSentNoMessage() {
    subscriber.onError(streamErrorEvent(mapOf("status" to "NOT_FOUND")))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "NOT_FOUND",
                mapOf("code" to "not-found", "message" to "NOT_FOUND")),
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

  // PublisherStream reports an error while reading the stream as INTERNAL, with the error as
  // details rather than as cause.
  private fun streamReadError(message: String, error: Throwable) =
      TestFunctionsExceptions.create(message, FirebaseFunctionsException.Code.INTERNAL, error, null)

  @Test
  fun onError_mapsStreamReadFailuresLikeNetworkErrors() {
    subscriber.onError(
        streamReadError("unexpected end of stream", IOException("unexpected end of stream")))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "unexpected end of stream",
                mapOf("code" to "unavailable", "message" to "UNAVAILABLE")),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onError_mapsStreamReadTimeoutsToDeadlineExceeded() {
    subscriber.onError(streamReadError("timeout", SocketTimeoutException("timeout")))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "timeout",
                mapOf("code" to "deadline-exceeded", "message" to "DEADLINE_EXCEEDED")),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onError_doesNotSendTheErrorBehindInvalidJson() {
    subscriber.onError(streamReadError("Invalid JSON: {", IllegalStateException("Unterminated")))

    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                "Invalid JSON: {",
                mapOf("code" to "internal", "message" to "Invalid JSON: {")),
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
