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

class TransactionHandler @JvmOverloads constructor(
  @NonNull private val channel: MethodChannel,
  private val transactionKey: Int
) : Handler {

  private val transactionCompletionSource = TaskCompletionSource<Map<String, Any?>>()

  fun getTask(): Task<Map<String, Any?>> {
    return transactionCompletionSource.task
  }

  @NonNull
  override fun doTransaction(@NonNull currentData: MutableData): Transaction.Result {
    val snapshotMap = HashMap<String, Any>().apply {
      put(Constants.KEY, currentData.key ?: "")
      put(Constants.VALUE, currentData.value)
    }

    val transactionArgs = HashMap<String, Any>().apply {
      put(Constants.SNAPSHOT, snapshotMap)
      put(Constants.TRANSACTION_KEY, transactionKey)
    }

    return try {
      val executor = TransactionExecutor(channel)
      val updatedData: Any? = executor.execute(transactionArgs)

      @Suppress("UNCHECKED_CAST")
      val transactionHandlerResult: Map<String, Any?> = when (updatedData) {
        is Map<*, *> -> updatedData as Map<String, Any?>
        null -> emptyMap()
        else -> {
          Log.e("firebase_database", "Unexpected transaction result type: ${updatedData::class.java}")
          emptyMap()
        }
      }

      val aborted: Boolean = (transactionHandlerResult["aborted"] as? Boolean) ?: false
      val exception: Boolean = (transactionHandlerResult["exception"] as? Boolean) ?: false

      if (aborted || exception) {
        Transaction.abort()
      } else {
        if (transactionHandlerResult.containsKey("value")) {
          currentData.value = transactionHandlerResult["value"]
        }
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
        val additionalParams: MutableMap<String, Any> = mutableMapOf(
          Constants.COMMITTED to committed
        )
        transactionCompletionSource.setResult(
          payload.withAdditionalParams(additionalParams).toMap()
        )
      }
      else -> {
        transactionCompletionSource.setResult(emptyMap())
      }
    }
  }
}
