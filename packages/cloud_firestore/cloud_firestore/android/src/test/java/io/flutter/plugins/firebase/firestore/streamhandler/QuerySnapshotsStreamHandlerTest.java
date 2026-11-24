/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenSource;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SnapshotListenOptions;
import com.google.firebase.firestore.SnapshotMetadata;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.Test;

public class QuerySnapshotsStreamHandlerTest {
  private static final Map<String, Object> CHUNKED_ARGS =
      Collections.singletonMap(QuerySnapshotChunkProtocol.LISTEN_CHUNKED_ARG_KEY, true);

  @Test
  public void emitsOneLogicalSnapshotAsBoundedProtocolMessagesWhenOptedIn() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    QuerySnapshot snapshot = singleDocumentSnapshot();

    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            Runnable::run,
            Runnable::run);
    RecordingEventSink sink = new RecordingEventSink();
    handler.onListen(CHUNKED_ARGS, sink);

    listenerRef.get().onEvent(snapshot, null);

    assertEquals(4, sink.events.size());
    for (Object event : sink.events) {
      assertTrue(event instanceof Map);
      assertFalse(event instanceof GeneratedAndroidFirebaseFirestore.InternalQuerySnapshot);
      assertTrue(
          QuerySnapshotChunkProtocol.encodedEnvelopeSize(event)
              <= QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
    }
    assertEquals(QuerySnapshotChunkProtocol.START_KIND, kind(sink.events.get(0)));
    assertEquals(QuerySnapshotChunkProtocol.DOCUMENTS_KIND, kind(sink.events.get(1)));
    assertEquals(QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND, kind(sink.events.get(2)));
    assertEquals(QuerySnapshotChunkProtocol.END_KIND, kind(sink.events.get(3)));
    assertNull(sink.errorCode);
  }

  @Test
  public void emitsLegacyInternalQuerySnapshotWhenClientDoesNotOptIn() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    QuerySnapshot snapshot = singleDocumentSnapshot();

    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            Runnable::run,
            Runnable::run);
    RecordingEventSink sink = new RecordingEventSink();
    handler.onListen(null, sink);

    listenerRef.get().onEvent(snapshot, null);

    assertEquals(1, sink.events.size());
    assertTrue(
        sink.events.get(0) instanceof GeneratedAndroidFirebaseFirestore.InternalQuerySnapshot);
    assertNull(sink.errorCode);
  }

  @Test
  public void serializesQueuedSnapshotsWithoutInterleaving() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    QuerySnapshot snapshot = emptySnapshot();
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    RecordingEventSink sink = new RecordingEventSink();

    handler.onListen(CHUNKED_ARGS, sink);
    listenerRef.get().onEvent(snapshot, null);
    listenerRef.get().onEvent(snapshot, null);
    executor.runAll();

    assertEquals(4, sink.events.size());
    assertEquals(QuerySnapshotChunkProtocol.START_KIND, kind(sink.events.get(0)));
    assertEquals(QuerySnapshotChunkProtocol.END_KIND, kind(sink.events.get(1)));
    assertEquals(QuerySnapshotChunkProtocol.START_KIND, kind(sink.events.get(2)));
    assertEquals(QuerySnapshotChunkProtocol.END_KIND, kind(sink.events.get(3)));
    assertEquals(1L, snapshotId(sink.events.get(0)));
    assertEquals(1L, snapshotId(sink.events.get(1)));
    assertEquals(2L, snapshotId(sink.events.get(2)));
    assertEquals(2L, snapshotId(sink.events.get(3)));
  }

  @Test
  public void cancellationDropsQueuedSnapshotMessages() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    RecordingEventSink sink = new RecordingEventSink();

    handler.onListen(CHUNKED_ARGS, sink);
    listenerRef.get().onEvent(emptySnapshot(), null);
    handler.onCancel(null);
    executor.runAll();

    assertTrue(sink.events.isEmpty());
  }

  @Test
  public void staleQueuedFramesFromCancelledGenerationDoNotEmitAfterRelisten() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    RecordingEventSink firstSink = new RecordingEventSink();
    RecordingEventSink secondSink = new RecordingEventSink();

    handler.onListen(CHUNKED_ARGS, firstSink);
    EventListener<QuerySnapshot> firstListener = listenerRef.get();
    firstListener.onEvent(emptySnapshot(), null);

    handler.onCancel(null);
    handler.onListen(CHUNKED_ARGS, secondSink);
    EventListener<QuerySnapshot> secondListener = listenerRef.get();
    secondListener.onEvent(emptySnapshot(), null);

    executor.runAll();

    assertTrue(firstSink.events.isEmpty());
    assertEquals(2, secondSink.events.size());
    assertEquals(QuerySnapshotChunkProtocol.START_KIND, kind(secondSink.events.get(0)));
    assertEquals(QuerySnapshotChunkProtocol.END_KIND, kind(secondSink.events.get(1)));
  }

  @Test
  public void registrationReturnedAfterCancellationDuringSubscribeIsRemoved() {
    Query query = mock(Query.class);
    ListenerRegistration registration = mock(ListenerRegistration.class);
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            Runnable::run,
            Runnable::run);
    when(query.addSnapshotListener(any(SnapshotListenOptions.class), any()))
        .thenAnswer(
            invocation -> {
              handler.onCancel(null);
              return registration;
            });

    handler.onListen(CHUNKED_ARGS, new RecordingEventSink());

    verify(registration).remove();
  }

  @Test
  public void nativeExceptionEmitsErrorEndsStreamAndRemovesRegistration() {
    Query query = mock(Query.class);
    ListenerRegistration registration = mock(ListenerRegistration.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef =
        captureListener(query, registration);
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            Runnable::run,
            Runnable::run);
    RecordingEventSink sink = new RecordingEventSink();

    handler.onListen(CHUNKED_ARGS, sink);
    FirebaseFirestoreException error =
        new FirebaseFirestoreException("denied", FirebaseFirestoreException.Code.PERMISSION_DENIED);
    listenerRef.get().onEvent(null, error);

    assertTrue(sink.events.isEmpty());
    assertEquals("firebase_firestore", sink.errorCode);
    assertEquals(1, sink.endOfStreamCount);
    verify(registration).remove();
  }

  @Test
  public void nativeErrorAfterQueuedSnapshotDeliversSnapshotBeforeErrorInChunkedMode() {
    Query query = mock(Query.class);
    ListenerRegistration registration = mock(ListenerRegistration.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef =
        captureListener(query, registration);
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    RecordingEventSink sink = new RecordingEventSink();

    handler.onListen(CHUNKED_ARGS, sink);
    listenerRef.get().onEvent(singleDocumentSnapshot(), null);
    listenerRef
        .get()
        .onEvent(
            null,
            new FirebaseFirestoreException(
                "denied", FirebaseFirestoreException.Code.PERMISSION_DENIED));
    executor.runAll();

    assertEquals(4, sink.events.size());
    assertEquals(QuerySnapshotChunkProtocol.START_KIND, kind(sink.events.get(0)));
    assertEquals(QuerySnapshotChunkProtocol.DOCUMENTS_KIND, kind(sink.events.get(1)));
    assertEquals(QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND, kind(sink.events.get(2)));
    assertEquals(QuerySnapshotChunkProtocol.END_KIND, kind(sink.events.get(3)));
    assertEquals("firebase_firestore", sink.errorCode);
    assertEquals(1, sink.endOfStreamCount);
    verify(registration).remove();
  }

  @Test
  public void nativeErrorAfterQueuedSnapshotDeliversSnapshotBeforeErrorInLegacyMode() {
    Query query = mock(Query.class);
    ListenerRegistration registration = mock(ListenerRegistration.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef =
        captureListener(query, registration);
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    RecordingEventSink sink = new RecordingEventSink();

    handler.onListen(null, sink);
    listenerRef.get().onEvent(singleDocumentSnapshot(), null);
    listenerRef
        .get()
        .onEvent(
            null,
            new FirebaseFirestoreException(
                "denied", FirebaseFirestoreException.Code.PERMISSION_DENIED));
    executor.runAll();

    assertEquals(1, sink.events.size());
    assertTrue(
        sink.events.get(0) instanceof GeneratedAndroidFirebaseFirestore.InternalQuerySnapshot);
    assertEquals("firebase_firestore", sink.errorCode);
    assertEquals(1, sink.endOfStreamCount);
    verify(registration).remove();
  }

  @Test
  public void cancellationBeforeQueuedErrorDeliverySuppressesError() {
    Query query = mock(Query.class);
    ListenerRegistration registration = mock(ListenerRegistration.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef =
        captureListener(query, registration);
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    RecordingEventSink sink = new RecordingEventSink();

    handler.onListen(CHUNKED_ARGS, sink);
    listenerRef
        .get()
        .onEvent(
            null,
            new FirebaseFirestoreException(
                "denied", FirebaseFirestoreException.Code.PERMISSION_DENIED));
    handler.onCancel(null);
    executor.runAll();

    assertNull(sink.errorCode);
    assertEquals(0, sink.endOfStreamCount);
    verify(registration).remove();
  }

  @Test
  public void legacySinkFailureSuppressesSubsequentQueuedSnapshotsBeforeError() {
    Query query = mock(Query.class);
    ListenerRegistration registration = mock(ListenerRegistration.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef =
        captureListener(query, registration);
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    List<Object> delivered = new ArrayList<>();
    String[] errorCode = new String[1];
    int[] endOfStreamCount = new int[1];
    EventChannel.EventSink failingSink =
        new EventChannel.EventSink() {
          @Override
          public void success(Object event) {
            delivered.add(event);
            throw new IllegalStateException("sink failed");
          }

          @Override
          public void error(String code, String message, Object details) {
            errorCode[0] = code;
          }

          @Override
          public void endOfStream() {
            endOfStreamCount[0]++;
          }
        };

    handler.onListen(null, failingSink);
    listenerRef.get().onEvent(singleDocumentSnapshot(), null);
    listenerRef.get().onEvent(singleDocumentSnapshot(), null);
    executor.runAll();

    assertEquals(1, delivered.size());
    assertEquals("firebase_firestore", errorCode[0]);
    assertEquals(1, endOfStreamCount[0]);
    verify(registration).remove();
  }

  @Test
  public void chunkedSnapshotCompletesBeforeSnapshotsInSyncOnSharedDeliveryExecutor() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    ManualExecutor workerDelegate = new ManualExecutor();
    SnapshotDeliveryExecutor deliveryExecutor = new SnapshotDeliveryExecutor(workerDelegate);
    ManualExecutor mainExecutor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            deliveryExecutor,
            mainExecutor);
    List<String> timeline = new ArrayList<>();
    EventChannel.EventSink querySink =
        new EventChannel.EventSink() {
          @Override
          public void success(Object event) {
            timeline.add("query:" + kind(event));
          }

          @Override
          public void error(String code, String message, Object details) {}

          @Override
          public void endOfStream() {}
        };

    handler.onListen(CHUNKED_ARGS, querySink);
    QuerySnapshot snapshot = singleDocumentSnapshot();
    deliveryExecutor.execute(() -> listenerRef.get().onEvent(snapshot, null));
    deliveryExecutor.execute(() -> mainExecutor.execute(() -> timeline.add("sync")));

    drainBoth(workerDelegate, mainExecutor);

    assertEquals(
        Arrays.asList(
            "query:" + QuerySnapshotChunkProtocol.START_KIND,
            "query:" + QuerySnapshotChunkProtocol.DOCUMENTS_KIND,
            "query:" + QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND,
            "query:" + QuerySnapshotChunkProtocol.END_KIND,
            "sync"),
        timeline);
  }

  @Test
  public void multipleChunkedSnapshotsAndSyncEventsPreserveStrictInterleavingOrder() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    ManualExecutor workerDelegate = new ManualExecutor();
    SnapshotDeliveryExecutor deliveryExecutor = new SnapshotDeliveryExecutor(workerDelegate);
    ManualExecutor mainExecutor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            deliveryExecutor,
            mainExecutor);
    List<String> timeline = new ArrayList<>();
    EventChannel.EventSink querySink =
        new EventChannel.EventSink() {
          @Override
          public void success(Object event) {
            timeline.add("q" + snapshotId(event) + ":" + kind(event));
          }

          @Override
          public void error(String code, String message, Object details) {}

          @Override
          public void endOfStream() {}
        };

    handler.onListen(CHUNKED_ARGS, querySink);
    QuerySnapshot firstSnapshot = singleDocumentSnapshot();
    QuerySnapshot secondSnapshot = singleDocumentSnapshot();
    deliveryExecutor.execute(() -> listenerRef.get().onEvent(firstSnapshot, null));
    deliveryExecutor.execute(() -> mainExecutor.execute(() -> timeline.add("sync1")));
    deliveryExecutor.execute(() -> listenerRef.get().onEvent(secondSnapshot, null));
    deliveryExecutor.execute(() -> mainExecutor.execute(() -> timeline.add("sync2")));

    drainBoth(workerDelegate, mainExecutor);

    assertEquals(
        Arrays.asList(
            "q1:" + QuerySnapshotChunkProtocol.START_KIND,
            "q1:" + QuerySnapshotChunkProtocol.DOCUMENTS_KIND,
            "q1:" + QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND,
            "q1:" + QuerySnapshotChunkProtocol.END_KIND,
            "sync1",
            "q2:" + QuerySnapshotChunkProtocol.START_KIND,
            "q2:" + QuerySnapshotChunkProtocol.DOCUMENTS_KIND,
            "q2:" + QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND,
            "q2:" + QuerySnapshotChunkProtocol.END_KIND,
            "sync2"),
        timeline);
  }

  @Test
  public void cancellationMidChunkedSnapshotReleasesSharedDeliveryExecutorForSync() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    ManualExecutor workerDelegate = new ManualExecutor();
    SnapshotDeliveryExecutor deliveryExecutor = new SnapshotDeliveryExecutor(workerDelegate);
    ManualExecutor mainExecutor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            deliveryExecutor,
            mainExecutor);
    List<String> timeline = new ArrayList<>();
    EventChannel.EventSink querySink =
        new EventChannel.EventSink() {
          @Override
          public void success(Object event) {
            timeline.add("query:" + kind(event));
          }

          @Override
          public void error(String code, String message, Object details) {}

          @Override
          public void endOfStream() {}
        };

    handler.onListen(CHUNKED_ARGS, querySink);
    QuerySnapshot snapshot = singleDocumentSnapshot();
    deliveryExecutor.execute(() -> listenerRef.get().onEvent(snapshot, null));
    deliveryExecutor.execute(() -> mainExecutor.execute(() -> timeline.add("sync")));

    workerDelegate.runAll();
    mainExecutor.runOne();
    handler.onCancel(null);
    drainBoth(workerDelegate, mainExecutor);

    assertEquals(Arrays.asList("query:" + QuerySnapshotChunkProtocol.START_KIND, "sync"), timeline);
  }

  @Test
  public void sinkFailureMidChunkedSnapshotReleasesSharedDeliveryExecutorForSync() {
    Query query = mock(Query.class);
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = captureListener(query);
    ManualExecutor workerDelegate = new ManualExecutor();
    SnapshotDeliveryExecutor deliveryExecutor = new SnapshotDeliveryExecutor(workerDelegate);
    ManualExecutor mainExecutor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            deliveryExecutor,
            mainExecutor);
    List<String> timeline = new ArrayList<>();
    EventChannel.EventSink failingSink =
        new EventChannel.EventSink() {
          @Override
          public void success(Object event) {
            timeline.add("query:" + kind(event));
            throw new IllegalStateException("sink failed");
          }

          @Override
          public void error(String code, String message, Object details) {
            timeline.add("error:" + code);
          }

          @Override
          public void endOfStream() {
            timeline.add("endOfStream");
          }
        };

    handler.onListen(CHUNKED_ARGS, failingSink);
    QuerySnapshot snapshot = singleDocumentSnapshot();
    deliveryExecutor.execute(() -> listenerRef.get().onEvent(snapshot, null));
    deliveryExecutor.execute(() -> mainExecutor.execute(() -> timeline.add("sync")));

    drainBoth(workerDelegate, mainExecutor);

    assertEquals(
        Arrays.asList(
            "query:" + QuerySnapshotChunkProtocol.START_KIND,
            "error:firebase_firestore",
            "endOfStream",
            "sync"),
        timeline);
  }

  private void drainBoth(ManualExecutor first, ManualExecutor second) {
    while (!first.pending.isEmpty() || !second.pending.isEmpty()) {
      first.runAll();
      second.runAll();
    }
  }

  @SuppressWarnings("unchecked")
  private AtomicReference<EventListener<QuerySnapshot>> captureListener(Query query) {
    return captureListener(query, mock(ListenerRegistration.class));
  }

  @SuppressWarnings("unchecked")
  private AtomicReference<EventListener<QuerySnapshot>> captureListener(
      Query query, ListenerRegistration registration) {
    AtomicReference<EventListener<QuerySnapshot>> listenerRef = new AtomicReference<>();
    when(query.addSnapshotListener(any(SnapshotListenOptions.class), any()))
        .thenAnswer(
            invocation -> {
              listenerRef.set(invocation.getArgument(1));
              return registration;
            });
    return listenerRef;
  }

  private QuerySnapshot singleDocumentSnapshot() {
    QuerySnapshot snapshot = mock(QuerySnapshot.class);
    QueryDocumentSnapshot document = mock(QueryDocumentSnapshot.class);
    DocumentReference reference = mock(DocumentReference.class);
    SnapshotMetadata metadata = mock(SnapshotMetadata.class);
    DocumentChange change = mock(DocumentChange.class);
    when(snapshot.getMetadata()).thenReturn(metadata);
    when(snapshot.getDocuments()).thenReturn(Collections.singletonList(document));
    when(snapshot.getDocumentChanges()).thenReturn(Collections.singletonList(change));
    when(metadata.hasPendingWrites()).thenReturn(false);
    when(metadata.isFromCache()).thenReturn(false);
    when(document.getMetadata()).thenReturn(metadata);
    when(document.getReference()).thenReturn(reference);
    when(reference.getPath()).thenReturn("projects/p/assets/a");
    when(document.getData(DocumentSnapshot.ServerTimestampBehavior.NONE))
        .thenReturn(Collections.singletonMap("title", "Asset A"));
    when(change.getType()).thenReturn(DocumentChange.Type.ADDED);
    when(change.getDocument()).thenReturn(document);
    when(change.getOldIndex()).thenReturn(-1);
    when(change.getNewIndex()).thenReturn(0);
    return snapshot;
  }

  private QuerySnapshot emptySnapshot() {
    QuerySnapshot snapshot = mock(QuerySnapshot.class);
    SnapshotMetadata metadata = mock(SnapshotMetadata.class);
    when(metadata.hasPendingWrites()).thenReturn(false);
    when(metadata.isFromCache()).thenReturn(false);
    when(snapshot.getMetadata()).thenReturn(metadata);
    when(snapshot.getDocuments()).thenReturn(Collections.emptyList());
    when(snapshot.getDocumentChanges()).thenReturn(Collections.emptyList());
    return snapshot;
  }

  private int kind(Object event) {
    return (Integer) ((Map<?, ?>) event).get("kind");
  }

  private long snapshotId(Object event) {
    return (Long) ((Map<?, ?>) event).get("snapshotId");
  }

  private static final class RecordingEventSink implements EventChannel.EventSink {
    final List<Object> events = new ArrayList<>();
    String errorCode;
    int endOfStreamCount;

    @Override
    public void success(Object event) {
      events.add(event);
    }

    @Override
    public void error(String code, String message, Object details) {
      errorCode = code;
    }

    @Override
    public void endOfStream() {
      endOfStreamCount++;
    }
  }

  private static final class ManualExecutor implements Executor {
    final ArrayDeque<Runnable> pending = new ArrayDeque<>();

    @Override
    public void execute(Runnable command) {
      pending.addLast(command);
    }

    void runOne() {
      pending.removeFirst().run();
    }

    void runAll() {
      while (!pending.isEmpty()) {
        pending.removeFirst().run();
      }
    }
  }
}
