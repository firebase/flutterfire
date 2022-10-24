/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import com.google.firebase.database.DataSnapshot;
import io.flutter.plugin.common.EventChannel;
import java.util.HashMap;
import java.util.Map;

@RestrictTo(RestrictTo.Scope.LIBRARY)
public abstract class EventsProxy {
  protected final EventChannel.EventSink eventSink;
  private final String eventType;

  protected EventsProxy(@NonNull EventChannel.EventSink eventSink, @NonNull String eventType) {
    this.eventSink = eventSink;
    this.eventType = eventType;
  }

  Map<String, Object> buildAdditionalParams(
      @NonNull String eventType, @Nullable String previousChildName) {
    final Map<String, Object> params = new HashMap<>();
    params.put(Constants.EVENT_TYPE, eventType);

    if (previousChildName != null) {
      params.put(Constants.PREVIOUS_CHILD_NAME, previousChildName);
    }

    return params;
  }

  protected void sendEvent(
      @NonNull String eventType, DataSnapshot snapshot, @Nullable String previousChildName) {
    if (!this.eventType.equals(eventType)) return;

    FlutterDataSnapshotPayload payload = new FlutterDataSnapshotPayload(snapshot);
    final Map<String, Object> additionalParams =
        buildAdditionalParams(eventType, previousChildName);

    eventSink.success(payload.withAdditionalParams(additionalParams).toMap());
  }
}
