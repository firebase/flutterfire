// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics;

import android.content.Context;
import android.util.Log;
import java.io.File;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 * Reads the ELF build ID from libapp.so at runtime.
 *
 * <p>The Firebase CLI's {@code crashlytics:symbols:upload} command uses the ELF build ID (from the
 * {@code .note.gnu.build-id} section) when uploading symbols. To ensure Crashlytics can match crash
 * reports to uploaded symbols, the plugin must report the same ELF build ID rather than the Dart
 * VM's internal snapshot build ID (which may differ, especially for AAB + flavor builds).
 */
final class ElfBuildIdReader {

  private static final String TAG = "FLTFirebaseCrashlytics";

  private static final byte[] ELF_MAGIC = {0x7f, 'E', 'L', 'F'};
  private static final int ELFCLASS64 = 2;
  private static final int PT_NOTE = 4;
  private static final int NT_GNU_BUILD_ID = 3;
  private static final String GNU_NOTE_NAME = "GNU";

  private ElfBuildIdReader() {}

  /**
   * Reads the ELF build ID from libapp.so in the app's native library directory.
   *
   * @return the build ID as a lowercase hex string, or {@code null} if it cannot be read.
   */
  static String readBuildId(Context context) {
    try {
      String nativeLibDir = context.getApplicationInfo().nativeLibraryDir;
      File libApp = new File(nativeLibDir, "libapp.so");
      if (!libApp.exists()) {
        return null;
      }
      return readBuildIdFromElf(libApp);
    } catch (Exception e) {
      Log.d(TAG, "Could not read ELF build ID from libapp.so", e);
      return null;
    }
  }

  private static String readBuildIdFromElf(File elfFile) throws Exception {
    try (RandomAccessFile raf = new RandomAccessFile(elfFile, "r")) {
      // Verify ELF magic bytes.
      byte[] magic = new byte[4];
      raf.readFully(magic);
      for (int i = 0; i < 4; i++) {
        if (magic[i] != ELF_MAGIC[i]) {
          return null;
        }
      }

      int elfClass = raf.read(); // 1 = 32-bit, 2 = 64-bit
      boolean is64 = elfClass == ELFCLASS64;

      int dataEncoding = raf.read(); // 1 = little-endian, 2 = big-endian
      ByteOrder order = dataEncoding == 1 ? ByteOrder.LITTLE_ENDIAN : ByteOrder.BIG_ENDIAN;

      if (is64) {
        return readBuildIdFromElf64(raf, order);
      } else {
        return readBuildIdFromElf32(raf, order);
      }
    }
  }

  private static String readBuildIdFromElf64(RandomAccessFile raf, ByteOrder order)
      throws Exception {
    // e_phoff is at offset 32 in the 64-bit ELF header.
    raf.seek(32);
    long phoff = readLong(raf, order);

    // e_phentsize is at offset 54, e_phnum at offset 56.
    raf.seek(54);
    int phentsize = readUnsignedShort(raf, order);
    int phnum = readUnsignedShort(raf, order);

    for (int i = 0; i < phnum; i++) {
      long phdr = phoff + (long) i * phentsize;
      raf.seek(phdr);
      int type = readInt(raf, order);
      if (type == PT_NOTE) {
        // p_offset is at phdr + 8, p_filesz at phdr + 32 for 64-bit.
        raf.seek(phdr + 8);
        long noteOffset = readLong(raf, order);
        raf.seek(phdr + 32);
        long noteSize = readLong(raf, order);

        String buildId = findGnuBuildId(raf, noteOffset, noteSize, order);
        if (buildId != null) {
          return buildId;
        }
      }
    }
    return null;
  }

  private static String readBuildIdFromElf32(RandomAccessFile raf, ByteOrder order)
      throws Exception {
    // e_phoff is at offset 28 in the 32-bit ELF header.
    raf.seek(28);
    long phoff = readInt(raf, order) & 0xFFFFFFFFL;

    // e_phentsize is at offset 42, e_phnum at offset 44.
    raf.seek(42);
    int phentsize = readUnsignedShort(raf, order);
    int phnum = readUnsignedShort(raf, order);

    for (int i = 0; i < phnum; i++) {
      long phdr = phoff + (long) i * phentsize;
      raf.seek(phdr);
      int type = readInt(raf, order);
      if (type == PT_NOTE) {
        // p_offset is at phdr + 4, p_filesz at phdr + 16 for 32-bit.
        raf.seek(phdr + 4);
        long noteOffset = readInt(raf, order) & 0xFFFFFFFFL;
        raf.seek(phdr + 16);
        long noteSize = readInt(raf, order) & 0xFFFFFFFFL;

        String buildId = findGnuBuildId(raf, noteOffset, noteSize, order);
        if (buildId != null) {
          return buildId;
        }
      }
    }
    return null;
  }

  /**
   * Searches a PT_NOTE segment for the GNU build ID note.
   *
   * <p>Note format: namesz (4) | descsz (4) | type (4) | name (aligned to 4) | desc (aligned to 4)
   */
  private static String findGnuBuildId(
      RandomAccessFile raf, long offset, long size, ByteOrder order) throws Exception {
    long end = offset + size;
    long pos = offset;

    while (pos + 12 <= end) {
      raf.seek(pos);
      int namesz = readInt(raf, order);
      int descsz = readInt(raf, order);
      int type = readInt(raf, order);

      if (namesz < 0 || descsz < 0 || namesz > 256) {
        break;
      }

      int nameAligned = align4(namesz);
      long descPos = pos + 12 + nameAligned;

      if (namesz > 0 && type == NT_GNU_BUILD_ID && descPos + descsz <= end) {
        byte[] nameBytes = new byte[namesz];
        raf.readFully(nameBytes);
        // Name is null-terminated.
        String name =
            namesz > 0 ? new String(nameBytes, 0, Math.max(0, namesz - 1), "US-ASCII") : "";

        if (GNU_NOTE_NAME.equals(name) && descsz > 0) {
          raf.seek(descPos);
          byte[] desc = new byte[descsz];
          raf.readFully(desc);
          return bytesToHex(desc);
        }
      }

      pos = descPos + align4(descsz);
    }
    return null;
  }

  private static int align4(int value) {
    return (value + 3) & ~3;
  }

  private static int readInt(RandomAccessFile raf, ByteOrder order) throws Exception {
    byte[] buf = new byte[4];
    raf.readFully(buf);
    return ByteBuffer.wrap(buf).order(order).getInt();
  }

  private static long readLong(RandomAccessFile raf, ByteOrder order) throws Exception {
    byte[] buf = new byte[8];
    raf.readFully(buf);
    return ByteBuffer.wrap(buf).order(order).getLong();
  }

  private static int readUnsignedShort(RandomAccessFile raf, ByteOrder order) throws Exception {
    byte[] buf = new byte[2];
    raf.readFully(buf);
    return ByteBuffer.wrap(buf).order(order).getShort() & 0xFFFF;
  }

  private static String bytesToHex(byte[] bytes) {
    StringBuilder sb = new StringBuilder(bytes.length * 2);
    for (byte b : bytes) {
      sb.append(String.format("%02x", b & 0xff));
    }
    return sb.toString();
  }
}
