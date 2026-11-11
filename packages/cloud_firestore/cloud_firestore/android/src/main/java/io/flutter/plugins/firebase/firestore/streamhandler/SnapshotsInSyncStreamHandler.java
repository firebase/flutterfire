/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.streamhandler;

import android.os.Handler;
import android.os.Looper;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.ListenerRegistration;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.concurrent.Executor;

public class SnapshotsInSyncStreamHandler implements StreamHandler {

  ListenerRegistration listenerRegistration;
  FirebaseFirestore firestore;
  private final Executor snapshotExecutor;
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  public SnapshotsInSyncStreamHandler(FirebaseFirestore firestore, Executor snapshotExecutor) {
    this.firestore = firestore;
    this.snapshotExecutor = snapshotExecutor;
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    listenerRegistration =
        firestore.addSnapshotsInSyncListener(
            snapshotExecutor, () -> mainHandler.post(() -> events.success(null)));
  }

  @Override
  public void onCancel(Object arguments) {
    if (listenerRegistration != null) {
      listenerRegistration.remove();
      listenerRegistration = null;
    }
  }
}
