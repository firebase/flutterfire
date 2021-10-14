package io.flutter.plugins.firebase.database;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.Nullable;

import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

import io.flutter.plugin.common.MethodChannel;

public class TransactionExecutor {
  private final TaskCompletionSource<Map<String, Object>> tcs;
  private final MethodChannel channel;
  private final Activity activity;

  public TransactionExecutor(MethodChannel channel, Activity activity) {
    this.activity = activity;
    this.tcs = new TaskCompletionSource<>();
    this.channel = channel;
  }

  public Map<String, Object> exec(Map<String, Object> arguments) throws ExecutionException, InterruptedException {
    activity.runOnUiThread(() -> {
      channel.invokeMethod(Constants.METHOD_DO_TRANSACTION, arguments, new MethodChannel.Result() {
        @Override
        @SuppressWarnings("unchecked")
        public void success(@Nullable Object result) {
          tcs.setResult((HashMap<String, Object>) result);
        }

        @Override
        @SuppressWarnings("unchecked")
        public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
          String message = errorMessage;
          Map<String, Object> additionalData = new HashMap<>();

          if (message == null) {
            message = FlutterFirebaseDatabaseException.UNKNOWN_ERROR_MESSAGE;
          }

          if (errorDetails instanceof Map) {
            additionalData = (Map<String, Object>) errorDetails;
          }

          final FlutterFirebaseDatabaseException e = new FlutterFirebaseDatabaseException(
            errorCode,
            message,
            additionalData
          );

          tcs.setException(e);
        }

        @Override
        public void notImplemented() {
          // never called
        }
      });
    });

    return Tasks.await(tcs.getTask());
  }
}
