/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;
import io.flutter.plugin.common.EventChannel.EventSink;

public class ValueEventsProxy extends EventsProxy implements ValueEventListener {
  protected ValueEventsProxy(@NonNull EventSink eventSink) {
    super(eventSink, Constants.EVENT_TYPE_VALUE);
  }

  @Override
  public void onDataChange(@NonNull DataSnapshot snapshot) {
    sendEvent(Constants.EVENT_TYPE_VALUE, snapshot, null);
  }

  @Override
  public void onCancelled(@NonNull DatabaseError error) {
    final FlutterFirebaseDatabaseException e =
        FlutterFirebaseDatabaseException.fromDatabaseError(error);
    eventSink.error(e.getCode(), e.getMessage(), e.getAdditionalData());
  }
}
