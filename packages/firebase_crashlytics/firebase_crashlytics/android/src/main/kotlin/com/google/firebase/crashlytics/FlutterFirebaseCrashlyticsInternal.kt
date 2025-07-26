/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package com.google.firebase.crashlytics

import android.annotation.SuppressLint
import com.google.firebase.crashlytics.internal.Logger

/** @hide
 */
object FlutterFirebaseCrashlyticsInternal {
  private const val LOADING_UNIT_KEY = "com.crashlytics.flutter.build-id."
  private const val FLUTTER_BUILD_ID_DEFAULT_KEY = LOADING_UNIT_KEY + 0

  @SuppressLint("VisibleForTests")
  fun recordFatalException(throwable: Throwable?) {
    if (throwable == null) {
      Logger.getLogger().w("A null value was passed to recordFatalException. Ignoring.")
      return
    }
    FirebaseCrashlytics.getInstance().core.logFatalException(throwable)
  }

  @SuppressLint("VisibleForTests")
  fun setFlutterBuildId(buildId: String?) {
    FirebaseCrashlytics.getInstance().core.setInternalKey(FLUTTER_BUILD_ID_DEFAULT_KEY, buildId)
  }

  @SuppressLint("VisibleForTests")
  fun setLoadingUnits(loadingUnits: List<String?>) {
    var unit = 0
    for (loadingUnit in loadingUnits) {
      unit++
      FirebaseCrashlytics.getInstance().core.setInternalKey(LOADING_UNIT_KEY + unit, loadingUnit)
    }
  }
}
