// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Looper;
import android.os.PowerManager;
import androidx.annotation.NonNull;
import java.lang.reflect.Field;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.Shadows;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(shadows = JobIntentWakeLockShadow.class)
public class JobIntentServiceWakeLockTest {

  @After
  public void tearDown() {
    JobIntentService.sClassWorkEnqueuer.clear();
    JobIntentWakeLockShadow.reset();
  }

  @Test(timeout = 10000)
  public void serviceProcessingFinishedDoesNotBlockCallerOnWakeLockRelease() throws Exception {
    JobIntentService.CompatWorkEnqueuer enqueuer = newEnqueuer();
    CountDownLatch releaseStarted = new CountDownLatch(1);
    CountDownLatch allowRelease = new CountDownLatch(1);

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock runLock = getRunWakeLock(enqueuer);
    assertTrue(runLock.isHeld());
    JobIntentWakeLockShadow.blockRelease(runLock, releaseStarted, allowRelease);

    enqueuer.serviceProcessingFinished();

    assertTrue(releaseStarted.await(2, TimeUnit.SECONDS));
    assertTrue(runLock.isHeld());
    assertNotEquals(Thread.currentThread(), JobIntentWakeLockShadow.releaseThread);

    allowRelease.countDown();
    assertTrue("run wake lock was not released", awaitNotHeld(runLock, 2, TimeUnit.SECONDS));
  }

  @Test(timeout = 10000)
  public void delayedReleaseDoesNotDropLaterSessionLock() throws Exception {
    JobIntentService.CompatWorkEnqueuer enqueuer = newEnqueuer();
    CountDownLatch firstReleaseStarted = new CountDownLatch(1);
    CountDownLatch allowFirstRelease = new CountDownLatch(1);

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock firstRunLock = getRunWakeLock(enqueuer);
    JobIntentWakeLockShadow.blockRelease(firstRunLock, firstReleaseStarted, allowFirstRelease);
    enqueuer.serviceProcessingFinished();
    assertTrue(firstReleaseStarted.await(2, TimeUnit.SECONDS));

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock secondRunLock = getRunWakeLock(enqueuer);
    assertTrue(secondRunLock.isHeld());
    assertNotEquals(firstRunLock, secondRunLock);

    allowFirstRelease.countDown();
    assertTrue(awaitNotHeld(firstRunLock, 2, TimeUnit.SECONDS));
    assertTrue(secondRunLock.isHeld());
    assertFalse(firstRunLock.isHeld());
  }

  @Test(timeout = 10000)
  public void delayedReleaseDoesNotReacquireLaunchLock() throws Exception {
    JobIntentService.CompatWorkEnqueuer enqueuer = newEnqueuer();
    CountDownLatch firstReleaseStarted = new CountDownLatch(1);
    CountDownLatch allowFirstRelease = new CountDownLatch(1);
    PowerManager.WakeLock launchLock = getLaunchWakeLock(enqueuer);

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock firstRunLock = getRunWakeLock(enqueuer);
    JobIntentWakeLockShadow.blockRelease(firstRunLock, firstReleaseStarted, allowFirstRelease);
    enqueuer.enqueueWork(new Intent("next"));
    assertTrue(enqueuer.mLaunchingService);
    enqueuer.serviceProcessingFinished();
    assertTrue(launchLock.isHeld());
    assertTrue(firstReleaseStarted.await(2, TimeUnit.SECONDS));

    enqueuer.serviceProcessingStarted();
    PowerManager.WakeLock secondRunLock = getRunWakeLock(enqueuer);
    assertFalse(launchLock.isHeld());
    assertTrue(secondRunLock.isHeld());

    allowFirstRelease.countDown();
    assertTrue(awaitNotHeld(firstRunLock, 2, TimeUnit.SECONDS));
    assertFalse(launchLock.isHeld());
    assertTrue(secondRunLock.isHeld());
  }

  @Test(timeout = 10000)
  public void onDestroyDoesNotBlockOnWakeLockRelease() throws Exception {
    CountDownLatch releaseStarted = new CountDownLatch(1);
    CountDownLatch allowRelease = new CountDownLatch(1);

    BlockingJobIntentService service =
        Robolectric.buildService(BlockingJobIntentService.class).create().get();
    service.onStartCommand(new Intent("test-work"), 0, 1);
    assertTrue(service.workStarted.await(2, TimeUnit.SECONDS));

    PowerManager.WakeLock runLock =
        getRunWakeLock((JobIntentService.CompatWorkEnqueuer) service.mCompatWorkEnqueuer);
    JobIntentWakeLockShadow.blockRelease(runLock, releaseStarted, allowRelease);

    service.onDestroy();

    assertTrue(releaseStarted.await(2, TimeUnit.SECONDS));
    assertTrue(runLock.isHeld());
    assertNotEquals(Thread.currentThread(), JobIntentWakeLockShadow.releaseThread);

    allowRelease.countDown();
    assertTrue("run wake lock was not released", awaitNotHeld(runLock, 2, TimeUnit.SECONDS));
    service.allowWorkToFinish.countDown();
    assertTrue(service.workFinished.await(2, TimeUnit.SECONDS));
    Shadows.shadowOf(Looper.getMainLooper()).idle();
  }

  @Test
  public void getWorkEnqueuerCachesByComponentAndWakefulFlag() {
    Context context = RuntimeEnvironment.getApplication();
    ComponentName cn = new ComponentName(context, FlutterFirebaseMessagingBackgroundService.class);
    JobIntentService.WorkEnqueuer first =
        JobIntentService.getWorkEnqueuer(context, cn, false, 0, true);
    JobIntentService.WorkEnqueuer second =
        JobIntentService.getWorkEnqueuer(context, cn, false, 0, true);
    assertSame(first, second);

    JobIntentService.WorkEnqueuer otherComponent =
        JobIntentService.getWorkEnqueuer(
            context, new ComponentName(context, BlockingJobIntentService.class), false, 0, true);
    assertNotSame(first, otherComponent);

    JobIntentService.WorkEnqueuer nonWakeful =
        JobIntentService.getWorkEnqueuer(context, cn, true, 1, false);
    assertNotSame(first, nonWakeful);
  }

  @Test
  public void enqueueWorkAndServiceShareTheSameEnqueuer() {
    Context context = RuntimeEnvironment.getApplication();
    ComponentName cn = new ComponentName(context, BlockingJobIntentService.class);
    JobIntentService.WorkEnqueuer fromEnqueue =
        JobIntentService.getWorkEnqueuer(context, cn, true, 0, true);

    BlockingJobIntentService service =
        Robolectric.buildService(BlockingJobIntentService.class).create().get();

    assertSame(fromEnqueue, service.mCompatWorkEnqueuer);
  }

  public static class BlockingJobIntentService extends JobIntentService {
    final CountDownLatch workStarted = new CountDownLatch(1);
    final CountDownLatch allowWorkToFinish = new CountDownLatch(1);
    final CountDownLatch workFinished = new CountDownLatch(1);

    @Override
    protected void onHandleWork(@NonNull Intent intent) {
      workStarted.countDown();
      try {
        if (!allowWorkToFinish.await(5, TimeUnit.SECONDS)) {
          throw new IllegalStateException("Timed out waiting to finish work");
        }
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      } finally {
        workFinished.countDown();
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
