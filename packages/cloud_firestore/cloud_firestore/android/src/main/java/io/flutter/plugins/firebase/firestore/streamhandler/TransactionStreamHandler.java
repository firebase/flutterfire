/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.Nullable;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.FirebaseFirestoreException.Code;
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Transaction;
import com.google.firebase.firestore.TransactionOptions;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestoreTransactionResult;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter;
import io.flutter.plugins.firebase.firestore.utils.PigeonParser;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

public class TransactionStreamHandler implements OnTransactionResultListener, StreamHandler {

  /** Callback when the transaction has been started. */
  public interface OnTransactionStartedListener {
    void onStarted(Transaction transaction);
  }

  final OnTransactionStartedListener onTransactionStartedListener;
  final FirebaseFirestore firestore;
  final String transactionId;
  final Long timeout;

  final Long maxAttempts;

  public TransactionStreamHandler(
      OnTransactionStartedListener onTransactionStartedListener,
      FirebaseFirestore firestore,
      String transactionId,
      Long timeout,
      Long maxAttempts) {
    this.onTransactionStartedListener = onTransactionStartedListener;
    this.firestore = firestore;
    this.transactionId = transactionId;
    this.timeout = timeout;
    this.maxAttempts = maxAttempts;
  }

  final Semaphore semaphore = new Semaphore(0);
  private GeneratedAndroidFirebaseFirestore.PigeonTransactionResult resultType;
  private List<GeneratedAndroidFirebaseFirestore.PigeonTransactionCommand> commands;

  final Handler mainLooper = new Handler(Looper.getMainLooper());

  @Override
  public void onListen(Object arguments, EventSink events) {
    firestore
        .runTransaction(
            new TransactionOptions.Builder().setMaxAttempts(maxAttempts.intValue()).build(),
            transaction -> {
              onTransactionStartedListener.onStarted(transaction);

              Map<String, Object> attemptMap = new HashMap<>();
              attemptMap.put("appName", firestore.getApp().getName());

              mainLooper.post(() -> events.success(attemptMap));

              try {
                if (!semaphore.tryAcquire(timeout, TimeUnit.MILLISECONDS)) {
                  return FlutterFirebaseFirestoreTransactionResult.failed(
                      new FirebaseFirestoreException("timed out", Code.DEADLINE_EXCEEDED));
                }
              } catch (InterruptedException e) {
                return FlutterFirebaseFirestoreTransactionResult.failed(
                    new FirebaseFirestoreException("interrupted", Code.DEADLINE_EXCEEDED));
              }

              if (commands.isEmpty()) {
                return FlutterFirebaseFirestoreTransactionResult.complete();
              }

              if (resultType == GeneratedAndroidFirebaseFirestore.PigeonTransactionResult.FAILURE) {
                return FlutterFirebaseFirestoreTransactionResult.complete();
              }

              for (GeneratedAndroidFirebaseFirestore.PigeonTransactionCommand command : commands) {
                DocumentReference documentReference = firestore.document(command.getPath());

                switch (command.getType()) {
                  case DELETE_TYPE:
                    transaction.delete(documentReference);
                    break;
                  case UPDATE:
                    transaction.update(
                        documentReference, Objects.requireNonNull(command.getData()));
                    break;
                  case SET:
                    {
                      GeneratedAndroidFirebaseFirestore.PigeonDocumentOption options =
                          Objects.requireNonNull(command.getOption());
                      SetOptions setOptions = null;

                      if (options.getMerge() != null && options.getMerge()) {
                        setOptions = SetOptions.merge();
                      } else if (options.getMergeFields() != null) {
                        List<List<String>> fieldList =
                            Objects.requireNonNull(options.getMergeFields());
                        List<FieldPath> fieldPathList = PigeonParser.parseFieldPath(fieldList);

                        setOptions = SetOptions.mergeFieldPaths(fieldPathList);
                      }

                      Map<String, Object> data = Objects.requireNonNull(command.getData());

                      if (setOptions == null) {
                        transaction.set(documentReference, data);
                      } else {
                        transaction.set(documentReference, data, setOptions);
                      }

                      break;
                    }
                }
              }
              return FlutterFirebaseFirestoreTransactionResult.complete();
            })
        .addOnCompleteListener(
            task -> {
              final HashMap<String, Object> map = new HashMap<>();
              if (task.getException() != null || task.getResult().exception != null) {
                final @Nullable Exception exception =
                    task.getException() != null ? task.getException() : task.getResult().exception;
                map.put("appName", firestore.getApp().getName());
                map.put("error", ExceptionConverter.createDetails(exception));
              } else if (task.getResult() != null) {
                map.put("complete", true);
              }

              mainLooper.post(
                  () -> {
                    events.success(map);
                    events.endOfStream();
                  });
            });
  }

  @Override
  public void onCancel(Object arguments) {
    semaphore.release();
  }

  @Override
  public void receiveTransactionResponse(
      GeneratedAndroidFirebaseFirestore.PigeonTransactionResult resultType,
      List<GeneratedAndroidFirebaseFirestore.PigeonTransactionCommand> commands) {
    this.resultType = resultType;
    this.commands = commands;
    semaphore.release();
  }
}
