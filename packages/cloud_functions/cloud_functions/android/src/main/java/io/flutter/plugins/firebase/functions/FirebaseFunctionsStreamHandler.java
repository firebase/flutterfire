package io.flutter.plugins.firebase.functions;

import android.net.Uri;
import com.google.firebase.functions.FirebaseFunctions;
import com.google.firebase.functions.StreamResponse;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.net.URL;
import java.util.Map;
import org.reactivestreams.Publisher;

public class FirebaseFunctionsStreamHandler implements StreamHandler {

  private final FirebaseFunctions firebaseFunctions;

  private StreamResponseSubscriber subscriber;

  public FirebaseFunctionsStreamHandler(FirebaseFunctions functions) {
    this.firebaseFunctions = functions;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    httpsStreamCall(argumentsMap, events);
  }

  @Override
  public void onCancel(Object arguments) {
    subscriber.cancel();
  }

  private void httpsStreamCall(Map<String, Object> arguments, EventChannel.EventSink events) {
    try {

      String functionName = (String) arguments.get("functionName");
      String functionUri = (String) arguments.get("functionUri");
      String origin = (String) arguments.get("origin");
      Object parameters = arguments.get("parameters");

      if (origin != null) {
        Uri originUri = Uri.parse(origin);
        firebaseFunctions.useEmulator(originUri.getHost(), originUri.getPort());
      }

      Publisher<StreamResponse> publisher;
      if (functionName != null) {
        publisher = firebaseFunctions.getHttpsCallable(functionName).stream(parameters);
      } else if (functionUri != null) {
        publisher = firebaseFunctions.getHttpsCallableFromUrl(new URL(functionUri)).stream();
      } else {
        throw new IllegalArgumentException("Either functionName or functionUri must be set");
      }
      subscriber = new StreamResponseSubscriber(events);
      publisher.subscribe(subscriber);
    } catch (Exception e) {
      events.error("firebase_functions", e.getMessage(), null);
    }
  }

  public Object getResult() {
    return subscriber.getResult();
  }
}
