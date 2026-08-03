/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.DEFAULT_ERROR_CODE;

import android.os.Handler;
import android.os.Looper;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.ListenSource;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.MetadataChanges;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.SnapshotListenOptions;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter;
import io.flutter.plugins.firebase.firestore.utils.PigeonParser;
import java.util.Map;
import java.util.concurrent.Executor;

public class QuerySnapshotsStreamHandler implements StreamHandler {

  ListenerRegistration listenerRegistration;
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  Query query;
  MetadataChanges metadataChanges;
  DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior;

  ListenSource source;
  Executor snapshotExecutor;

  public QuerySnapshotsStreamHandler(
      Query query,
      Boolean includeMetadataChanges,
      DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior,
      ListenSource source,
      Executor snapshotExecutor) {
    this.query = query;
    this.metadataChanges =
        includeMetadataChanges ? MetadataChanges.INCLUDE : MetadataChanges.EXCLUDE;
    this.serverTimestampBehavior = serverTimestampBehavior;
    this.source = source;
    this.snapshotExecutor = snapshotExecutor;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    SnapshotListenOptions.Builder optionsBuilder = new SnapshotListenOptions.Builder();
    optionsBuilder.setMetadataChanges(metadataChanges);
    optionsBuilder.setSource(source);
    optionsBuilder.setExecutor(snapshotExecutor);

    listenerRegistration =
        query.addSnapshotListener(
            optionsBuilder.build(),
            (querySnapshot, exception) -> {
              if (exception != null) {
                Map<String, String> exceptionDetails = ExceptionConverter.createDetails(exception);
                mainHandler.post(
                    () -> {
                      events.error(DEFAULT_ERROR_CODE, exception.getMessage(), exceptionDetails);
                      events.endOfStream();
                    });

                onCancel(null);
              } else {
                // Emit the Pigeon object directly; the Pigeon-aware codec serializes
                // nested `InternalDocumentSnapshot` / `InternalDocumentChange` /
                // `InternalSnapshotMetadata` with their proper type codes. Pigeon 26
                // no longer flattens nested types via `.toList()`.
                Object pigeonSnapshot =
                    PigeonParser.toPigeonQuerySnapshot(querySnapshot, serverTimestampBehavior);
                mainHandler.post(() -> events.success(pigeonSnapshot));
              }
            });
  }

  @Override
  public void onCancel(Object arguments) {
    if (listenerRegistration != null) {
      listenerRegistration.remove();
      listenerRegistration = null;
    }
  }
}
