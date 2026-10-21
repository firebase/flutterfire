// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
package io.flutter.plugins.firebase.storage

/**
 * The in-progress tasks of one plugin instance, keyed by their Dart handle.
 *
 * Handles come from a per-isolate counter, so each Flutter engine needs its own registry: with a
 * shared one, engines overwrite each other's tasks, and detaching one engine cancels them all.
 */
internal class FlutterFirebaseStorageTaskRegistry<T : Any> {
  private val tasks = HashMap<Int, T>()

  @Synchronized
  fun put(handle: Int, task: T) {
    tasks[handle] = task
  }

  @Synchronized fun get(handle: Int): T? = tasks[handle]

  /** Removes [task], unless [handle] now belongs to another task. */
  @Synchronized
  fun remove(handle: Int, task: T) {
    if (tasks[handle] === task) tasks.remove(handle)
  }

  /** Removes and returns all tasks. */
  @Synchronized
  fun removeAll(): List<T> {
    val all = ArrayList(tasks.values)
    tasks.clear()
    return all
  }
}
