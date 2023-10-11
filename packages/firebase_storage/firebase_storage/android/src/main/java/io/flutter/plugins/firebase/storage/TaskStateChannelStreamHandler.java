/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.storage;

import android.util.Log;
import com.google.firebase.storage.StorageTask;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.OnProgressListener;
import com.google.firebase.storage.OnPausedListener;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import androidx.annotation.Nullable;

public class TaskStateChannelStreamHandler implements StreamHandler {
  private final FirebaseStorage androidStorage;
  private final StorageTask androidTask;

  private final String TASK_STATE_NAME = "taskState";
  private final String TASK_APP_NAME = "appName";
  private final String TASK_SNAPSHOT = "snapshot";

  private static final Executor taskExecutor = Executors.newSingleThreadExecutor();
  private Boolean destroyed = false;

  private final Object pauseSyncObject = new Object();
  private final Object resumeSyncObject = new Object();
  private final Object cancelSyncObject = new Object();

  public TaskStateChannelStreamHandler(FirebaseStorage androidStorage, StorageTask androidTask) {
    this.androidStorage = androidStorage;
    this.androidTask = androidTask;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    androidTask.addOnProgressListener(
        taskSnapshot -> {
          if (destroyed)
            return;
          Map<String, Object> event = getTaskEventMap(taskSnapshot, null);
          event.put(TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.RUNNING.index);
          events.success(event);
          synchronized (resumeSyncObject) {
            resumeSyncObject.notifyAll();
          }
        });

    androidTask.addOnPausedListener(
        taskSnapshot -> {
          if (destroyed)
            return;
          Map<String, Object> event = getTaskEventMap(taskSnapshot, null);
          event.put(TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.PAUSED.index);
          events.success(event);
          synchronized (pauseSyncObject) {
            pauseSyncObject.notifyAll();
          }
        });

    androidTask.addOnSuccessListener(
        taskSnapshot -> {
          if (destroyed)
            return;
          Map<String, Object> event = getTaskEventMap(taskSnapshot, null);
          event.put(TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.SUCCESS.index);
          events.success(event);
          //destroy();
        });

    androidTask.addOnCanceledListener(
        () -> {
          if (destroyed)
            return;
          Map<String, Object> event = getTaskEventMap(null, null);
          event.put(TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.CANCELED.index);
          events.success(event);
        });

    androidTask.addOnFailureListener(
        exception -> {
          if (destroyed)
            return;
          Map<String, Object> event = getTaskEventMap(null, exception);
          event.put(TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.ERROR.index);
          events.error(FlutterFirebaseStoragePlugin.DEFAULT_ERROR_CODE, exception.getMessage(), event);
        });

  }

  @Override
  public void onCancel(Object arguments) {
    // TODO
  }

  private Map<String, Object> getTaskEventMap(
    @Nullable Object snapshot, @Nullable Exception exception) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put(TASK_APP_NAME, androidStorage.getApp().getName());
    if (snapshot != null) {
      arguments.put(TASK_SNAPSHOT, FlutterFirebaseStorageTask.parseTaskSnapshot(snapshot));
    }
    if (exception != null) {
      arguments.put("error", FlutterFirebaseStoragePlugin.getExceptionDetails(exception));
    }
    return arguments;
  }
}
