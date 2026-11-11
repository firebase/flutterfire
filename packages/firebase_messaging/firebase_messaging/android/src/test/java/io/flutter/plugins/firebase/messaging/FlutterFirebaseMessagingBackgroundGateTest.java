// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.app.Application;
import android.app.KeyguardManager;
import android.app.job.JobScheduler;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.os.Bundle;
import android.os.Looper;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.Shadows;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 28)
public class FlutterFirebaseMessagingBackgroundGateTest {
  private Context context;

  @Before
  public void setUp() {
    context = RuntimeEnvironment.getApplication();
    ContextHolder.setApplicationContext(context);
    FlutterFirebaseMessagingBackgroundGate.resetForTests();
    preferences().edit().clear().commit();
    FlutterFirebaseMessagingReceiver.notifications.clear();
    JobIntentService.sClassWorkEnqueuer.clear();
  }

  @After
  public void tearDown() {
    setManifestValue(null);
    FlutterFirebaseMessagingBackgroundGate.resetForTests();
    preferences().edit().clear().commit();
    unlock();
    FlutterFirebaseMessagingReceiver.notifications.clear();
    JobIntentService.sClassWorkEnqueuer.clear();
    ContextHolder.setApplicationContext(null);
  }

  @Test
  public void backgroundMessageWithoutHandlerDoesNotStartTheService() throws Exception {
    lockKeyguard();

    deliverBackgroundMessage();

    assertNoBackgroundWorkScheduled();
  }

  @Test
  public void backgroundMessageWithStoredHandlerStartsTheService() throws Exception {
    lockKeyguard();
    writeHandles(42L, 99L);

    deliverBackgroundMessage();

    assertTrue(backgroundWorkScheduled());
    assertEquals(42L, readHandle(FlutterFirebaseMessagingBackgroundExecutor.CALLBACK_HANDLE_KEY));
  }

  @Test
  public void manifestFalseSkipsAStoredHandlerAndClearsIt() throws Exception {
    lockKeyguard();
    writeHandles(42L, 99L);
    setManifestValue(Boolean.FALSE);

    deliverBackgroundMessage();

    assertNoBackgroundWorkScheduled();
    assertEquals(0L, readHandle(FlutterFirebaseMessagingBackgroundExecutor.CALLBACK_HANDLE_KEY));
    assertEquals(
        0L, readHandle(FlutterFirebaseMessagingBackgroundExecutor.USER_CALLBACK_HANDLE_KEY));
    assertFalse(
        new FlutterFirebaseMessagingBackgroundExecutor().isDartBackgroundHandlerRegistered());
  }

  @Test
  public void manifestStringFalseSkipsAStoredHandler() throws Exception {
    lockKeyguard();
    writeHandles(42L, 99L);
    setManifestValue("false");

    deliverBackgroundMessage();

    assertNoBackgroundWorkScheduled();
  }

  @Test
  public void manifestTrueKeepsAStoredHandler() throws Exception {
    lockKeyguard();
    writeHandles(42L, 99L);
    setManifestValue(Boolean.TRUE);

    deliverBackgroundMessage();

    assertTrue(backgroundWorkScheduled());
    assertEquals(42L, readHandle(FlutterFirebaseMessagingBackgroundExecutor.CALLBACK_HANDLE_KEY));
  }

  @Test
  public void serviceCreateWithManifestFalseDoesNotStartTheIsolate() throws Exception {
    writeHandles(42L, 99L);
    setManifestValue(Boolean.FALSE);

    Robolectric.buildService(FlutterFirebaseMessagingBackgroundService.class).create();
    Shadows.shadowOf(Looper.getMainLooper()).idle();
    FlutterFirebaseMessagingBackgroundGate.awaitClearForTests();

    assertEquals(0L, readHandle(FlutterFirebaseMessagingBackgroundExecutor.CALLBACK_HANDLE_KEY));
    assertFalse(
        new FlutterFirebaseMessagingBackgroundExecutor().isDartBackgroundHandlerRegistered());
  }

  private void deliverBackgroundMessage() throws InterruptedException {
    Intent intent = new Intent("com.google.android.c2dm.intent.RECEIVE");
    Bundle extras = new Bundle();
    extras.putString("google.message_id", "m1");
    intent.putExtras(extras);
    new FlutterFirebaseMessagingReceiver().onReceive(context, intent);
    FlutterFirebaseMessagingReceiver.awaitBackgroundWorkForTests();
  }

  private void writeHandles(long pluginHandle, long userHandle) {
    preferences()
        .edit()
        .putLong(FlutterFirebaseMessagingBackgroundExecutor.CALLBACK_HANDLE_KEY, pluginHandle)
        .putLong(FlutterFirebaseMessagingBackgroundExecutor.USER_CALLBACK_HANDLE_KEY, userHandle)
        .commit();
  }

  private long readHandle(String key) {
    return preferences().getLong(key, 0L);
  }

  private SharedPreferences preferences() {
    return context.getSharedPreferences(
        FlutterFirebaseMessagingUtils.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
  }

  private void setManifestValue(Object value) {
    PackageInfo info =
        Shadows.shadowOf(context.getPackageManager())
            .getInternalMutablePackageInfo(context.getPackageName());
    if (info.applicationInfo.metaData == null) {
      info.applicationInfo.metaData = new Bundle();
    }
    info.applicationInfo.metaData.remove(FlutterFirebaseMessagingBackgroundGate.METADATA_KEY);
    if (value instanceof Boolean) {
      info.applicationInfo.metaData.putBoolean(
          FlutterFirebaseMessagingBackgroundGate.METADATA_KEY, (Boolean) value);
    } else if (value instanceof String) {
      info.applicationInfo.metaData.putString(
          FlutterFirebaseMessagingBackgroundGate.METADATA_KEY, (String) value);
    }
    FlutterFirebaseMessagingBackgroundGate.resetForTests();
  }

  private void lockKeyguard() {
    KeyguardManager keyguardManager =
        (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
    Shadows.shadowOf(keyguardManager).setKeyguardLocked(true);
  }

  private void unlock() {
    KeyguardManager keyguardManager =
        (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
    Shadows.shadowOf(keyguardManager).setKeyguardLocked(false);
  }

  private void assertNoBackgroundWorkScheduled() {
    assertFalse(backgroundWorkScheduled());
    assertNull(
        Shadows.shadowOf((Application) context.getApplicationContext()).getNextStartedService());
  }

  private boolean backgroundWorkScheduled() {
    JobScheduler scheduler = (JobScheduler) context.getSystemService(Context.JOB_SCHEDULER_SERVICE);
    List<?> jobs = scheduler.getAllPendingJobs();
    if (jobs != null && !jobs.isEmpty()) {
      return true;
    }
    return Shadows.shadowOf((Application) context.getApplicationContext()).getNextStartedService()
        != null;
  }
}
