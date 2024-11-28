/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package com.google.firebase.crashlytics;

import android.annotation.SuppressLint;
import com.google.firebase.crashlytics.internal.Logger;
import java.util.List;

/** @hide */
public final class FlutterFirebaseCrashlyticsInternal {
  private static final String LOADING_UNIT_KEY = "com.crashlytics.flutter.build-id.";
  private static final String FLUTTER_BUILD_ID_DEFAULT_KEY = LOADING_UNIT_KEY + 0;

  @SuppressLint("VisibleForTests")
  public static void recordFatalException(Throwable throwable) {
    if (throwable == null) {
      Logger.getLogger().w("A null value was passed to recordFatalException. Ignoring.");
      return;
    }
    FirebaseCrashlytics.getInstance().core.logFatalException(throwable);
  }

  @SuppressLint("VisibleForTests")
  public static void setFlutterBuildId(String buildId) {
    FirebaseCrashlytics.getInstance().core.setInternalKey(FLUTTER_BUILD_ID_DEFAULT_KEY, buildId);
  }

  @SuppressLint("VisibleForTests")
  public static void setLoadingUnits(List<String> loadingUnits) {
    int unit = 0;
    for (String loadingUnit : loadingUnits) {
      unit++;
      FirebaseCrashlytics.getInstance().core.setInternalKey(LOADING_UNIT_KEY + unit, loadingUnit);
    }
  }

  private FlutterFirebaseCrashlyticsInternal() {}
}
