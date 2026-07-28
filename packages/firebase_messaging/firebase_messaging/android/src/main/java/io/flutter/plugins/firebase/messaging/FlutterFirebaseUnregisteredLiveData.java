// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import androidx.lifecycle.LiveData;

public class FlutterFirebaseUnregisteredLiveData extends LiveData<String> {
  private static FlutterFirebaseUnregisteredLiveData instance;

  public static FlutterFirebaseUnregisteredLiveData getInstance() {
    if (instance == null) {
      instance = new FlutterFirebaseUnregisteredLiveData();
    }
    return instance;
  }

  public void postFid(String fid) {
    postValue(fid);
  }
}
