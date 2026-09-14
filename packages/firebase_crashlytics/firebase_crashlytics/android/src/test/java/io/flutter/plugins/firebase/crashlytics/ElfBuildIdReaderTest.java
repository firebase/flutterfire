// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import org.junit.Test;

public class ElfBuildIdReaderTest {

  private static final int ELFCLASS32 = 1;
  private static final int ELFCLASS64 = 2;
  private static final int ELFDATA2LSB = 1;
  private static final int ELFDATA2MSB = 2;
  private static final int PT_NOTE = 4;
  private static final int PT_LOAD = 1;
  private static final int NT_GNU_BUILD_ID = 3;

  private static final int ELF32_HEADER_BYTES = 52;
  private static final int ELF64_HEADER_BYTES = 64;
  private static final int ELF32_PHDR_BYTES = 32;
  private static final int ELF64_PHDR_BYTES = 56;

  private static final int INITIAL_PREFIX_BYTES = 4 * 1024;
  private static final int MAX_PREFIX_BYTES = 256 * 1024;

  private static final byte[] BUILD_ID = {
    0x01,
    0x02,
    (byte) 0xab,
    (byte) 0xff,
    0x10,
    0x20,
    0x30,
    0x40,
    0x50,
    0x60,
    0x70,
    (byte) 0x80,
    (byte) 0x90,
    (byte) 0xa0,
    (byte) 0xb0,
    (byte) 0xc0,
    0x0d,
    0x0e,
    0x0f,
    0x00
  };
  private static final String BUILD_ID_HEX = "0102abff102030405060708090a0b0c00d0e0f00";

  // --- Parser: happy paths across ELF classes and byte orders ---

