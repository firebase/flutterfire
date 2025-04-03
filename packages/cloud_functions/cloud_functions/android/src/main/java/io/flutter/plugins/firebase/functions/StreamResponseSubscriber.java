// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.functions;

import android.os.Handler;
import android.os.Looper;
import com.google.firebase.functions.StreamResponse;
import io.flutter.plugin.common.EventChannel;
import java.util.HashMap;
import java.util.Map;
import org.reactivestreams.Subscriber;
import org.reactivestreams.Subscription;

public class StreamResponseSubscriber implements Subscriber<StreamResponse> {
  private Subscription subscription;
  private final EventChannel.EventSink eventSink;

  private final Handler mainThreadHandler = new Handler(Looper.getMainLooper());

  public StreamResponseSubscriber(EventChannel.EventSink eventSink) {
    this.eventSink = eventSink;
  }

  @Override
  public void onSubscribe(Subscription s) {
    this.subscription = s;
    subscription.request(Long.MAX_VALUE);
  }

  @Override
  public void onNext(StreamResponse streamResponse) {
    Map<String, Object> responseMap = new HashMap<>();
    if (streamResponse instanceof StreamResponse.Message) {
      Object message = ((StreamResponse.Message) streamResponse).getMessage().getData();
      responseMap.put("message", message);
      mainThreadHandler.post(() -> eventSink.success(responseMap));
    } else {
      Object result = ((StreamResponse.Result) streamResponse).getResult().getData();
      responseMap.put("result", result);
      mainThreadHandler.post(() -> eventSink.success(responseMap));
    }
  }

  @Override
  public void onError(Throwable t) {
    if (eventSink != null) {
      eventSink.error("firebase_functions", t.getMessage(), null);
    }
  }

  @Override
  public void onComplete() {
    if (eventSink != null) {
      eventSink.endOfStream();
    }
  }

  public void cancel() {
    if (subscription != null) {
      subscription.cancel();
    }
  }
}
