package io.flutter.plugins.firebase.database;

import com.google.firebase.database.DataSnapshot;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class FlutterDataSnapshotPayload {
  private final DataSnapshot dataSnapshot;
  private Map<String, Object> payloadMap = new HashMap<>();

  public FlutterDataSnapshotPayload(DataSnapshot snapshot) {
    dataSnapshot = snapshot;

    Map<String, Object> snapshotMap = new HashMap<>();
    payloadMap.put(Constants.SNAPSHOT, snapshotMap);

    final String key = snapshot.getKey();
    final Object value = snapshot.getValue();
    final Object priority = snapshot.getPriority();

    snapshotMap.put(Constants.KEY, key);
    snapshotMap.put(Constants.VALUE, value);
    snapshotMap.put(Constants.PRIORITY, priority);
  }

  FlutterDataSnapshotPayload withAdditionalParams(Map<String, Object> params) {
    final Map<String, Object> prevPayloadMap = payloadMap;
    payloadMap = new HashMap<>();
    payloadMap.putAll(prevPayloadMap);
    payloadMap.putAll(params);

    return this;
  }

  FlutterDataSnapshotPayload withChildKeys() {
    final int childrenCount = (int) dataSnapshot.getChildrenCount();
    if (childrenCount == 0) {
      return this;
    }

    final String[] childKeys = new String[childrenCount];

    int i = 0;
    final Iterable<DataSnapshot> children = dataSnapshot.getChildren();

    for (DataSnapshot child : children) {
      childKeys[i] = child.getKey();
      i++;
    }

    payloadMap.put(Constants.CHILD_KEYS, Arrays.asList(childKeys));

    return this;
  }

  Map<String, Object> toMap() {
    return payloadMap;
  }
}
