// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.crashlytics

import androidx.annotation.Keep

/**
 * This class is purely cosmetic - to indicate on the Crashlytics console that it's a FlutterError
 * error rather than the generic `java.lang.Exception`.
 *
 *
 * Name matches iOS implementation.
 */
@Keep
class FirebaseCrashlyticsFlutterError internal constructor(message: String?) : Exception(message)
