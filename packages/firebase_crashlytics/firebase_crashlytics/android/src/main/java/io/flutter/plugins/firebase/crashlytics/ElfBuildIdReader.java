// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics;

import android.content.Context;
import android.util.Log;
import androidx.annotation.VisibleForTesting;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * Reads the ELF build ID from libapp.so at runtime.
 *
 * <p>The Firebase CLI's {@code crashlytics:symbols:upload} command uses the ELF build ID (from the
 * {@code .note.gnu.build-id} section) when uploading symbols. To ensure Crashlytics can match crash
 * reports to uploaded symbols, the plugin must report the same ELF build ID rather than the Dart
 * VM's internal snapshot build ID (which may differ, especially for AAB + flavor builds).
 *
 * <p>Only a bounded prefix of the library is ever read into memory: every allocation here is sized
 * by a constant, never by a value read from the file.
 */
final class ElfBuildIdReader {

  private static final String TAG = "FLTFirebaseCrashlytics";

  private static final byte[] ELF_MAGIC = {0x7f, 'E', 'L', 'F'};
  private static final int ELFCLASS32 = 1;
  private static final int ELFCLASS64 = 2;
  private static final int ELFDATA2LSB = 1;
  private static final int ELFDATA2MSB = 2;
  private static final int PT_NOTE = 4;
  private static final int NT_GNU_BUILD_ID = 3;
  private static final String GNU_NOTE_NAME = "GNU";

  /** First attempt: enough for the ELF header, program header table, and typical notes. */
  private static final int INITIAL_PREFIX_BYTES = 4 * 1024;

  /**
   * Hard ceiling for a retry if a note sits further into the library. A library whose build ID note
   * starts beyond this reports no build ID at all, which costs symbol matching but never memory.
   */
  private static final int MAX_PREFIX_BYTES = 256 * 1024;

  /** GNU build IDs are small; this bounds hostile or corrupt descsz values. */
  private static final int MAX_DESC_BYTES = 1024;

  private static final int ELF32_HEADER_BYTES = 52;
  private static final int ELF64_HEADER_BYTES = 64;
  private static final int ELF32_PHDR_MIN_BYTES = 32;
  private static final int ELF64_PHDR_MIN_BYTES = 56;
  private static final int NOTE_HEADER_BYTES = 12;

  private ElfBuildIdReader() {}

  /** Parse outcome: either a build ID, or how many prefix bytes would have been needed. */
  @VisibleForTesting
  static final class ParseResult {
    final String buildId;
    final int bytesNeeded;

    ParseResult(String buildId, int bytesNeeded) {
      this.buildId = buildId;
      this.bytesNeeded = bytesNeeded;
    }

    static final ParseResult NOT_FOUND = new ParseResult(null, 0);
  }

  /**
   * Opens a stream positioned at the start of the library.
   *
   * <p>Retrying with a larger prefix re-reads from the beginning, so the source must be able to
   * hand out a fresh stream on each call.
   */
  @VisibleForTesting
  interface StreamSource {
    InputStream open() throws IOException;
  }

  /**
   * Reads the ELF build ID from libapp.so.
   *
   * <p>First checks the native library directory (for devices that extract native libs). If not
   * found there, reads libapp.so from inside the APK (for devices with extractNativeLibs=false).
   *
   * @return the build ID as a lowercase hex string, or {@code null} if it cannot be read.
   */
  static String readBuildId(Context context) {
    try {
      // Try extracted native library first.
      String nativeLibDir = context.getApplicationInfo().nativeLibraryDir;
      File libApp = new File(nativeLibDir, "libapp.so");
      if (libApp.exists()) {
        return readBuildIdFromFile(libApp);
      }

      // Fall back to reading from inside the APK (or split APKs for AAB installs).
      return readBuildIdFromApk(context);
    } catch (Exception | OutOfMemoryError e) {
      Log.d(TAG, "Could not read ELF build ID from libapp.so", e);
      return null;
    }
  }

