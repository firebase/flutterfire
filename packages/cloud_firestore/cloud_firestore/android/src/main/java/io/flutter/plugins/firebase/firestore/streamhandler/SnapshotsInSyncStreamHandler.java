package io.flutter.plugins.firebase.firestore.streamhandler;

import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.ListenerRegistration;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class SnapshotsInSyncStreamHandler implements StreamHandler {

  final HashMap<Integer, ListenerRegistration> listenerRegistrations = new HashMap<>();

  @Override
  public void onListen(Object arguments, EventSink events) {
    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;

    int handle = (int) Objects.requireNonNull(argumentsMap.get("handle"));
    FirebaseFirestore firestore =
        (FirebaseFirestore) Objects.requireNonNull(argumentsMap.get("firestore"));

    Runnable snapshotsInSyncRunnable =
        () -> {
          Map<String, Integer> data = new HashMap<>();
          data.put("handle", handle);
          events.success(data);
        };

    listenerRegistrations.put(
        handle, firestore.addSnapshotsInSyncListener(snapshotsInSyncRunnable));
  }

  @Override
  public void onCancel(Object arguments) {
    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    int handle = (int) Objects.requireNonNull(argumentsMap.get("handle"));

    ListenerRegistration registration = listenerRegistrations.remove(handle);
    if (registration != null) {
      registration.remove();
    }
  }
}
