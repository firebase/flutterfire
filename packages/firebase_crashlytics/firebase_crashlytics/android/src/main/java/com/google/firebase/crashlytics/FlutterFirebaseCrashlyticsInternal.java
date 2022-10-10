package com.google.firebase.crashlytics;

import android.annotation.SuppressLint;
import com.google.firebase.crashlytics.internal.Logger;

/** @hide */
public final class FlutterFirebaseCrashlyticsInternal {
  @SuppressLint("VisibleForTests")
  public static void recordFatalException(Throwable throwable) {
    if (throwable == null) {
      Logger.getLogger().w("A null value was passed to recordFatalException. Ignoring.");
      return;
    }
    FirebaseCrashlytics.getInstance().core.logFatalException(throwable);
  }

  private FlutterFirebaseCrashlyticsInternal() {}
}
