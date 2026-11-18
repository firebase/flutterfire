// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions;

import android.content.ContextWrapper;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.functions.FirebaseFunctions;

/**
 * Creates a {@link FirebaseFunctions} for tests that never reach the network. Its constructor is
 * Kotlin {@code internal}, so Kotlin code outside the SDK cannot call it, but Java can.
 */
final class TestFirebaseFunctions {
  private TestFirebaseFunctions() {}

  static FirebaseFunctions create() {
    return new FirebaseFunctions(
        new ContextWrapper(null),
        "test-project",
        "us-central1",
        limitedUseAppCheckTokens -> Tasks.forResult(null),
        Runnable::run,
        // Drops the security provider install, which needs a device.
        command -> {});
  }
}
