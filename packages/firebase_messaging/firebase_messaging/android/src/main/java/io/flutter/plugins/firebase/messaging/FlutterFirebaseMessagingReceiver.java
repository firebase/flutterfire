// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.google.firebase.messaging.RemoteMessage;
import java.util.HashMap;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class FlutterFirebaseMessagingReceiver extends BroadcastReceiver {
  private static final String TAG = "FLTFireMsgReceiver";
  private static final String EXTRA_WRAPPED_INTENT = "wrapped_intent";
  private static final String EXTRA_MESSAGE_TYPE = "message_type";
  private static final String MESSAGE_TYPE_MESSAGE = "gcm";
  static HashMap<String, RemoteMessage> notifications = new HashMap<>();

  // SharedPreferences writes and process-state lookups must not run on the main
  // thread: when a receiver returns, Android blocks the main thread until all
  // pending SharedPreferences.apply() writes have hit disk (QueuedWork.waitToFinish),
  // which causes ANRs under I/O pressure.
  private static final Executor backgroundExecutor = Executors.newSingleThreadExecutor();

  @Override
  public void onReceive(Context context, Intent intent) {
    if (ContextHolder.getApplicationContext() == null) {
      Context aContext = context;
      if (context.getApplicationContext() != null) {
        aContext = context.getApplicationContext();
      }

      ContextHolder.setApplicationContext(aContext);
    }

    RemoteMessage remoteMessage = remoteMessageFrom(intent);
    if (remoteMessage == null) {
      return;
    }
    Log.d(TAG, "broadcast received for message");

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
              FlutterFirebaseRemoteMessageDispatcher.getInstance().dispatch(remoteMessage);
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
            // Null when onReceive is called outside of a broadcast, as the e2e tests do.
            if (pendingResult != null) {
              pendingResult.finish();
            }
          }
        });
  }

  /**
   * Returns the message to deliver for a broadcast, or null for a broadcast without extras, for a
   * notification event, or for one whose {@code message_type} is set and is not {@code gcm}.
   *
   * <p>When firebase-messaging displays a notification for a message that has analytics enabled, it
   * gives the notification a delete intent. If the user dismisses the notification, Android sends
   * the app that intent: a {@code com.google.android.c2dm.intent.RECEIVE} broadcast, the action
   * messages use, with the {@code NOTIFICATION_DISMISS} intent in its {@code wrapped_intent} extra.
   * Google's CloudMessagingReceiver handles a broadcast with an intent there as a notification
   * event, never as a message, and this receiver ignores it. Read as a message, it has no ID and
   * nothing in it.
   */
  @VisibleForTesting
  @Nullable
  static RemoteMessage remoteMessageFrom(Intent intent) {
    Bundle extras = intent.getExtras();
    if (extras == null) {
      Log.d(
          TAG,
          "broadcast received but intent contained no extras to process RemoteMessage. Operation"
              + " cancelled.");
      return null;
    }

    // The same check as CloudMessagingReceiver. The typed getter needs API 33, and AndroidX's
    // IntentCompat only relies on it from API 34.
    @SuppressWarnings("deprecation")
    Parcelable wrappedIntent = intent.getParcelableExtra(EXTRA_WRAPPED_INTENT);
    if (wrappedIntent instanceof Intent) {
      Log.d(
          TAG,
          "broadcast received for notification event "
              + ((Intent) wrappedIntent).getAction()
              + ", not a message. Ignored.");
      return null;
    }

    // FirebaseMessagingService passes a broadcast to onMessageReceived only if it has no message
    // type or gcm. Any other type is not a message: deleted_messages, which FCM sends when it has
    // deleted messages pending for the app, send_event and send_error, about upstream messages, or
    // a type the SDK does not know and drops.
    String messageType = intent.getStringExtra(EXTRA_MESSAGE_TYPE);
    if (messageType != null && !MESSAGE_TYPE_MESSAGE.equals(messageType)) {
      Log.d(
          TAG, "broadcast received for message type " + messageType + ", not a message. Ignored.");
      return null;
    }

    return new RemoteMessage(extras);
  }
}
