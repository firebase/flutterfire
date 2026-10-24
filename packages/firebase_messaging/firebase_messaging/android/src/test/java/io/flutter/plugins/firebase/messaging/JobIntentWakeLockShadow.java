// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.os.PowerManager;
import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import org.robolectric.annotation.Implementation;
import org.robolectric.annotation.Implements;
import org.robolectric.annotation.RealObject;
import org.robolectric.annotation.Resetter;
import org.robolectric.shadows.ShadowPowerManager;

/**
 * WakeLock shadow that can stall {@link PowerManager.WakeLock#release()} for selected locks. Tests
 * use this instead of replacing {@link JobIntentService#wakeLockExecutor}, so a slow PowerManager
 * Binder call is what blocks — the same condition as the ANR.
 */
@Implements(PowerManager.WakeLock.class)
public class JobIntentWakeLockShadow extends ShadowPowerManager.ShadowWakeLock {
  @RealObject private PowerManager.WakeLock realObject;

  private static final Set<PowerManager.WakeLock> blockOnRelease =
      Collections.synchronizedSet(
          Collections.newSetFromMap(new IdentityHashMap<PowerManager.WakeLock, Boolean>()));
  static volatile CountDownLatch releaseStarted;
  static volatile CountDownLatch allowRelease;
  static volatile Thread releaseThread;

  static void blockRelease(
      PowerManager.WakeLock wakeLock, CountDownLatch started, CountDownLatch allow) {
    blockOnRelease.add(wakeLock);
    releaseStarted = started;
    allowRelease = allow;
    releaseThread = null;
  }

  @Resetter
  public static void reset() {
    blockOnRelease.clear();
    releaseStarted = null;
    allowRelease = null;
    releaseThread = null;
  }

  @Implementation
  protected void release() {
    release(0);
  }

  @Implementation
  protected void release(int flags) {
    // Wait outside the shadow monitor so isHeld() / acquire() on this lock
    // can still run while release() is stalled, matching a slow Binder call.
    if (blockOnRelease.contains(realObject)) {
      releaseThread = Thread.currentThread();
      CountDownLatch started = releaseStarted;
      CountDownLatch allow = allowRelease;
      if (started != null) {
        started.countDown();
      }
      if (allow != null) {
        try {
          if (!allow.await(5, TimeUnit.SECONDS)) {
            throw new IllegalStateException("Timed out waiting to allow wake lock release");
          }
        } catch (InterruptedException e) {
          Thread.currentThread().interrupt();
        }
      }
    }
    super.release(flags);
  }
}
