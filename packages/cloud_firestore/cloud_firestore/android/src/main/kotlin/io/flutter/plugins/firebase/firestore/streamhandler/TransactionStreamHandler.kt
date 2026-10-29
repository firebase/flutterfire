/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler

import android.os.Handler
import android.os.Looper
import com.google.firebase.firestore.FieldPath
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import com.google.firebase.firestore.FirebaseFirestoreException.Code
import com.google.firebase.firestore.SetOptions
import com.google.firebase.firestore.Transaction
import com.google.firebase.firestore.TransactionOptions
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreTransactionResult
import io.flutter.plugins.firebase.firestore.InternalTransactionCommand
import io.flutter.plugins.firebase.firestore.InternalTransactionResult
import io.flutter.plugins.firebase.firestore.InternalTransactionType
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter
import io.flutter.plugins.firebase.firestore.utils.PigeonParser
import java.util.concurrent.Semaphore
import java.util.concurrent.TimeUnit

class TransactionStreamHandler(
    private val onTransactionStartedListener: (Transaction) -> Unit,
    private val onTransactionCancelledListener: (String) -> Unit,
    private val firestore: FirebaseFirestore,
    private val transactionId: String,
    private val timeout: Long,
    private val maxAttempts: Long
) : OnTransactionResultListener, StreamHandler {
  private val semaphore = Semaphore(0)
  private val attemptState = TransactionAttemptState()
  private val mainLooper = Handler(Looper.getMainLooper())

  override fun onListen(arguments: Any?, events: EventSink) {
    firestore
        .runTransaction(
            TransactionOptions.Builder().setMaxAttempts(maxAttempts.toInt()).build(),
            Transaction.Function { transaction ->
              // A retry must not see the previous attempt. Cancelling this attempt before Dart
              // answers would otherwise commit those commands.
              attemptState.beginAttempt()
              onTransactionStartedListener(transaction)

              val attemptMap = hashMapOf<String, Any>("appName" to firestore.app.name)
              mainLooper.post { events.success(attemptMap) }

              try {
                if (!semaphore.tryAcquire(timeout, TimeUnit.MILLISECONDS)) {
                  // Throw a non-FirebaseFirestoreException so the Android SDK
                  // does not retry or commit. Returning a failed result object
                  // makes apply() succeed, which commits and then crashes a later
                  // transaction.get (see #18666).
                  throw RuntimeException(
                      FirebaseFirestoreException("timed out", Code.DEADLINE_EXCEEDED))
                }
              } catch (e: InterruptedException) {
                throw RuntimeException(
                    FirebaseFirestoreException("interrupted", Code.DEADLINE_EXCEEDED))
              }

              // Only an explicit SUCCESS with a command list may commit. A Dart failure, a
              // cancel, or a retry that has not heard back yet aborts. Throw outside
              // FirebaseFirestoreException so the SDK does not retry or commit (#18666).
              val resolvedCommands = attemptState.outcome()
              if (resolvedCommands.isEmpty()) {
                return@Function FlutterFirebaseFirestoreTransactionResult.complete()
              }

              for (command in resolvedCommands) {
                if (command == null) continue
                val documentReference = firestore.document(command.path)
                when (command.type) {
                  InternalTransactionType.GET -> {}
                  InternalTransactionType.DELETE_TYPE -> transaction.delete(documentReference)
                  InternalTransactionType.UPDATE -> {
                    val rawData = requireNotNull(command.data)
                    val updateData = HashMap<FieldPath, Any?>()
                    for (key in rawData.keys) {
                      when (key) {
                        is String -> updateData[FieldPath.of(key)] = rawData[key]
                        is FieldPath -> updateData[key] = rawData[key]
                      }
                    }
                    val firstFieldPath = updateData.keys.iterator().next()
                    val firstObject = updateData[firstFieldPath]
                    val flattenData = ArrayList<Any?>()
                    for (fieldPath in updateData.keys) {
                      if (fieldPath == firstFieldPath) continue
                      flattenData.add(fieldPath)
                      flattenData.add(updateData[fieldPath])
                    }
                    transaction.update(
                        documentReference, firstFieldPath, firstObject, *flattenData.toTypedArray())
                  }
                  InternalTransactionType.SET -> {
                    val options = requireNotNull(command.option)
                    var setOptions: SetOptions? = null
                    if (options.merge == true) {
                      setOptions = SetOptions.merge()
                    } else if (options.mergeFields != null) {
                      val fieldPathList = PigeonParser.parseFieldPath(options.mergeFields!!)
                      setOptions = SetOptions.mergeFieldPaths(fieldPathList)
                    }

                    @Suppress("UNCHECKED_CAST")
                    val data = requireNotNull(command.data) as Map<String, Any>
                    if (setOptions == null) {
                      transaction.set(documentReference, data)
                    } else {
                      transaction.set(documentReference, data, setOptions)
                    }
                  }
                }
              }
              FlutterFirebaseFirestoreTransactionResult.complete()
            })
        .addOnCompleteListener { task ->
          val taskException = task.exception
          val map =
              transactionTaskEvent(
                  firestore.app.name,
                  taskException,
                  if (taskException == null) task.result else null)

          mainLooper.post {
            events.success(map)
            events.endOfStream()
          }
        }
  }

  override fun onCancel(arguments: Any?) {
    semaphore.release()
    notifyTransactionCancelled(arguments, transactionId, onTransactionCancelledListener)
  }

  override fun receiveTransactionResponse(
      resultType: InternalTransactionResult,
      commands: List<InternalTransactionCommand?>?
  ) {
    attemptState.receive(resultType, commands)
    semaphore.release()
  }
}

internal class TransactionAttemptState {
  private var resultType: InternalTransactionResult? = null
  private var commands: List<InternalTransactionCommand?>? = null

  fun beginAttempt() {
    resultType = null
    commands = null
  }

  fun receive(resultType: InternalTransactionResult, commands: List<InternalTransactionCommand?>?) {
    this.resultType = resultType
    this.commands = commands
  }

  fun outcome(): List<InternalTransactionCommand?> {
    return commandsForTransactionAttempt(resultType, commands)
  }
}

internal fun commandsForTransactionAttempt(
    resultType: InternalTransactionResult?,
    commands: List<InternalTransactionCommand?>?
): List<InternalTransactionCommand?> {
  if (resultType != InternalTransactionResult.SUCCESS || commands == null) {
    throw RuntimeException(FirebaseFirestoreException("transaction aborted", Code.ABORTED))
  }
  return commands
}

internal fun transactionTaskEvent(
    appName: String,
    taskException: Exception?,
    result: FlutterFirebaseFirestoreTransactionResult?
): HashMap<String, Any?> {
  val map = HashMap<String, Any?>()
  val exception = taskException ?: result?.exception
  if (exception != null) {
    map["appName"] = appName
    map["error"] = ExceptionConverter.createDetails(exception)
  } else if (result != null) {
    map["complete"] = true
  }
  return map
}

internal fun notifyTransactionCancelled(
    arguments: Any?,
    transactionId: String,
    onTransactionCancelled: (String) -> Unit
) {
  // FlutterFirebaseFirestorePlugin passes null when disposing all listeners and clears the
  // listener maps itself. A non-null value identifies Dart's EventChannel cancellation.
  if (arguments != null) {
    onTransactionCancelled(transactionId)
  }
}
