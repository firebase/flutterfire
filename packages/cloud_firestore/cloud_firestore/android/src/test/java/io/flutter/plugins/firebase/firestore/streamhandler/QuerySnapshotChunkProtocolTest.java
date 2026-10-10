/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.junit.Test;

public class QuerySnapshotChunkProtocolTest {
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

      assertTrue(
          QuerySnapshotChunkProtocol.encodedEnvelopeSize(message)
              <= QuerySnapshotChunkProtocol.MAX_ENCODED_ENVELOPE_BYTES);
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
