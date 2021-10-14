package io.flutter.plugins.firebase.database;

import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;

public class EventStreamHandler implements StreamHandler {
  private final Query query;
  private ValueEventListener valueEventListener;
  private ChildEventListener childEventListener;

  public EventStreamHandler(Query query) {
    this.query = query;
  }

  @SuppressWarnings("unchecked")
  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    final Map<String, Object> args = (Map<String, Object>) arguments;
    final String eventType = (String) args.get(Constants.EVENT_TYPE);

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
