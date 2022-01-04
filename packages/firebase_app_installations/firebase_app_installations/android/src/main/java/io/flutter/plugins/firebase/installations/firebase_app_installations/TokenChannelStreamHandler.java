// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.installations.firebase_app_installations;

import com.google.firebase.installations.FirebaseInstallations;
import com.google.firebase.installations.internal.FidListener;
import io.flutter.plugin.common.EventChannel;
import java.util.HashMap;
import java.util.Map;

public class TokenChannelStreamHandler implements EventChannel.StreamHandler {

  private final FirebaseInstallations firebaseInstallations;
  private FidListener listener;

  public TokenChannelStreamHandler(FirebaseInstallations firebaseInstallations) {
    this.firebaseInstallations = firebaseInstallations;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {

    listener = createTokenEventListener(events);

    firebaseInstallations.registerFidListener(listener);
  }

  @Override
  public void onCancel(Object arguments) {
    if (listener != null) {
      listener = null;
    }
  }

  FidListener createTokenEventListener(final EventChannel.EventSink events) {
    return token -> {
      Map<String, Object> event = new HashMap<>();

      event.put("token", token);

      events.success(event);
    };
  }
}
