/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

public class TransactionExecutor {
  private final TaskCompletionSource<Object> completion;
  private final MethodChannel channel;

  protected TransactionExecutor(MethodChannel channel) {
    this.completion = new TaskCompletionSource<>();
    this.channel = channel;
  }

  protected Object execute(final Map<String, Object> arguments)
      throws ExecutionException, InterruptedException {
    new Handler(Looper.getMainLooper())
        .post(
            () ->
                channel.invokeMethod(
                    Constants.METHOD_CALL_TRANSACTION_HANDLER,
                    arguments,
                    new MethodChannel.Result() {
                      @Override
                      public void success(@Nullable Object result) {
                        completion.setResult(result);
                      }

                      @Override
                      @SuppressWarnings("unchecked")
                      public void error(
                          String errorCode,
                          @Nullable String errorMessage,
                          @Nullable Object errorDetails) {
                        String message = errorMessage;
                        Map<String, Object> additionalData = new HashMap<>();

                        if (message == null) {
                          message = FlutterFirebaseDatabaseException.UNKNOWN_ERROR_MESSAGE;
                        }

                        if (errorDetails instanceof Map) {
                          additionalData = (Map<String, Object>) errorDetails;
                        }

                        final FlutterFirebaseDatabaseException e =
                            new FlutterFirebaseDatabaseException(
                                errorCode, message, additionalData);

                        completion.setException(e);
                      }

                      @Override
                      public void notImplemented() {
                        // never called
                      }
                    }));

    return Tasks.await(completion.getTask());
  }
}
