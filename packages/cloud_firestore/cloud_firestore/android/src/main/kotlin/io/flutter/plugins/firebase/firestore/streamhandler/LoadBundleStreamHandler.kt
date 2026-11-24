/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler

import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.LoadBundleTaskProgress
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.Companion.DEFAULT_ERROR_CODE
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter

class LoadBundleStreamHandler(
    private val firestore: FirebaseFirestore,
    private val bundle: ByteArray
) : EventChannel.StreamHandler {
  private var eventSink: EventChannel.EventSink? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    eventSink = events
    val task = firestore.loadBundle(bundle)
    // Progress listeners only see updates made after they are added, so a bundle
    // that finishes loading first would never report SUCCESS and the Dart stream
    // would never close. Success listeners also run for a completed task, so the
    // final snapshot is sent from there.
    task.addOnProgressListener { progress ->
      if (progress.taskState != LoadBundleTaskProgress.TaskState.SUCCESS) {
        events.success(progress)
      }
    }
    task.addOnSuccessListener { events.success(it) }
    task.addOnFailureListener { exception ->
      val exceptionDetails = ExceptionConverter.createDetails(exception)
      events.error(DEFAULT_ERROR_CODE, exception.message, exceptionDetails)
      onCancel(null)
    }
  }

  override fun onCancel(arguments: Any?) {
    eventSink?.endOfStream()
  }
}
