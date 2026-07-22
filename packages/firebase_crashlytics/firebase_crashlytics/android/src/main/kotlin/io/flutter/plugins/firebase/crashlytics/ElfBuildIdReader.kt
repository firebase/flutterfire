// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics

import android.content.Context
import android.util.Log
import java.io.File
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.charset.StandardCharsets
import java.util.zip.ZipFile

/**
 * Reads the ELF build ID from libapp.so at runtime.
 *
 * The Firebase CLI's `crashlytics:symbols:upload` command uses the ELF build ID (from the
 * `.note.gnu.build-id` section) when uploading symbols. To ensure Crashlytics can match crash
 * reports to uploaded symbols, the plugin must report the same ELF build ID rather than the Dart
 * VM's internal snapshot build ID (which may differ, especially for AAB + flavor builds).
 */
internal object ElfBuildIdReader {
  private const val TAG = "FLTFirebaseCrashlytics"
  private val ELF_MAGIC = byteArrayOf(0x7f, 'E'.code.toByte(), 'L'.code.toByte(), 'F'.code.toByte())
  private const val ELFCLASS64 = 2
  private const val PT_NOTE = 4
  private const val NT_GNU_BUILD_ID = 3
  private const val GNU_NOTE_NAME = "GNU"

  /**
   * Reads the ELF build ID from libapp.so.
   *
   * First checks the native library directory (for devices that extract native libs). If not found
   * there, reads libapp.so from inside the APK (for devices with extractNativeLibs=false).
   *
   * @return the build ID as a lowercase hex string, or `null` if it cannot be read.
   */
  fun readBuildId(context: Context): String? =
    try {
      val libApp = File(context.applicationInfo.nativeLibraryDir, "libapp.so")
      if (libApp.exists()) {
        readBuildIdFromElf(libApp)
      } else {
        readBuildIdFromApk(context)
      }
    } catch (exception: Exception) {
      Log.d(TAG, "Could not read ELF build ID from libapp.so", exception)
      null
    }

  private fun readBuildIdFromApk(context: Context): String? {
    readBuildIdFromZip(context.applicationInfo.sourceDir)?.let {
      return it
    }
    context.applicationInfo.splitSourceDirs?.forEach { splitDir ->
      readBuildIdFromZip(splitDir)?.let {
        return it
      }
    }
    return null
  }

  private fun readBuildIdFromZip(apkPath: String): String? {
    ZipFile(apkPath).use { zipFile ->
      val entries = zipFile.entries()
      while (entries.hasMoreElements()) {
        val entry = entries.nextElement()
        if (entry.name.endsWith("/libapp.so")) {
          zipFile.getInputStream(entry).use { input ->
            val elfData = ByteArray(entry.size.toInt())
            var offset = 0
            while (offset < elfData.size) {
              val read = input.read(elfData, offset, elfData.size - offset)
              if (read < 0) break
              offset += read
            }
            return readBuildIdFromBytes(elfData)
          }
        }
      }
    }
    return null
  }

  private fun readBuildIdFromElf(elfFile: File): String? =
    RandomAccessFile(elfFile, "r").use(::readBuildIdFromRaf)

  private fun readBuildIdFromBytes(data: ByteArray): String? {
    return try {
      val buffer = ByteBuffer.wrap(data)
      for (expected in ELF_MAGIC) {
        if (buffer.get() != expected) return null
      }

      val is64 = buffer.get().toInt() and 0xff == ELFCLASS64
      val dataEncoding = buffer.get().toInt() and 0xff
      buffer.order(if (dataEncoding == 1) ByteOrder.LITTLE_ENDIAN else ByteOrder.BIG_ENDIAN)

      if (is64) readBuildIdFromBuffer64(buffer) else readBuildIdFromBuffer32(buffer)
    } catch (exception: Exception) {
      Log.d(TAG, "Could not parse ELF from APK", exception)
      null
    }
  }

  private fun readBuildIdFromBuffer64(buffer: ByteBuffer): String? {
    buffer.position(32)
    val programHeaderOffset = buffer.long
    buffer.position(54)
    val programHeaderEntrySize = buffer.short.toInt() and 0xffff
    val programHeaderCount = buffer.short.toInt() and 0xffff

    repeat(programHeaderCount) { index ->
      val programHeader = (programHeaderOffset + index.toLong() * programHeaderEntrySize).toInt()
      buffer.position(programHeader)
      if (buffer.int == PT_NOTE) {
        buffer.position(programHeader + 8)
        val noteOffset = buffer.long
        buffer.position(programHeader + 32)
        val noteSize = buffer.long
        findGnuBuildIdInBuffer(buffer, noteOffset, noteSize)?.let {
          return it
        }
      }
    }
    return null
  }

  private fun readBuildIdFromBuffer32(buffer: ByteBuffer): String? {
    buffer.position(28)
    val programHeaderOffset = buffer.int.toLong() and 0xffffffffL
    buffer.position(42)
    val programHeaderEntrySize = buffer.short.toInt() and 0xffff
    val programHeaderCount = buffer.short.toInt() and 0xffff

    repeat(programHeaderCount) { index ->
      val programHeader = (programHeaderOffset + index.toLong() * programHeaderEntrySize).toInt()
      buffer.position(programHeader)
      if (buffer.int == PT_NOTE) {
        buffer.position(programHeader + 4)
        val noteOffset = buffer.int.toLong() and 0xffffffffL
        buffer.position(programHeader + 16)
        val noteSize = buffer.int.toLong() and 0xffffffffL
        findGnuBuildIdInBuffer(buffer, noteOffset, noteSize)?.let {
          return it
        }
      }
    }
    return null
  }

