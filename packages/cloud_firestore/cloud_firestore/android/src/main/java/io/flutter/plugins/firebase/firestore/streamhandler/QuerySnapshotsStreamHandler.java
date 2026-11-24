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
import java.util.ArrayList;
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
  private final ArrayDeque<QueuedSnapshot> pendingSnapshots = new ArrayDeque<>();
  private Runnable activeTurnRelease;
  private EventSink eventSink;
  private boolean emissionActive;
  private boolean chunkedTransport;
  private boolean aborted;
  private Exception pendingError;
  private long listenerGeneration;

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
    ListenerRegistration previousRegistration;
    List<Runnable> turnsToRelease;
    final long generation;
    synchronized (this) {
      previousRegistration = listenerRegistration;
      listenerRegistration = null;
      generation = ++listenerGeneration;
      emissionActive = false;
      aborted = false;
      pendingError = null;
      turnsToRelease = drainHeldTurnsLocked();
      eventSink = events;
      chunkedTransport = QuerySnapshotChunkProtocol.supportsChunking(arguments);
    }

    if (previousRegistration != null) {
      previousRegistration.remove();
    }
    runAll(turnsToRelease);

    SnapshotListenOptions.Builder optionsBuilder = new SnapshotListenOptions.Builder();
    optionsBuilder.setMetadataChanges(metadataChanges);
    optionsBuilder.setSource(source);
    optionsBuilder.setExecutor(snapshotExecutor);

    ListenerRegistration registration =
        query.addSnapshotListener(
            optionsBuilder.build(),
            (querySnapshot, exception) -> {
              if (exception != null) {
                onNativeError(exception, generation);
              } else {
                enqueueSnapshot(Objects.requireNonNull(querySnapshot), generation);
              }
            });

    retainListenerRegistration(registration, generation);
  }

  private void retainListenerRegistration(ListenerRegistration registration, long generation) {
    boolean removeRegistration;
    synchronized (this) {
      removeRegistration =
          listenerGeneration != generation || eventSink == null || aborted || pendingError != null;
      if (!removeRegistration) {
        listenerRegistration = registration;
      }
    }
    if (removeRegistration) {
      registration.remove();
    }
  }

  private void enqueueSnapshot(QuerySnapshot snapshot, long generation) {
    boolean shouldStart;
    boolean useChunked;
    synchronized (this) {
      if (listenerGeneration != generation
          || eventSink == null
          || aborted
          || pendingError != null) {
        return;
      }
      useChunked = chunkedTransport;
      if (!useChunked) {
        shouldStart = false;
      } else {
        Runnable releaseTurn = null;
        if (snapshotExecutor instanceof SnapshotDeliveryExecutor) {
          releaseTurn = ((SnapshotDeliveryExecutor) snapshotExecutor).deferNext();
        }
        pendingSnapshots.addLast(new QueuedSnapshot(snapshot, releaseTurn));
        shouldStart = !emissionActive;
        if (shouldStart) {
          emissionActive = true;
        }
      }
    }

    if (!useChunked) {
      try {
        Object pigeonSnapshot =
            PigeonParser.toPigeonQuerySnapshot(snapshot, serverTimestampBehavior);
        postSuccess(pigeonSnapshot, generation, null);
      } catch (Exception exception) {
        emitErrorImmediately(exception, generation);
      }
      return;
    }

    if (shouldStart) {
      emitNextSnapshot(generation);
    }
  }

  private void emitNextSnapshot(long generation) {
    QueuedSnapshot queued;
    Exception errorToDeliver = null;
    synchronized (this) {
      if (listenerGeneration != generation || eventSink == null || aborted) {
        return;
      }
      queued = pendingSnapshots.pollFirst();
      if (queued == null) {
        emissionActive = false;
        activeTurnRelease = null;
        errorToDeliver = pendingError;
      } else {
        activeTurnRelease = queued.releaseTurn;
      }
    }

    if (queued == null) {
      if (errorToDeliver != null) {
        scheduleErrorDelivery(errorToDeliver, generation);
      }
      return;
    }

    try {
      SnapshotEmission emission =
          new SnapshotEmission(
              nextSnapshotId.incrementAndGet(), queued.snapshot, queued.releaseTurn);
      postSuccess(
          QuerySnapshotChunkProtocol.start(
              emission.id, emission.documentCount, emission.documentChangeCount, emission.metadata),
          generation,
          () -> emitNextChunk(emission, generation));
    } catch (Exception exception) {
      emitErrorImmediately(exception, generation);
    } catch (Error error) {
      releaseAllTurns();
      throw error;
    }
  }

  private void emitNextChunk(SnapshotEmission emission, long generation) {
    if (!isActive(generation)) {
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
            generation,
            () -> emitNextChunk(emission, generation));
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
            generation,
            () -> emitNextChunk(emission, generation));
        return;
      }

      postSuccess(
          QuerySnapshotChunkProtocol.end(emission.id),
          generation,
          () -> finishSnapshotEmission(emission, generation));
    } catch (Exception exception) {
      emitErrorImmediately(exception, generation);
    } catch (Error error) {
      releaseAllTurns();
      throw error;
    }
  }

  private void finishSnapshotEmission(SnapshotEmission emission, long generation) {
    Runnable toRelease;
    Exception errorToDeliver = null;
    boolean continueDraining;
    synchronized (this) {
      if (activeTurnRelease == emission.releaseTurn) {
        activeTurnRelease = null;
      }
      toRelease = emission.releaseTurn;
      if (listenerGeneration != generation || eventSink == null || aborted) {
        continueDraining = false;
      } else if (pendingSnapshots.isEmpty()) {
        emissionActive = false;
        continueDraining = false;
        errorToDeliver = pendingError;
      } else {
        continueDraining = true;
      }
    }

    try {
      if (errorToDeliver != null) {
        scheduleErrorDelivery(errorToDeliver, generation);
      }
    } finally {
      if (toRelease != null) {
        toRelease.run();
      }
    }

    if (continueDraining) {
      emitNextSnapshot(generation);
    }
  }

  private void postSuccess(Object message, long generation, Runnable afterSuccess) {
    EventSink sink;
    synchronized (this) {
      if (listenerGeneration != generation || eventSink == null || aborted) {
        return;
      }
      sink = eventSink;
    }

    eventExecutor.execute(
        () -> {
          if (!isActive(generation)) {
            return;
          }
          try {
            sink.success(message);
            if (afterSuccess != null && isActive(generation)) {
              executeSnapshotContinuation(afterSuccess);
            }
          } catch (Exception exception) {
            emitErrorImmediately(exception, generation);
          } catch (Error error) {
            releaseAllTurns();
            throw error;
          }
        });
  }

  private void executeSnapshotContinuation(Runnable command) {
    if (snapshotExecutor instanceof SnapshotDeliveryExecutor) {
      ((SnapshotDeliveryExecutor) snapshotExecutor).executeContinuation(command);
    } else {
      snapshotExecutor.execute(command);
    }
  }

  private void onNativeError(Exception exception, long generation) {
    ListenerRegistration registration;
    boolean deliverNow;
    synchronized (this) {
      if (listenerGeneration != generation
          || eventSink == null
          || aborted
          || pendingError != null) {
        return;
      }
      pendingError = exception;
      registration = listenerRegistration;
      listenerRegistration = null;
      deliverNow = !(chunkedTransport && emissionActive);
    }

    if (registration != null) {
      registration.remove();
    }

    if (deliverNow) {
      scheduleErrorDelivery(exception, generation);
    }
  }

  private void emitErrorImmediately(Exception exception, long generation) {
    ListenerRegistration registration;
    List<Runnable> turnsToRelease;
    synchronized (this) {
      if (listenerGeneration != generation || eventSink == null || aborted) {
        return;
      }
      aborted = true;
      pendingError = exception;
      turnsToRelease = drainHeldTurnsLocked();
      emissionActive = false;
      registration = listenerRegistration;
      listenerRegistration = null;
    }

    try {
      if (registration != null) {
        registration.remove();
      }
      scheduleErrorDelivery(exception, generation);
    } finally {
      runAll(turnsToRelease);
    }
  }

  private void scheduleErrorDelivery(Exception exception, long generation) {
    Map<String, String> exceptionDetails = ExceptionConverter.createDetails(exception);
    eventExecutor.execute(
        () -> {
          EventSink sink;
          List<Runnable> turnsToRelease;
          synchronized (this) {
            if (listenerGeneration != generation || eventSink == null) {
              return;
            }
            listenerGeneration++;
            turnsToRelease = drainHeldTurnsLocked();
            emissionActive = false;
            aborted = false;
            pendingError = null;
            sink = eventSink;
            eventSink = null;
          }
          try {
            sink.error(DEFAULT_ERROR_CODE, exception.getMessage(), exceptionDetails);
            sink.endOfStream();
          } finally {
            runAll(turnsToRelease);
          }
        });
  }

  private List<Runnable> drainHeldTurnsLocked() {
    List<Runnable> turns = new ArrayList<>();
    if (activeTurnRelease != null) {
      turns.add(activeTurnRelease);
      activeTurnRelease = null;
    }
    while (!pendingSnapshots.isEmpty()) {
      QueuedSnapshot queued = pendingSnapshots.pollFirst();
      if (queued.releaseTurn != null) {
        turns.add(queued.releaseTurn);
      }
    }
    return turns;
  }

  private void releaseAllTurns() {
    List<Runnable> turns;
    synchronized (this) {
      turns = drainHeldTurnsLocked();
      emissionActive = false;
    }
    runAll(turns);
  }

  private static void runAll(List<Runnable> callbacks) {
    for (Runnable callback : callbacks) {
      callback.run();
    }
  }

  private synchronized boolean isActive(long generation) {
    return listenerGeneration == generation && eventSink != null && !aborted;
  }

  @Override
  public void onCancel(Object arguments) {
    ListenerRegistration registration;
    List<Runnable> turnsToRelease;
    synchronized (this) {
      listenerGeneration++;
      turnsToRelease = drainHeldTurnsLocked();
      emissionActive = false;
      aborted = false;
      pendingError = null;
      eventSink = null;
      registration = listenerRegistration;
      listenerRegistration = null;
    }
    if (registration != null) {
      registration.remove();
    }
    runAll(turnsToRelease);
  }

  private static Executor mainThreadExecutor() {
    Handler mainHandler = new Handler(Looper.getMainLooper());
    return mainHandler::post;
  }

  private static final class QueuedSnapshot {
    final QuerySnapshot snapshot;
    final Runnable releaseTurn;

    QueuedSnapshot(QuerySnapshot snapshot, Runnable releaseTurn) {
      this.snapshot = snapshot;
      this.releaseTurn = releaseTurn;
    }
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
    final Runnable releaseTurn;

    SnapshotEmission(long id, QuerySnapshot snapshot, Runnable releaseTurn) {
      this.id = id;
      this.releaseTurn = releaseTurn;
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
