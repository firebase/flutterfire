// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.util.SparseArray;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Transaction;
import io.flutter.plugin.common.MethodChannel;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

class FlutterFirebaseFirestoreTransactionHandler {
  static final SparseArray<Transaction> transactions = new SparseArray<>();
  private MethodChannel channel;
  private WeakReference<Activity> activityRef;
  private int transactionId;

  FlutterFirebaseFirestoreTransactionHandler(
      MethodChannel channel, Activity activity, int transactionId) {
    this.channel = channel;
    this.activityRef = new WeakReference<>(activity);
    this.transactionId = transactionId;
  }

  static void dispose(int transactionId) {
    transactions.delete(transactionId);
  }

  // Gets a transaction document
  // Throws an exception if the handler does not exist
  static DocumentSnapshot getDocument(int transactionId, DocumentReference documentReference)
      throws Exception {
    Transaction transaction = transactions.get(transactionId);

    if (transaction == null) {
      throw new Exception(
          "Transaction.getDocument(): No transaction handler exists for ID: " + transactionId);
    }

    return transaction.get(documentReference);
  }

  Task<FlutterFirebaseFirestoreTransactionResult> create(
      FirebaseFirestore firestore, Long timeout) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put("transactionId", transactionId);
    arguments.put("appName", firestore.getApp().getName());

    return firestore.runTransaction(
        transaction -> {
          transactions.append(transactionId, transaction);

          final TaskCompletionSource<Map<String, Object>> completionSource =
              new TaskCompletionSource<>();
          final Task<Map<String, Object>> sourceTask = completionSource.getTask();

          if (activityRef.get() == null) {
            return FlutterFirebaseFirestoreTransactionResult.failed(
                new ActivityNotFoundException("Activity context no longer exists."));
          }

          Runnable runnable =
              () ->
                  channel.invokeMethod(
                      "Transaction#attempt",
                      arguments,
                      new MethodChannel.Result() {
                        @Override
                        @SuppressWarnings("unchecked")
                        public void success(@Nullable Object result) {
                          completionSource.trySetResult((Map<String, Object>) result);
                        }

                        @Override
                        public void error(
                            String errorCode,
                            @Nullable String errorMessage,
                            @Nullable Object errorDetails) {
                          completionSource.trySetException(
                              new FirebaseFirestoreException(
                                  "Transaction#attempt error: " + errorMessage,
                                  FirebaseFirestoreException.Code.ABORTED));
                        }

                        @Override
                        public void notImplemented() {
                          completionSource.trySetException(
                              new FirebaseFirestoreException(
                                  "Transaction#attempt: Not implemented",
                                  FirebaseFirestoreException.Code.ABORTED));
                        }
                      });

          activityRef.get().runOnUiThread(runnable);

          Map<String, Object> response;

          try {
            response = Tasks.await(sourceTask, timeout, TimeUnit.MILLISECONDS);
            String responseType = (String) Objects.requireNonNull(response.get("type"));
            // Do nothing - already handled in Dart land.
            if (responseType.equals("ERROR")) {
              return FlutterFirebaseFirestoreTransactionResult.complete();
            }
          } catch (TimeoutException e) {
            return FlutterFirebaseFirestoreTransactionResult.failed(
                new FirebaseFirestoreException(
                    e.getMessage(), FirebaseFirestoreException.Code.DEADLINE_EXCEEDED));
          } catch (Exception e) {
            return FlutterFirebaseFirestoreTransactionResult.failed(e);
          }

          @SuppressWarnings("unchecked")
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
              case "SET":
                {
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

          return FlutterFirebaseFirestoreTransactionResult.complete();
        });
  }
}
