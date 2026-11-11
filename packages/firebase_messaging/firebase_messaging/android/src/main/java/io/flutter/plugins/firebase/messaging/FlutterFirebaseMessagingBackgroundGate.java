// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * Reads the stored callback handle and the manifest opt-out, and decides whether this process
 * should start the background Dart handler.
 */
final class FlutterFirebaseMessagingBackgroundGate {
  static final String METADATA_KEY = "firebase_messaging_background_handler_enabled";

  private static final String TAG = "FLTFireBGExecutor";
  private static final Object manifestLock = new Object();
  private static final Executor clearExecutor = Executors.newSingleThreadExecutor();

  private static boolean manifestRead = false;
  @Nullable private static Boolean manifestEnabled;

  private FlutterFirebaseMessagingBackgroundGate() {}

  static BackgroundHandlerStartDecision.Action decide(Context context) {
    Context appContext = applicationContext(context);
    return BackgroundHandlerStartDecision.decide(
        FlutterFirebaseMessagingBackgroundExecutor.readPluginCallbackHandle(appContext),
        manifestEnabled(appContext));
  }

  /** True when the manifest opts out, including before the stored handles have been deleted. */
  static boolean handlerDisabled(Context context) {
    return Boolean.FALSE.equals(manifestEnabled(applicationContext(context)));
  }

  static void clearHandles(Context context) {
    FlutterFirebaseMessagingBackgroundExecutor.clearCallbackHandles(applicationContext(context));
  }

  /** Preference writes must not run on the main thread. Service startup calls this instead. */
  static void clearHandlesAsync(Context context) {
    Context appContext = applicationContext(context);
    clearExecutor.execute(() -> clearHandles(appContext));
  }

  @VisibleForTesting
  static void awaitClearForTests() throws InterruptedException {
    CountDownLatch latch = new CountDownLatch(1);
    clearExecutor.execute(latch::countDown);
    if (!latch.await(5, TimeUnit.SECONDS)) {
      throw new AssertionError("callback handle clear did not finish");
    }
  }

  @VisibleForTesting
  static void resetForTests() {
    synchronized (manifestLock) {
      manifestRead = false;
      manifestEnabled = null;
    }
  }

  @Nullable
  private static Boolean manifestEnabled(Context context) {
    synchronized (manifestLock) {
      if (manifestRead) {
        return manifestEnabled;
      }
    }
    if (context == null) {
      return null;
    }
    Boolean value = loadManifestEnabled(context);
    synchronized (manifestLock) {
      if (!manifestRead) {
        manifestEnabled = value;
        manifestRead = true;
      }
      return manifestEnabled;
    }
  }

  @Nullable
  private static Boolean loadManifestEnabled(Context context) {
    try {
      ApplicationInfo info =
          context
              .getPackageManager()
              .getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
      if (info.metaData == null || !info.metaData.containsKey(METADATA_KEY)) {
        return null;
      }
      return BackgroundHandlerStartDecision.manifestValue(info.metaData.get(METADATA_KEY));
    } catch (PackageManager.NameNotFoundException exception) {
      Log.w(TAG, "Could not read " + METADATA_KEY + " from the manifest.", exception);
      return null;
    }
  }

  @Nullable
  private static Context applicationContext(Context context) {
    if (context == null) {
      return null;
    }
    Context appContext = context.getApplicationContext();
    return appContext != null ? appContext : context;
  }
}
