/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import com.google.firebase.Timestamp;
import com.google.firebase.firestore.GeoPoint;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.Test;

public class QuerySnapshotChunkProtocolTest {
  private static final StandardMethodCodec METHOD_CODEC =
      new StandardMethodCodec(GeneratedAndroidFirebaseFirestore.PigeonCodec.INSTANCE);

  @Test
  public void supportsChunkingMatchesListenArgument() {
    assertTrue(
        QuerySnapshotChunkProtocol.supportsChunking(
            Collections.singletonMap(QuerySnapshotChunkProtocol.LISTEN_CHUNKED_ARG_KEY, true)));
    assertFalse(
        QuerySnapshotChunkProtocol.supportsChunking(
            Collections.singletonMap(QuerySnapshotChunkProtocol.LISTEN_CHUNKED_ARG_KEY, false)));
    assertFalse(QuerySnapshotChunkProtocol.supportsChunking(Collections.emptyMap()));
    assertFalse(QuerySnapshotChunkProtocol.supportsChunking("chunked"));
    assertFalse(QuerySnapshotChunkProtocol.supportsChunking(null));
  }

  @Test
  public void sizerMatchesStandardMethodCodecByteForByte() {
    Map<String, Object> fields = new LinkedHashMap<>();
    fields.put("string", "hello-world");
    fields.put("int", 42);
    fields.put("long", 1L << 40);
    fields.put("double", 3.141592653589793);
    fields.put("bool", true);
    fields.put("null", null);
    fields.put("geo", new GeoPoint(37.7749, -122.4194));
    fields.put("timestamp", new Timestamp(1700000000L, 123456000));
    fields.put("list", Collections.singletonList(1.5));

    GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata metadata =
        new GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata.Builder()
            .setHasPendingWrites(true)
            .setIsFromCache(false)
            .build();
    GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot doc =
        new GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot.Builder()
            .setPath("projects/p/assets/aligned")
            .setData(fields)
            .setMetadata(metadata)
            .build();
    GeneratedAndroidFirebaseFirestore.InternalDocumentChange change =
        new GeneratedAndroidFirebaseFirestore.InternalDocumentChange.Builder()
            .setType(GeneratedAndroidFirebaseFirestore.DocumentChangeType.MODIFIED)
            .setDocument(doc)
            .setOldIndex(0L)
            .setNewIndex(1L)
            .build();

    List<Object> messages = new ArrayList<>();
    messages.add(QuerySnapshotChunkProtocol.start(7L, 1, 1, metadata));
    messages.add(
        QuerySnapshotChunkProtocol.itemChunk(
            7L, QuerySnapshotChunkProtocol.DOCUMENTS_KIND, Collections.singletonList(doc)));
    messages.add(
        QuerySnapshotChunkProtocol.itemChunk(
            7L,
            QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND,
            Collections.singletonList(change)));
    messages.add(QuerySnapshotChunkProtocol.end(7L));

    for (Object message : messages) {
      ByteBuffer encodedMessage =
          GeneratedAndroidFirebaseFirestore.PigeonCodec.INSTANCE.encodeMessage(message);
      assertEquals(
          encodedMessage.position(), QuerySnapshotChunkProtocol.encodedMessageSize(message));

      ByteBuffer encodedEnvelope = METHOD_CODEC.encodeSuccessEnvelope(message);
      assertEquals(
          encodedEnvelope.position(), QuerySnapshotChunkProtocol.encodedEnvelopeSize(message));
    }
  }

