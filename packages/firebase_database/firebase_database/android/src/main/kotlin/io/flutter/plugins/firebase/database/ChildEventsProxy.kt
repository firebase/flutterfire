/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.firebase.database.ChildEventListener
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import io.flutter.plugin.common.EventChannel.EventSink

class ChildEventsProxy
  @JvmOverloads
  constructor(
    @NonNull eventSink: EventSink,
    @NonNull eventType: String,
  ) : EventsProxy(eventSink, eventType),
    ChildEventListener {
    override fun onChildAdded(
      @NonNull snapshot: DataSnapshot,
      @Nullable previousChildName: String?,
    ) {
      sendEvent(Constants.EVENT_TYPE_CHILD_ADDED, snapshot, previousChildName)
    }

    override fun onChildChanged(
      @NonNull snapshot: DataSnapshot,
      @Nullable previousChildName: String?,
    ) {
      sendEvent(Constants.EVENT_TYPE_CHILD_CHANGED, snapshot, previousChildName)
    }

    override fun onChildRemoved(
      @NonNull snapshot: DataSnapshot,
    ) {
      sendEvent(Constants.EVENT_TYPE_CHILD_REMOVED, snapshot, null)
    }

    override fun onChildMoved(
      @NonNull snapshot: DataSnapshot,
      @Nullable previousChildName: String?,
    ) {
      sendEvent(Constants.EVENT_TYPE_CHILD_MOVED, snapshot, previousChildName)
    }

    override fun onCancelled(
      @NonNull error: DatabaseError,
    ) {
      val e = FlutterFirebaseDatabaseException.fromDatabaseError(error)
      eventSink.error(e.code, e.message, e.additionalData)
    }
  }
