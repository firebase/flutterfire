// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import org.junit.Test;

public class FlutterFirebaseMessagingReceiverTest {
  // A broadcast whose "wrapped_intent" extra is `wrapped`. The android.jar of unit tests keeps no
  // extras, so the broadcast answers the one the receiver reads itself.
  private static Intent broadcastWrapping(final Parcelable wrapped) {
    return new Intent() {
      @Override
      @SuppressWarnings({"deprecation", "unchecked"})
      public <T extends Parcelable> T getParcelableExtra(String name) {
        return "wrapped_intent".equals(name) ? (T) wrapped : null;
      }
    };
  }

  @Test
  public void aDismissedNotificationIsANotificationEvent() {
    // What firebase-messaging broadcasts when the user dismisses a notification it displayed.
    Intent dismissal =
        broadcastWrapping(new Intent("com.google.firebase.messaging.NOTIFICATION_DISMISS"));

    assertTrue(FlutterFirebaseMessagingReceiver.isNotificationEvent(dismissal));
  }

  @Test
  public void aMessageIsNotANotificationEvent() {
    assertFalse(FlutterFirebaseMessagingReceiver.isNotificationEvent(broadcastWrapping(null)));
  }

  @Test
  public void aWrappedExtraThatIsNotAnIntentIsNotANotificationEvent() {
    assertFalse(
        FlutterFirebaseMessagingReceiver.isNotificationEvent(broadcastWrapping(new Bundle())));
  }
}
