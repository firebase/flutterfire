/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore;

import java.io.ByteArrayOutputStream;

public final class PigeonCodecSizer {
  private PigeonCodecSizer() {}

  public static int encodedMessageSize(Object message) {
    if (message == null) {
      return 0;
    }
    CountingByteArrayOutputStream stream = new CountingByteArrayOutputStream();
    GeneratedAndroidFirebaseFirestore.PigeonCodec.INSTANCE.writeValue(stream, message);
    return stream.size();
  }

  public static int encodedSuccessEnvelopeSize(Object message) {
    CountingByteArrayOutputStream stream = new CountingByteArrayOutputStream();
    // StandardMethodCodec prefixes success envelopes with a single 0 byte.
    stream.write(0);
    GeneratedAndroidFirebaseFirestore.PigeonCodec.INSTANCE.writeValue(stream, message);
    return stream.size();
  }

  private static final class CountingByteArrayOutputStream extends ByteArrayOutputStream {
    private int totalBytes;

    CountingByteArrayOutputStream() {
      super(0);
    }

    @Override
    public void write(int b) {
      totalBytes++;
    }

    @Override
    public void write(byte[] b, int off, int len) {
      if (len < 0 || off < 0 || off > b.length || off + len > b.length) {
        throw new IndexOutOfBoundsException();
      }
      totalBytes += len;
    }

    @Override
    public int size() {
      return totalBytes;
    }
  }
}
