// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.functions;

import android.os.Handler;
import android.os.Looper;
import com.google.firebase.functions.StreamResponse;
import io.flutter.plugin.common.EventChannel;
import java.util.concurrent.CountDownLatch;
import org.reactivestreams.Subscriber;
import org.reactivestreams.Subscription;

public class StreamResponseSubscriber implements Subscriber<StreamResponse> {
  private Subscription subscription;
  private final EventChannel.EventSink eventSink;

  private final Handler mainThreadHandler = new Handler(Looper.getMainLooper());

  private CountDownLatch latch = new CountDownLatch(1);

  private Object result;

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
    if (streamResponse instanceof StreamResponse.Message) {
      Object message = ((StreamResponse.Message) streamResponse).getMessage().getData();
      mainThreadHandler.post(() -> eventSink.success(message));
    } else {
      this.result = ((StreamResponse.Result) streamResponse).getResult().getData();
      latch.countDown();
    }
  }

  @Override
  public void onError(Throwable t) {
    if (eventSink != null) {
      eventSink.error("firebase_functions", t.getMessage(), null);
      latch.countDown();
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
      latch.countDown();
    }
  }

  public Object getResult() {
    try {
      latch.await();
      return this.result;
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
}
