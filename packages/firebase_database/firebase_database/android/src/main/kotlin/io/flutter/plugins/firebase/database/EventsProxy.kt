/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import androidx.annotation.NonNull
import androidx.annotation.Nullable
import androidx.annotation.RestrictTo
import com.google.firebase.database.DataSnapshot
import io.flutter.plugin.common.EventChannel
import java.util.*

@RestrictTo(RestrictTo.Scope.LIBRARY)
abstract class EventsProxy
  @JvmOverloads
  constructor(
    protected val eventSink: EventChannel.EventSink,
    private val eventType: String,
  ) {
    fun buildAdditionalParams(
      @NonNull eventType: String,
      @Nullable previousChildName: String?,
    ): Map<String, Any?> {
      val params = mutableMapOf<String, Any?>()
      params[Constants.EVENT_TYPE] = eventType

      if (previousChildName != null) {
        params[Constants.PREVIOUS_CHILD_NAME] = previousChildName
      }

      return params
    }

    protected fun sendEvent(
      @NonNull eventType: String,
      snapshot: DataSnapshot,
      @Nullable previousChildName: String?,
    ) {
      if (this.eventType != eventType) return

      val payload = FlutterDataSnapshotPayload(snapshot)
      val additionalParams = buildAdditionalParams(eventType, previousChildName)

      eventSink.success(payload.withAdditionalParams(additionalParams).toMap())
    }
  }
