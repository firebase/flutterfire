/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.appcheck;

import com.google.firebase.appcheck.FirebaseAppCheck;
import io.flutter.plugin.common.EventChannel;
import java.util.HashMap;
import java.util.Map;

public class TokenChannelStreamHandler implements EventChannel.StreamHandler {

  private final FirebaseAppCheck firebaseAppCheck;
  private FirebaseAppCheck.AppCheckListener listener;

  public TokenChannelStreamHandler(FirebaseAppCheck firebaseAppCheck) {
    this.firebaseAppCheck = firebaseAppCheck;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {

    listener =
        result -> {
          Map<String, Object> event = new HashMap<>();
          event.put("token", result.getToken());
          events.success(event);
        };

    firebaseAppCheck.addAppCheckListener(listener);
  }

  @Override
  public void onCancel(Object arguments) {
    if (listener != null) {
      firebaseAppCheck.removeAppCheckListener(listener);
      listener = null;
    }
  }
}
