/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package com.google.firebase.crashlytics

import android.annotation.SuppressLint
import com.google.firebase.crashlytics.internal.Logger

/** @hide */
class FlutterFirebaseCrashlyticsInternal private constructor() {
  companion object {
    private const val LOADING_UNIT_KEY = "com.crashlytics.flutter.build-id."
    private const val FLUTTER_BUILD_ID_DEFAULT_KEY = "${LOADING_UNIT_KEY}0"

    @JvmStatic
    @SuppressLint("VisibleForTests")
    fun recordFatalException(throwable: Throwable?) {
      if (throwable == null) {
        Logger.getLogger().w("A null value was passed to recordFatalException. Ignoring.")
        return
      }
      FirebaseCrashlytics.getInstance().core.logFatalException(throwable)
    }

    @JvmStatic
    @SuppressLint("VisibleForTests")
    fun setFlutterBuildId(buildId: String) {
      FirebaseCrashlytics.getInstance().core.setInternalKey(FLUTTER_BUILD_ID_DEFAULT_KEY, buildId)
    }

    @JvmStatic
    @SuppressLint("VisibleForTests")
    fun setLoadingUnits(loadingUnits: List<String>) {
      loadingUnits.forEachIndexed { index, loadingUnit ->
        FirebaseCrashlytics.getInstance()
          .core
          .setInternalKey("$LOADING_UNIT_KEY${index + 1}", loadingUnit)
      }
    }
  }
}
