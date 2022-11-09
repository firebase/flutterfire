/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import io.flutter.plugin.common.EventChannel.EventSink;

public class ChildEventsProxy extends EventsProxy implements ChildEventListener {
  protected ChildEventsProxy(@NonNull EventSink eventSink, @NonNull String eventType) {
    super(eventSink, eventType);
  }

  @Override
  public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
    sendEvent(Constants.EVENT_TYPE_CHILD_ADDED, snapshot, previousChildName);
  }

  @Override
  public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
    sendEvent(Constants.EVENT_TYPE_CHILD_CHANGED, snapshot, previousChildName);
  }

  @Override
  public void onChildRemoved(@NonNull DataSnapshot snapshot) {
    sendEvent(Constants.EVENT_TYPE_CHILD_REMOVED, snapshot, null);
  }

  @Override
  public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
    sendEvent(Constants.EVENT_TYPE_CHILD_MOVED, snapshot, previousChildName);
  }

  @Override
  public void onCancelled(@NonNull DatabaseError error) {
    final FlutterFirebaseDatabaseException e =
        FlutterFirebaseDatabaseException.fromDatabaseError(error);
    eventSink.error(e.getCode(), e.getMessage(), e.getAdditionalData());
  }
}
