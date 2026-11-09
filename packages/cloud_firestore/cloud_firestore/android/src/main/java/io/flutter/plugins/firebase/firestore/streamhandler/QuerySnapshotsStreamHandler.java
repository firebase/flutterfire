/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.DEFAULT_ERROR_CODE;

import android.os.Handler;
import android.os.Looper;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.ListenSource;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.MetadataChanges;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SnapshotListenOptions;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter;
import io.flutter.plugins.firebase.firestore.utils.PigeonParser;
import java.util.ArrayDeque;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicLong;

public class QuerySnapshotsStreamHandler implements StreamHandler {
  ListenerRegistration listenerRegistration;

  Query query;
  MetadataChanges metadataChanges;
  DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior;

  ListenSource source;
  Executor snapshotExecutor;
  private final Executor eventExecutor;
  private final AtomicLong nextSnapshotId = new AtomicLong();
  private final ArrayDeque<QuerySnapshot> pendingSnapshots = new ArrayDeque<>();
  private EventSink eventSink;
  private boolean emissionActive;
  private boolean cancelled;

  public QuerySnapshotsStreamHandler(
      Query query,
      Boolean includeMetadataChanges,
      DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior,
      ListenSource source,
      Executor snapshotExecutor) {
    this(
        query,
        includeMetadataChanges,
        serverTimestampBehavior,
        source,
        snapshotExecutor,
        mainThreadExecutor());
  }

  QuerySnapshotsStreamHandler(
      Query query,
      Boolean includeMetadataChanges,
      DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior,
      ListenSource source,
      Executor snapshotExecutor,
      Executor eventExecutor) {
    this.query = query;
    this.metadataChanges =
        includeMetadataChanges ? MetadataChanges.INCLUDE : MetadataChanges.EXCLUDE;
    this.serverTimestampBehavior = serverTimestampBehavior;
    this.source = source;
    this.snapshotExecutor = snapshotExecutor;
    this.eventExecutor = eventExecutor;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    synchronized (this) {
      cancelled = false;
      emissionActive = false;
      pendingSnapshots.clear();
      eventSink = events;
    }

    SnapshotListenOptions.Builder optionsBuilder = new SnapshotListenOptions.Builder();
    optionsBuilder.setMetadataChanges(metadataChanges);
    optionsBuilder.setSource(source);
    optionsBuilder.setExecutor(snapshotExecutor);

    ListenerRegistration registration =
        query.addSnapshotListener(
            optionsBuilder.build(),
            (querySnapshot, exception) -> {
              if (exception != null) {
                emitError(exception);
              } else {
                enqueueSnapshot(Objects.requireNonNull(querySnapshot));
              }
            });

    retainListenerRegistration(registration);
  }

  void retainListenerRegistration(ListenerRegistration registration) {
    boolean removeRegistration;
    synchronized (this) {
      removeRegistration = cancelled;
      if (!removeRegistration) {
        listenerRegistration = registration;
      }
    }
    if (removeRegistration) {
      registration.remove();
    }
  }

  void emitSnapshotForTesting(QuerySnapshot snapshot, EventSink events) {
    synchronized (this) {
      if (eventSink != null && eventSink != events) {
        throw new IllegalStateException("A different event sink is already active");
      }
      cancelled = false;
      eventSink = events;
    }
    enqueueSnapshot(snapshot);
  }

  private void enqueueSnapshot(QuerySnapshot snapshot) {
    boolean shouldStart;
    synchronized (this) {
      if (cancelled) {
        return;
      }
      pendingSnapshots.addLast(snapshot);
      shouldStart = !emissionActive;
      if (shouldStart) {
        emissionActive = true;
      }
    }

    if (shouldStart) {
      emitNextSnapshot();
    }
  }

  private void emitNextSnapshot() {
    QuerySnapshot snapshot;
    synchronized (this) {
      if (cancelled) {
        return;
      }
      snapshot = pendingSnapshots.pollFirst();
      if (snapshot == null) {
        emissionActive = false;
        return;
      }
    }

    try {
      SnapshotEmission emission = new SnapshotEmission(nextSnapshotId.incrementAndGet(), snapshot);
      postSuccess(
          QuerySnapshotChunkProtocol.start(
              emission.id, emission.documentCount, emission.documentChangeCount, emission.metadata),
          () -> emitNextChunk(emission));
    } catch (Exception exception) {
      emitError(exception);
    }
  }

