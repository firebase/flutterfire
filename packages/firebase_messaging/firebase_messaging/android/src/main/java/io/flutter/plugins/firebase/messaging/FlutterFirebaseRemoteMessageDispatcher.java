// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.google.firebase.messaging.RemoteMessage;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;

/**
 * Delivers the messages received while the app is in the foreground to the plugin on every engine
 * whose Dart listens to {@code onMessage}, each message exactly once.
 *
 * <p>This replaces a {@code LiveData}, which keeps only the last of the values posted before the
 * main thread runs, and hands its last value again to every new observer (each new engine).
 *
 * <p>Messages received while no engine is listening, for example while the app engine is starting,
 * are kept for {@link #PENDING_MESSAGE_LIFETIME_MS} and delivered to the first engine that starts
 * listening.
 */
class FlutterFirebaseRemoteMessageDispatcher {
  interface Listener {
    void onRemoteMessage(@NonNull RemoteMessage message);
  }

  interface Clock {
    long elapsedRealtime();
  }

  private static final String TAG = "FLTFireMsgDispatcher";

  @VisibleForTesting static final int MAX_PENDING_MESSAGES = 50;
  @VisibleForTesting static final long PENDING_MESSAGE_LIFETIME_MS = 60_000;

  private static FlutterFirebaseRemoteMessageDispatcher instance;

  @SuppressWarnings("deprecation")
  static synchronized FlutterFirebaseRemoteMessageDispatcher getInstance() {
    if (instance == null) {
      Handler mainHandler = new Handler(Looper.getMainLooper());
      instance =
          new FlutterFirebaseRemoteMessageDispatcher(
              mainHandler::post,
              SystemClock::elapsedRealtime,
              // Keeps observers of the deprecated LiveData working.
              message ->
                  FlutterFirebaseRemoteMessageLiveData.getInstance().notifyObservers(message));
    }
    return instance;
  }

  private static final class PendingMessage {
    final RemoteMessage message;
    final long receivedAt;

    PendingMessage(RemoteMessage message, long receivedAt) {
      this.message = message;
      this.receivedAt = receivedAt;
    }
  }

  private final Executor mainThread;
  private final Clock clock;
  @Nullable private final Listener everyMessageListener;
  // Only accessed on the main thread.
  private final List<Listener> listeners = new ArrayList<>();
  private final ArrayDeque<PendingMessage> pendingMessages = new ArrayDeque<>();
  // Logged once until messages are delivered again, apps may never listen.
  private boolean loggedDroppedMessages = false;

  /**
   * @param everyMessageListener is told about every message as it arrives, whether or not an engine
   *     listens.
   */
  @VisibleForTesting
  FlutterFirebaseRemoteMessageDispatcher(
      Executor mainThread, Clock clock, @Nullable Listener everyMessageListener) {
    this.mainThread = mainThread;
    this.clock = clock;
    this.everyMessageListener = everyMessageListener;
  }

  /** Delivers {@code message} on the main thread. Can be called from any thread. */
  void dispatch(@NonNull RemoteMessage message) {
    mainThread.execute(() -> deliver(message));
  }

  /** Must be called on the main thread. */
  void addListener(@NonNull Listener listener) {
    listeners.add(listener);
    loggedDroppedMessages = false;
    long now = clock.elapsedRealtime();
    while (!pendingMessages.isEmpty()) {
      PendingMessage pending = pendingMessages.poll();
      if (now - pending.receivedAt <= PENDING_MESSAGE_LIFETIME_MS) {
        listener.onRemoteMessage(pending.message);
      } else {
        logDroppedMessage(pending.message, "no engine listened to onMessage in time");
      }
    }
  }

  /** Must be called on the main thread. */
  void removeListener(@NonNull Listener listener) {
    listeners.remove(listener);
  }

  private void logDroppedMessage(RemoteMessage message, String reason) {
    if (!loggedDroppedMessages) {
      loggedDroppedMessages = true;
      Log.w(TAG, "Dropped foreground message " + message.getMessageId() + ": " + reason + ".");
    }
  }

  private void deliver(RemoteMessage message) {
    if (everyMessageListener != null) {
      everyMessageListener.onRemoteMessage(message);
    }
    if (listeners.isEmpty()) {
      pendingMessages.add(new PendingMessage(message, clock.elapsedRealtime()));
      if (pendingMessages.size() > MAX_PENDING_MESSAGES) {
        logDroppedMessage(pendingMessages.poll().message, "too many waiting for onMessage");
      }
      return;
    }
    // Copy: a listener may remove itself while handling the message.
    for (Listener listener : new ArrayList<>(listeners)) {
      listener.onRemoteMessage(message);
    }
  }
}
