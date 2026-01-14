/*
 * Copyright 2022, the Chromium project authors.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */
package io.flutter.plugins.firebase.storage

import android.net.Uri
import android.util.SparseArray
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.firebase.storage.FileDownloadTask
import com.google.firebase.storage.StorageMetadata
import com.google.firebase.storage.StorageReference
import com.google.firebase.storage.StorageTask
import com.google.firebase.storage.UploadTask
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.HashMap

internal class FlutterFirebaseStorageTask private constructor(
  private val type: FlutterFirebaseStorageTaskType,
  private val handle: Int,
  private val reference: StorageReference,
  private val bytes: ByteArray?,
  private val fileUri: Uri?,
  private val metadata: StorageMetadata?
) {
  private val pauseSyncObject = Object()
  private val resumeSyncObject = Object()
  private val cancelSyncObject = Object()
  private lateinit var storageTask: StorageTask<*>
  private var destroyed: Boolean = false

  init {
    synchronized(inProgressTasks) { inProgressTasks.put(handle, this) }
  }

  fun startTaskWithMethodChannel(@NonNull channel: MethodChannel, @NonNull identifier: String): TaskStateChannelStreamHandler {
    storageTask = when (type) {
      FlutterFirebaseStorageTaskType.BYTES -> if (metadata == null) reference.putBytes(bytes!!) else reference.putBytes(bytes!!, metadata)
      FlutterFirebaseStorageTaskType.FILE -> if (metadata == null) reference.putFile(fileUri!!) else reference.putFile(fileUri!!, metadata)
      FlutterFirebaseStorageTaskType.DOWNLOAD -> reference.getFile(fileUri!!)
    }

    return TaskStateChannelStreamHandler(this, reference.storage, storageTask as Any, identifier)
  }

  fun getSnapshot(): Any = storageTask.snapshot

  fun pause(): Boolean = storageTask.pause()

  fun resume(): Boolean = storageTask.resume()

  fun cancel(): Boolean = storageTask.cancel()

  fun isCanceled(): Boolean = storageTask.isCanceled

  fun isInProgress(): Boolean = storageTask.isInProgress

  fun isPaused(): Boolean = storageTask.isPaused

  fun isDestroyed(): Boolean = destroyed

  fun notifyResumeObjects() { synchronized(resumeSyncObject) { resumeSyncObject.notifyAll() } }
  fun notifyCancelObjects() { synchronized(cancelSyncObject) { cancelSyncObject.notifyAll() } }
  fun notifyPauseObjects() { synchronized(pauseSyncObject) { pauseSyncObject.notifyAll() } }

  // Intentionally do not expose the StorageTask generic type outside this class

  fun destroy() {
    if (destroyed) return
    destroyed = true

    synchronized(inProgressTasks) {
      if (storageTask.isInProgress || storageTask.isPaused) {
        storageTask.cancel()
      }
      inProgressTasks.remove(handle)
    }

    synchronized(cancelSyncObject) { cancelSyncObject.notifyAll() }
    synchronized(pauseSyncObject) { pauseSyncObject.notifyAll() }
    synchronized(resumeSyncObject) { resumeSyncObject.notifyAll() }
  }

  companion object {
    val inProgressTasks: SparseArray<FlutterFirebaseStorageTask> = SparseArray()

    @JvmStatic
    fun getInProgressTaskForHandle(handle: Int): FlutterFirebaseStorageTask? {
      synchronized(inProgressTasks) { return inProgressTasks.get(handle) }
    }

    @JvmStatic
    fun cancelInProgressTasks() {
      synchronized(inProgressTasks) {
        for (i in 0 until inProgressTasks.size()) {
          val task: FlutterFirebaseStorageTask? = inProgressTasks.valueAt(i)
          task?.destroy()
        }
        inProgressTasks.clear()
      }
    }

    @JvmStatic
    fun uploadBytes(handle: Int, reference: StorageReference, data: ByteArray, metadata: StorageMetadata?): FlutterFirebaseStorageTask {
      return FlutterFirebaseStorageTask(FlutterFirebaseStorageTaskType.BYTES, handle, reference, data, null, metadata)
    }

    @JvmStatic
    fun uploadFile(handle: Int, reference: StorageReference, fileUri: Uri, metadata: StorageMetadata?): FlutterFirebaseStorageTask {
      return FlutterFirebaseStorageTask(FlutterFirebaseStorageTaskType.FILE, handle, reference, null, fileUri, metadata)
    }

    @JvmStatic
    fun downloadFile(handle: Int, reference: StorageReference, file: File): FlutterFirebaseStorageTask {
      return FlutterFirebaseStorageTask(FlutterFirebaseStorageTaskType.DOWNLOAD, handle, reference, null, Uri.fromFile(file), null)
    }

    @JvmStatic
    fun parseUploadTaskSnapshot(snapshot: UploadTask.TaskSnapshot): Map<String, Any?> {
      val out: MutableMap<String, Any?> = HashMap()
      out["path"] = snapshot.storage.path
      out["bytesTransferred"] = snapshot.bytesTransferred
      out["totalBytes"] = snapshot.totalByteCount
      if (snapshot.metadata != null) {
        out["metadata"] = FlutterFirebaseStoragePlugin.parseMetadataToMap(snapshot.metadata!!)
      }
      return out
    }

    @JvmStatic
    fun parseDownloadTaskSnapshot(snapshot: FileDownloadTask.TaskSnapshot): Map<String, Any?> {
      val out: MutableMap<String, Any?> = HashMap()
      out["path"] = snapshot.storage.path
      // Workaround: sometimes getBytesTransferred != getTotalByteCount when completed
      out["bytesTransferred"] = if (snapshot.task.isSuccessful) snapshot.totalByteCount else snapshot.bytesTransferred
      out["totalBytes"] = snapshot.totalByteCount
      return out
    }

    @JvmStatic
    fun parseTaskSnapshot(snapshot: Any): Map<String, Any?> {
      return if (snapshot is FileDownloadTask.TaskSnapshot) {
        parseDownloadTaskSnapshot(snapshot)
      } else {
        parseUploadTaskSnapshot(snapshot as UploadTask.TaskSnapshot)
      }
    }
  }

  private enum class FlutterFirebaseStorageTaskType {
    FILE,
    BYTES,
    DOWNLOAD
  }
}


