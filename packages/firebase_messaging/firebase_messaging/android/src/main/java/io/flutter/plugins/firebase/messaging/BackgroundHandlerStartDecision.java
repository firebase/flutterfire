// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

/**
 * Whether a background message should start the Dart handler.
 *
 * <p>{@code manifestEnabled} is null when the app manifest does not set {@code
 * firebase_messaging_background_handler_enabled}.
 */
final class BackgroundHandlerStartDecision {
  enum Action {
    START,
    SKIP,
    SKIP_AND_CLEAR
  }

  private BackgroundHandlerStartDecision() {}

  static Action decide(long callbackHandle, Boolean manifestEnabled) {
    if (Boolean.FALSE.equals(manifestEnabled)) {
      return Action.SKIP_AND_CLEAR;
    }
    if (callbackHandle == 0L) {
      return Action.SKIP;
    }
    return Action.START;
  }

  /**
   * The manifest value for the background handler, or null when the entry is absent or not a
   * boolean. Android stores {@code android:value="false"} as a boolean, and sometimes as the string
   * {@code "false"}.
   */
  static Boolean manifestValue(Object raw) {
    if (raw instanceof Boolean) {
      return (Boolean) raw;
    }
    if (raw instanceof String) {
      String value = (String) raw;
      if ("true".equalsIgnoreCase(value)) {
        return Boolean.TRUE;
      }
      if ("false".equalsIgnoreCase(value)) {
        return Boolean.FALSE;
      }
    }
    return null;
  }
}
