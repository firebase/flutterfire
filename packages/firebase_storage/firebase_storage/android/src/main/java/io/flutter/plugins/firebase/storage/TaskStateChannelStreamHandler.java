/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.storage;

import androidx.annotation.Nullable;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageException;
import com.google.firebase.storage.StorageTask;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.HashMap;
import java.util.Map;

public class TaskStateChannelStreamHandler implements StreamHandler {
  private final FlutterFirebaseStorageTask flutterTask;
  private final FirebaseStorage androidStorage;
  private final StorageTask<?> androidTask;
  private final String identifier;

  private final String TASK_STATE_NAME = "taskState";
  private final String TASK_APP_NAME = "appName";
  private final String TASK_SNAPSHOT = "snapshot";
  private final String TASK_ERROR = "error";

  public TaskStateChannelStreamHandler(
      FlutterFirebaseStorageTask flutterTask,
      FirebaseStorage androidStorage,
      StorageTask androidTask,
      String identifier) {
    this.flutterTask = flutterTask;
    this.androidStorage = androidStorage;
    this.androidTask = androidTask;
    this.identifier = identifier;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    androidTask.addOnProgressListener(
        taskSnapshot -> {
          if (flutterTask.isDestroyed()) return;
          Map<String, Object> event = getTaskEventMap(taskSnapshot, null);
          event.put(
              TASK_STATE_NAME,
              GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.RUNNING.index);
          events.success(event);
          flutterTask.notifyResumeObjects();
        });

    androidTask.addOnPausedListener(
        taskSnapshot -> {
          if (flutterTask.isDestroyed()) return;
          Map<String, Object> event = getTaskEventMap(taskSnapshot, null);
          event.put(
              TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.PAUSED.index);
          events.success(event);
          flutterTask.notifyPauseObjects();
        });

    androidTask.addOnSuccessListener(
        taskSnapshot -> {
          if (flutterTask.isDestroyed()) return;
          Map<String, Object> event = getTaskEventMap(taskSnapshot, null);
          event.put(
              TASK_STATE_NAME,
              GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.SUCCESS.index);
          events.success(event);
          flutterTask.destroy();
        });

    androidTask.addOnCanceledListener(
        () -> {
          if (flutterTask.isDestroyed()) return;
          Map<String, Object> event = getTaskEventMap(null, null);
          event.put(
              TASK_STATE_NAME,
              // We use "Error" state as we synthetically update snapshot cancel state in cancel() method in Dart
              // This is also inline with iOS which doesn't have a cancel state, only failure
              GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.ERROR.index);
          // We need to pass an exception that the task was canceled like the other platforms
          Map<String, Object> syntheticException = new HashMap<>();
          syntheticException.put(
              "code", FlutterFirebaseStorageException.getCode(StorageException.ERROR_CANCELED));
          syntheticException.put(
              "message",
              FlutterFirebaseStorageException.getMessage(StorageException.ERROR_CANCELED));
          event.put(TASK_ERROR, syntheticException);
          events.success(event);
          flutterTask.notifyCancelObjects();
          flutterTask.destroy();
        });

    androidTask.addOnFailureListener(
        exception -> {
          if (flutterTask.isDestroyed()) return;
          Map<String, Object> event = getTaskEventMap(null, exception);
          event.put(
              TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonStorageTaskState.ERROR.index);
          events.success(event);
          flutterTask.destroy();
        });
  }

  @Override
  public void onCancel(Object arguments) {
    if (!androidTask.isCanceled()) androidTask.cancel();
    if (!flutterTask.isDestroyed()) flutterTask.destroy();
    EventChannel eventChannel = FlutterFirebaseStoragePlugin.eventChannels.get(identifier);

    // Remove stream handler and clear the event channel
    if (eventChannel != null) {
      eventChannel.setStreamHandler(null);
      FlutterFirebaseStoragePlugin.eventChannels.remove(identifier);
    }

    if (FlutterFirebaseStoragePlugin.streamHandlers.get(identifier) != null) {
      FlutterFirebaseStoragePlugin.streamHandlers.remove(identifier);
    }
  }

  private Map<String, Object> getTaskEventMap(
      @Nullable Object snapshot, @Nullable Exception exception) {
    Map<String, Object> arguments = new HashMap<>();
    arguments.put(TASK_APP_NAME, androidStorage.getApp().getName());
    if (snapshot != null) {
      arguments.put(TASK_SNAPSHOT, FlutterFirebaseStorageTask.parseTaskSnapshot(snapshot));
    }
    if (exception != null) {
      arguments.put(TASK_ERROR, FlutterFirebaseStoragePlugin.getExceptionDetails(exception));
    }
    return arguments;
  }
}
