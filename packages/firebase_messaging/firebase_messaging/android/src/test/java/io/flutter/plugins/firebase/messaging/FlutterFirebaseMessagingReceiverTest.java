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
  // The android.jar of unit tests keeps no extras, so this broadcast answers the two reads the
  // receiver makes itself: all its extras, and the "wrapped_intent" one.
  private static Intent broadcast(final Bundle extras, final Parcelable wrappedIntent) {
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
    };
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
}
