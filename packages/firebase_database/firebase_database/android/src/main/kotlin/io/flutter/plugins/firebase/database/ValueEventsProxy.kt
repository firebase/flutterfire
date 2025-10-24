/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import androidx.annotation.NonNull
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import io.flutter.plugin.common.EventChannel.EventSink

class ValueEventsProxy
  @JvmOverloads
  constructor(
    @NonNull eventSink: EventSink,
  ) : EventsProxy(eventSink, Constants.EVENT_TYPE_VALUE),
    ValueEventListener {
    override fun onDataChange(
      @NonNull snapshot: DataSnapshot,
    ) {
      sendEvent(Constants.EVENT_TYPE_VALUE, snapshot, null)
    }

    override fun onCancelled(
      @NonNull error: DatabaseError,
    ) {
      val e = FlutterFirebaseDatabaseException.fromDatabaseError(error)
      eventSink.error(e.code, e.message, e.additionalData)
    }
  }