  @Test
  public void readBuildIdFromBytes_readsElf64LittleEndian() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, 256, 36);
    writeNote(buffer, 256, "GNU", NT_GNU_BUILD_ID, BUILD_ID);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals(BUILD_ID_HEX, result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_readsElf64BigEndian() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.BIG_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, 256, 36);
    writeNote(buffer, 256, "GNU", NT_GNU_BUILD_ID, BUILD_ID);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals(BUILD_ID_HEX, result.buildId);
  }

  @Test
  public void readBuildIdFromBytes_readsElf32LittleEndian() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf32(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr32(buffer, 0, PT_NOTE, 200, 36);
    writeNote(buffer, 200, "GNU", NT_GNU_BUILD_ID, BUILD_ID);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals(BUILD_ID_HEX, result.buildId);
  }

  @Test
  public void readBuildIdFromBytes_readsElf32BigEndian() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf32(image, ByteOrder.BIG_ENDIAN, 1);
    writePhdr32(buffer, 0, PT_NOTE, 200, 36);
    writeNote(buffer, 200, "GNU", NT_GNU_BUILD_ID, new byte[] {0x10, 0x20});

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals("1020", result.buildId);
  }

  // --- Parser: note and segment traversal ---

  @Test
  public void readBuildIdFromBytes_skipsNonGnuNotePrecedingGnuNote() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    // Both notes live in the same PT_NOTE segment; the parser must walk past the first.
    int next = writeNote(buffer, 256, "Go", 4, new byte[] {0x11, 0x22, 0x33, 0x44});
    writeNote(buffer, next, "GNU", NT_GNU_BUILD_ID, BUILD_ID);
    writePhdr64(buffer, 0, PT_NOTE, 256, 128);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals(BUILD_ID_HEX, result.buildId);
  }

  @Test
  public void readBuildIdFromBytes_findsGnuNoteInLaterProgramHeader() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 3);
    writePhdr64(buffer, 0, PT_LOAD, 0, 512);
    // The first PT_NOTE carries something else, so the search must continue to the second.
    writePhdr64(buffer, 1, PT_NOTE, 256, 24);
    writeNote(buffer, 256, "Go", 4, new byte[] {0x11, 0x22, 0x33, 0x44});
    writePhdr64(buffer, 2, PT_NOTE, 320, 36);
    writeNote(buffer, 320, "GNU", NT_GNU_BUILD_ID, BUILD_ID);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals(BUILD_ID_HEX, result.buildId);
  }

  @Test
  public void readBuildIdFromBytes_usesReachableNoteWhenEarlierSegmentIsOutOfRange() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 2);
    writePhdr64(buffer, 0, PT_NOTE, 1000, 64);
    writePhdr64(buffer, 1, PT_NOTE, 256, 36);
    writeNote(buffer, 256, "GNU", NT_GNU_BUILD_ID, BUILD_ID);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals(BUILD_ID_HEX, result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_ignoresBuildIdNoteWithForeignName() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, 256, 36);
    writeNote(buffer, 256, "Go", NT_GNU_BUILD_ID, BUILD_ID);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  // --- Parser: truncation reporting ---

  @Test
  public void readBuildIdFromBytes_reportsBytesNeededForTruncatedNoteSegment() {
    byte[] image = new byte[128];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, 400, 56);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(456, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_reportsSmallestReachableNote() {
    byte[] image = new byte[256];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 2);
    writePhdr64(buffer, 0, PT_NOTE, 4000, 100);
    writePhdr64(buffer, 1, PT_NOTE, 400, 56);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertEquals(456, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_reportsBytesNeededForProgramHeaderTableBeyondBuffer() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    buffer.putLong(32, 4000);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(4056, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_reportsHeaderSizeForUndersizedBuffer() {
    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(new byte[16]);

    assertNull(result.buildId);
    assertEquals(ELF32_HEADER_BYTES, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_reportsElf64HeaderSizeForPartialHeader() {
    byte[] image = new byte[56];
    writeIdent(image, ELFCLASS64, ByteOrder.LITTLE_ENDIAN);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(ELF64_HEADER_BYTES, result.bytesNeeded);
  }

  // --- Parser: malformed input ---

  @Test
  public void readBuildIdFromBytes_returnsNotFoundForGarbage() {
    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(new byte[512]);

    assertNull(result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_returnsNotFoundForUnsupportedElfClass() {
    byte[] image = new byte[512];
    writeIdent(image, 7, ByteOrder.LITTLE_ENDIAN);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_returnsNotFoundForUnsupportedDataEncoding() {
    byte[] image = new byte[512];
    writeIdent(image, ELFCLASS64, ByteOrder.LITTLE_ENDIAN);
    image[5] = 7;

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_returnsNotFoundForUndersizedProgramHeaderEntry() {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    // An ELF64 program header cannot be shorter than 56 bytes; reading one would overrun.
    buffer.putShort(54, (short) 40);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  @Test
  public void readBuildIdFromBytes_rejectsOversizedDescription() {
    byte[] image = new byte[4096];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, 256, 2064);

    buffer.putInt(256, 4);
    buffer.putInt(260, 2048);
    buffer.putInt(264, NT_GNU_BUILD_ID);
    buffer.put(268, (byte) 'G');
    buffer.put(269, (byte) 'N');
    buffer.put(270, (byte) 'U');
    buffer.put(271, (byte) 0);

    ElfBuildIdReader.ParseResult result = ElfBuildIdReader.readBuildIdFromBytes(image);

    assertNull(result.buildId);
    assertEquals(0, result.bytesNeeded);
  }

  // --- Prefix loop ---

  @Test
  public void readBuildIdFromSource_readsBuildIdWithinInitialPrefix() throws IOException {
    byte[] image = new byte[512];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, 256, 36);
    writeNote(buffer, 256, "GNU", NT_GNU_BUILD_ID, BUILD_ID);

    assertEquals(BUILD_ID_HEX, ElfBuildIdReader.readBuildIdFromSource(sourceOf(image)));
  }

  @Test
  public void readBuildIdFromSource_retriesWithLargerPrefixWhenNoteIsBeyondInitialLimit()
      throws IOException {
    byte[] image = new byte[2 * INITIAL_PREFIX_BYTES];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    int noteOffset = INITIAL_PREFIX_BYTES + 904;
    writePhdr64(buffer, 0, PT_NOTE, noteOffset, 36);
    writeNote(buffer, noteOffset, "GNU", NT_GNU_BUILD_ID, BUILD_ID);

    assertEquals(BUILD_ID_HEX, ElfBuildIdReader.readBuildIdFromSource(sourceOf(image)));
  }

  /** Regression test: a note that points past the end of a truncated library must not loop. */
  @Test(timeout = 5000)
  public void readBuildIdFromSource_returnsNullForTruncatedLibrary() throws IOException {
    byte[] image = new byte[128];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, 400, 56);

    assertNull(ElfBuildIdReader.readBuildIdFromSource(sourceOf(image)));
  }

  @Test(timeout = 5000)
  public void readBuildIdFromSource_returnsNullWhenNoteIsBeyondMaxPrefix() throws IOException {
    byte[] image = new byte[INITIAL_PREFIX_BYTES];
    ByteBuffer buffer = newElf64(image, ByteOrder.LITTLE_ENDIAN, 1);
    writePhdr64(buffer, 0, PT_NOTE, MAX_PREFIX_BYTES + 1024, 36);

    assertNull(ElfBuildIdReader.readBuildIdFromSource(sourceOf(image)));
  }

  @Test(timeout = 5000)
  public void readBuildIdFromSource_returnsNullForEmptyStream() throws IOException {
    assertNull(ElfBuildIdReader.readBuildIdFromSource(sourceOf(new byte[0])));
  }

  // --- Helpers ---

  private static ElfBuildIdReader.StreamSource sourceOf(byte[] image) {
    return () -> new ByteArrayInputStream(image);
  }

  private static void writeIdent(byte[] image, int elfClass, ByteOrder order) {
    image[0] = 0x7f;
    image[1] = 'E';
    image[2] = 'L';
    image[3] = 'F';
    image[4] = (byte) elfClass;
    image[5] = (byte) (order == ByteOrder.LITTLE_ENDIAN ? ELFDATA2LSB : ELFDATA2MSB);
  }

  private static ByteBuffer newElf64(byte[] image, ByteOrder order, int phnum) {
    writeIdent(image, ELFCLASS64, order);
    ByteBuffer buffer = ByteBuffer.wrap(image).order(order);
    buffer.putLong(32, ELF64_HEADER_BYTES); // e_phoff
    buffer.putShort(54, (short) ELF64_PHDR_BYTES); // e_phentsize
    buffer.putShort(56, (short) phnum); // e_phnum
    return buffer;
  }

  private static ByteBuffer newElf32(byte[] image, ByteOrder order, int phnum) {
    writeIdent(image, ELFCLASS32, order);
    ByteBuffer buffer = ByteBuffer.wrap(image).order(order);
    buffer.putInt(28, ELF32_HEADER_BYTES); // e_phoff
    buffer.putShort(42, (short) ELF32_PHDR_BYTES); // e_phentsize
    buffer.putShort(44, (short) phnum); // e_phnum
    return buffer;
  }

  private static void writePhdr64(ByteBuffer buffer, int index, int type, long offset, long size) {
    int phdr = ELF64_HEADER_BYTES + index * ELF64_PHDR_BYTES;
    buffer.putInt(phdr, type); // p_type
    buffer.putLong(phdr + 8, offset); // p_offset
    buffer.putLong(phdr + 32, size); // p_filesz
  }

  private static void writePhdr32(ByteBuffer buffer, int index, int type, int offset, int size) {
    int phdr = ELF32_HEADER_BYTES + index * ELF32_PHDR_BYTES;
    buffer.putInt(phdr, type); // p_type
    buffer.putInt(phdr + 4, offset); // p_offset
    buffer.putInt(phdr + 16, size); // p_filesz
  }

  /** Writes one ELF note and returns the offset just past it. */
  private static int writeNote(ByteBuffer buffer, int offset, String name, int type, byte[] desc) {
    byte[] nameBytes = (name + "\0").getBytes(StandardCharsets.US_ASCII);
    buffer.putInt(offset, nameBytes.length); // namesz
    buffer.putInt(offset + 4, desc.length); // descsz
    buffer.putInt(offset + 8, type); // type
    for (int i = 0; i < nameBytes.length; i++) {
      buffer.put(offset + 12 + i, nameBytes[i]);
    }
    int descPos = offset + 12 + align4(nameBytes.length);
    for (int i = 0; i < desc.length; i++) {
      buffer.put(descPos + i, desc[i]);
    }
    return descPos + align4(desc.length);
  }

  private static int align4(int value) {
    return (value + 3) & ~3;
  }
}
