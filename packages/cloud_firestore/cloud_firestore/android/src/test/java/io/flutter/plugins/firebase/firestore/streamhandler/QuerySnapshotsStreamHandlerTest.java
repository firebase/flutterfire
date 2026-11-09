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
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.ListenSource;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.SnapshotMetadata;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executor;
import org.junit.Test;

public class QuerySnapshotsStreamHandlerTest {
  @Test
  public void emitsOneLogicalSnapshotAsBoundedProtocolMessages() {
    Query query = mock(Query.class);
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
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            query,
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            Runnable::run,
            Runnable::run);
    RecordingEventSink sink = new RecordingEventSink();
    handler.emitSnapshotForTesting(snapshot, sink);

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
  public void serializesQueuedSnapshotsWithoutInterleaving() {
    Query query = mock(Query.class);
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

    handler.emitSnapshotForTesting(snapshot, sink);
    handler.emitSnapshotForTesting(snapshot, sink);
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
    ManualExecutor executor = new ManualExecutor();
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            mock(Query.class),
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            executor,
            executor);
    RecordingEventSink sink = new RecordingEventSink();

    handler.emitSnapshotForTesting(emptySnapshot(), sink);
    handler.onCancel(null);
    executor.runAll();

    assertTrue(sink.events.isEmpty());
  }

  @Test
  public void registrationReturnedAfterCancellationIsRemoved() {
    ListenerRegistration registration = mock(ListenerRegistration.class);
    QuerySnapshotsStreamHandler handler =
        new QuerySnapshotsStreamHandler(
            mock(Query.class),
            false,
            DocumentSnapshot.ServerTimestampBehavior.NONE,
            ListenSource.DEFAULT,
            Runnable::run,
            Runnable::run);

    handler.onCancel(null);
    handler.retainListenerRegistration(registration);

    verify(registration).remove();
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

    void runAll() {
      while (!pending.isEmpty()) {
        pending.removeFirst().run();
      }
    }
  }
}