  @Test
  public void documentChunkEnvelopesStayWithinTheTransportTarget() {
    List<GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot> documents = new ArrayList<>();
    String payload = String.join("", Collections.nCopies(2048, "abcdefgh"));
    for (int index = 0; index < 100; index++) {
      documents.add(document("projects/p/assets/" + index, payload));
    }

    QuerySnapshotChunker<
            GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot,
            GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot>
        chunker =
            new QuerySnapshotChunker<>(
                documents.iterator(),
                value -> value,
                QuerySnapshotChunkProtocol::encodedMessageSize,
                QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
    List<GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot> received = new ArrayList<>();

    while (chunker.hasNext()) {
      List<GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot> chunk =
          chunker.nextChunk(
              values ->
                  QuerySnapshotChunkProtocol.encodedEnvelopeSize(
                      QuerySnapshotChunkProtocol.itemChunk(
                          42, QuerySnapshotChunkProtocol.DOCUMENTS_KIND, values)));
      Map<String, Object> message =
          QuerySnapshotChunkProtocol.itemChunk(
              42, QuerySnapshotChunkProtocol.DOCUMENTS_KIND, chunk);

      int realEnvelopeBytes = METHOD_CODEC.encodeSuccessEnvelope(message).position();
      assertEquals(realEnvelopeBytes, QuerySnapshotChunkProtocol.encodedEnvelopeSize(message));
      assertTrue(realEnvelopeBytes <= QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
      received.addAll(chunk);
    }

    assertEquals(documents, received);
  }

  @Test
  public void oneOversizedDocumentStillProducesOneBoundedByFirestoreItemMessage() {
    GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot document =
        document(
            "projects/p/assets/large", String.join("", Collections.nCopies(131072, "abcdefgh")));
    QuerySnapshotChunker<
            GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot,
            GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot>
        chunker =
            new QuerySnapshotChunker<>(
                Collections.singletonList(document).iterator(),
                value -> value,
                QuerySnapshotChunkProtocol::encodedMessageSize,
                QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);

    List<GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot> chunk =
        chunker.nextChunk(
            values ->
                QuerySnapshotChunkProtocol.encodedEnvelopeSize(
                    QuerySnapshotChunkProtocol.itemChunk(
                        1, QuerySnapshotChunkProtocol.DOCUMENTS_KIND, values)));

    assertEquals(Collections.singletonList(document), chunk);
    assertTrue(
        QuerySnapshotChunkProtocol.encodedEnvelopeSize(
                QuerySnapshotChunkProtocol.itemChunk(
                    1, QuerySnapshotChunkProtocol.DOCUMENTS_KIND, chunk))
            < 2 * 1024 * 1024);
  }

  @Test
  public void productionSizedSnapshotReplacesOneHugeEnvelopeWithBoundedMessages() {
    int documentCount = 6112;
    String payload = String.join("", Collections.nCopies(344, "abcdefgh"));
    List<GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot> documents =
        new ArrayList<>(documentCount);
    List<GeneratedAndroidFirebaseFirestore.InternalDocumentChange> changes =
        new ArrayList<>(documentCount);
    for (int index = 0; index < documentCount; index++) {
      GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot document =
          document("projects/p/assets/" + index, payload);
      documents.add(document);
      changes.add(
          new GeneratedAndroidFirebaseFirestore.InternalDocumentChange.Builder()
              .setType(GeneratedAndroidFirebaseFirestore.DocumentChangeType.ADDED)
              .setDocument(document)
              .setOldIndex(-1L)
              .setNewIndex((long) index)
              .build());
    }
    GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata metadata =
        new GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata.Builder()
            .setHasPendingWrites(false)
            .setIsFromCache(false)
            .build();
    GeneratedAndroidFirebaseFirestore.InternalQuerySnapshot original =
        new GeneratedAndroidFirebaseFirestore.InternalQuerySnapshot.Builder()
            .setDocuments(documents)
            .setDocumentChanges(changes)
            .setMetadata(metadata)
            .build();

    int originalEnvelopeBytes = QuerySnapshotChunkProtocol.encodedEnvelopeSize(original);
    assertTrue(
        "Expected the original envelope to exceed 30 MiB, got " + originalEnvelopeBytes,
        originalEnvelopeBytes > 30 * 1024 * 1024);

    assertBoundedChunks(documents, QuerySnapshotChunkProtocol.DOCUMENTS_KIND);
    assertBoundedChunks(changes, QuerySnapshotChunkProtocol.DOCUMENT_CHANGES_KIND);
  }

  private <T> void assertBoundedChunks(List<T> items, int kind) {
    QuerySnapshotChunker<T, T> chunker =
        new QuerySnapshotChunker<>(
            items.iterator(),
            value -> value,
            QuerySnapshotChunkProtocol::encodedMessageSize,
            QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
    int received = 0;
    while (chunker.hasNext()) {
      List<T> chunk =
          chunker.nextChunk(
              values ->
                  QuerySnapshotChunkProtocol.encodedEnvelopeSize(
                      QuerySnapshotChunkProtocol.itemChunk(1, kind, values)));
      assertTrue(
          QuerySnapshotChunkProtocol.encodedEnvelopeSize(
                  QuerySnapshotChunkProtocol.itemChunk(1, kind, chunk))
              <= QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
      received += chunk.size();
    }
    assertEquals(items.size(), received);
  }

  private GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot document(
      String path, String payload) {
    GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata metadata =
        new GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata.Builder()
            .setHasPendingWrites(false)
            .setIsFromCache(false)
            .build();
    return new GeneratedAndroidFirebaseFirestore.InternalDocumentSnapshot.Builder()
        .setPath(path)
        .setData(Collections.singletonMap("payload", payload))
        .setMetadata(metadata)
        .build();
  }
}
