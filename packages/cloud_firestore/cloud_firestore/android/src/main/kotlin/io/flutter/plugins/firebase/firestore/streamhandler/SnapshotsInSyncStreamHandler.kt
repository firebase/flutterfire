/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler

import android.os.Handler
import android.os.Looper
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import java.util.concurrent.Executor

class SnapshotsInSyncStreamHandler(
    private val firestore: FirebaseFirestore,
    private val snapshotExecutor: Executor
) : StreamHandler {
  private var listenerRegistration: ListenerRegistration? = null
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onListen(arguments: Any?, events: EventSink) {
    listenerRegistration =
        firestore.addSnapshotsInSyncListener(snapshotExecutor) {
          mainHandler.post { events.success(null) }
        }
  }

  override fun onCancel(arguments: Any?) {
    listenerRegistration?.remove()
    listenerRegistration = null
  }
}
