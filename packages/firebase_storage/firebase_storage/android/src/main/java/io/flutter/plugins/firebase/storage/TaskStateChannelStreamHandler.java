/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.storage;
import com.google.firebase.storage.StorageTask;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.OnProgressListener;
import com.google.firebase.storage.OnPausedListener;

import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.HashMap;
import java.util.Map;


public class TaskStateChannelStreamHandler implements StreamHandler {
  private final FirebaseStorage androidStorage;
  private final StorageTask androidTask;
  private OnProgressListener onProgressListener;
  private OnPausedListener onPausedListener;
  //private OnSuccessListener onSuccessListener;
  //private OnCanceledListener onCancelListener;
  //private OnFailureListener onFailureListener;

  private final String TASK_STATE_NAME = "TaskState";

  public TaskStateChannelStreamHandler(FirebaseStorage androidStorage, StorageTask androidTask) {
    this.androidStorage = androidStorage;
    this.androidTask = androidTask;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    Map<String, Object> event = new HashMap<>();
    event.put("appName", androidStorage.getApp().getName());

    //final AtomicBoolean initialAuthState = new AtomicBoolean(true);

    onProgressListener =
        storageTask -> {
          event.put(TASK_STATE_NAME, GeneratedAndroidFirebaseStorage.PigeonTaskState.RUNNING);

          // put task snapshot

          events.success(event);
        };

    androidTask.addOnProgressListener(onProgressListener);



  }

  @Override
  public void onCancel(Object arguments) {
    if (onProgressListener != null) {
      androidTask.removeOnProgressListener(onProgressListener);
      onProgressListener = null;
    }
  }
}
