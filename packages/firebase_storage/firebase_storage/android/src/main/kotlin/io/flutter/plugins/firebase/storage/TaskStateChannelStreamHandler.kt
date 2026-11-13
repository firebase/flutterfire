/*
 * Copyright 2023, the Chromium project authors.
 * Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.storage

import androidx.annotation.Nullable
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.StorageException
import com.google.firebase.storage.StorageTask
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import java.util.HashMap

internal class TaskStateChannelStreamHandler(
    private val flutterTask: FlutterFirebaseStorageTask,
    private val androidStorage: FirebaseStorage,
    task: Any,
    private val identifier: String,
    private val onCancelled: (String) -> Unit
) : StreamHandler {

  private val androidTask: StorageTask<*> = task as StorageTask<*>

  @Volatile private var events: EventSink? = null

  private val TASK_STATE_NAME = "taskState"
  private val TASK_APP_NAME = "appName"
  private val TASK_SNAPSHOT = "snapshot"
  private val TASK_ERROR = "error"

  override fun onListen(arguments: Any?, events: EventSink) {
    this.events = events
    androidTask.addOnProgressListener { taskSnapshot ->
      if (flutterTask.isDestroyed()) return@addOnProgressListener
      val event = getTaskEventMap(taskSnapshot, null)
      event[TASK_STATE_NAME] = InternalStorageTaskState.RUNNING.raw
      this.events?.success(event)
      flutterTask.notifyResumeObjects()
    }

    androidTask.addOnPausedListener { taskSnapshot ->
      if (flutterTask.isDestroyed()) return@addOnPausedListener
      val event = getTaskEventMap(taskSnapshot, null)
      event[TASK_STATE_NAME] = InternalStorageTaskState.PAUSED.raw
      this.events?.success(event)
      flutterTask.notifyPauseObjects()
    }

    androidTask.addOnSuccessListener { taskSnapshot ->
      if (flutterTask.isDestroyed()) return@addOnSuccessListener
      val event = getTaskEventMap(taskSnapshot, null)
      event[TASK_STATE_NAME] = InternalStorageTaskState.SUCCESS.raw
      this.events?.success(event)
      flutterTask.destroy()
    }

    androidTask.addOnCanceledListener {
      if (flutterTask.isDestroyed()) return@addOnCanceledListener
      val event = getTaskEventMap(null, null)
      event[TASK_STATE_NAME] = InternalStorageTaskState.ERROR.raw
      val syntheticException: MutableMap<String, Any> = HashMap()
      syntheticException["code"] =
          FlutterFirebaseStorageException.getCode(StorageException.ERROR_CANCELED)
      syntheticException["message"] =
          FlutterFirebaseStorageException.getMessage(StorageException.ERROR_CANCELED)
      event[TASK_ERROR] = syntheticException
      this.events?.success(event)
      flutterTask.notifyCancelObjects()
      flutterTask.destroy()
    }

    androidTask.addOnFailureListener { exception ->
      if (flutterTask.isDestroyed()) return@addOnFailureListener
      val event = getTaskEventMap(null, exception)
      event[TASK_STATE_NAME] = InternalStorageTaskState.ERROR.raw
      this.events?.success(event)
      flutterTask.destroy()
    }
  }

  override fun onCancel(arguments: Any?) {
    // Only stop sending events: the task keeps running, can still be paused, resumed or cancelled
    // by its handle, and the listeners above still release it once it ends.
    events = null
    onCancelled(identifier)
  }

  private fun getTaskEventMap(
      @Nullable snapshot: Any?,
      @Nullable exception: Exception?
  ): MutableMap<String, Any?> {
    val arguments: MutableMap<String, Any?> = HashMap()
    arguments[TASK_APP_NAME] = androidStorage.app.name
    if (snapshot != null) {
      arguments[TASK_SNAPSHOT] = FlutterFirebaseStorageTask.parseTaskSnapshot(snapshot)
    }
    if (exception != null) {
      arguments[TASK_ERROR] = FlutterFirebaseStoragePlugin.getExceptionDetails(exception)
    }
    return arguments
  }
}
