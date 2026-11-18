// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions;

import androidx.annotation.Nullable;
import com.google.firebase.functions.FirebaseFunctionsException;

/**
 * Creates {@link FirebaseFunctionsException}s for tests. Its constructors are Kotlin {@code
 * internal}, so Kotlin code outside the SDK cannot call them, but Java can.
 */
final class TestFunctionsExceptions {
  private TestFunctionsExceptions() {}

  static FirebaseFunctionsException create(
      String message,
      FirebaseFunctionsException.Code code,
      @Nullable Object details,
      @Nullable Throwable cause) {
    // The four-argument constructor rejects a null cause.
    return cause == null
        ? new FirebaseFunctionsException(message, code, details)
        : new FirebaseFunctionsException(message, code, details, cause);
  }
}
