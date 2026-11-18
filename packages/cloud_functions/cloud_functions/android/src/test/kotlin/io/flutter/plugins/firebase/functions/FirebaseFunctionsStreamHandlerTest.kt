// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class FirebaseFunctionsStreamHandlerTest {
  private val eventSink = RecordingEventSink()
  private val handler = FirebaseFunctionsStreamHandler(TestFirebaseFunctions.create())

  // Sets neither functionName nor functionUri, so the stream fails before subscribing.
  private val invalidArguments = mapOf("limitedUseAppCheckToken" to false)

  @Test
  fun onListen_setupFailureSendsErrorThenEndsStream() {
    handler.onListen(invalidArguments, eventSink)

    val message = "Either functionName or functionUri must be set"
    assertEquals(
        listOf(
            listOf(
                "error",
                "firebase_functions",
                message,
                mapOf("code" to "unknown", "message" to message)),
            listOf("endOfStream")),
        eventSink.events)
  }

  @Test
  fun onCancel_afterSetupFailureDoesNotThrow() {
    handler.onListen(invalidArguments, eventSink)

    handler.onCancel(invalidArguments)
  }
}
