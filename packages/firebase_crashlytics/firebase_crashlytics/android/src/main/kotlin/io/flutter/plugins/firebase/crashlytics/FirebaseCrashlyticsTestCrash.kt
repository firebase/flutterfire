// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.crashlytics

import androidx.annotation.Keep

/**
 * This class is purely cosmetic - to indicate on the Crashlytics console that it's a
 * FirebaseCrashlyticsTestCrash error rather than the generic `java.lang.RuntimeException`.
 *
 *
 * Name and message match iOS implementation.
 */
@Keep
class FirebaseCrashlyticsTestCrash internal constructor() :
  RuntimeException("This is a test crash caused by calling .crash() in Dart.")
