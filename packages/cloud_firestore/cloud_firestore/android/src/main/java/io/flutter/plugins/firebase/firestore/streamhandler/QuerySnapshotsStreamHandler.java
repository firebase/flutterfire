package io.flutter.plugins.firebase.firestore.streamhandler;

import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.MetadataChanges;
import com.google.firebase.firestore.Query;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class QuerySnapshotsStreamHandler implements StreamHandler {

  final HashMap<Integer, ListenerRegistration> listenerRegistrations = new HashMap<>();

  @Override
  public void onListen(Object arguments, EventSink events) {
    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;

    final int handle = (int) Objects.requireNonNull(argumentsMap.get("handle"));

    MetadataChanges metadataChanges =
        (Boolean) Objects.requireNonNull(argumentsMap.get("includeMetadataChanges"))
            ? MetadataChanges.INCLUDE
            : MetadataChanges.EXCLUDE;

    Query query = (Query) argumentsMap.get("query");

    if (query == null) {
      throw new IllegalArgumentException(
          "An error occurred while parsing query arguments, see native logs for more information. Please report this issue.");
    }

    ListenerRegistration listenerRegistration =
        query.addSnapshotListener(
            metadataChanges,
            (querySnapshot, exception) -> {
              Map<String, Object> querySnapshotMap = new HashMap<>();

              querySnapshotMap.put("handle", handle);

              if (exception != null) {
                Map<String, Object> exceptionMap = new HashMap<>();
                FlutterFirebaseFirestoreException firestoreException =
                    new FlutterFirebaseFirestoreException(exception, exception.getCause());
                exceptionMap.put("code", firestoreException.getCode());
                exceptionMap.put("message", firestoreException.getMessage());
                querySnapshotMap.put("error", exceptionMap);
              } else {
                querySnapshotMap.put("snapshot", querySnapshot);
              }

              events.success(querySnapshotMap);
            });

    listenerRegistrations.put(handle, listenerRegistration);
  }

  @Override
  public void onCancel(Object arguments) {
    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    final int handle = (int) Objects.requireNonNull(argumentsMap.get("handle"));

    ListenerRegistration registration = listenerRegistrations.remove(handle);
    if (registration != null) {
      registration.remove();
    }
  }
}
