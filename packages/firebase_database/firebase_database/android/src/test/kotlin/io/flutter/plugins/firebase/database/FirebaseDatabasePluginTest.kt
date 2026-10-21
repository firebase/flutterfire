// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database

import com.google.firebase.database.InternalHelpers
import com.google.firebase.database.MutableData
import com.google.firebase.database.Transaction
import com.google.firebase.database.snapshot.NodeUtilities
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler
import io.flutter.plugin.common.BinaryMessenger.BinaryReply
import java.nio.ByteBuffer
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit
import kotlin.Result as KotlinResult
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
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

  /** A transaction as the RTDB SDK drives it, with what the plugin reports to Dart. */
  private inner class TransactionRun(plugin: FirebaseDatabasePlugin) {
    var reported: KotlinResult<Unit>? = null
    val handler =
        plugin.transactionHandler(
            TransactionRequest(path = "counter", transactionKey = 1, applyLocally = true)) {
              reported = it
            }
    val mutableData: MutableData =
        InternalHelpers.createMutableData(NodeUtilities.NodeFromJSON("current"))

    /** Runs the handler on a separate thread, as the RTDB SDK does from its run loop. */
    fun doTransactionOnRunLoop(): Future<Transaction.Result> =
        rtdbRunLoop.submit<Transaction.Result> { handler.doTransaction(mutableData) }
  }

  private val messenger = FakeDartMessenger()
  private val rtdbRunLoop = Executors.newSingleThreadExecutor()

  @After
  fun tearDown() {
    rtdbRunLoop.shutdownNow()
  }

  private fun attachedPlugin(timeoutMillis: Long): FirebaseDatabasePlugin {
    // Runs the main-thread work inline, so the fake Dart side receives calls synchronously.
    val plugin = FirebaseDatabasePlugin(Executor { it.run() }, timeoutMillis)
    plugin.initPluginInstance(messenger)
    return plugin
  }

  private fun replyFromDart(result: TransactionHandlerResult) {
    messenger.pendingReplies
        .poll(5, TimeUnit.SECONDS)!!
        .reply(FirebaseDatabaseFlutterApi.codec.encodeMessage(listOf(result))?.apply { rewind() })
  }

  /** Asserts that Dart gets a `FirebaseException` with [code]. */
  private fun assertReportedFailure(code: String, reported: KotlinResult<Unit>?) {
    val error = reported!!.exceptionOrNull() as FlutterError
    // The Dart side reads the code of a `FirebaseException` from the details.
    assertEquals("firebase_database", error.code)
    assertEquals(code, (error.details as Map<*, *>)["code"])
  }

  @Test(timeout = 10_000)
  fun transaction_commitsTheValueFromDart() {
    val run = TransactionRun(attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(1)))

    val pending = run.doTransactionOnRunLoop()
    replyFromDart(TransactionHandlerResult(value = "updated", aborted = false, exception = false))

    assertTrue(pending.get().isSuccess)
    assertEquals("updated", run.mutableData.value)
    run.handler.onComplete(null, true, null)
    assertTrue(run.reported!!.isSuccess)
  }

  @Test(timeout = 10_000)
  fun transaction_abortedByDartCompletesWithoutAnError() {
    val run = TransactionRun(attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(1)))

    val pending = run.doTransactionOnRunLoop()
    replyFromDart(TransactionHandlerResult(value = null, aborted = true, exception = false))

    assertFalse(pending.get().isSuccess)
    run.handler.onComplete(null, false, null)
    // Dart reads `committed: false`.
    assertTrue(run.reported!!.isSuccess)
  }

  @Test(timeout = 10_000)
  fun transaction_failsWithDeadlineExceededWhenDartNeverReplies() {
    val run = TransactionRun(attachedPlugin(timeoutMillis = 100))

    assertFalse(run.doTransactionOnRunLoop().get().isSuccess)
    run.handler.onComplete(null, false, null)

    assertReportedFailure("deadline-exceeded", run.reported)
  }

  @Test(timeout = 10_000)
  fun detachFromEngine_failsAPendingTransaction() {
    val plugin = attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(10))
    val run = TransactionRun(plugin)

    val pending = run.doTransactionOnRunLoop()
    // Dart received the call, and the engine goes away before it replies.
    messenger.pendingReplies.take()
    plugin.detachFromEngine()

    assertFalse(pending.get().isSuccess)
    run.handler.onComplete(null, false, null)
    assertReportedFailure("cancelled", run.reported)
  }

  @Test(timeout = 10_000)
  fun transaction_failsWithoutCallingDartAfterDetach() {
    val plugin = attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(10))
    plugin.detachFromEngine()
    val run = TransactionRun(plugin)

    assertFalse(run.doTransactionOnRunLoop().get().isSuccess)
    assertTrue(messenger.pendingReplies.isEmpty())
    run.handler.onComplete(null, false, null)
    assertReportedFailure("cancelled", run.reported)
  }

  @Test(timeout = 10_000)
  fun initPluginInstance_callsDartAgainAfterADetach() {
    val plugin = attachedPlugin(timeoutMillis = TimeUnit.MINUTES.toMillis(1))
    plugin.detachFromEngine()
    plugin.initPluginInstance(messenger)
    val run = TransactionRun(plugin)

    val pending = run.doTransactionOnRunLoop()
    replyFromDart(TransactionHandlerResult(value = "updated", aborted = false, exception = false))

    assertTrue(pending.get().isSuccess)
  }
}
