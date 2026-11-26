// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import androidx.lifecycle.LiveData;
import com.google.firebase.messaging.RemoteMessage;

/**
 * @deprecated Foreground messages are delivered by {@code FlutterFirebaseRemoteMessageDispatcher},
 *     which, unlike a {@link LiveData}, does not drop messages posted in quick succession or replay
 *     the last one to new observers. {@link #postRemoteMessage} forwards to it, and observers of
 *     this LiveData are still told about every message.
 */
@Deprecated
public class FlutterFirebaseRemoteMessageLiveData extends LiveData<RemoteMessage> {
  private static FlutterFirebaseRemoteMessageLiveData instance;

  public static FlutterFirebaseRemoteMessageLiveData getInstance() {
    if (instance == null) {
      instance = new FlutterFirebaseRemoteMessageLiveData();
    }
    return instance;
  }

  public void postRemoteMessage(RemoteMessage remoteMessage) {
    FlutterFirebaseRemoteMessageDispatcher.getInstance().dispatch(remoteMessage);
  }

  /** Called by the dispatcher on the main thread for every message. */
  void notifyObservers(RemoteMessage remoteMessage) {
    setValue(remoteMessage);
  }
}
