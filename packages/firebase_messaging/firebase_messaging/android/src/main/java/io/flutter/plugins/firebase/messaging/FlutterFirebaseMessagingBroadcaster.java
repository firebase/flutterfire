// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ExecutorService;

import static io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingUtils.EXTRA_REMOTE_MESSAGE;

public class FlutterFirebaseMessagingBroadcaster {
  private static final String TAG = "FLTFireMsgBroadcaster";
  private static final List<String> externalIntentListenerStrings = new ArrayList<String>();


  public static Task<Void> registerMessageIntentListener(Context context, FlutterFirebaseMessagingPlugin receiver, ExecutorService cachedThreadPool, Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      FirebaseMessaging firebaseMessaging = FlutterFirebaseMessagingUtils
        .getFirebaseMessagingForArguments(arguments);
      String intentActionString = (String) Objects.requireNonNull(arguments.get("intentActionString"));
      FlutterFirebaseMessagingBroadcaster.addMessageIntentListener(context, receiver, intentActionString);
      return null;
    });
  }

  // This adds listeners that wish to join the onReceive onbroadcast
  // for push messages. This can be used when other plugins need to inspect
  // push messages.
  public static Task<Void>  addMessageIntentListener(Context context, FlutterFirebaseMessagingPlugin receiver, String intentActionString) {
    // Register broadcast receiver
    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(intentActionString);
    LocalBroadcastManager manager = LocalBroadcastManager.getInstance(context);
    manager.registerReceiver(receiver, intentFilter);
    FlutterFirebaseMessagingBroadcaster.addNewIntentListener(intentActionString);
    Log.i(TAG, "Registered Intent String: " + intentActionString);
    return null;
  }

  public static void broadcastToExternalListeners(Context context, final RemoteMessage remoteMessage) {
    // If there are any external listeners for onMessageReceived
    // send those intent broadcasts.
    // May be used by other plugins that need to be notified of push messages.
    if (!externalIntentListenerStrings.isEmpty()) {
      for (String intentString : externalIntentListenerStrings) {
        Intent intent = new Intent();
        intent.setAction(intentString);
        intent.putExtra(EXTRA_REMOTE_MESSAGE, remoteMessage);
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
        Log.i(TAG, "Broadcasted Intent String: " + intentString);
      }
    }
  }

  /**
   * Add external listeners for onMessageReceived messages. This is used so other
   * plugins have an opportunity to respond to push notifications by regietering
   * intent strings.
   *
   */
  public static void addNewIntentListener(String intentActionString) {
    externalIntentListenerStrings.add(intentActionString);
  }
}
