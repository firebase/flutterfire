package io.flutter.plugins.firebase.database;

import androidx.annotation.Nullable;

import com.google.android.gms.tasks.Task;
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
    this.tcs = new TaskCompletionSource<Map<String, Object>>();
    this.channel = channel;
  }

  public Map<String, Object> exec(Map<String, Object> arguments) throws ExecutionException, InterruptedException {
    channel.invokeMethod("DoTransaction", arguments, new MethodChannel.Result() {
      @Override
      public void success(@Nullable Object result) {
        tcs.setResult((HashMap<String, Object>) result);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        final Map<String, Object> details = (HashMap<String, Object>) errorDetails;
        final FirebaseDatabaseException e = new FirebaseDatabaseException(errorCode, errorMessage, details);
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
