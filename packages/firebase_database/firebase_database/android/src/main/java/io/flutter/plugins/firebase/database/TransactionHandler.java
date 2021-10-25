package io.flutter.plugins.firebase.database;

import android.app.Activity;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.Transaction;
import com.google.firebase.database.Transaction.Handler;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

public class TransactionHandler implements Handler {
  private final MethodChannel channel;
  private final TaskCompletionSource<Map<String, Object>> transactionCompletionSource;
  private final int transactionKey;
  private final Activity activity;

  public TransactionHandler(@NonNull MethodChannel channel, int transactionKey, Activity activity) {
    this.channel = channel;
    this.transactionKey = transactionKey;
    this.activity = activity;
    this.transactionCompletionSource = new TaskCompletionSource<>();
  }

  Task<Map<String, Object>> getTask() {
    return transactionCompletionSource.getTask();
  }

  @NonNull
  @Override
  public Transaction.Result doTransaction(@NonNull MutableData currentData) {
    final Map<String, Object> snapshotMap = new HashMap<>();
    final Map<String, Object> transactionArgs = new HashMap<>();

    snapshotMap.put(Constants.KEY, currentData.getKey());
    snapshotMap.put(Constants.VALUE, currentData.getValue());

    transactionArgs.put(Constants.SNAPSHOT, snapshotMap);
    transactionArgs.put(Constants.TRANSACTION_KEY, transactionKey);

    try {
      final TransactionExecutor executor = new TransactionExecutor(channel, activity);
      final Object updatedData = executor.exec(transactionArgs);

      currentData.setValue(updatedData);
      return Transaction.success(currentData);
    } catch (Exception e) {
      Log.d("firebase_database", e.toString());
      return Transaction.abort();
    }
  }

  @Override
  public void onComplete(
      @Nullable DatabaseError error, boolean committed, @Nullable DataSnapshot currentData) {
    if (error != null) {
      transactionCompletionSource.setException(
          FlutterFirebaseDatabaseException.fromDatabaseError(error));
    } else if (currentData != null) {
      final FlutterDataSnapshotPayload payload = new FlutterDataSnapshotPayload(currentData);

      final Map<String, Object> additionalParams = new HashMap<>();
      additionalParams.put(Constants.COMMITTED, committed);

      transactionCompletionSource.setResult(
          payload.withChildKeys().withAdditionalParams(additionalParams).toMap());
    }
  }
}
