/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import android.os.Handler
import android.os.Looper
import androidx.annotation.Nullable
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import io.flutter.plugin.common.MethodChannel
import java.util.*
import java.util.concurrent.ExecutionException

class TransactionExecutor constructor(
  private val channel: MethodChannel,
) {
  private val completion = TaskCompletionSource<Any>()

  @Throws(ExecutionException::class, InterruptedException::class)
  fun execute(arguments: Map<String, Any>): Any {
    Handler(Looper.getMainLooper()).post {
      channel.invokeMethod(
        Constants.METHOD_CALL_TRANSACTION_HANDLER,
        arguments,
        object : MethodChannel.Result {
          override fun success(
            @Nullable result: Any?,
          ) {
            completion.setResult(result)
          }

          @Suppress("UNCHECKED_CAST")
          override fun error(
            errorCode: String,
            @Nullable errorMessage: String?,
            @Nullable errorDetails: Any?,
          ) {
            var message = errorMessage
            val additionalData = mutableMapOf<String, Any>()

            if (message == null) {
              message = FlutterFirebaseDatabaseException.UNKNOWN_ERROR_MESSAGE
            }

            if (errorDetails is Map<*, *>) {
              additionalData.putAll(errorDetails as Map<String, Any>)
            }

            val e =
              FlutterFirebaseDatabaseException(
                errorCode,
                message,
                additionalData,
              )

            completion.setException(e)
          }

          override fun notImplemented() {
            // never called
          }
        },
      )
    }

    return Tasks.await(completion.task)
  }
}
