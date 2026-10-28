// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.StandardMethodCodec

/**
 * Records the events sent to it, in order. Encodes them first, as EventChannel does, so a value the
 * codec can't send fails the test instead of crashing the app.
 */
class RecordingEventSink : EventSink {
  val events = mutableListOf<List<Any?>>()

  override fun success(event: Any?) {
    StandardMethodCodec.INSTANCE.encodeSuccessEnvelope(event)
    events.add(listOf("success", event))
  }

  override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
    StandardMethodCodec.INSTANCE.encodeErrorEnvelope(errorCode!!, errorMessage, errorDetails)
    events.add(listOf("error", errorCode, errorMessage, errorDetails))
  }

  override fun endOfStream() {
    events.add(listOf("endOfStream"))
  }
}
