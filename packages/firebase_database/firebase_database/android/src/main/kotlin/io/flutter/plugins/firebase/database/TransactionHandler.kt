/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.MutableData
import com.google.firebase.database.Transaction
import com.google.firebase.database.Transaction.Handler
import io.flutter.plugin.common.MethodChannel
import java.util.*

class TransactionHandler @JvmOverloads constructor(
    @NonNull private val channel: MethodChannel,
    private val transactionKey: Int
) : Handler {
    
    private val transactionCompletionSource = TaskCompletionSource<Map<String, Any>>()

    fun getTask(): Task<Map<String, Any>> {
        return transactionCompletionSource.task
    }

    @NonNull
    override fun doTransaction(@NonNull currentData: MutableData): Transaction.Result {
        val snapshotMap = mutableMapOf<String, Any>()
        val transactionArgs = mutableMapOf<String, Any>()

        snapshotMap[Constants.KEY] = currentData.key ?: ""
        snapshotMap[Constants.VALUE] = currentData.value

        transactionArgs[Constants.SNAPSHOT] = snapshotMap
        transactionArgs[Constants.TRANSACTION_KEY] = transactionKey

        return try {
            val executor = TransactionExecutor(channel)
            val updatedData = executor.execute(transactionArgs)
            @Suppress("UNCHECKED_CAST")
            val transactionHandlerResult = updatedData as Map<String, Any>
            val aborted = transactionHandlerResult["aborted"] as Boolean
            val exception = transactionHandlerResult["exception"] as Boolean
            
            if (aborted || exception) {
                Transaction.abort()
            } else {
                currentData.value = transactionHandlerResult["value"]
                Transaction.success(currentData)
            }
        } catch (e: Exception) {
            Log.e("firebase_database", "An unexpected exception occurred for a transaction.", e)
            Transaction.abort()
        }
    }

    override fun onComplete(
        @Nullable error: DatabaseError?,
        committed: Boolean,
        @Nullable currentData: DataSnapshot?
    ) {
        when {
            error != null -> {
                transactionCompletionSource.setException(
                    FlutterFirebaseDatabaseException.fromDatabaseError(error)
                )
            }
            currentData != null -> {
                val payload = FlutterDataSnapshotPayload(currentData)
                val additionalParams = mutableMapOf<String, Any>()
                additionalParams[Constants.COMMITTED] = committed
                transactionCompletionSource.setResult(payload.withAdditionalParams(additionalParams).toMap())
            }
        }
    }
}
