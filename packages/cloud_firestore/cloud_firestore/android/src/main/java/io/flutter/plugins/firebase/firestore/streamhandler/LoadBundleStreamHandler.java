package io.flutter.plugins.firebase.firestore.streamhandler;

import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.LoadBundleTask;
import java.util.Map;
import java.util.Objects;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter;

import static io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.DEFAULT_ERROR_CODE;

public class LoadBundleStreamHandler implements EventChannel.StreamHandler {
  private EventChannel.EventSink eventSink;

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;

    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    byte[] bundle = (byte[]) Objects.requireNonNull(argumentsMap.get("bundle"));

    FirebaseFirestore firestore = FirebaseFirestore.getInstance();

    LoadBundleTask task = firestore.loadBundle(bundle);

    task.addOnProgressListener(
      snapshot -> {
        events.success(snapshot);
      }
    );

    task.addOnFailureListener(
      exception -> {
        Map<String, String> exceptionDetails = ExceptionConverter.createDetails(exception);
        events.error(DEFAULT_ERROR_CODE, exception.getMessage(), exceptionDetails);
        onCancel(null);
      }
    );
  }

  @Override
  public void onCancel(Object arguments) {
    eventSink.endOfStream();
  }
}
