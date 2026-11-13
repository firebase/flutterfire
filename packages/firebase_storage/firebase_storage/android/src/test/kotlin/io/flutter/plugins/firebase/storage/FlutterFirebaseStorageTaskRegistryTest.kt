// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
package io.flutter.plugins.firebase.storage

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class FlutterFirebaseStorageTaskRegistryTest {
  private class FakeTask(val name: String)

  @Test
  fun sameHandleInTwoEnginesDoesNotCollide() {
    // Every engine's Dart isolate numbers its tasks from 0.
    val mainEngine = FlutterFirebaseStorageTaskRegistry<FakeTask>()
    val backgroundEngine = FlutterFirebaseStorageTaskRegistry<FakeTask>()
    val mainTask = FakeTask("main")
    val backgroundTask = FakeTask("background")

    mainEngine.put(0, mainTask)
    backgroundEngine.put(0, backgroundTask)

    assertSame(mainTask, mainEngine.get(0))
    assertSame(backgroundTask, backgroundEngine.get(0))
  }

  @Test
  fun removeAllOnlyAffectsItsOwnEngine() {
    val mainEngine = FlutterFirebaseStorageTaskRegistry<FakeTask>()
    val backgroundEngine = FlutterFirebaseStorageTaskRegistry<FakeTask>()
    val mainTask = FakeTask("main")
    val backgroundTask = FakeTask("background")
    mainEngine.put(0, mainTask)
    backgroundEngine.put(0, backgroundTask)

    // What onDetachedFromEngine does for the detaching engine.
    assertEquals(listOf(backgroundTask), backgroundEngine.removeAll())

    assertNull(backgroundEngine.get(0))
    assertSame(mainTask, mainEngine.get(0))
    assertTrue(backgroundEngine.removeAll().isEmpty())
  }

  @Test
  fun removeKeepsANewerTaskWithTheSameHandle() {
    val registry = FlutterFirebaseStorageTaskRegistry<FakeTask>()
    val oldTask = FakeTask("old")
    val newTask = FakeTask("new")
    registry.put(0, oldTask)
    // A hot restart resets the Dart handle counter.
    registry.put(0, newTask)

    registry.remove(0, oldTask)
    assertSame(newTask, registry.get(0))

    registry.remove(0, newTask)
    assertNull(registry.get(0))
  }
}
