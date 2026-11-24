/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import java.util.ArrayDeque;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicBoolean;

public final class SnapshotDeliveryExecutor implements Executor {
  private final Executor delegate;
  private final ArrayDeque<Runnable> queue = new ArrayDeque<>();
  private boolean running;
  private int activeDeferrals;

  public SnapshotDeliveryExecutor(Executor delegate) {
    this.delegate = delegate;
  }

  @Override
  public void execute(Runnable command) {
    Runnable next;
    synchronized (this) {
      queue.addLast(command);
      next = pollNextLocked();
    }
    if (next != null) {
      dispatch(next);
    }
  }

  public void executeContinuation(Runnable command) {
    delegate.execute(command);
  }

  public Runnable deferNext() {
    synchronized (this) {
      activeDeferrals++;
    }
    AtomicBoolean completed = new AtomicBoolean(false);
    return () -> {
      if (!completed.compareAndSet(false, true)) {
        return;
      }
      Runnable next;
      synchronized (this) {
        activeDeferrals--;
        next = pollNextLocked();
      }
      if (next != null) {
        dispatch(next);
      }
    };
  }

  private Runnable pollNextLocked() {
    if (running || activeDeferrals > 0) {
      return null;
    }
    Runnable next = queue.pollFirst();
    if (next == null) {
      return null;
    }
    running = true;
    return next;
  }

  private void dispatch(Runnable task) {
    try {
      delegate.execute(
          () -> {
            Runnable next = null;
            try {
              task.run();
            } finally {
              synchronized (this) {
                running = false;
                next = pollNextLocked();
              }
              if (next != null) {
                dispatch(next);
              }
            }
          });
    } catch (RuntimeException | Error error) {
      synchronized (this) {
        running = false;
      }
      throw error;
    }
  }
}
