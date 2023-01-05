/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.Map;
import java.util.Objects;

interface OnDispose {
  void run();
}

public class EventStreamHandler implements StreamHandler {
  private final Query query;
  private final OnDispose onDispose;
  private ValueEventListener valueEventListener;
  private ChildEventListener childEventListener;

  public EventStreamHandler(Query query, OnDispose onDispose) {
    this.query = query;
    this.onDispose = onDispose;
  }

  @SuppressWarnings("unchecked")
  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    final Map<String, Object> args = (Map<String, Object>) arguments;
    final String eventType = (String) Objects.requireNonNull(args.get(Constants.EVENT_TYPE));

    if (Constants.EVENT_TYPE_VALUE.equals(eventType)) {
      valueEventListener = new ValueEventsProxy(events);
      query.addValueEventListener(valueEventListener);
    } else {
      childEventListener = new ChildEventsProxy(events, eventType);
      query.addChildEventListener(childEventListener);
    }
  }

  @Override
  public void onCancel(Object arguments) {
    this.onDispose.run();

    if (valueEventListener != null) {
      query.removeEventListener(valueEventListener);
      valueEventListener = null;
    }

    if (childEventListener != null) {
      query.removeEventListener(childEventListener);
      childEventListener = null;
    }
  }
}
