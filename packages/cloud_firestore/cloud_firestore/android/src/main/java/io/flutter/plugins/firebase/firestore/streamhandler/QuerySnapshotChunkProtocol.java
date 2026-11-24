/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import io.flutter.plugins.firebase.firestore.PigeonCodecSizer;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

final class QuerySnapshotChunkProtocol {
  // Kept in sync with query_snapshot_chunk_assembler.dart.
  static final String LISTEN_CHUNKED_ARG_KEY = "firestoreQuerySnapshotChunked";
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

  static final int MAX_ENCODED_ENVELOPE_BYTES = 512 * 1024;

  private QuerySnapshotChunkProtocol() {}

  static boolean supportsChunking(Object arguments) {
    if (!(arguments instanceof Map<?, ?>)) {
      return false;
    }
    return Boolean.TRUE.equals(((Map<?, ?>) arguments).get(LISTEN_CHUNKED_ARG_KEY));
  }

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
    return PigeonCodecSizer.encodedMessageSize(message);
  }

  static int encodedEnvelopeSize(Object message) {
    return PigeonCodecSizer.encodedSuccessEnvelopeSize(message);
  }

  private static Map<String, Object> base(long snapshotId, int kind) {
    Map<String, Object> message = new LinkedHashMap<>();
    message.put(CHUNK_MARKER_KEY, true);
    message.put(SNAPSHOT_ID_KEY, snapshotId);
    message.put(KIND_KEY, kind);
    return message;
  }
}
