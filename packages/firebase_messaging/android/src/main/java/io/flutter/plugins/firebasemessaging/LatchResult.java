package io.flutter.plugins.firebasemessaging;

import java.util.concurrent.CountDownLatch;

import io.flutter.plugin.common.MethodChannel;

public class LatchResult {

  private MethodChannel.Result result;

  public LatchResult(final CountDownLatch latch) {
    result = new MethodChannel.Result() {
      @Override
      public void success(Object result) {
        latch.countDown();
      }

      @Override
      public void error(String errorCode, String errorMessage, Object errorDetails) {
        latch.countDown();
      }

      @Override
      public void notImplemented() {
        latch.countDown();
      }
    };
  }

  public MethodChannel.Result getResult() {
    return result;
  }


}
