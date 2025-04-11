// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.functions;

import android.net.Uri;
import com.google.firebase.functions.FirebaseFunctions;
import com.google.firebase.functions.HttpsCallableOptions;
import com.google.firebase.functions.HttpsCallableReference;
import com.google.firebase.functions.StreamResponse;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.net.URL;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.TimeUnit;
import org.reactivestreams.Publisher;

public class FirebaseFunctionsStreamHandler implements StreamHandler {

  private final FirebaseFunctions firebaseFunctions;

  private StreamResponseSubscriber subscriber;

  public FirebaseFunctionsStreamHandler(FirebaseFunctions functions) {
    this.firebaseFunctions = functions;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    @SuppressWarnings("unchecked")
    Map<String, Object> argumentsMap = (Map<String, Object>) arguments;
    httpsStreamCall(argumentsMap, events);
  }

  @Override
  public void onCancel(Object arguments) {
    subscriber.cancel();
  }

  private void httpsStreamCall(Map<String, Object> arguments, EventChannel.EventSink events) {
    try {

      String functionName = (String) arguments.get("functionName");
      String functionUri = (String) arguments.get("functionUri");
      String origin = (String) arguments.get("origin");
      Integer timeout = (Integer) arguments.get("timeout");
      Object parameters = arguments.get("parameters");
      boolean limitedUseAppCheckToken =
          (boolean) Objects.requireNonNull(arguments.get("limitedUseAppCheckToken"));

      if (origin != null) {
        Uri originUri = Uri.parse(origin);
        firebaseFunctions.useEmulator(originUri.getHost(), originUri.getPort());
      }

      HttpsCallableReference httpsCallableReference;
      HttpsCallableOptions options =
          new HttpsCallableOptions.Builder()
              .setLimitedUseAppCheckTokens(limitedUseAppCheckToken)
              .build();

      Publisher<StreamResponse> publisher;
      if (functionName != null) {
        httpsCallableReference = firebaseFunctions.getHttpsCallable(functionName, options);
        publisher = httpsCallableReference.stream(parameters);
      } else if (functionUri != null) {
        httpsCallableReference =
            firebaseFunctions.getHttpsCallableFromUrl(new URL(functionUri), options);
        publisher = httpsCallableReference.stream();
      } else {
        throw new IllegalArgumentException("Either functionName or functionUri must be set");
      }

      if (timeout != null) {
        httpsCallableReference.setTimeout(timeout.longValue(), TimeUnit.MILLISECONDS);
      }
      subscriber = new StreamResponseSubscriber(events);
      publisher.subscribe(subscriber);
    } catch (Exception e) {
      events.error("firebase_functions", e.getMessage(), null);
    }
  }
}
