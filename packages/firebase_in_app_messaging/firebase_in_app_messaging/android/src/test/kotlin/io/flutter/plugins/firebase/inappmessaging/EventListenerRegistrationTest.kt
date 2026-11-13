// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.inappmessaging

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class EventListenerRegistrationTest {
  // Stands in for the listeners registered with `FirebaseInAppMessaging`.
  private var sdkHasListeners = false
  private var addCount = 0

  private val registration =
      EventListenerRegistration(
          addListeners = {
            sdkHasListeners = true
            addCount++
          },
          removeListeners = { sdkHasListeners = false },
      )

  /** What `FirebaseInAppMessagingDisplay` and the plugin do on pause and resume. */
  private fun pauseAndResumeActivity() {
    sdkHasListeners = false // `removeAllListeners()`
    registration.onRemovedBySdk()
    registration.restore()
  }

  @Test
  fun add_registersTheListenersOnce() {
    registration.add()
    registration.add()

    assertTrue(sdkHasListeners)
    assertEquals(1, addCount)
  }

  @Test
  fun listenersAreAddedAgainAfterAnActivityPause() {
    registration.add()

    pauseAndResumeActivity()
    assertTrue(sdkHasListeners)

    pauseAndResumeActivity()
    assertTrue(sdkHasListeners)
    assertEquals(3, addCount)
  }

  @Test
  fun resumeDoesNotAddListenersThatAreNotWanted() {
    pauseAndResumeActivity()

    assertFalse(sdkHasListeners)
    assertEquals(0, addCount)
  }

  @Test
  fun remove_stopsAddingTheListenersAgain() {
    registration.add()
    registration.remove()
    assertFalse(sdkHasListeners)

    pauseAndResumeActivity()
    assertFalse(sdkHasListeners)
    assertFalse(registration.isWanted)
  }
}
