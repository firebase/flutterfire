// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.PowerManager;
import androidx.annotation.NonNull;
import java.lang.reflect.Field;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;

@RunWith(RobolectricTestRunner.class)
public class JobIntentServiceWakeLockTest {
  private Executor originalExecutor;

  @Before
  public void setUp() {
    originalExecutor = JobIntentService.wakeLockExecutor;
  }

  @After
  public void tearDown() {
    JobIntentService.wakeLockExecutor = originalExecutor;
  }

  @Test
  public void serviceProcessingFinishedDoesNotBlockCallerOnWakeLockRelease() throws Exception {
    JobIntentService.CompatWorkEnqueuer enqueuer = newEnqueuer();
    CountDownLatch releaseStarted = new CountDownLatch(1);
    CountDownLatch allowRelease = new CountDownLatch(1);
    AtomicReference<Thread> releaseThread = new AtomicReference<>();

    JobIntentService.wakeLockExecutor =
        command ->
            new Thread(
                    () -> {
                      releaseThread.set(Thread.currentThread());
                      releaseStarted.countDown();
                      try {
                        if (!allowRelease.await(5, TimeUnit.SECONDS)) {
                          throw new IllegalStateException("Timed out waiting to release");
                        }
                      } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                      }
                      command.run();
                    },
                    "test-wakelock")
                .start();

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock runLock = getRunWakeLock(enqueuer);
    assertTrue(runLock.isHeld());

