/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler

import android.os.Handler
import android.os.Looper
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.ListenSource
import com.google.firebase.firestore.ListenerRegistration
import com.google.firebase.firestore.MetadataChanges
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.SnapshotListenOptions
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.Companion.DEFAULT_ERROR_CODE
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter
import io.flutter.plugins.firebase.firestore.utils.PigeonParser
import java.util.concurrent.Executor

class QuerySnapshotsStreamHandler(
    private val query: Query,
    includeMetadataChanges: Boolean,
    private val serverTimestampBehavior: DocumentSnapshot.ServerTimestampBehavior,
    private val source: ListenSource,
    private val snapshotExecutor: Executor
) : StreamHandler {
  private var listenerRegistration: ListenerRegistration? = null
  private val mainHandler = Handler(Looper.getMainLooper())
  private val metadataChanges =
      if (includeMetadataChanges) MetadataChanges.INCLUDE else MetadataChanges.EXCLUDE

  override fun onListen(arguments: Any?, events: EventSink) {
    val optionsBuilder =
        SnapshotListenOptions.Builder()
            .setMetadataChanges(metadataChanges)
            .setSource(source)
            .setExecutor(snapshotExecutor)

    listenerRegistration =
        query.addSnapshotListener(optionsBuilder.build()) { querySnapshot, exception ->
          if (exception != null) {
            val exceptionDetails = ExceptionConverter.createDetails(exception)
            mainHandler.post {
              events.error(DEFAULT_ERROR_CODE, exception.message, exceptionDetails)
              events.endOfStream()
            }
            onCancel(null)
          } else {
            val pigeonSnapshot =
                PigeonParser.toPigeonQuerySnapshot(querySnapshot!!, serverTimestampBehavior)
            mainHandler.post { events.success(pigeonSnapshot) }
          }
        }
  }

  override fun onCancel(arguments: Any?) {
    listenerRegistration?.remove()
    listenerRegistration = null
  }
}
