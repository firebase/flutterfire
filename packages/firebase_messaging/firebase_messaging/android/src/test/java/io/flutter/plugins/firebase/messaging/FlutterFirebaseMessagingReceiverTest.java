// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import org.junit.Test;

public class FlutterFirebaseMessagingReceiverTest {
  // The android.jar of unit tests keeps no extras, so this broadcast answers the reads the receiver
  // makes itself: all its extras, the "wrapped_intent" one and the "message_type" one.
  private static Intent broadcast(
      final Bundle extras, final Parcelable wrappedIntent, final String messageType) {
    return new Intent() {
      @Override
      public Bundle getExtras() {
        return extras;
      }

      @Override
      @SuppressWarnings({"deprecation", "unchecked"})
      public <T extends Parcelable> T getParcelableExtra(String name) {
        return "wrapped_intent".equals(name) ? (T) wrappedIntent : null;
      }

      @Override
      public String getStringExtra(String name) {
        return "message_type".equals(name) ? messageType : null;
      }
    };
  }

  private static Intent broadcast(Bundle extras, Parcelable wrappedIntent) {
    return broadcast(extras, wrappedIntent, null);
  }

  private static Intent broadcastOfType(String messageType) {
    return broadcast(new Bundle(), null, messageType);
  }

  @Test
  public void readsTheMessageOfABroadcastWithExtras() {
    assertNotNull(
        FlutterFirebaseMessagingReceiver.remoteMessageFrom(broadcast(new Bundle(), null)));
  }

  @Test
  public void ignoresABroadcastWrappingAnIntent() {
    // What firebase-messaging's delete intent wraps when the user dismisses a notification. The
    // android.jar of unit tests drops the action: any wrapped Intent is a notification event.
    Intent dismissal =
        broadcast(new Bundle(), new Intent("com.google.firebase.messaging.NOTIFICATION_DISMISS"));

    assertNull(FlutterFirebaseMessagingReceiver.remoteMessageFrom(dismissal));
  }

  @Test
  public void ignoresABroadcastWithoutExtras() {
    assertNull(FlutterFirebaseMessagingReceiver.remoteMessageFrom(broadcast(null, null)));
  }

  @Test
  public void readsTheMessageWhenTheWrappedValueIsNotAnIntent() {
    // CloudMessagingReceiver also reads only an Intent there as a notification event.
    assertNotNull(
        FlutterFirebaseMessagingReceiver.remoteMessageFrom(broadcast(new Bundle(), new Bundle())));
  }

  @Test
  public void readsTheMessageOfABroadcastOfTypeGcm() {
    assertNotNull(FlutterFirebaseMessagingReceiver.remoteMessageFrom(broadcastOfType("gcm")));
  }

  @Test
  public void ignoresADeletedMessagesBroadcast() {
    // Like the broadcast FCM sends when it has deleted messages pending for the app.
    assertNull(
        FlutterFirebaseMessagingReceiver.remoteMessageFrom(broadcastOfType("deleted_messages")));
  }

  @Test
  public void ignoresMessageTypesOtherThanGcm() {
    // FirebaseMessagingService passes upstream message events to their own callbacks, and drops
    // a type it does not know.
    for (String messageType : new String[] {"send_event", "send_error", "unknown"}) {
      assertNull(
          messageType,
          FlutterFirebaseMessagingReceiver.remoteMessageFrom(broadcastOfType(messageType)));
    }
  }
}
