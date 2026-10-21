// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.firebaseremoteconfig

import com.google.firebase.remoteconfig.ConfigUpdate
import com.google.firebase.remoteconfig.FirebaseRemoteConfigException
import io.flutter.plugin.common.EventChannel.EventSink
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class FirebaseRemoteConfigPluginTest {
  @Volatile private var mainThread: Thread? = null
  private val mainThreadExecutor: ExecutorService =
      Executors.newSingleThreadExecutor { runnable -> Thread(runnable).also { mainThread = it } }

  /** An [EventSink] that, like FlutterJNI, throws when it is used off the main thread. */
  private inner class MainThreadOnlyEventSink : EventSink {
    val received = LinkedBlockingQueue<String>()

    private fun ensureRunningOnMainThread() {
      if (Thread.currentThread() !== mainThread) {
        throw RuntimeException(
            "Methods marked with @UiThread must be executed on the main thread. Current thread: " +
                Thread.currentThread().name)
      }
    }

    override fun success(event: Any?) {
      ensureRunningOnMainThread()
      received.add("success $event")
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
      ensureRunningOnMainThread()
      received.add("error $errorCode: $errorMessage")
    }

    override fun endOfStream() {
      ensureRunningOnMainThread()
      received.add("endOfStream")
    }
  }

  private val events = MainThreadOnlyEventSink()

  @After
  fun tearDown() {
    mainThreadExecutor.shutdownNow()
  }

  @Test
  fun onError_isForwardedToDartOnTheMainThread() {
    val listener = FirebaseRemoteConfigPlugin.createConfigUpdateListener(events, mainThreadExecutor)

    // The SDK reports realtime errors from its own background executor, which is this test thread.
    listener.onError(
        FirebaseRemoteConfigException(
            "The connection to the realtime stream failed.",
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_STREAM_ERROR))

    assertEquals(
        "error firebase_remote_config: The connection to the realtime stream failed.",
        events.received.poll(5, TimeUnit.SECONDS))
  }

  @Test
  fun onUpdate_isForwardedToDartOnTheMainThread() {
    val listener = FirebaseRemoteConfigPlugin.createConfigUpdateListener(events, mainThreadExecutor)

    listener.onUpdate(ConfigUpdate.create(setOf("welcome_message")))

    assertEquals("success [welcome_message]", events.received.poll(5, TimeUnit.SECONDS))
  }
}
