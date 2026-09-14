// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Parcel;
import android.util.Log;
import com.google.firebase.messaging.RemoteMessage;
import java.util.HashMap;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class FlutterFirebaseMessagingReceiver extends BroadcastReceiver {
  private static final String TAG = "FLTFireMsgReceiver";
  static HashMap<String, RemoteMessage> notifications = new HashMap<>();

  // SharedPreferences writes and process-state lookups must not run on the main
  // thread: when a receiver returns, Android blocks the main thread until all
  // pending SharedPreferences.apply() writes have hit disk (QueuedWork.waitToFinish),
  // which causes ANRs under I/O pressure.
  private static final Executor backgroundExecutor = Executors.newSingleThreadExecutor();

  @Override
  public void onReceive(Context context, Intent intent) {
    Log.d(TAG, "broadcast received for message");
    if (ContextHolder.getApplicationContext() == null) {
      Context aContext = context;
      if (context.getApplicationContext() != null) {
        aContext = context.getApplicationContext();
      }

      ContextHolder.setApplicationContext(aContext);
    }

    if (intent.getExtras() == null) {
      Log.d(
          TAG,
          "broadcast received but intent contained no extras to process RemoteMessage. Operation"
              + " cancelled.");
      return;
    }

    RemoteMessage remoteMessage = new RemoteMessage(intent.getExtras());

    // Keep the in-memory message available to the plugin on the main thread; it is
    // read from the main thread when a notification is tapped.
    if (remoteMessage.getNotification() != null) {
      notifications.put(remoteMessage.getMessageId(), remoteMessage);
    }

    // goAsync() keeps the broadcast alive until pendingResult.finish() so the
    // remaining work can safely run off the main thread.
    final PendingResult pendingResult = goAsync();
    backgroundExecutor.execute(
        () -> {
          try {
            // Store the RemoteMessage if the message contains a notification payload.
            if (remoteMessage.getNotification() != null) {
              FlutterFirebaseMessagingStore.getInstance().storeFirebaseMessage(remoteMessage);
            }

            //  |-> ---------------------
            //      App in Foreground
            //   ------------------------
            if (FlutterFirebaseMessagingUtils.isApplicationForeground(context)) {
              FlutterFirebaseRemoteMessageLiveData.getInstance().postRemoteMessage(remoteMessage);
              return;
            }

            //  |-> ---------------------
            //    App in Background/Quit
            //   ------------------------
            Intent onBackgroundMessageIntent =
                new Intent(context, FlutterFirebaseMessagingBackgroundService.class);

            Parcel parcel = Parcel.obtain();
            remoteMessage.writeToParcel(parcel, 0);
            // We write to parcel using RemoteMessage.writeToParcel() to pass entire RemoteMessage
            // as array
            // of bytes
            // Which can be read using RemoteMessage.createFromParcel(parcel) API
            onBackgroundMessageIntent.putExtra(
                FlutterFirebaseMessagingUtils.EXTRA_REMOTE_MESSAGE, parcel.marshall());

            FlutterFirebaseMessagingBackgroundService.enqueueMessageProcessing(
                context,
                onBackgroundMessageIntent,
                remoteMessage.getOriginalPriority() == RemoteMessage.PRIORITY_HIGH);
          } finally {
            pendingResult.finish();
          }
        });
  }
}