  private fun findGnuBuildIdInBuffer(buffer: ByteBuffer, offset: Long, size: Long): String? {
    val end = offset + size
    var position = offset
    while (position + 12 <= end) {
      buffer.position(position.toInt())
      val nameSize = buffer.int
      val descriptionSize = buffer.int
      val type = buffer.int
      if (nameSize < 0 || descriptionSize < 0 || nameSize > 256) break

      val descriptionPosition = position + 12 + align4(nameSize)
      if (nameSize > 0 && type == NT_GNU_BUILD_ID && descriptionPosition + descriptionSize <= end) {
        val nameBytes = ByteArray(nameSize)
        buffer.get(nameBytes)
        val name = String(nameBytes, 0, maxOf(0, nameSize - 1), StandardCharsets.US_ASCII)
        if (name == GNU_NOTE_NAME && descriptionSize > 0) {
          buffer.position(descriptionPosition.toInt())
          return bytesToHex(ByteArray(descriptionSize).also(buffer::get))
        }
      }
      position = descriptionPosition + align4(descriptionSize)
    }
    return null
  }

  private fun readBuildIdFromRaf(file: RandomAccessFile): String? {
    val magic = ByteArray(4)
    file.readFully(magic)
    for (index in magic.indices) {
      if (magic[index] != ELF_MAGIC[index]) return null
    }

    val is64 = file.read() == ELFCLASS64
    val order = if (file.read() == 1) ByteOrder.LITTLE_ENDIAN else ByteOrder.BIG_ENDIAN
    return if (is64) readBuildIdFromElf64(file, order) else readBuildIdFromElf32(file, order)
  }

  private fun readBuildIdFromElf64(file: RandomAccessFile, order: ByteOrder): String? {
    file.seek(32)
    val programHeaderOffset = readLong(file, order)
    file.seek(54)
    val programHeaderEntrySize = readUnsignedShort(file, order)
    val programHeaderCount = readUnsignedShort(file, order)

    repeat(programHeaderCount) { index ->
      val programHeader = programHeaderOffset + index.toLong() * programHeaderEntrySize
      file.seek(programHeader)
      if (readInt(file, order) == PT_NOTE) {
        file.seek(programHeader + 8)
        val noteOffset = readLong(file, order)
        file.seek(programHeader + 32)
        val noteSize = readLong(file, order)
        findGnuBuildId(file, noteOffset, noteSize, order)?.let {
          return it
        }
      }
    }
    return null
  }

  private fun readBuildIdFromElf32(file: RandomAccessFile, order: ByteOrder): String? {
    file.seek(28)
    val programHeaderOffset = readInt(file, order).toLong() and 0xffffffffL
    file.seek(42)
    val programHeaderEntrySize = readUnsignedShort(file, order)
    val programHeaderCount = readUnsignedShort(file, order)

    repeat(programHeaderCount) { index ->
      val programHeader = programHeaderOffset + index.toLong() * programHeaderEntrySize
      file.seek(programHeader)
      if (readInt(file, order) == PT_NOTE) {
        file.seek(programHeader + 4)
        val noteOffset = readInt(file, order).toLong() and 0xffffffffL
        file.seek(programHeader + 16)
        val noteSize = readInt(file, order).toLong() and 0xffffffffL
        findGnuBuildId(file, noteOffset, noteSize, order)?.let {
          return it
        }
      }
    }
    return null
  }

  /**
   * Searches a PT_NOTE segment for the GNU build ID note.
   *
   * Note format: namesz (4) | descsz (4) | type (4) | name (aligned to 4) | desc (aligned to 4)
   */
  private fun findGnuBuildId(
    file: RandomAccessFile,
    offset: Long,
    size: Long,
    order: ByteOrder
  ): String? {
    val end = offset + size
    var position = offset
    while (position + 12 <= end) {
      file.seek(position)
      val nameSize = readInt(file, order)
      val descriptionSize = readInt(file, order)
      val type = readInt(file, order)
      if (nameSize < 0 || descriptionSize < 0 || nameSize > 256) break

      val descriptionPosition = position + 12 + align4(nameSize)
      if (nameSize > 0 && type == NT_GNU_BUILD_ID && descriptionPosition + descriptionSize <= end) {
        val nameBytes = ByteArray(nameSize)
        file.readFully(nameBytes)
        val name = String(nameBytes, 0, maxOf(0, nameSize - 1), StandardCharsets.US_ASCII)
        if (name == GNU_NOTE_NAME && descriptionSize > 0) {
          file.seek(descriptionPosition)
          return bytesToHex(ByteArray(descriptionSize).also(file::readFully))
        }
      }
      position = descriptionPosition + align4(descriptionSize)
    }
    return null
  }

  private fun align4(value: Int): Int = (value + 3) and 3.inv()

  private fun readInt(file: RandomAccessFile, order: ByteOrder): Int =
    ByteBuffer.wrap(ByteArray(4).also(file::readFully)).order(order).int

  private fun readLong(file: RandomAccessFile, order: ByteOrder): Long =
    ByteBuffer.wrap(ByteArray(8).also(file::readFully)).order(order).long

  private fun readUnsignedShort(file: RandomAccessFile, order: ByteOrder): Int =
    ByteBuffer.wrap(ByteArray(2).also(file::readFully)).order(order).short.toInt() and 0xffff

  private fun bytesToHex(bytes: ByteArray): String =
    buildString(bytes.size * 2) {
      bytes.forEach { byte -> append(String.format("%02x", byte.toInt() and 0xff)) }
    }
}
