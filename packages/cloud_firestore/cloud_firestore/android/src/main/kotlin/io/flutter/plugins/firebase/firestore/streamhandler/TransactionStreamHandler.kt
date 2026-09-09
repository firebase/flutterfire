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
  private var resultType: InternalTransactionResult? = null
  private var commands: List<InternalTransactionCommand?>? = null
  private val mainLooper = Handler(Looper.getMainLooper())

  override fun onListen(arguments: Any?, events: EventSink) {
    firestore
        .runTransaction(
            TransactionOptions.Builder().setMaxAttempts(maxAttempts.toInt()).build(),
            Transaction.Function { transaction ->
              onTransactionStartedListener(transaction)

              val attemptMap = hashMapOf<String, Any>("appName" to firestore.app.name)
              mainLooper.post { events.success(attemptMap) }

              try {
                if (!semaphore.tryAcquire(timeout, TimeUnit.MILLISECONDS)) {
                  return@Function FlutterFirebaseFirestoreTransactionResult.failed(
                      FirebaseFirestoreException("timed out", Code.DEADLINE_EXCEEDED))
                }
              } catch (e: InterruptedException) {
                return@Function FlutterFirebaseFirestoreTransactionResult.failed(
                    FirebaseFirestoreException("interrupted", Code.DEADLINE_EXCEEDED))
              }

              val resolvedCommands = commands
              if (resolvedCommands.isNullOrEmpty()) {
                return@Function FlutterFirebaseFirestoreTransactionResult.complete()
              }

              if (resultType == InternalTransactionResult.FAILURE) {
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
          val map = HashMap<String, Any?>()
          val resultException = task.result?.exception
          if (task.exception != null || resultException != null) {
            val exception = task.exception ?: resultException
            map["appName"] = firestore.app.name
            map["error"] = ExceptionConverter.createDetails(exception)
          } else if (task.result != null) {
            map["complete"] = true
          }

          mainLooper.post {
            events.success(map)
            events.endOfStream()
          }
        }
  }

  override fun onCancel(arguments: Any?) {
    semaphore.release()
    onTransactionCancelledListener(transactionId)
  }

  override fun receiveTransactionResponse(
      resultType: InternalTransactionResult,
      commands: List<InternalTransactionCommand?>?
  ) {
    this.resultType = resultType
    this.commands = commands
    semaphore.release()
  }
}