  /**
   * Reads the ELF build ID from libapp.so stored inside the APK. On newer Android versions, native
   * libraries may not be extracted to the filesystem.
   */
  private static String readBuildIdFromApk(Context context) throws Exception {
    // Check the base APK first.
    String result = readBuildIdFromZip(context.getApplicationInfo().sourceDir);
    if (result != null) {
      return result;
    }

    // For AAB installs, libapp.so is in a split APK (e.g., split_config.arm64_v8a.apk).
    String[] splitDirs = context.getApplicationInfo().splitSourceDirs;
    if (splitDirs != null) {
      for (String splitDir : splitDirs) {
        result = readBuildIdFromZip(splitDir);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  private static String readBuildIdFromZip(String apkPath) throws Exception {
    try (ZipFile zipFile = new ZipFile(apkPath)) {
      Enumeration<? extends ZipEntry> entries = zipFile.entries();
      while (entries.hasMoreElements()) {
        ZipEntry entry = entries.nextElement();
        if (entry.getName().endsWith("/libapp.so")) {
          return readBuildIdFromSource(() -> zipFile.getInputStream(entry));
        }
      }
    }
    return null;
  }

  private static String readBuildIdFromFile(File elfFile) throws Exception {
    return readBuildIdFromSource(() -> new FileInputStream(elfFile));
  }

  /**
   * Parses successively larger prefixes until the build ID is found or the source runs out.
   *
   * <p>Each retry strictly increases the prefix size and stops at {@link #MAX_PREFIX_BYTES}, so the
   * loop always terminates: a truncated or malformed library returns {@code null} rather than
   * asking for bytes the source can never supply.
   */
  @VisibleForTesting
  static String readBuildIdFromSource(StreamSource source) throws IOException {
    int limit = INITIAL_PREFIX_BYTES;
    while (true) {
      byte[] prefix;
      try (InputStream is = source.open()) {
        prefix = readPrefix(is, limit);
      }

      ParseResult result = readBuildIdFromBytes(prefix);
      if (result.buildId != null) {
        return result.buildId;
      }

      // A short read means the source is exhausted, so a larger prefix cannot reveal anything new.
      if (result.bytesNeeded <= prefix.length || prefix.length < limit) {
        return null;
      }
      if (result.bytesNeeded > MAX_PREFIX_BYTES) {
        Log.w(
            TAG,
            "The ELF build ID of libapp.so lies beyond the first "
                + MAX_PREFIX_BYTES
                + " bytes; Crashlytics may not match symbols for this build.");
        return null;
      }
      limit = result.bytesNeeded;
    }
  }

  /** Reads at most {@code limit} bytes from the start of the stream. */
  private static byte[] readPrefix(InputStream is, int limit) throws IOException {
    byte[] buffer = new byte[limit];
    int offset = 0;
    while (offset < limit) {
      int read = is.read(buffer, offset, limit - offset);
      if (read < 0) {
        break;
      }
      offset += read;
    }
    return offset == limit ? buffer : Arrays.copyOf(buffer, offset);
  }

  /**
   * Parses an ELF prefix.
   *
   * <p>Every bound is checked against the buffer length, so a truncated prefix reports how many
   * bytes it would have needed instead of throwing.
   */
  @VisibleForTesting
  static ParseResult readBuildIdFromBytes(byte[] data) {
    if (data.length < ELF32_HEADER_BYTES) {
      return new ParseResult(null, ELF32_HEADER_BYTES);
    }

    for (int i = 0; i < ELF_MAGIC.length; i++) {
      if (data[i] != ELF_MAGIC[i]) {
        return ParseResult.NOT_FOUND;
      }
    }

    int elfClass = data[4] & 0xFF;
    boolean is64;
    if (elfClass == ELFCLASS64) {
      is64 = true;
      if (data.length < ELF64_HEADER_BYTES) {
        return new ParseResult(null, ELF64_HEADER_BYTES);
      }
    } else if (elfClass == ELFCLASS32) {
      is64 = false;
    } else {
      return ParseResult.NOT_FOUND;
    }

    int dataEncoding = data[5] & 0xFF;
    ByteOrder order;
    if (dataEncoding == ELFDATA2LSB) {
      order = ByteOrder.LITTLE_ENDIAN;
    } else if (dataEncoding == ELFDATA2MSB) {
      order = ByteOrder.BIG_ENDIAN;
    } else {
      return ParseResult.NOT_FOUND;
    }

    ByteBuffer buf = ByteBuffer.wrap(data).order(order);

    long phoff;
    int phentsize;
    int phnum;
    int minPhdrBytes;
    if (is64) {
      // e_phoff at 32, e_phentsize at 54, e_phnum at 56.
      phoff = buf.getLong(32);
      phentsize = buf.getShort(54) & 0xFFFF;
      phnum = buf.getShort(56) & 0xFFFF;
      minPhdrBytes = ELF64_PHDR_MIN_BYTES;
    } else {
      // e_phoff at 28, e_phentsize at 42, e_phnum at 44.
      phoff = buf.getInt(28) & 0xFFFFFFFFL;
      phentsize = buf.getShort(42) & 0xFFFF;
      phnum = buf.getShort(44) & 0xFFFF;
      minPhdrBytes = ELF32_PHDR_MIN_BYTES;
    }

    if (phoff <= 0 || phentsize < minPhdrBytes || phnum <= 0) {
      return ParseResult.NOT_FOUND;
    }

    long tableSize = (long) phnum * phentsize;
    if (phoff > Long.MAX_VALUE - tableSize) {
      return ParseResult.NOT_FOUND;
    }
    long tableEnd = phoff + tableSize;
    if (tableEnd > data.length) {
      return new ParseResult(null, saturateToInt(tableEnd));
    }

    int bytesNeeded = 0;
    for (int i = 0; i < phnum; i++) {
      long phdrLong = phoff + (long) i * phentsize;
      if (phdrLong > Integer.MAX_VALUE) {
        return ParseResult.NOT_FOUND;
      }
      int phdr = (int) phdrLong;
      if (buf.getInt(phdr) != PT_NOTE) {
        continue;
      }

      long noteOffset;
      long noteSize;
      if (is64) {
        // p_offset at phdr + 8, p_filesz at phdr + 32.
        noteOffset = buf.getLong(phdr + 8);
        noteSize = buf.getLong(phdr + 32);
      } else {
        // p_offset at phdr + 4, p_filesz at phdr + 16.
        noteOffset = buf.getInt(phdr + 4) & 0xFFFFFFFFL;
        noteSize = buf.getInt(phdr + 16) & 0xFFFFFFFFL;
      }

      if (noteOffset < 0 || noteSize <= 0 || noteOffset > Long.MAX_VALUE - noteSize) {
        continue;
      }

      long noteEnd = noteOffset + noteSize;
      if (noteEnd > data.length) {
        // Remember the smallest retry that could still succeed.
        int needed = saturateToInt(noteEnd);
        if (bytesNeeded == 0 || needed < bytesNeeded) {
          bytesNeeded = needed;
        }
        continue;
      }

      String buildId = findGnuBuildIdInBuffer(buf, (int) noteOffset, (int) noteSize);
      if (buildId != null) {
        return new ParseResult(buildId, 0);
      }
    }
    return bytesNeeded == 0 ? ParseResult.NOT_FOUND : new ParseResult(null, bytesNeeded);
  }

  /**
   * Narrows a file offset to an {@code int}, saturating rather than wrapping.
   *
   * <p>The caller decides whether the result exceeds {@link #MAX_PREFIX_BYTES}; saturating here
   * instead of clamping keeps "needs more than we are willing to read" distinguishable from "needs
   * exactly the cap".
   */
  private static int saturateToInt(long value) {
    return (int) Math.min(value, (long) Integer.MAX_VALUE);
  }

  /**
   * Searches a PT_NOTE segment for the GNU build ID note.
   *
   * <p>Note format: namesz (4) | descsz (4) | type (4) | name (aligned to 4) | desc (aligned to 4)
   */
  private static String findGnuBuildIdInBuffer(ByteBuffer buf, int offset, int size) {
    int end = offset + size;
    int pos = offset;

    while (pos <= end - NOTE_HEADER_BYTES) {
      int namesz = buf.getInt(pos);
      int descsz = buf.getInt(pos + 4);
      int type = buf.getInt(pos + 8);

      if (namesz < 0 || descsz < 0 || namesz > 256 || descsz > MAX_DESC_BYTES) {
        break;
      }

      int nameAligned = align4(namesz);
      int descPos = pos + NOTE_HEADER_BYTES + nameAligned;

      if (namesz > 0 && type == NT_GNU_BUILD_ID && descPos + descsz <= end) {
        byte[] nameBytes = new byte[namesz];
        for (int i = 0; i < namesz; i++) {
          nameBytes[i] = buf.get(pos + NOTE_HEADER_BYTES + i);
        }
        // Name is null-terminated.
        String name = new String(nameBytes, 0, Math.max(0, namesz - 1), StandardCharsets.US_ASCII);

        if (GNU_NOTE_NAME.equals(name) && descsz > 0) {
          byte[] desc = new byte[descsz];
          for (int i = 0; i < descsz; i++) {
            desc[i] = buf.get(descPos + i);
          }
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

  private static String bytesToHex(byte[] bytes) {
    StringBuilder sb = new StringBuilder(bytes.length * 2);
    for (byte b : bytes) {
      sb.append(String.format("%02x", b & 0xff));
    }
    return sb.toString();
  }
}
