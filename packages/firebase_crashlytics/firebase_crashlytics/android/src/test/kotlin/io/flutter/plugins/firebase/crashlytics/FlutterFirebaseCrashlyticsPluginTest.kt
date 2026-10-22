// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.crashlytics

import android.content.ContextWrapper
import android.content.pm.ApplicationInfo
import io.flutter.plugin.common.BinaryMessenger
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.Executor
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class FlutterFirebaseCrashlyticsPluginTest {
  @get:Rule val folder = TemporaryFolder()

  /**
   * Records the threads that look up the application info, which every libapp.so read starts with,
   * and fails the first [failures] lookups like a process short of memory or file descriptors.
   */
  private class RecordingContext(nativeLibraryDir: File, private var failures: Int = 0) :
      ContextWrapper(null) {
    val applicationInfoThreads: MutableList<Thread> = CopyOnWriteArrayList()
    private val info = ApplicationInfo().apply { this.nativeLibraryDir = nativeLibraryDir.path }

    override fun getApplicationInfo(): ApplicationInfo {
      applicationInfoThreads.add(Thread.currentThread())
      if (failures > 0) {
        failures--
        throw IllegalStateException("Too many open files")
      }
      return info
    }

    fun withApk(apk: File): RecordingContext = apply { info.sourceDir = apk.path }
  }

  private object NoOpMessenger : BinaryMessenger {
    override fun send(channel: String, message: ByteBuffer?) {}

    override fun send(
        channel: String,
        message: ByteBuffer?,
        callback: BinaryMessenger.BinaryReply?
    ) {}

    override fun setMessageHandler(
        channel: String,
        handler: BinaryMessenger.BinaryMessageHandler?
    ) {}
  }

  private lateinit var nativeLibraryDir: File
  private lateinit var defaultBuildIdExecutor: Executor

  @Before
  fun setUp() {
    ElfBuildIdReader.clearCachedBuildId()
    nativeLibraryDir = folder.newFolder("lib")
    FileOutputStream(File(nativeLibraryDir, "libapp.so")).use {
      it.write(ElfBuildIdReaderTest.elfWithBuildId(0x42.toByte()))
    }
    // Runs the startup read on another thread, like the thread pool does, and waits for it so no
    // read outlives the test.
    defaultBuildIdExecutor = FlutterFirebaseCrashlyticsPlugin.buildIdExecutor
    FlutterFirebaseCrashlyticsPlugin.buildIdExecutor = Executor { runnable ->
      Thread(runnable).apply {
        start()
        join()
      }
    }
  }

  @After
  fun tearDown() {
    FlutterFirebaseCrashlyticsPlugin.buildIdExecutor = defaultBuildIdExecutor
    ElfBuildIdReader.clearCachedBuildId()
  }

  @Test
  fun onAttachedToEngine_readsLibappOnceInTheBackground() {
    // Every engine attaches its plugins on the main thread, which this test thread stands in for.
    var reads = 0
    repeat(2) {
      val context = RecordingContext(nativeLibraryDir)

      FlutterFirebaseCrashlyticsPlugin().attachToEngine(context, NoOpMessenger)

      assertFalse(context.applicationInfoThreads.contains(Thread.currentThread()))
      reads += context.applicationInfoThreads.size
    }
    // Read at the first attach, so a first error report doesn't have to.
    assertEquals(1, reads)
    assertEquals(
        ElfBuildIdReaderTest.hexWithFirstByte(0x42.toByte()),
        ElfBuildIdReader.cachedBuildId(RecordingContext(nativeLibraryDir)))
  }

  @Test
  fun cachedBuildId_readsLibappOncePerProcess() {
    val firstEngine = RecordingContext(nativeLibraryDir)
    val secondEngine = RecordingContext(nativeLibraryDir)

    val expected = ElfBuildIdReaderTest.hexWithFirstByte(0x42.toByte())
    assertEquals(expected, ElfBuildIdReader.cachedBuildId(firstEngine))
    assertEquals(expected, ElfBuildIdReader.cachedBuildId(firstEngine))
    assertEquals(expected, ElfBuildIdReader.cachedBuildId(secondEngine))

    assertEquals(
        1, firstEngine.applicationInfoThreads.size + secondEngine.applicationInfoThreads.size)
  }

  @Test
  fun cachedBuildId_readsAgainAfterAFailedRead() {
    val context = RecordingContext(nativeLibraryDir, failures = 1)

    assertNull(ElfBuildIdReader.cachedBuildId(context))
    assertEquals(
        ElfBuildIdReaderTest.hexWithFirstByte(0x42.toByte()),
        ElfBuildIdReader.cachedBuildId(context))
  }

  @Test
  fun cachedBuildId_keepsALibraryWithoutBuildId() {
    // Debug (JIT) builds have no libapp.so: that answer does not change, so it is kept.
    val apk = folder.newFile("base.apk")
    ZipOutputStream(FileOutputStream(apk)).use {
      it.putNextEntry(ZipEntry("AndroidManifest.xml"))
      it.closeEntry()
    }
    val context = RecordingContext(folder.newFolder("empty")).withApk(apk)

    assertNull(ElfBuildIdReader.cachedBuildId(context))
    val lookups = context.applicationInfoThreads.size
    assertNull(ElfBuildIdReader.cachedBuildId(context))

    assertEquals(lookups, context.applicationInfoThreads.size)
  }
}
