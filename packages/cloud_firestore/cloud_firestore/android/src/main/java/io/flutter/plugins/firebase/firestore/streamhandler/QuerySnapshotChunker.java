/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.function.Function;
import java.util.function.ToIntFunction;

/**
 * Incrementally converts and partitions snapshot items without retaining a converted copy of the
 * complete query snapshot.
 *
 * <p>The inexpensive per-item size estimate chooses an initial boundary. The exact envelope sizer
 * then removes tail items until the actual platform message fits. A single item is always allowed
 * through even when it exceeds the target, because Firestore already bounds an individual document
 * to 1 MiB and the stream must continue making progress.
 */
final class QuerySnapshotChunker<S, T> {
  private final Iterator<S> source;
  private final Function<S, T> converter;
  private final ToIntFunction<T> itemSize;
  private final int targetBytes;
  private final ArrayDeque<T> pending = new ArrayDeque<>();

  QuerySnapshotChunker(
      Iterator<S> source, Function<S, T> converter, ToIntFunction<T> itemSize, int targetBytes) {
    if (targetBytes <= 0) {
      throw new IllegalArgumentException("targetBytes must be positive");
    }
    this.source = source;
    this.converter = converter;
    this.itemSize = itemSize;
    this.targetBytes = targetBytes;
  }

  boolean hasNext() {
    return !pending.isEmpty() || source.hasNext();
  }

  List<T> nextChunk(ToIntFunction<List<T>> exactEnvelopeSize) {
    if (!hasNext()) {
      throw new NoSuchElementException("No snapshot items remain");
    }

    ArrayList<T> chunk = new ArrayList<>();
    int estimatedBytes = 0;

    while (hasNext()) {
      T item = pending.isEmpty() ? converter.apply(source.next()) : pending.removeFirst();
      int encodedItemBytes = Math.max(0, itemSize.applyAsInt(item));

      if (!chunk.isEmpty() && estimatedBytes + encodedItemBytes > targetBytes) {
        pending.addFirst(item);
        break;
      }

      chunk.add(item);
      estimatedBytes += encodedItemBytes;
      if (estimatedBytes >= targetBytes) {
        break;
      }
    }

    while (chunk.size() > 1 && exactEnvelopeSize.applyAsInt(chunk) > targetBytes) {
      pending.addFirst(chunk.remove(chunk.size() - 1));
    }

    return chunk;
  }
}