  private void emitNextChunk(SnapshotEmission emission) {
    if (isCancelled()) {
      return;
    }

    try {
      if (emission.documents.hasNext()) {
        List<GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot> chunk =
            emission.documents.nextChunk(
                values ->
                    QuerySnapshotChunkProtocol.encodedEnvelopeSize(
                        QuerySnapshotChunkProtocol.itemChunk(
                            emission.id, QuerySnapshotChunkProtocol.DOCUMENTS_KIND, values)));
        postSuccess(
            QuerySnapshotChunkProtocol.itemChunk(
                emission.id, QuerySnapshotChunkProtocol.DOCUMENTS_KIND, chunk),
            () -> emitNextChunk(emission));
        return;
      }

      if (emission.documentChanges.hasNext()) {
        List<GeneratedAndroidFirebaseFirestore.InternalDocumentChange> chunk =
            emission.documentChanges.nextChunk(
                values ->
                    QuerySnapshotChunkProtocol.encodedEnvelopeSize(
                        QuerySnapshotChunkProtocol.itemChunk(
                            emission.id,
                            QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND,
                            values)));
        postSuccess(
            QuerySnapshotChunkProtocol.itemChunk(
                emission.id, QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND, chunk),
            () -> emitNextChunk(emission));
        return;
      }

      postSuccess(QuerySnapshotChunkProtocol.end(emission.id), this::emitNextSnapshot);
    } catch (Exception exception) {
      emitError(exception);
    }
  }

  private void postSuccess(Object message, Runnable afterSuccess) {
    EventSink sink;
    synchronized (this) {
      if (cancelled || eventSink == null) {
        return;
      }
      sink = eventSink;
    }

    eventExecutor.execute(
        () -> {
          if (isCancelled()) {
            return;
          }
          try {
            sink.success(message);
            snapshotExecutor.execute(afterSuccess);
          } catch (Exception exception) {
            emitError(exception);
          }
        });
  }

  private void emitError(Exception exception) {
    EventSink sink;
    ListenerRegistration registration;
    synchronized (this) {
      if (cancelled) {
        return;
      }
      cancelled = true;
      pendingSnapshots.clear();
      emissionActive = false;
      sink = eventSink;
      eventSink = null;
      registration = listenerRegistration;
      listenerRegistration = null;
    }

    if (registration != null) {
      registration.remove();
    }
    if (sink == null) {
      return;
    }

    Map<String, String> exceptionDetails = ExceptionConverter.createDetails(exception);
    eventExecutor.execute(
        () -> {
          sink.error(DEFAULT_ERROR_CODE, exception.getMessage(), exceptionDetails);
          sink.endOfStream();
        });
  }

  private synchronized boolean isCancelled() {
    return cancelled;
  }

  @Override
  public void onCancel(Object arguments) {
    ListenerRegistration registration;
    synchronized (this) {
      cancelled = true;
      pendingSnapshots.clear();
      emissionActive = false;
      eventSink = null;
      registration = listenerRegistration;
      listenerRegistration = null;
    }
    if (registration != null) {
      registration.remove();
    }
  }

  private static Executor mainThreadExecutor() {
    Handler mainHandler = new Handler(Looper.getMainLooper());
    return command -> mainHandler.post(command);
  }

  private final class SnapshotEmission {
    final long id;
    final int documentCount;
    final int documentChangeCount;
    final GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata metadata;
    final QuerySnapshotChunker<
            DocumentSnapshot, GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot>
        documents;
    final QuerySnapshotChunker<
            DocumentChange, GeneratedAndroidFirebaseFirestore.InternalDocumentChange>
        documentChanges;

    SnapshotEmission(long id, QuerySnapshot snapshot) {
      this.id = id;
      List<DocumentSnapshot> nativeDocuments = snapshot.getDocuments();
      List<DocumentChange> nativeDocumentChanges = snapshot.getDocumentChanges();
      documentCount = nativeDocuments.size();
      documentChangeCount = nativeDocumentChanges.size();
      metadata = PigeonParser.toPigeonSnapshotMetadata(snapshot.getMetadata());
      documents =
          new QuerySnapshotChunker<>(
              nativeDocuments.iterator(),
              value -> PigeonParser.toPigeonDocumentSnapshot(value, serverTimestampBehavior),
              QuerySnapshotChunkProtocol::encodedMessageSize,
              QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
      documentChanges =
          new QuerySnapshotChunker<>(
              nativeDocumentChanges.iterator(),
              value -> PigeonParser.toPigeonDocumentChange(value, serverTimestampBehavior),
              QuerySnapshotChunkProtocol::encodedMessageSize,
              QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
    }
  }
}
