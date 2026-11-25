// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.firebaseremoteconfig

import com.google.firebase.remoteconfig.ConfigUpdate
import com.google.firebase.remoteconfig.ConfigUpdateListener
import com.google.firebase.remoteconfig.ConfigUpdateListenerRegistration
import com.google.firebase.remoteconfig.FirebaseRemoteConfigException
import com.google.firebase.remoteconfig.FirebaseRemoteConfigServerException
import io.flutter.plugin.common.EventChannel.EventSink
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
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
      received.add("error $errorCode: $errorMessage $errorDetails")
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

  private fun nextEvent(): String? = events.received.poll(5, TimeUnit.SECONDS)

  @Test
  fun onError_isForwardedToDartOnTheMainThread() {
    val listener = FirebaseRemoteConfigPlugin.createConfigUpdateListener(events, mainThreadExecutor)

    // The SDK reports realtime errors from its own background executor, which is this test thread.
    listener.onError(
        FirebaseRemoteConfigException(
            "The connection to the realtime stream failed.",
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_STREAM_ERROR))

    assertEquals(
        "error firebase_remote_config: The connection to the realtime stream failed. " +
            "{code=config-update-stream-error, " +
            "message=The connection to the realtime stream failed.}",
        nextEvent())
  }

  @Test
  fun onError_reportsAStableCodeForEachNativeCode() {
    val listener = FirebaseRemoteConfigPlugin.createConfigUpdateListener(events, mainThreadExecutor)
    val expectedCodes =
        mapOf(
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_STREAM_ERROR to
                "config-update-stream-error",
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_MESSAGE_INVALID to
                "config-update-message-invalid",
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_NOT_FETCHED to
                "config-update-not-fetched",
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_UNAVAILABLE to
                "config-update-unavailable",
            FirebaseRemoteConfigException.Code.UNKNOWN to "unknown",
        )
    assertEquals(FirebaseRemoteConfigException.Code.values().toSet(), expectedCodes.keys)

    for ((nativeCode, code) in expectedCodes) {
      listener.onError(FirebaseRemoteConfigException("message", nativeCode))

      assertEquals(
          "error firebase_remote_config: message {code=$code, message=message}", nextEvent())
    }
  }

  @Test
  fun onError_keepsTheHttpStatusInTheMessage() {
    val listener = FirebaseRemoteConfigPlugin.createConfigUpdateListener(events, mainThreadExecutor)

    listener.onError(
        FirebaseRemoteConfigServerException(
            503,
            "Unable to connect to the server. Try again in a few minutes. HTTP status code: 503",
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_STREAM_ERROR))

    val event = nextEvent()
    assertNotNull(event)
    assertTrue(event!!, event.contains("code=config-update-stream-error"))
    assertTrue(event, event.contains("message=Unable to connect") && event.endsWith("503}"))
  }

  @Test
  fun onUpdate_isForwardedToDartOnTheMainThread() {
    val listener = FirebaseRemoteConfigPlugin.createConfigUpdateListener(events, mainThreadExecutor)

    listener.onUpdate(ConfigUpdate.create(setOf("welcome_message")))

    assertEquals("success [welcome_message]", nextEvent())
  }

  @Test
  fun onListen_registersAListenerThatReportsOnTheMainThread() {
    val registered = LinkedBlockingQueue<Pair<String, ConfigUpdateListener>>()
    var removed = false
    val plugin =
        FirebaseRemoteConfigPlugin(mainThreadExecutor) { appName, listener ->
          registered.add(appName to listener)
          ConfigUpdateListenerRegistration { removed = true }
        }

    plugin.onListen(mapOf("appName" to "[DEFAULT]"), events)

    val (appName, listener) = registered.single()
    assertEquals("[DEFAULT]", appName)

    // Both callbacks come from the SDK's background executor, which is this test thread.
    listener.onError(
        FirebaseRemoteConfigException(
            "Unable to fetch the latest version of the template.",
            FirebaseRemoteConfigException.Code.CONFIG_UPDATE_NOT_FETCHED))
    listener.onUpdate(ConfigUpdate.create(setOf("welcome_message")))

    assertEquals(
        "error firebase_remote_config: Unable to fetch the latest version of the template. " +
            "{code=config-update-not-fetched, " +
            "message=Unable to fetch the latest version of the template.}",
        nextEvent())
    assertEquals("success [welcome_message]", nextEvent())

    plugin.onCancel(mapOf("appName" to "[DEFAULT]"))
    assertTrue(removed)
  }
}
