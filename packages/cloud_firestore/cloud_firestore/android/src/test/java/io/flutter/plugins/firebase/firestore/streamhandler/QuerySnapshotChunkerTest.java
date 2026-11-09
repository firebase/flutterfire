/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.Test;

public class QuerySnapshotChunkerTest {
  @Test
  public void chunksItemsWithoutReordering() {
    QuerySnapshotChunker<Integer, Integer> chunker =
        new QuerySnapshotChunker<>(
            Arrays.asList(1, 2, 3).iterator(), value -> value, value -> 4, 10);

    assertEquals(Arrays.asList(1, 2), chunker.nextChunk(this::encodedSizeWithOneByteHeader));
    assertEquals(
        Collections.singletonList(3), chunker.nextChunk(this::encodedSizeWithOneByteHeader));
    assertFalse(chunker.hasNext());
  }

  @Test
  public void shrinksAChunkWhenTheExactEnvelopeExceedsTheTarget() {
    QuerySnapshotChunker<Integer, Integer> chunker =
        new QuerySnapshotChunker<>(
            Arrays.asList(1, 2, 3).iterator(), value -> value, value -> 4, 10);

    assertEquals(
        Collections.singletonList(1), chunker.nextChunk(this::encodedSizeWithFourByteHeader));
    assertEquals(
        Collections.singletonList(2), chunker.nextChunk(this::encodedSizeWithFourByteHeader));
    assertEquals(
        Collections.singletonList(3), chunker.nextChunk(this::encodedSizeWithFourByteHeader));
  }

  @Test
  public void allowsOneOversizedItemSoProgressCannotStall() {
    QuerySnapshotChunker<Integer, Integer> chunker =
        new QuerySnapshotChunker<>(
            Collections.singletonList(1).iterator(), value -> value, value -> 14, 10);

    assertEquals(Collections.singletonList(1), chunker.nextChunk(values -> 15));
    assertFalse(chunker.hasNext());
  }

  @Test
  public void convertsEverySourceItemExactlyOnce() {
    AtomicInteger conversions = new AtomicInteger();
    QuerySnapshotChunker<Integer, Integer> chunker =
        new QuerySnapshotChunker<>(
            Arrays.asList(1, 2, 3).iterator(),
            value -> {
              conversions.incrementAndGet();
              return value;
            },
            value -> 4,
            10);

    while (chunker.hasNext()) {
      assertTrue(chunker.nextChunk(this::encodedSizeWithFourByteHeader).size() >= 1);
    }

    assertEquals(3, conversions.get());
  }

  @Test
  public void emptyInputHasNoChunk() {
    QuerySnapshotChunker<Integer, Integer> chunker =
        new QuerySnapshotChunker<>(
            Collections.<Integer>emptyList().iterator(), value -> value, value -> 1, 10);

    assertFalse(chunker.hasNext());
  }

  private int encodedSizeWithOneByteHeader(List<Integer> values) {
    return 1 + (values.size() * 4);
  }

  private int encodedSizeWithFourByteHeader(List<Integer> values) {
    return 4 + (values.size() * 4);
  }
}
