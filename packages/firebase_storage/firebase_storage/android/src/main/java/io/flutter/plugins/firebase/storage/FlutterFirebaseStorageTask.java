/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.storage;

import static io.flutter.plugins.firebase.storage.FlutterFirebaseStoragePlugin.parseMetadataToMap;

import android.net.Uri;
import android.util.SparseArray;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.storage.FileDownloadTask;
import com.google.firebase.storage.StorageMetadata;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.StorageTask;
import com.google.firebase.storage.UploadTask;
import io.flutter.plugin.common.MethodChannel;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

class FlutterFirebaseStorageTask {
  static final SparseArray<FlutterFirebaseStorageTask> inProgressTasks = new SparseArray<>();
  private final FlutterFirebaseStorageTaskType type;
  private final int handle;
  private final StorageReference reference;
  private final byte[] bytes;
  private final Uri fileUri;
  private final StorageMetadata metadata;
  private final Object pauseSyncObject = new Object();
  private final Object resumeSyncObject = new Object();
  private final Object cancelSyncObject = new Object();
  private StorageTask<?> storageTask;
  private Boolean destroyed = false;

  private FlutterFirebaseStorageTask(
      FlutterFirebaseStorageTaskType type,
      int handle,
      StorageReference reference,
      @Nullable byte[] bytes,
      @Nullable Uri fileUri,
      @Nullable StorageMetadata metadata) {
    this.type = type;
    this.handle = handle;
    this.reference = reference;
    this.bytes = bytes;
    this.fileUri = fileUri;
    this.metadata = metadata;
    synchronized (inProgressTasks) {
      inProgressTasks.put(handle, this);
    }
  }

  @Nullable
  static FlutterFirebaseStorageTask getInProgressTaskForHandle(int handle) {
    synchronized (inProgressTasks) {
      return inProgressTasks.get(handle);
    }
  }

  static void cancelInProgressTasks() {
    synchronized (inProgressTasks) {
      for (int i = 0; i < inProgressTasks.size(); i++) {
        FlutterFirebaseStorageTask task = null;
        task = inProgressTasks.valueAt(i);
        if (task != null) {
          task.destroy();
        }
      }

      inProgressTasks.clear();
    }
  }

  public static FlutterFirebaseStorageTask uploadBytes(
      int handle, StorageReference reference, byte[] data, @Nullable StorageMetadata metadata) {
    return new FlutterFirebaseStorageTask(
        FlutterFirebaseStorageTaskType.BYTES, handle, reference, data, null, metadata);
  }

  public static FlutterFirebaseStorageTask uploadFile(
      int handle,
      StorageReference reference,
      @NonNull Uri fileUri,
      @Nullable StorageMetadata metadata) {
    return new FlutterFirebaseStorageTask(
        FlutterFirebaseStorageTaskType.FILE, handle, reference, null, fileUri, metadata);
  }

  public static FlutterFirebaseStorageTask downloadFile(
      int handle, StorageReference reference, @NonNull File file) {
    return new FlutterFirebaseStorageTask(
        FlutterFirebaseStorageTaskType.DOWNLOAD, handle, reference, null, Uri.fromFile(file), null);
  }

  public static Map<String, Object> parseUploadTaskSnapshot(UploadTask.TaskSnapshot snapshot) {
    Map<String, Object> out = new HashMap<>();
    out.put("path", snapshot.getStorage().getPath());
    out.put("bytesTransferred", snapshot.getBytesTransferred());
    out.put("totalBytes", snapshot.getTotalByteCount());
    if (snapshot.getMetadata() != null) {
      out.put("metadata", parseMetadataToMap(snapshot.getMetadata()));
    }
    return out;
  }

  public static Map<String, Object> parseDownloadTaskSnapshot(
      FileDownloadTask.TaskSnapshot snapshot) {
    Map<String, Object> out = new HashMap<>();
    out.put("path", snapshot.getStorage().getPath());
    if (snapshot.getTask().isSuccessful()) {
      // TODO(Salakar): work around a bug on the Firebase Android SDK where
      // sometimes `getBytesTransferred` != `getTotalByteCount` even
      // when download has completed.
      out.put("bytesTransferred", snapshot.getTotalByteCount());
    } else {
      out.put("bytesTransferred", snapshot.getBytesTransferred());
    }
    out.put("totalBytes", snapshot.getTotalByteCount());
    return out;
  }

  static Map<String, Object> parseTaskSnapshot(Object snapshot) {
    if (snapshot instanceof FileDownloadTask.TaskSnapshot) {
      return parseDownloadTaskSnapshot((FileDownloadTask.TaskSnapshot) snapshot);
    } else {
      return parseUploadTaskSnapshot((UploadTask.TaskSnapshot) snapshot);
    }
  }

  void destroy() {
    if (destroyed) return;
    destroyed = true;

    synchronized (inProgressTasks) {
      if (storageTask.isInProgress() || storageTask.isPaused()) {
        storageTask.cancel();
      }
      inProgressTasks.remove(handle);
    }

    synchronized (cancelSyncObject) {
      cancelSyncObject.notifyAll();
    }

    synchronized (pauseSyncObject) {
      pauseSyncObject.notifyAll();
    }

    synchronized (resumeSyncObject) {
      resumeSyncObject.notifyAll();
    }
  }

  TaskStateChannelStreamHandler startTaskWithMethodChannel(
      @NonNull MethodChannel channel, @NonNull String identifier) throws Exception {
    if (type == FlutterFirebaseStorageTaskType.BYTES && bytes != null) {
      if (metadata == null) {
        storageTask = reference.putBytes(bytes);
      } else {
        storageTask = reference.putBytes(bytes, metadata);
      }
    } else if (type == FlutterFirebaseStorageTaskType.FILE && fileUri != null) {
      if (metadata == null) {
        storageTask = reference.putFile(fileUri);
      } else {
        storageTask = reference.putFile(fileUri, metadata);
      }
    } else if (type == FlutterFirebaseStorageTaskType.DOWNLOAD && fileUri != null) {
      storageTask = reference.getFile(fileUri);
    } else {
      throw new Exception("Unable to start task. Some arguments have no been initialized.");
    }

    return new TaskStateChannelStreamHandler(this, reference.getStorage(), storageTask, identifier);
  }

  public Object getSnapshot() {
    return storageTask.getSnapshot();
  }

  public boolean isDestroyed() {
    return destroyed;
  }

  public void notifyResumeObjects() {
    synchronized (resumeSyncObject) {
      resumeSyncObject.notifyAll();
    }
  }

  public void notifyCancelObjects() {
    synchronized (cancelSyncObject) {
      cancelSyncObject.notifyAll();
    }
  }

  public void notifyPauseObjects() {
    synchronized (pauseSyncObject) {
      pauseSyncObject.notifyAll();
    }
  }

  public StorageTask<?> getAndroidTask() {
    return storageTask;
  }

  private enum FlutterFirebaseStorageTaskType {
    FILE,
    BYTES,
    DOWNLOAD,
  }
}
