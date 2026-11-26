// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;

import android.os.Bundle;
import com.google.firebase.messaging.RemoteMessage;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.junit.Before;
import org.junit.Test;

public class FlutterFirebaseRemoteMessageDispatcherTest {
  // Runs posted tasks only when asked, like a main thread busy with something else.
  private final ArrayDeque<Runnable> mainThreadTasks = new ArrayDeque<>();
  private long now = 1_000;
  private final RecordingListener everyMessage = new RecordingListener();
  private FlutterFirebaseRemoteMessageDispatcher dispatcher;

  private static final class RecordingListener
      implements FlutterFirebaseRemoteMessageDispatcher.Listener {
    final List<RemoteMessage> messages = new ArrayList<>();

    @Override
    public void onRemoteMessage(RemoteMessage message) {
      messages.add(message);
    }
  }

  @Before
  public void setUp() {
    dispatcher =
        new FlutterFirebaseRemoteMessageDispatcher(mainThreadTasks::add, () -> now, everyMessage);
  }

  private void runMainThread() {
    while (!mainThreadTasks.isEmpty()) {
      mainThreadTasks.poll().run();
    }
  }

  private static RemoteMessage message() {
    return new RemoteMessage(new Bundle());
  }

  @Test
  public void deliversEveryMessagePostedBeforeTheMainThreadRuns() {
    RecordingListener listener = new RecordingListener();
    dispatcher.addListener(listener);
    RemoteMessage first = message();
    RemoteMessage second = message();
    RemoteMessage third = message();

    dispatcher.dispatch(first);
    dispatcher.dispatch(second);
    dispatcher.dispatch(third);
    runMainThread();

    assertEquals(Arrays.asList(first, second, third), listener.messages);
  }

  @Test
  public void deliversToEveryListener() {
    RecordingListener first = new RecordingListener();
    RecordingListener second = new RecordingListener();
    dispatcher.addListener(first);
    dispatcher.addListener(second);
    RemoteMessage message = message();

    dispatcher.dispatch(message);
    runMainThread();

    assertEquals(Arrays.asList(message), first.messages);
    assertEquals(Arrays.asList(message), second.messages);
  }

  @Test
  public void doesNotReplayDeliveredMessagesToALaterListener() {
    RecordingListener first = new RecordingListener();
    dispatcher.addListener(first);
    dispatcher.dispatch(message());
    runMainThread();

    RecordingListener later = new RecordingListener();
    dispatcher.addListener(later);
    RemoteMessage next = message();
    dispatcher.dispatch(next);
    runMainThread();

    assertEquals(Arrays.asList(next), later.messages);
    assertEquals(2, first.messages.size());
  }

  @Test
  public void keepsMessagesUntilTheFirstListenerThenOnlyDeliversThemOnce() {
    RemoteMessage first = message();
    RemoteMessage second = message();
    dispatcher.dispatch(first);
    dispatcher.dispatch(second);
    runMainThread();

    RecordingListener listener = new RecordingListener();
    dispatcher.addListener(listener);
    RecordingListener later = new RecordingListener();
    dispatcher.addListener(later);

    assertEquals(Arrays.asList(first, second), listener.messages);
    assertEquals(0, later.messages.size());
  }

  @Test
  public void dropsKeptMessagesOnceTheyAreTooOld() {
    RemoteMessage old = message();
    dispatcher.dispatch(old);
    runMainThread();
    now += FlutterFirebaseRemoteMessageDispatcher.PENDING_MESSAGE_LIFETIME_MS + 1;
    RemoteMessage recent = message();
    dispatcher.dispatch(recent);
    runMainThread();

    RecordingListener listener = new RecordingListener();
    dispatcher.addListener(listener);

    assertEquals(Arrays.asList(recent), listener.messages);
  }

  @Test
  public void keepsOnlyTheMostRecentMessagesWhenTooManyArrive() {
    List<RemoteMessage> sent = new ArrayList<>();
    for (int i = 0; i < FlutterFirebaseRemoteMessageDispatcher.MAX_PENDING_MESSAGES + 1; i++) {
      RemoteMessage message = message();
      sent.add(message);
      dispatcher.dispatch(message);
    }
    runMainThread();

    RecordingListener listener = new RecordingListener();
    dispatcher.addListener(listener);

    assertEquals(sent.subList(1, sent.size()), listener.messages);
  }

  @Test
  public void tellsTheEveryMessageListenerAboutEveryMessageWhenItArrives() {
    RemoteMessage kept = message();
    dispatcher.dispatch(kept);
    runMainThread();
    RecordingListener listener = new RecordingListener();
    dispatcher.addListener(listener);
    RemoteMessage delivered = message();
    dispatcher.dispatch(delivered);
    runMainThread();

    assertEquals(Arrays.asList(kept, delivered), everyMessage.messages);
  }

  @Test
  public void stopsDeliveringToARemovedListener() {
    RecordingListener removed = new RecordingListener();
    RecordingListener remaining = new RecordingListener();
    dispatcher.addListener(removed);
    dispatcher.addListener(remaining);

    dispatcher.removeListener(removed);
    RemoteMessage message = message();
    dispatcher.dispatch(message);
    runMainThread();

    assertEquals(0, removed.messages.size());
    assertSame(message, remaining.messages.get(0));
  }
}
