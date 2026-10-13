/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.nio.ByteBuffer;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Wire messages for bounded Android query-snapshot transport. */
final class QuerySnapshotChunkProtocol {
  // Keep these values in sync with query_snapshot_chunk_assembler.dart.
  private static final String CHUNK_MARKER_KEY = "firestoreQuerySnapshotChunk";
  private static final String SNAPSHOT_ID_KEY = "snapshotId";
  private static final String KIND_KEY = "kind";
  private static final String PAYLOAD_KEY = "payload";
  private static final String DOCUMENT_COUNT_KEY = "documentCount";
  private static final String DOCUMENT_CHANGE_COUNT_KEY = "documentChangeCount";

  static final int START_KIND = 0;
  static final int DOCUMENTS_KIND = 1;
  static final int DOCUMENT_CHANGES_KIND = 2;
  static final int END_KIND = 3;

  /**
   * Keeps the transient platform-channel envelope far below the 18–31 MiB allocations observed in
   * the crash report. A single Firestore document may exceed this target, but Firestore itself
   * bounds that exceptional message to one 1 MiB document plus codec overhead.
   */
  static final int MAX_ENCODED_ENVELOPE_BYTES = 512 * 1024;

  private static final StandardMethodCodec METHOD_CODEC =
      new StandardMethodCodec(GeneratedAndroidFirebaseFirestore.PigeonCodec.INSTANCE);

  private QuerySnapshotChunkProtocol() {}

  static Map<String, Object> start(
      long snapshotId,
      int documentCount,
      int documentChangeCount,
      GeneratedAndroidFirebaseFirestore.InternalSnapshotMetadata metadata) {
    Map<String, Object> message = base(snapshotId, START_KIND);
    message.put(PAYLOAD_KEY, metadata);
    message.put(DOCUMENT_COUNT_KEY, documentCount);
    message.put(DOCUMENT_CHANGE_COUNT_KEY, documentChangeCount);
    return message;
  }

  static Map<String, Object> itemChunk(long snapshotId, int kind, List<?> items) {
    Map<String, Object> message = base(snapshotId, kind);
    message.put(PAYLOAD_KEY, items);
    return message;
  }

  static Map<String, Object> end(long snapshotId) {
    return base(snapshotId, END_KIND);
  }

  static int encodedMessageSize(Object message) {
    ByteBuffer encoded =
        GeneratedAndroidFirebaseFirestore.PigeonCodec.INSTANCE.encodeMessage(message);
    return encoded == null ? 0 : encoded.position();
  }

  static int encodedEnvelopeSize(Object message) {
    ByteBuffer encoded = METHOD_CODEC.encodeSuccessEnvelope(message);
    return encoded.position();
  }

  private static Map<String, Object> base(long snapshotId, int kind) {
    Map<String, Object> message = new LinkedHashMap<>();
    message.put(CHUNK_MARKER_KEY, true);
    message.put(SNAPSHOT_ID_KEY, snapshotId);
    message.put(KIND_KEY, kind);
    return message;
  }
}
