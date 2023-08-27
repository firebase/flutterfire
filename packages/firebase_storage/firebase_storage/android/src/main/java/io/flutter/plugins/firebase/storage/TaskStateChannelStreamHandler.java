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

public class TaskStateChannelStreamHandler implements StreamHandler {
  private final FirebaseStorage androidStorage;
  private final StorageTask androidTask;
  private OnProgressListener onProgressListener;
  private OnPausedListener onPausedListener;
  // private OnSuccessListener onSuccessListener;
  // private OnCanceledListener onCancelListener;
  // private OnFailureListener onFailureListener;

  private final String TASK_STATE_NAME = "TaskState";
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
    Map<String, Object> event = new HashMap<>();
    event.put("appName", androidStorage.getApp().getName());

    // final AtomicBoolean initialAuthState = new AtomicBoolean(true);

    // onProgressListener = storageTask -> {
    //   event.put(TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonTaskState.RUNNING);

    //   event.put(TASK_SNAPSHOT, androidTask.getSnapshot());
    //   Log.w(
    //       "TaskStateChannelStreamHandler",
    //       "Trigger onProgressListener");
    //   events.success(event);
    // };

    androidTask.addOnProgressListener(
        taskExecutor,
        taskSnapshot -> {
          if (destroyed)
            return;
          // new Handler(Looper.getMainLooper())
          // .post(
          // () ->
          // channel.invokeMethod("Task#onProgress", getTaskEventMap(taskSnapshot,
          // null)));
          Log.w(
              "TaskStateChannelStreamHandler",
              "Trigger onProgressListener");
          synchronized (resumeSyncObject) {
            resumeSyncObject.notifyAll();
          }
        });

    androidTask.addOnPausedListener(
        taskExecutor,
        taskSnapshot -> {
          if (destroyed)
            return;
          // new Handler(Looper.getMainLooper())
          // .post(
          // () -> channel.invokeMethod("Task#onPaused", getTaskEventMap(taskSnapshot,
          // null)));
          Log.w(
              "TaskStateChannelStreamHandler",
              "Trigger onPausedListener");
          synchronized (pauseSyncObject) {
            pauseSyncObject.notifyAll();
          }
        });

    androidTask.addOnSuccessListener(
        taskExecutor,
        taskSnapshot -> {
          if (destroyed)
            return;
          // new Handler(Looper.getMainLooper())
          // .post(
          // () ->
          // channel.invokeMethod("Task#onSuccess", getTaskEventMap(taskSnapshot, null)));
          Log.w(
              "TaskStateChannelStreamHandler",
              "Trigger onSuccessListener");
          //destroy();
        });

    androidTask.addOnCanceledListener(
        taskExecutor,
        () -> {
          if (destroyed)
            return;
          // new Handler(Looper.getMainLooper())
          // .post(
          // () -> {
          // channel.invokeMethod("Task#onCanceled", getTaskEventMap(null, null));
          // destroy();
          // });
          Log.w(
              "TaskStateChannelStreamHandler",
              "Trigger onCancelListener");
        });

    androidTask.addOnFailureListener(
        taskExecutor,
        exception -> {
          if (destroyed)
            return;
          // new Handler(Looper.getMainLooper())
          // .post(
          // () -> {
          // channel.invokeMethod("Task#onFailure", getTaskEventMap(null, exception));
          // destroy();
          // });
          Log.w(
              "TaskStateChannelStreamHandler",
              "Trigger onFailureListener");
        });

  }

  @Override
  public void onCancel(Object arguments) {
    // if (onProgressListener != null) {
    //   androidTask.removeOnProgressListener(onProgressListener);
    //   onProgressListener = null;
    // }
  }
}
