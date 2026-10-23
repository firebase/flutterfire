// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.inappmessaging

/**
 * Tracks whether the message lifecycle listeners should be registered with
 * `FirebaseInAppMessaging`, separately from whether they currently are.
 *
 * `firebase-inappmessaging-display` calls `removeAllListeners()` every time an activity pauses, so
 * the listeners have to be added again when an activity resumes, for as long as Dart wants the
 * events.
 */
internal class EventListenerRegistration(
    private val addListeners: () -> Unit,
    private val removeListeners: () -> Unit,
) {
  var isWanted = false
    private set

  private var isAdded = false

  /** Starts forwarding the events, and keeps doing so until [remove]. */
  fun add() {
    isWanted = true
    restore()
  }

  fun remove() {
    isWanted = false
    if (isAdded) {
      isAdded = false
      removeListeners()
    }
  }

  /** The SDK dropped every listener, as it does in `onActivityPaused`. */
  fun onRemovedBySdk() {
    isAdded = false
  }

  /** Adds the listeners again if they are wanted and were dropped. */
  fun restore() {
    if (isWanted && !isAdded) {
      addListeners()
      isAdded = true
    }
  }
}
