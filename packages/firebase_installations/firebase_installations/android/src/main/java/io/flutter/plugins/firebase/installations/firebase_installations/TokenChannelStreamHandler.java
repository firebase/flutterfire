package io.flutter.plugins.firebase.installations.firebase_installations;

import androidx.annotation.NonNull;

import com.google.firebase.installations.FirebaseInstallations;
import com.google.firebase.installations.internal.FidListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;

public class TokenChannelStreamHandler implements EventChannel.StreamHandler {

  private final FirebaseInstallations firebaseInstallations;
  private FidListener listener;

  public TokenChannelStreamHandler(FirebaseInstallations firebaseInstallations) {
    this.firebaseInstallations = firebaseInstallations;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {

    listener = createTokenEventListener(events);


    firebaseInstallations.registerFidListener(listener);
  }

  @Override
  public void onCancel(Object arguments) {
    if (listener != null) {
      listener = null;
    }
  }

  FidListener createTokenEventListener(final EventChannel.EventSink events) {
    return token -> {
      Map<String, Object> event = new HashMap<>();

      Log.d("TOKEN", token);
      event.put("token" , token);

      events.success(event);
    };
  }
}
