/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler

import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler

class SnapshotsInSyncStreamHandler(private val firestore: FirebaseFirestore) : StreamHandler {
  private var listenerRegistration: ListenerRegistration? = null

  override fun onListen(arguments: Any?, events: EventSink) {
    listenerRegistration = firestore.addSnapshotsInSyncListener { events.success(null) }
  }

  override fun onCancel(arguments: Any?) {
    listenerRegistration?.remove()
    listenerRegistration = null
  }
}