    long startedAt = System.nanoTime();
    enqueuer.serviceProcessingFinished();
    long elapsedMs = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startedAt);

    assertTrue("serviceProcessingFinished blocked on wake lock release", elapsedMs < 500);
    assertTrue(releaseStarted.await(2, TimeUnit.SECONDS));
    assertTrue(runLock.isHeld());
    assertNotEquals(Thread.currentThread(), releaseThread.get());

    allowRelease.countDown();
    assertTrue(awaitNotHeld(runLock, 2, TimeUnit.SECONDS));
  }

  @Test
  public void delayedReleaseDoesNotDropLaterSessionLock() throws Exception {
    JobIntentService.CompatWorkEnqueuer enqueuer = newEnqueuer();
    CountDownLatch firstReleaseStarted = new CountDownLatch(1);
    CountDownLatch allowFirstRelease = new CountDownLatch(1);

    JobIntentService.wakeLockExecutor =
        command ->
            new Thread(
                    () -> {
                      firstReleaseStarted.countDown();
                      try {
                        if (!allowFirstRelease.await(5, TimeUnit.SECONDS)) {
                          throw new IllegalStateException("Timed out waiting to release");
                        }
                      } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                      }
                      command.run();
                    },
                    "test-wakelock")
                .start();

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock firstRunLock = getRunWakeLock(enqueuer);
    enqueuer.serviceProcessingFinished();
    assertTrue(firstReleaseStarted.await(2, TimeUnit.SECONDS));

    JobIntentService.wakeLockExecutor = command -> new Thread(command, "test-wakelock-2").start();
    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock secondRunLock = getRunWakeLock(enqueuer);
    assertTrue(secondRunLock.isHeld());
    assertNotEquals(firstRunLock, secondRunLock);

    allowFirstRelease.countDown();
    assertTrue(awaitNotHeld(firstRunLock, 2, TimeUnit.SECONDS));
    assertTrue(secondRunLock.isHeld());
    assertFalse(firstRunLock.isHeld());
  }

  @Test
  public void delayedReleaseDoesNotReacquireLaunchLock() throws Exception {
    JobIntentService.CompatWorkEnqueuer enqueuer = newEnqueuer();
    CountDownLatch firstReleaseStarted = new CountDownLatch(1);
    CountDownLatch allowFirstRelease = new CountDownLatch(1);
    PowerManager.WakeLock launchLock = getLaunchWakeLock(enqueuer);

    JobIntentService.wakeLockExecutor =
        command ->
            new Thread(
                    () -> {
                      firstReleaseStarted.countDown();
                      try {
                        if (!allowFirstRelease.await(5, TimeUnit.SECONDS)) {
                          throw new IllegalStateException("Timed out waiting to release");
                        }
                      } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                      }
                      command.run();
                    },
                    "test-wakelock")
                .start();

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock firstRunLock = getRunWakeLock(enqueuer);
    enqueuer.mLaunchingService = true;
    enqueuer.serviceProcessingFinished();
    assertTrue(launchLock.isHeld());
    assertTrue(firstReleaseStarted.await(2, TimeUnit.SECONDS));

    JobIntentService.wakeLockExecutor = command -> new Thread(command, "test-wakelock-2").start();
    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock secondRunLock = getRunWakeLock(enqueuer);
    assertFalse(launchLock.isHeld());
    assertTrue(secondRunLock.isHeld());

    allowFirstRelease.countDown();
    assertTrue(awaitNotHeld(firstRunLock, 2, TimeUnit.SECONDS));
    assertFalse(launchLock.isHeld());
    assertTrue(secondRunLock.isHeld());
  }

  @Test
  public void onDestroyDoesNotBlockOnWakeLockRelease() throws Exception {
    CountDownLatch releaseStarted = new CountDownLatch(1);
    CountDownLatch allowRelease = new CountDownLatch(1);

    JobIntentService.wakeLockExecutor =
        command ->
            new Thread(
                    () -> {
                      releaseStarted.countDown();
                      try {
                        if (!allowRelease.await(5, TimeUnit.SECONDS)) {
                          throw new IllegalStateException("Timed out waiting to release");
                        }
                      } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                      }
                      command.run();
                    },
                    "test-wakelock")
                .start();

    BlockingJobIntentService service =
        Robolectric.buildService(BlockingJobIntentService.class).create().get();
    service.onStartCommand(new Intent("test-work"), 0, 1);
    assertTrue(service.workStarted.await(2, TimeUnit.SECONDS));

    long startedAt = System.nanoTime();
    service.onDestroy();
    long elapsedMs = TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startedAt);

    assertTrue("onDestroy blocked on wake lock release", elapsedMs < 500);
    assertTrue(releaseStarted.await(2, TimeUnit.SECONDS));

    allowRelease.countDown();
    service.allowWorkToFinish.countDown();
  }

  public static class BlockingJobIntentService extends JobIntentService {
    final CountDownLatch workStarted = new CountDownLatch(1);
    final CountDownLatch allowWorkToFinish = new CountDownLatch(1);

    @Override
    protected void onHandleWork(@NonNull Intent intent) {
      workStarted.countDown();
      try {
        if (!allowWorkToFinish.await(5, TimeUnit.SECONDS)) {
          throw new IllegalStateException("Timed out waiting to finish work");
        }
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      }
    }
  }

  private static JobIntentService.CompatWorkEnqueuer newEnqueuer() {
    Context context = RuntimeEnvironment.getApplication();
    ComponentName componentName =
        new ComponentName(context, FlutterFirebaseMessagingBackgroundService.class);
    return new JobIntentService.CompatWorkEnqueuer(context, componentName);
  }

  private static PowerManager.WakeLock getRunWakeLock(JobIntentService.CompatWorkEnqueuer enqueuer)
      throws Exception {
    return getWakeLock(enqueuer, "mRunWakeLock");
  }

  private static PowerManager.WakeLock getLaunchWakeLock(
      JobIntentService.CompatWorkEnqueuer enqueuer) throws Exception {
    return getWakeLock(enqueuer, "mLaunchWakeLock");
  }

  private static PowerManager.WakeLock getWakeLock(
      JobIntentService.CompatWorkEnqueuer enqueuer, String fieldName) throws Exception {
    Field field = JobIntentService.CompatWorkEnqueuer.class.getDeclaredField(fieldName);
    field.setAccessible(true);
    return (PowerManager.WakeLock) field.get(enqueuer);
  }

  private static boolean awaitNotHeld(PowerManager.WakeLock wakeLock, long timeout, TimeUnit unit)
      throws InterruptedException {
    long deadline = System.nanoTime() + unit.toNanos(timeout);
    while (wakeLock.isHeld() && System.nanoTime() < deadline) {
      Thread.sleep(10);
    }
    return !wakeLock.isHeld();
  }
}
