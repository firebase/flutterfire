/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executor;
import org.junit.Test;

public class SnapshotDeliveryExecutorTest {

  @Test
  public void executesQueuedTasksInFifoOrder() {
    ManualExecutor delegate = new ManualExecutor();
    SnapshotDeliveryExecutor executor = new SnapshotDeliveryExecutor(delegate);
    List<String> events = new ArrayList<>();

    executor.execute(() -> events.add("first"));
    executor.execute(() -> events.add("second"));
    executor.execute(() -> events.add("third"));
    delegate.runAll();

    assertEquals(Arrays.asList("first", "second", "third"), events);
  }

  @Test
  public void deferralHoldsSubsequentTasksUntilCompletedWhileAllowingContinuations() {
    ManualExecutor delegate = new ManualExecutor();
    SnapshotDeliveryExecutor executor = new SnapshotDeliveryExecutor(delegate);
    List<String> events = new ArrayList<>();

    executor.execute(
        () -> {
          events.add("start");
          Runnable complete = executor.deferNext();
          executor.executeContinuation(
              () -> {
                events.add("chunk");
                executor.executeContinuation(
                    () -> {
                      events.add("end");
                      complete.run();
                    });
              });
        });
    executor.execute(() -> events.add("sync"));
    delegate.runAll();

    assertEquals(Arrays.asList("start", "chunk", "end", "sync"), events);
  }

  @Test
  public void deferralCompletionIsIdempotent() {
    ManualExecutor delegate = new ManualExecutor();
    SnapshotDeliveryExecutor executor = new SnapshotDeliveryExecutor(delegate);
    List<String> events = new ArrayList<>();

    Runnable first = executor.deferNext();
    Runnable second = executor.deferNext();
    executor.execute(() -> events.add("sync"));

    first.run();
    first.run();
    delegate.runAll();
    assertEquals(Arrays.asList(), events);

    second.run();
    delegate.runAll();
    assertEquals(Arrays.asList("sync"), events);
  }

  @Test
  public void uncaughtTaskExceptionDoesNotStallSubsequentQueuedTasks() {
    ManualExecutor delegate = new ManualExecutor();
    SnapshotDeliveryExecutor executor = new SnapshotDeliveryExecutor(delegate);
    List<String> events = new ArrayList<>();

    executor.execute(
        () -> {
          events.add("failing");
          throw new IllegalStateException("boom");
        });
    executor.execute(() -> events.add("after"));

    assertThrows(IllegalStateException.class, delegate::runOne);
    delegate.runAll();

    assertEquals(Arrays.asList("failing", "after"), events);
  }

  private static final class ManualExecutor implements Executor {
    final ArrayDeque<Runnable> pending = new ArrayDeque<>();

    @Override
    public void execute(Runnable command) {
      pending.addLast(command);
    }

    void runOne() {
      pending.removeFirst().run();
    }

    void runAll() {
      while (!pending.isEmpty()) {
        pending.removeFirst().run();
      }
    }
  }
}
