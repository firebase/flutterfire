// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database

import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler
import io.flutter.plugin.common.BinaryMessenger.BinaryReply
import java.nio.ByteBuffer
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class FirebaseDatabasePluginTest {
  /** Records the transaction handler calls sent to Dart, which only replies when told to. */
  private class FakeDartMessenger : BinaryMessenger {
    val pendingReplies = LinkedBlockingQueue<BinaryReply>()

    override fun send(channel: String, message: ByteBuffer?) {}

    override fun send(channel: String, message: ByteBuffer?, callback: BinaryReply?) {
      callback?.let { pendingReplies.add(it) }
    }

    override fun setMessageHandler(channel: String, handler: BinaryMessageHandler?) {}
  }

  private val messenger = FakeDartMessenger()
  // The plugin only uses the messenger. The constructor is called reflectively because Kotlin
  // rejects null for its other, @NonNull, parameters.
  private val binding =
      FlutterPluginBinding::class
          .java
          .constructors
          .single()
          .newInstance(null, null, messenger, null, null, null, null) as FlutterPluginBinding
  private val rtdbRunLoop = Executors.newSingleThreadExecutor()

  @After
  fun tearDown() {
    rtdbRunLoop.shutdownNow()
  }

  private fun attachedPlugin(timeoutMillis: Long): FirebaseDatabasePlugin {
    // Runs the main-thread work inline, so the fake Dart side receives calls synchronously.
    val plugin = FirebaseDatabasePlugin(Executor { it.run() }, timeoutMillis)
    plugin.onAttachedToEngine(binding)
    return plugin
  }

  /** Calls the handler from a separate thread, as the RTDB SDK does from its run loop. */
  private fun callTransactionHandlerOnRunLoop(
      plugin: FirebaseDatabasePlugin
  ): Future<TransactionHandlerResult?> =
      rtdbRunLoop.submit<TransactionHandlerResult?> { plugin.callTransactionHandler(1, "current") }

  @Test
  fun callTransactionHandler_returnsTheResultFromDart() {
    val plugin = attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(1))

    val pending = callTransactionHandlerOnRunLoop(plugin)
    val reply = messenger.pendingReplies.poll(5, TimeUnit.SECONDS)!!
    val dartResult = TransactionHandlerResult(value = "updated", aborted = false, exception = false)
    reply.reply(
        FirebaseDatabaseFlutterApi.codec.encodeMessage(listOf(dartResult))?.apply { rewind() })

    assertEquals(dartResult, pending.get(5, TimeUnit.SECONDS))
  }

  @Test(timeout = 10_000)
  fun callTransactionHandler_abortsWhenDartNeverReplies() {
    val plugin = attachedPlugin(timeoutMillis = 100)

    assertNull(callTransactionHandlerOnRunLoop(plugin).get())
  }

  @Test(timeout = 10_000)
  fun onDetachedFromEngine_releasesAPendingTransactionHandler() {
    val plugin = attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(10))

    val pending = callTransactionHandlerOnRunLoop(plugin)
    // Dart received the call, and the engine goes away before it replies.
    messenger.pendingReplies.take()
    plugin.onDetachedFromEngine(binding)

    assertNull(pending.get())
  }

  @Test(timeout = 10_000)
  fun callTransactionHandler_abortsWithoutCallingDartAfterDetach() {
    val plugin = attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(10))
    plugin.onDetachedFromEngine(binding)

    assertNull(callTransactionHandlerOnRunLoop(plugin).get())
    assertTrue(messenger.pendingReplies.isEmpty())
  }
}
