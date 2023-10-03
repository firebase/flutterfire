// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import androidx.lifecycle.LiveData;

public class FlutterFirebaseTokenLiveData extends LiveData<String> {
  private static FlutterFirebaseTokenLiveData instance;

  public static FlutterFirebaseTokenLiveData getInstance() {
    if (instance == null) {
      instance = new FlutterFirebaseTokenLiveData();
    }
    return instance;
  }

  public void postToken(String token) {
    postValue(token);
  }
}
