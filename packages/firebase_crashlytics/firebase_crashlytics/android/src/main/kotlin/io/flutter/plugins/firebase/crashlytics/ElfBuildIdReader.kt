// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics

import android.content.Context
import android.util.Log
import androidx.annotation.VisibleForTesting
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.charset.StandardCharsets
import java.util.zip.ZipFile
import kotlin.math.min

/**
 * Reads the ELF build ID from libapp.so at runtime.
 *
 * The Firebase CLI's `crashlytics:symbols:upload` command uses the ELF build ID (from the
 * `.note.gnu.build-id` section) when uploading symbols. To ensure Crashlytics can match crash
 * reports to uploaded symbols, the plugin must report the same ELF build ID rather than the Dart
 * VM's internal snapshot build ID (which may differ, especially for AAB + flavor builds).
 *
 * Only a bounded prefix of the library is ever read into memory: every allocation here is sized by
 * a constant, never by a value read from the file.
 */
internal class ElfBuildIdReader private constructor() {
  /** Parse outcome: either a build ID, or how many prefix bytes would have been needed. */
  @VisibleForTesting
  class ParseResult(
      @JvmField val buildId: String?,
      @JvmField val bytesNeeded: Int,
  ) {
    companion object {
      @JvmField val NOT_FOUND = ParseResult(null, 0)
    }
  }

  /**
   * Opens a stream positioned at the start of the library.
   *
   * Retrying with a larger prefix re-reads from the beginning, so the source must be able to hand
   * out a fresh stream on each call.
   */
  @VisibleForTesting
  fun interface StreamSource {
    @Throws(IOException::class) fun open(): InputStream
  }

