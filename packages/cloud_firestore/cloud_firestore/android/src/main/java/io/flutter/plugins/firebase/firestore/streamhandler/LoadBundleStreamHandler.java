/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import static io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin.DEFAULT_ERROR_CODE;

import androidx.annotation.NonNull;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.LoadBundleTask;
import com.google.firebase.firestore.LoadBundleTaskProgress;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.firebase.firestore.utils.ExceptionConverter;
import java.util.Map;

public class LoadBundleStreamHandler implements EventChannel.StreamHandler {

  public LoadBundleStreamHandler(FirebaseFirestore firestore, @NonNull byte[] bundle) {
    this.firestore = firestore;
    this.bundle = bundle;
  }

  private EventChannel.EventSink eventSink;

  private final FirebaseFirestore firestore;
  private final @NonNull byte[] bundle;

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
    LoadBundleTask task = firestore.loadBundle(bundle);

    // Progress listeners only see updates made after they are added, so a bundle
    // that finishes loading first would never report SUCCESS and the Dart stream
    // would never close. Success listeners also run for a completed task, so the
    // final snapshot is sent from there.
    task.addOnProgressListener(
        progress -> {
          if (progress.getTaskState() != LoadBundleTaskProgress.TaskState.SUCCESS) {
            events.success(progress);
          }
        });

    task.addOnSuccessListener(events::success);

    task.addOnFailureListener(
        exception -> {
          Map<String, String> exceptionDetails = ExceptionConverter.createDetails(exception);
          events.error(DEFAULT_ERROR_CODE, exception.getMessage(), exceptionDetails);
          onCancel(null);
        });
  }

  @Override
  public void onCancel(Object arguments) {
    eventSink.endOfStream();
  }
}
