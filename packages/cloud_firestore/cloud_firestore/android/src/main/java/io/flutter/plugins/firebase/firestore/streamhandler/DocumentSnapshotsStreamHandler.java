package io.flutter.plugins.firebase.firestore.streamhandler;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.MetadataChanges;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class DocumentSnapshotsStreamHandler implements StreamHandler {

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

    DocumentReference documentReference =
        (DocumentReference) Objects.requireNonNull(argumentsMap.get("reference"));

    ListenerRegistration listenerRegistration =
        documentReference.addSnapshotListener(
            metadataChanges,
            (documentSnapshot, exception) -> {
              Map<String, Object> eventMap = new HashMap<>();

              eventMap.put("handle", handle);

              if (exception != null) {
                Map<String, Object> exceptionMap = new HashMap<>();
                FlutterFirebaseFirestoreException firestoreException =
                    new FlutterFirebaseFirestoreException(exception, exception.getCause());

                exceptionMap.put("code", firestoreException.getCode());
                exceptionMap.put("message", firestoreException.getMessage());
                eventMap.put("error", exceptionMap);
              } else {
                eventMap.put("snapshot", documentSnapshot);
              }
              events.success(eventMap);
            });

    listenerRegistrations.put(handle, listenerRegistration);
  }

  @Override
  public void onCancel(Object arguments) {
    if (arguments == null) {
      return;
    }

    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    final int handle = (int) Objects.requireNonNull(argumentsMap.get("handle"));

    ListenerRegistration registration = listenerRegistrations.remove(handle);
    if (registration != null) {
      registration.remove();
    }
  }
}