  companion object {
    private const val TAG = "FLTFirebaseCrashlytics"

    private val ELF_MAGIC =
        byteArrayOf(0x7f, 'E'.code.toByte(), 'L'.code.toByte(), 'F'.code.toByte())
    private const val ELFCLASS32 = 1
    private const val ELFCLASS64 = 2
    private const val ELFDATA2LSB = 1
    private const val ELFDATA2MSB = 2
    private const val PT_NOTE = 4
    private const val NT_GNU_BUILD_ID = 3
    private const val GNU_NOTE_NAME = "GNU"

    /** First attempt: enough for the ELF header, program header table, and typical notes. */
    private const val INITIAL_PREFIX_BYTES = 4 * 1024

    /**
     * Hard ceiling for a retry if a note sits further into the library. A library whose build ID
     * note starts beyond this reports no build ID at all, which costs symbol matching but never
     * memory.
     */
    private const val MAX_PREFIX_BYTES = 256 * 1024

    /** GNU build IDs are small; this bounds hostile or corrupt descsz values. */
    private const val MAX_DESC_BYTES = 1024

    private const val ELF32_HEADER_BYTES = 52
    private const val ELF64_HEADER_BYTES = 64
    private const val ELF32_PHDR_MIN_BYTES = 32
    private const val ELF64_PHDR_MIN_BYTES = 56
    private const val NOTE_HEADER_BYTES = 12

    /**
     * Reads the ELF build ID from libapp.so.
     *
     * First checks the native library directory (for devices that extract native libs). If not
     * found there, reads libapp.so from inside the APK (for devices with extractNativeLibs=false).
     *
     * @return the build ID as a lowercase hex string, or `null` if it cannot be read.
     */
    @JvmStatic
    fun readBuildId(context: Context): String? {
      return try {
        val libApp = File(context.applicationInfo.nativeLibraryDir, "libapp.so")
        if (libApp.exists()) {
          readBuildIdFromFile(libApp)
        } else {
          readBuildIdFromApk(context)
        }
      } catch (exception: Exception) {
        Log.d(TAG, "Could not read ELF build ID from libapp.so", exception)
        null
      } catch (error: OutOfMemoryError) {
        Log.d(TAG, "Could not read ELF build ID from libapp.so", error)
        null
      }
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
            return readBuildIdFromSource { zipFile.getInputStream(entry) }
          }
        }
      }
      return null
    }

    private fun readBuildIdFromFile(elfFile: File): String? = readBuildIdFromSource {
      FileInputStream(elfFile)
    }

    /**
     * Parses successively larger prefixes until the build ID is found or the source runs out.
     *
     * Each retry strictly increases the prefix size and stops at [MAX_PREFIX_BYTES], so the loop
     * always terminates: a truncated or malformed library returns `null` rather than asking for
     * bytes the source can never supply.
     */
    @JvmStatic
    @VisibleForTesting
    @Throws(IOException::class)
    fun readBuildIdFromSource(source: StreamSource): String? {
      var limit = INITIAL_PREFIX_BYTES
      while (true) {
        val prefix = source.open().use { inputStream -> readPrefix(inputStream, limit) }

        val result = readBuildIdFromBytes(prefix)
        if (result.buildId != null) {
          return result.buildId
        }

        // A short read means the source is exhausted, so a larger prefix cannot reveal anything
        // new.
        if (result.bytesNeeded <= prefix.size || prefix.size < limit) {
          return null
        }
        if (result.bytesNeeded > MAX_PREFIX_BYTES) {
          Log.w(
              TAG,
              "The ELF build ID of libapp.so lies beyond the first " +
                  MAX_PREFIX_BYTES +
                  " bytes; Crashlytics may not match symbols for this build.")
          return null
        }
        limit = result.bytesNeeded
      }
    }

    /** Reads at most [limit] bytes from the start of the stream. */
    @Throws(IOException::class)
    private fun readPrefix(inputStream: InputStream, limit: Int): ByteArray {
      val buffer = ByteArray(limit)
      var offset = 0
      while (offset < limit) {
        val read = inputStream.read(buffer, offset, limit - offset)
        if (read < 0) {
          break
        }
        offset += read
      }
      return if (offset == limit) buffer else buffer.copyOf(offset)
    }

    /**
     * Parses an ELF prefix.
     *
     * Every bound is checked against the buffer length, so a truncated prefix reports how many
     * bytes it would have needed instead of throwing.
     */
    @JvmStatic
    @VisibleForTesting
    fun readBuildIdFromBytes(data: ByteArray): ParseResult {
      if (data.size < ELF32_HEADER_BYTES) {
        return ParseResult(null, ELF32_HEADER_BYTES)
      }

      for (i in ELF_MAGIC.indices) {
        if (data[i] != ELF_MAGIC[i]) {
          return ParseResult.NOT_FOUND
        }
      }

      val elfClass = data[4].toInt() and 0xff
      val is64: Boolean
      when (elfClass) {
        ELFCLASS64 -> {
          is64 = true
          if (data.size < ELF64_HEADER_BYTES) {
            return ParseResult(null, ELF64_HEADER_BYTES)
          }
        }
        ELFCLASS32 -> is64 = false
        else -> return ParseResult.NOT_FOUND
      }

      val dataEncoding = data[5].toInt() and 0xff
      val order =
          when (dataEncoding) {
            ELFDATA2LSB -> ByteOrder.LITTLE_ENDIAN
            ELFDATA2MSB -> ByteOrder.BIG_ENDIAN
            else -> return ParseResult.NOT_FOUND
          }

      val buf = ByteBuffer.wrap(data).order(order)

      val phoff: Long
      val phentsize: Int
      val phnum: Int
      val minPhdrBytes: Int
      if (is64) {
        // e_phoff at 32, e_phentsize at 54, e_phnum at 56.
        phoff = buf.getLong(32)
        phentsize = buf.getShort(54).toInt() and 0xffff
        phnum = buf.getShort(56).toInt() and 0xffff
        minPhdrBytes = ELF64_PHDR_MIN_BYTES
      } else {
        // e_phoff at 28, e_phentsize at 42, e_phnum at 44.
        phoff = buf.getInt(28).toLong() and 0xffffffffL
        phentsize = buf.getShort(42).toInt() and 0xffff
        phnum = buf.getShort(44).toInt() and 0xffff
        minPhdrBytes = ELF32_PHDR_MIN_BYTES
      }

      if (phoff <= 0 || phentsize < minPhdrBytes || phnum <= 0) {
        return ParseResult.NOT_FOUND
      }

      val tableSize = phnum.toLong() * phentsize
      if (phoff > Long.MAX_VALUE - tableSize) {
        return ParseResult.NOT_FOUND
      }
      val tableEnd = phoff + tableSize
      if (tableEnd > data.size) {
        return ParseResult(null, saturateToInt(tableEnd))
      }

      var bytesNeeded = 0
      for (i in 0 until phnum) {
        val phdrLong = phoff + i.toLong() * phentsize
        if (phdrLong > Int.MAX_VALUE) {
          return ParseResult.NOT_FOUND
        }
        val phdr = phdrLong.toInt()
        if (buf.getInt(phdr) != PT_NOTE) {
          continue
        }

        val noteOffset: Long
        val noteSize: Long
        if (is64) {
          // p_offset at phdr + 8, p_filesz at phdr + 32.
          noteOffset = buf.getLong(phdr + 8)
          noteSize = buf.getLong(phdr + 32)
        } else {
          // p_offset at phdr + 4, p_filesz at phdr + 16.
          noteOffset = buf.getInt(phdr + 4).toLong() and 0xffffffffL
          noteSize = buf.getInt(phdr + 16).toLong() and 0xffffffffL
        }

        if (noteOffset < 0 || noteSize <= 0 || noteOffset > Long.MAX_VALUE - noteSize) {
          continue
        }

        val noteEnd = noteOffset + noteSize
        if (noteEnd > data.size) {
          // Remember the smallest retry that could still succeed.
          val needed = saturateToInt(noteEnd)
          if (bytesNeeded == 0 || needed < bytesNeeded) {
            bytesNeeded = needed
          }
          continue
        }

        val buildId = findGnuBuildIdInBuffer(buf, noteOffset.toInt(), noteSize.toInt())
        if (buildId != null) {
          return ParseResult(buildId, 0)
        }
      }
      return if (bytesNeeded == 0) ParseResult.NOT_FOUND else ParseResult(null, bytesNeeded)
    }

    /**
     * Narrows a file offset to an `int`, saturating rather than wrapping.
     *
     * The caller decides whether the result exceeds [MAX_PREFIX_BYTES]; saturating here instead of
     * clamping keeps "needs more than we are willing to read" distinguishable from "needs exactly
     * the cap".
     */
    private fun saturateToInt(value: Long): Int = min(value, Int.MAX_VALUE.toLong()).toInt()

    /**
     * Searches a PT_NOTE segment for the GNU build ID note.
     *
     * Note format: namesz (4) | descsz (4) | type (4) | name (aligned to 4) | desc (aligned to 4)
     */
    private fun findGnuBuildIdInBuffer(buf: ByteBuffer, offset: Int, size: Int): String? {
      val end = offset + size
      var pos = offset

      while (pos <= end - NOTE_HEADER_BYTES) {
        val namesz = buf.getInt(pos)
        val descsz = buf.getInt(pos + 4)
        val type = buf.getInt(pos + 8)

        if (namesz < 0 || descsz < 0 || namesz > 256 || descsz > MAX_DESC_BYTES) {
          break
        }

        val nameAligned = align4(namesz)
        val descPos = pos + NOTE_HEADER_BYTES + nameAligned

        if (namesz > 0 && type == NT_GNU_BUILD_ID && descPos + descsz <= end) {
          val nameBytes = ByteArray(namesz)
          for (i in 0 until namesz) {
            nameBytes[i] = buf.get(pos + NOTE_HEADER_BYTES + i)
          }
          // Name is null-terminated.
          val name = String(nameBytes, 0, maxOf(0, namesz - 1), StandardCharsets.US_ASCII)

          if (name == GNU_NOTE_NAME && descsz > 0) {
            val desc = ByteArray(descsz)
            for (i in 0 until descsz) {
              desc[i] = buf.get(descPos + i)
            }
            return bytesToHex(desc)
          }
        }

        pos = descPos + align4(descsz)
      }
      return null
    }

    private fun align4(value: Int): Int = (value + 3) and 3.inv()

    private fun bytesToHex(bytes: ByteArray): String =
        buildString(bytes.size * 2) {
          bytes.forEach { byte -> append(String.format("%02x", byte.toInt() and 0xff)) }
        }
  }
}
