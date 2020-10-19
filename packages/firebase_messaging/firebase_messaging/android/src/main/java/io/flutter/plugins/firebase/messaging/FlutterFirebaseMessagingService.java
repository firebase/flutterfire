package io.flutter.plugins.firebase.messaging;

import androidx.annotation.NonNull;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class FlutterFirebaseMessagingService extends FirebaseMessagingService {
  @Override
  public void onNewToken(@NonNull String token) {
    // TODO new token intent
    // TODO new token intent
    // TODO new token intent
    // TODO new token intent
    // TODO new token intent
  }

  @Override
  public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
    // Added for commenting purposes;
    // We don't handle the message here as we already handle it in the receiver and don't want to duplicate.

  }
}
