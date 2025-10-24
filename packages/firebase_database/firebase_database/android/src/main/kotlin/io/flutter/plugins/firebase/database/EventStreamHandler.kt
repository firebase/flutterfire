/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import com.google.firebase.database.ChildEventListener
import com.google.firebase.database.Query
import com.google.firebase.database.ValueEventListener
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import java.util.*

interface OnDispose {
  fun run()
}

class EventStreamHandler
  @JvmOverloads
  constructor(
    private val query: Query,
    private val onDispose: OnDispose,
  ) : StreamHandler {
    private var valueEventListener: ValueEventListener? = null
    private var childEventListener: ChildEventListener? = null

    @Suppress("UNCHECKED_CAST")
    override fun onListen(
      arguments: Any?,
      events: EventChannel.EventSink?,
    ) {
      val args = arguments as Map<String, Any>
      val eventType = args[Constants.EVENT_TYPE] as String

      if (Constants.EVENT_TYPE_VALUE == eventType) {
        events?.let { eventSink ->
          valueEventListener = ValueEventsProxy(eventSink)
          query.addValueEventListener(valueEventListener!!)
        }
      } else {
        events?.let { eventSink ->
          childEventListener = ChildEventsProxy(eventSink, eventType)
          query.addChildEventListener(childEventListener!!)
        }
      }
    }

    override fun onCancel(arguments: Any?) {
      try {
        // Remove listeners first to prevent any new events
        valueEventListener?.let {
          query.removeEventListener(it)
          valueEventListener = null
        }

        childEventListener?.let {
          query.removeEventListener(it)
          childEventListener = null
        }

        // Then run the dispose callback
        onDispose.run()
      } catch (e: Exception) {
        // Log any cleanup errors but don't throw
        android.util.Log.w("EventStreamHandler", "Error during cleanup: ${e.message}")
      }
    }
  }
