package io.flutter.plugins.firebase.firestore.streamhandler;

import android.app.Activity;
import android.util.Log;
import android.util.SparseArray;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Transaction;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

public class TransactionStreamHandler implements StreamHandler {

  final AtomicReference<Activity> activityRef;
  final SparseArray<Transaction> transactions;

  public TransactionStreamHandler(AtomicReference<Activity> activityRef,
    SparseArray<Transaction> transactions) {
    this.activityRef = activityRef;
    this.transactions = transactions;
  }

  // TODO: http://tutorials.jenkov.com/java-concurrency/threadlocal.html
  final Map<Integer, Semaphore> semaphores = new HashMap<>();
  final Map<Integer, Map<String, Object>> attemptedTransactionResponses = new HashMap<>();

  @Override
  public void onListen(Object arguments, EventSink events) {
    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;

    FirebaseFirestore firestore =
      (FirebaseFirestore) Objects.requireNonNull(argumentsMap.get("firestore"));
    int transactionId = (int) Objects.requireNonNull(argumentsMap.get("transactionId"));

    Object value = argumentsMap.get("timeout");
    Long timeout;

    if (value instanceof Long) {
      timeout = (Long) value;
    } else if (value instanceof Integer) {
      timeout = Long.valueOf((Integer) value);
    } else {
      timeout = 5000L;
    }

    Map<String, Object> transactionAttemptArguments = new HashMap<>();
    transactionAttemptArguments.put("transactionId", transactionId);
    transactionAttemptArguments.put("appName", firestore.getApp().getName());

    firestore.runTransaction(transaction -> {
      transactions.put(transactionId, transaction);

      final Semaphore semaphore = new Semaphore(0);
      semaphores.put(transactionId, semaphore);

      Map<String, Object> attemptMap = new HashMap<>();
      attemptMap.put("attempt", transactionAttemptArguments);

      activityRef.get().runOnUiThread(() -> events.success(attemptMap));

      try {
        semaphore.tryAcquire(timeout, TimeUnit.SECONDS);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }

      Map<String, Object> response = attemptedTransactionResponses.get(transactionId);

      List<Map<String, Object>> commands =
        (List<Map<String, Object>>) Objects.requireNonNull(response.get("commands"));

      for (Map<String, Object> command : commands) {
        String type = (String) Objects.requireNonNull(command.get("type"));
        String path = (String) Objects.requireNonNull(command.get("path"));
        DocumentReference documentReference = firestore.document(path);

        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) command.get("data");

        switch (type) {
          case "DELETE":
            transaction.delete(documentReference);
            break;
          case "UPDATE":
            transaction.update(documentReference, Objects.requireNonNull(data));
            break;
          case "SET": {
            @SuppressWarnings("unchecked")
            Map<String, Object> options =
              (Map<String, Object>) Objects.requireNonNull(command.get("options"));
            SetOptions setOptions = null;

            if (options.get("merge") != null && (boolean) options.get("merge")) {
              setOptions = SetOptions.merge();
            } else if (options.get("mergeFields") != null) {
              @SuppressWarnings("unchecked")
              List<FieldPath> fieldPathList =
                (List<FieldPath>) Objects.requireNonNull(options.get("mergeFields"));
              setOptions = SetOptions.mergeFieldPaths(fieldPathList);
            }

            if (setOptions == null) {
              transaction.set(documentReference, Objects.requireNonNull(data));
            } else {
              transaction.set(documentReference, Objects.requireNonNull(data), setOptions);
            }

            break;
          }
        }
      }

      return true;
    }).addOnFailureListener(e -> Log.e("TAG", "error in exception", e));
  }

  @Override
  public void onCancel(Object arguments) {

  }

  public void receiveTransactionResponse(int transactionId, Map<String, Object> result) {
    attemptedTransactionResponses.put(transactionId, result);

    final Semaphore semaphore = semaphores.get(transactionId);
    semaphore.release();
  }

}
