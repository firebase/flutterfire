// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.inappmessaging

import android.app.Activity
import android.app.Application
import android.os.Bundle
import com.google.firebase.inappmessaging.FirebaseInAppMessagingClickListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDismissListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplay
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplayErrorListener
import com.google.firebase.inappmessaging.FirebaseInAppMessagingImpressionListener
import io.flutter.plugin.common.BinaryMessenger
import java.nio.ByteBuffer
import java.util.concurrent.Executor
import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class FirebaseInAppMessagingPluginTest {
  private val sdk = FakeSdk()
  private val application = FakeApplication()
  private val activity = Activity()
  private val messenger = FakeBinaryMessenger()

  @Before
  fun setUp() {
    // `firebase-inappmessaging-display` registers its callbacks when Firebase
    // initializes, before any plugin does.
    application.registerActivityLifecycleCallbacks(sdk.defaultDisplayLifecycle)
  }

  private fun attachPlugin(): FirebaseInAppMessagingPlugin =
      FirebaseInAppMessagingPlugin(Executor { it.run() }, sdk).apply {
        onAttachedToEngine(application, messenger)
      }

  private fun FirebaseInAppMessagingPlugin.addEventListeners() {
    var result: Result<Unit>? = null
    addEventListeners("[DEFAULT]") { result = it }
    assertTrue(result!!.isSuccess)
  }

  private fun FirebaseInAppMessagingPlugin.setCustomDisplayEnabled(enabled: Boolean) {
    var result: Result<Unit>? = null
    setCustomDisplayEnabled("[DEFAULT]", enabled) { result = it }
    assertTrue(result!!.isSuccess)
  }

  @Test
  fun addEventListeners_addsTheListeners() {
    attachPlugin().addEventListeners()

    assertEquals(4, sdk.listeners.size)
  }

  @Test
  fun listenersAreAddedAgainWhenAnActivityResumes() {
    attachPlugin().addEventListeners()
    application.resume(activity)

    application.pause(activity)
    assertEquals(0, sdk.listeners.size)
    application.resume(activity)
    assertEquals(4, sdk.listeners.size)

    application.pause(activity)
    application.resume(activity)
    assertEquals(4, sdk.listeners.size)
  }

  @Test
  fun onDetachedFromEngine_stopsAddingTheListeners() {
    val plugin = attachPlugin()
    plugin.addEventListeners()

    plugin.onDetachedFromEngine(messenger)
    assertEquals(0, sdk.listeners.size)

    application.pause(activity)
    application.resume(activity)
    assertEquals(0, sdk.listeners.size)
    assertEquals(listOf(sdk.defaultDisplayLifecycle), application.callbacks)
  }

  @Test
  fun disablingCustomDisplay_rebindsTheDefaultDisplayAndKeepsTheListeners() {
    val plugin = attachPlugin()
    plugin.addEventListeners()
    plugin.setCustomDisplayEnabled(true)
    application.resume(activity)
    assertSame(plugin, sdk.displayComponent)

    plugin.setCustomDisplayEnabled(false)

    assertEquals(1, sdk.defaultDisplayRebinds)
    assertSame(sdk.defaultDisplay, sdk.displayComponent)
    assertEquals(4, sdk.listeners.size)
  }

  @Test
  fun disablingCustomDisplayThatIsOff_leavesTheDefaultDisplayAlone() {
    val plugin = attachPlugin()
    plugin.addEventListeners()
    // Another Flutter engine's plugin.
    attachPlugin().addEventListeners()
    application.resume(activity)

    plugin.setCustomDisplayEnabled(false)

    assertEquals(0, sdk.defaultDisplayRebinds)
    assertEquals(8, sdk.listeners.size)
  }

  @Test
  fun onDetachedFromEngine_withCustomDisplayOff_leavesTheDefaultDisplayAlone() {
    val plugin = attachPlugin()
    plugin.addEventListeners()
    application.resume(activity)

    plugin.onDetachedFromEngine(messenger)

    assertEquals(0, sdk.defaultDisplayRebinds)
  }
}

/** Stands in for `FirebaseInAppMessaging` and `firebase-inappmessaging-display`. */
private class FakeSdk : InAppMessagingSdk {
  val listeners = mutableListOf<Any>()
  var displayComponent: FirebaseInAppMessagingDisplay? = null
  var defaultDisplayRebinds = 0
  val defaultDisplay = FirebaseInAppMessagingDisplay { _, _ -> }

  /** What `firebase-inappmessaging-display` does on activity pause and resume. */
  val defaultDisplayLifecycle =
      object : TestActivityLifecycleCallbacks() {
        override fun onActivityResumed(activity: Activity) {
          displayComponent = defaultDisplay
        }

        override fun onActivityPaused(activity: Activity) {
          // `removeAllListeners()`
          listeners.clear()
        }
      }

  override fun addListeners(
      click: FirebaseInAppMessagingClickListener,
      impression: FirebaseInAppMessagingImpressionListener,
      dismiss: FirebaseInAppMessagingDismissListener,
      displayError: FirebaseInAppMessagingDisplayErrorListener,
      executor: Executor,
  ) {
    listeners.addAll(listOf(click, impression, dismiss, displayError))
  }

  override fun removeListeners(
      click: FirebaseInAppMessagingClickListener,
      impression: FirebaseInAppMessagingImpressionListener,
      dismiss: FirebaseInAppMessagingDismissListener,
      displayError: FirebaseInAppMessagingDisplayErrorListener,
  ) {
    listeners.removeAll(listOf(click, impression, dismiss, displayError))
  }

  override fun setMessageDisplayComponent(display: FirebaseInAppMessagingDisplay) {
    displayComponent = display
  }

  override fun rebindDefaultDisplay(activity: Activity) {
    defaultDisplayRebinds++
    defaultDisplayLifecycle.onActivityPaused(activity)
    defaultDisplayLifecycle.onActivityResumed(activity)
  }
}

private class FakeApplication : Application() {
  val callbacks = mutableListOf<ActivityLifecycleCallbacks>()

  override fun registerActivityLifecycleCallbacks(callback: ActivityLifecycleCallbacks) {
    callbacks += callback
  }

  override fun unregisterActivityLifecycleCallbacks(callback: ActivityLifecycleCallbacks) {
    callbacks -= callback
  }

  fun resume(activity: Activity) = callbacks.toList().forEach { it.onActivityResumed(activity) }

  fun pause(activity: Activity) = callbacks.toList().forEach { it.onActivityPaused(activity) }
}

private open class TestActivityLifecycleCallbacks : Application.ActivityLifecycleCallbacks {
  override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}

  override fun onActivityStarted(activity: Activity) {}

  override fun onActivityResumed(activity: Activity) {}

  override fun onActivityPaused(activity: Activity) {}

  override fun onActivityStopped(activity: Activity) {}

  override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

  override fun onActivityDestroyed(activity: Activity) {}
}

private class FakeBinaryMessenger : BinaryMessenger {
  override fun send(channel: String, message: ByteBuffer?) {}

  override fun send(
      channel: String,
      message: ByteBuffer?,
      callback: BinaryMessenger.BinaryReply?
  ) {}

  override fun setMessageHandler(channel: String, handler: BinaryMessenger.BinaryMessageHandler?) {}
}
