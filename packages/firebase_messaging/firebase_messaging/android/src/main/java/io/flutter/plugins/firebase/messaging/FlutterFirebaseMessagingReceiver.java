package io.flutter.plugins.firebase.messaging;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
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
      // TODO store message for later access
      // TODO store message for later access
      // TODO store message for later access
      // TODO store message for later access
      // TODO store message for later access
      // TODO store message for later access
    }

    //  |-> ---------------------
    //      App in Foreground
    //   ------------------------
    if (FlutterFirebaseMessagingUtils.isApplicationForeground(context)) {
      // TODO send ACTION_REMOTE_MESSAGE intent
      // TODO send ACTION_REMOTE_MESSAGE intent
      // TODO send ACTION_REMOTE_MESSAGE intent
      // TODO send ACTION_REMOTE_MESSAGE intent
      // TODO send ACTION_REMOTE_MESSAGE intent
      // TODO send ACTION_REMOTE_MESSAGE intent
      return;
    }

    //  |-> ---------------------
    //    App in Background/Quit
    //   ------------------------
    Intent backgroundIntent = new Intent(context, FlutterFirebaseMessagingBackgroundService.class);
    backgroundIntent.putExtra("message", remoteMessage);
    FlutterFirebaseMessagingBackgroundService.enqueueMessageProcessing(context, backgroundIntent);
  }
}
