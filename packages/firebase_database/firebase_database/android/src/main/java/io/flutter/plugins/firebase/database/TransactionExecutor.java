package io.flutter.plugins.firebase.database;

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

  public TransactionExecutor(MethodChannel channel) {
    this.tcs = new TaskCompletionSource<>();
    this.channel = channel;
  }

  public Map<String, Object> exec(Map<String, Object> arguments) throws ExecutionException, InterruptedException {
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
        Map<String, Object> addtionalData = new HashMap<>();

        if (message == null) {
          message = FlutterFirebaseDatabaseException.UNKNOWN_ERROR_MESSAGE;
        }

        if (errorDetails instanceof Map) {
          addtionalData = (Map<String, Object>) errorDetails;
        }

        final FlutterFirebaseDatabaseException e = new FlutterFirebaseDatabaseException(
          errorCode,
          message,
          addtionalData
        );

        tcs.setException(e);
      }

      @Override
      public void notImplemented() {
        // never called
      }
    });

    return Tasks.await(tcs.getTask());
  }
}
