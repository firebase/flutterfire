// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import androidx.lifecycle.LiveData;

public class FlutterFirebaseRegisteredLiveData extends LiveData<String> {
  private static FlutterFirebaseRegisteredLiveData instance;

  public static FlutterFirebaseRegisteredLiveData getInstance() {
    if (instance == null) {
      instance = new FlutterFirebaseRegisteredLiveData();
    }
    return instance;
  }

  public void postFid(String fid) {
    postValue(fid);
  }
}
