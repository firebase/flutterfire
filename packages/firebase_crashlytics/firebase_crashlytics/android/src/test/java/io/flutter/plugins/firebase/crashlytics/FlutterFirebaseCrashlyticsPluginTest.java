// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.crashlytics;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import android.content.ContextWrapper;
import android.content.pm.ApplicationInfo;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Executor;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

public class FlutterFirebaseCrashlyticsPluginTest {
  @Rule public final TemporaryFolder nativeLibraryDir = new TemporaryFolder();

  /**
   * Records the threads that look up the application info, which every libapp.so read starts with.
   */
  private static final class RecordingContext extends ContextWrapper {
    final List<Thread> applicationInfoThreads = new CopyOnWriteArrayList<>();
    private final ApplicationInfo applicationInfo = new ApplicationInfo();

    RecordingContext(File nativeLibraryDir) {
      super(null);
      applicationInfo.nativeLibraryDir = nativeLibraryDir.getPath();
    }

    @Override
    public ApplicationInfo getApplicationInfo() {
      applicationInfoThreads.add(Thread.currentThread());
      return applicationInfo;
    }
  }

  private static final BinaryMessenger MESSENGER =
      new BinaryMessenger() {
        @Override
        public void send(String channel, ByteBuffer message) {}

        @Override
        public void send(String channel, ByteBuffer message, BinaryReply callback) {}

        @Override
        public void setMessageHandler(String channel, BinaryMessageHandler handler) {}
      };

  private Executor defaultBuildIdExecutor;

  @Before
  public void setUp() throws IOException {
    ElfBuildIdReader.clearCachedBuildId();
    // Runs the startup read on another thread, like the thread pool does, and waits for it so no
    // read outlives the test.
    defaultBuildIdExecutor = FlutterFirebaseCrashlyticsPlugin.getBuildIdExecutor();
    FlutterFirebaseCrashlyticsPlugin.setBuildIdExecutor(
        runnable -> {
          Thread thread = new Thread(runnable);
          thread.start();
          try {
            thread.join();
          } catch (InterruptedException e) {
            throw new AssertionError(e);
          }
        });
    try (FileOutputStream libapp =
        new FileOutputStream(new File(nativeLibraryDir.getRoot(), "libapp.so"))) {
      libapp.write(ElfBuildIdReaderTest.elfWithBuildId((byte) 0x42));
    }
  }

  @After
  public void tearDown() {
    FlutterFirebaseCrashlyticsPlugin.setBuildIdExecutor(defaultBuildIdExecutor);
    ElfBuildIdReader.clearCachedBuildId();
  }

  @Test
  public void onAttachedToEngine_readsLibappOnceInTheBackground() {
    // Every engine attaches its plugins on the main thread, which this test thread stands in for.
    int reads = 0;
    for (int engine = 0; engine < 2; engine++) {
      RecordingContext context = new RecordingContext(nativeLibraryDir.getRoot());

      new FlutterFirebaseCrashlyticsPlugin()
          .onAttachedToEngine(
              new FlutterPluginBinding(context, null, MESSENGER, null, null, null, null));

      assertFalse(context.applicationInfoThreads.contains(Thread.currentThread()));
      reads += context.applicationInfoThreads.size();
    }
    // Read at the first attach, so a first error report doesn't have to.
    assertEquals(1, reads);
    assertEquals(
        ElfBuildIdReaderTest.hexWithFirstByte((byte) 0x42),
        ElfBuildIdReader.cachedBuildId(new RecordingContext(nativeLibraryDir.getRoot())));
  }

  @Test
  public void cachedBuildId_readsLibappOncePerProcess() {
    RecordingContext firstEngine = new RecordingContext(nativeLibraryDir.getRoot());
    RecordingContext secondEngine = new RecordingContext(nativeLibraryDir.getRoot());

    String expected = ElfBuildIdReaderTest.hexWithFirstByte((byte) 0x42);
    assertEquals(expected, ElfBuildIdReader.cachedBuildId(firstEngine));
    assertEquals(expected, ElfBuildIdReader.cachedBuildId(firstEngine));
    assertEquals(expected, ElfBuildIdReader.cachedBuildId(secondEngine));

    assertEquals(
        1, firstEngine.applicationInfoThreads.size() + secondEngine.applicationInfoThreads.size());
  }
}
