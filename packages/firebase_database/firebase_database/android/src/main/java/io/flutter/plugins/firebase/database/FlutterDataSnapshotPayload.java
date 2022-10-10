/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import com.google.firebase.database.DataSnapshot;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class FlutterDataSnapshotPayload {
  private Map<String, Object> payloadMap = new HashMap<>();

  public FlutterDataSnapshotPayload(DataSnapshot snapshot) {
    Map<String, Object> snapshotMap = new HashMap<>();

    snapshotMap.put(Constants.KEY, snapshot.getKey());
    snapshotMap.put(Constants.VALUE, snapshot.getValue());
    snapshotMap.put(Constants.PRIORITY, snapshot.getPriority());

    final int childrenCount = (int) snapshot.getChildrenCount();
    if (childrenCount == 0) {
      snapshotMap.put(Constants.CHILD_KEYS, new ArrayList<>());
    } else {
      final String[] childKeys = new String[childrenCount];
      int i = 0;
      final Iterable<DataSnapshot> children = snapshot.getChildren();
      for (DataSnapshot child : children) {
        childKeys[i] = child.getKey();
        i++;
      }
      snapshotMap.put(Constants.CHILD_KEYS, Arrays.asList(childKeys));
    }

    payloadMap.put(Constants.SNAPSHOT, snapshotMap);
  }

  FlutterDataSnapshotPayload withAdditionalParams(Map<String, Object> params) {
    final Map<String, Object> prevPayloadMap = payloadMap;
    payloadMap = new HashMap<>();
    payloadMap.putAll(prevPayloadMap);
    payloadMap.putAll(params);
    return this;
  }

  Map<String, Object> toMap() {
    return payloadMap;
  }
}
