// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore.streamhandler

import com.google.firebase.firestore.FirebaseFirestoreException
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreTransactionResult
import io.flutter.plugins.firebase.firestore.InternalTransactionCommand
import io.flutter.plugins.firebase.firestore.InternalTransactionResult
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class TransactionStreamHandlerTest {
  @Test
  fun failureWithNullCommandsAbortsWithoutCommit() {
    assertAborted { commandsForTransactionAttempt(InternalTransactionResult.FAILURE, null) }
  }

  @Test
  fun successWithNullCommandsAborts() {
    assertAborted { commandsForTransactionAttempt(InternalTransactionResult.SUCCESS, null) }
  }

  @Test
  fun cancelBeforeResultAborts() {
    assertAborted { commandsForTransactionAttempt(null, null) }
  }

  @Test
  fun missingResultDoesNotApplyLeftoverCommands() {
    assertAborted { commandsForTransactionAttempt(null, emptyList()) }
  }

  @Test
  fun retryThenCancelDoesNotReplayPreviousCommands() {
    val state = TransactionAttemptState()
    state.receive(InternalTransactionResult.SUCCESS, listOf(null))
    state.beginAttempt()
    assertAborted { state.outcome() }
  }

  @Test
  fun retryUsesOnlyTheCommandsStoredForThatAttempt() {
    val state = TransactionAttemptState()
    val previous = listOf<InternalTransactionCommand?>(null)
    val next = emptyList<InternalTransactionCommand?>()
    state.receive(InternalTransactionResult.SUCCESS, previous)
    state.beginAttempt()
    state.receive(InternalTransactionResult.SUCCESS, next)
    assertSame(next, state.outcome())
  }

  @Test
  fun failureWithCommandsAborts() {
    assertAborted { commandsForTransactionAttempt(InternalTransactionResult.FAILURE, emptyList()) }
  }

  @Test
  fun successWithEmptyCommandsContinues() {
    val commands = emptyList<InternalTransactionCommand?>()
    assertSame(commands, commandsForTransactionAttempt(InternalTransactionResult.SUCCESS, commands))
  }

  @Test
  fun failedTaskEventCarriesAppNameAndError() {
    val exception =
        FirebaseFirestoreException("transaction aborted", FirebaseFirestoreException.Code.ABORTED)
    val event = transactionTaskEvent("app", exception, null)
    assertEquals("app", event["appName"])
    @Suppress("UNCHECKED_CAST") val error = event["error"] as Map<String, String>
    assertEquals("aborted", error["code"])
    assertFalse(event.containsKey("complete"))
  }

  @Test
  fun failedResultEventCarriesError() {
    val exception =
        FirebaseFirestoreException("transaction aborted", FirebaseFirestoreException.Code.ABORTED)
    val event =
        transactionTaskEvent(
            "app", null, FlutterFirebaseFirestoreTransactionResult.failed(exception))
    assertEquals("app", event["appName"])
    assertTrue(event.containsKey("error"))
    assertFalse(event.containsKey("complete"))
  }

  @Test
  fun successfulResultEventIsComplete() {
    val event =
        transactionTaskEvent("app", null, FlutterFirebaseFirestoreTransactionResult.complete())
    assertEquals(true, event["complete"])
    assertFalse(event.containsKey("error"))
  }

  @Test
  fun missingTaskResultDoesNotThrow() {
    val event = transactionTaskEvent("app", null, null)
    assertTrue(event.isEmpty())
  }

  @Test
  fun disposeCancelDoesNotRemoveTransaction() {
    var called = false
    notifyTransactionCancelled(null, "tx-1") { called = true }
    assertFalse(called)
  }

  @Test
  fun dartCancelRemovesTransaction() {
    var id: String? = null
    notifyTransactionCancelled("cancelled-by-dart", "tx-1") { id = it }
    assertEquals("tx-1", id)
  }

  private fun assertAborted(body: () -> Unit) {
    try {
      body()
    } catch (thrown: RuntimeException) {
      val cause = thrown.cause as FirebaseFirestoreException
      assertEquals(FirebaseFirestoreException.Code.ABORTED, cause.code)
      return
    }
    throw AssertionError("expected the transaction attempt to abort")
  }
}
