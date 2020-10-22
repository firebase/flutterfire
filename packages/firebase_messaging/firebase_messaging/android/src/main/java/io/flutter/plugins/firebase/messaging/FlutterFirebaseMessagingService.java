package io.flutter.plugins.firebase.messaging;

import android.content.Intent;
import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class FlutterFirebaseMessagingService extends FirebaseMessagingService {
  @Override
  public void onNewToken(@NonNull String token) {
    Intent onMessageIntent = new Intent(FlutterFirebaseMessagingConstants.ACTION_TOKEN);
    onMessageIntent.putExtra(FlutterFirebaseMessagingConstants.EXTRA_TOKEN, token);
    LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(onMessageIntent);
  }

  @Override
  public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
    // Added for commenting purposes;
    // We don't handle the message here as we already handle it in the receiver and don't want to duplicate.
  }
}
