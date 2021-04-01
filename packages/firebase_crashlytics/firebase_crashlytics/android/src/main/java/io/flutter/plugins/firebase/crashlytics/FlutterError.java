// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics;

import androidx.annotation.Keep;

/**
 * This class is purely cosmetic - to indicate on the Crashlytics console that it's a FlutterError
 * error rather than the generic `java.lang.Exception`.
 *
 * <p>Name matches iOS implementation.
 */
@Keep
public class FlutterError extends Exception {
  FlutterError(String message) {
    super(message);
  }
}
