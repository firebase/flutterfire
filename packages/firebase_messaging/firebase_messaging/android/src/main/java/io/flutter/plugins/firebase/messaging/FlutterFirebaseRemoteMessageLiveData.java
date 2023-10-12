// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import androidx.lifecycle.LiveData;
import com.google.firebase.messaging.RemoteMessage;

public class FlutterFirebaseRemoteMessageLiveData extends LiveData<RemoteMessage> {
  private static FlutterFirebaseRemoteMessageLiveData instance;

  public static FlutterFirebaseRemoteMessageLiveData getInstance() {
    if (instance == null) {
      instance = new FlutterFirebaseRemoteMessageLiveData();
    }
    return instance;
  }

  public void postRemoteMessage(RemoteMessage remoteMessage) {
    postValue(remoteMessage);
  }
}
