package io.flutter.plugins.firebase.messaging;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.google.firebase.messaging.RemoteMessage;
import java.util.HashMap;

public class FlutterFirebaseMessagingReceiver extends BroadcastReceiver {
  private static final String TAG = "FLTFireMsgReceiver";
  static HashMap<String, RemoteMessage> notifications = new HashMap<>();

  @Override
  public void onReceive(Context context, Intent intent) {
    Log.d(TAG, "broadcast received for message");
    if (ContextHolder.getApplicationContext() == null) {
      ContextHolder.setApplicationContext(context.getApplicationContext());
    }

    RemoteMessage remoteMessage = new RemoteMessage(intent.getExtras());

    // Store the RemoteMessage if the message contains a notification payload.
    if (remoteMessage.getNotification() != null) {
      notifications.put(remoteMessage.getMessageId(), remoteMessage);
      // TODO(Salakar) store message for reading in getInitialMessage when activities restart.
      // TODO(Salakar) store message for reading in getInitialMessage when activities restart.
      // TODO(Salakar) store message for reading in getInitialMessage when activities restart.
      // TODO(Salakar) store message for reading in getInitialMessage when activities restart.
      // TODO(Salakar) store message for reading in getInitialMessage when activities restart.
      // TODO(Salakar) store message for reading in getInitialMessage when activities restart.
    }

    //  |-> ---------------------
    //      App in Foreground
    //   ------------------------
    if (FlutterFirebaseMessagingUtils.isApplicationForeground(context)) {
      Intent onMessageIntent = new Intent(FlutterFirebaseMessagingConstants.ACTION_REMOTE_MESSAGE);
      onMessageIntent.putExtra(
          FlutterFirebaseMessagingConstants.EXTRA_REMOTE_MESSAGE, remoteMessage);
      LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageIntent);
      return;
    }

    //  |-> ---------------------
    //    App in Background/Quit
    //   ------------------------
    Intent onBackgroundMessageIntent =
        new Intent(context, FlutterFirebaseMessagingBackgroundService.class);
    onBackgroundMessageIntent.putExtra(
        FlutterFirebaseMessagingConstants.EXTRA_REMOTE_MESSAGE, remoteMessage);
    FlutterFirebaseMessagingBackgroundService.enqueueMessageProcessing(
        context, onBackgroundMessageIntent);
  }
}
