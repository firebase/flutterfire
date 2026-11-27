// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.os.Looper;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.Shadows;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = 28)
public class FlutterFirebaseMessagingNotificationDelegationTest {

  private static final class RecordingResult implements MethodChannel.Result {
    final AtomicBoolean completed = new AtomicBoolean(false);
    final AtomicBoolean succeeded = new AtomicBoolean(false);
    final AtomicReference<Object> successValue = new AtomicReference<>();
    final AtomicReference<String> errorCode = new AtomicReference<>();
    final AtomicReference<String> errorMessage = new AtomicReference<>();
    final AtomicReference<Object> errorDetails = new AtomicReference<>();

    @Override
    public void success(@Nullable Object result) {
      successValue.set(result);
      succeeded.set(true);
      completed.set(true);
    }

    @Override
    public void error(String code, @Nullable String message, @Nullable Object details) {
      errorCode.set(code);
      errorMessage.set(message);
      errorDetails.set(details);
      completed.set(true);
    }

    @Override
    public void notImplemented() {
      completed.set(true);
    }

    void await() throws InterruptedException {
      long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(5);
      while (!completed.get() && System.nanoTime() < deadline) {
        Shadows.shadowOf(Looper.getMainLooper()).idle();
        Thread.sleep(10);
      }
      Shadows.shadowOf(Looper.getMainLooper()).idle();
      assertTrue("Timed out waiting for MethodChannel.Result", completed.get());
    }
  }

  private static final class FakeDelegationHandler
      implements FlutterFirebaseMessagingPlugin.NotificationDelegationHandler {
    boolean enabled;
    Boolean lastSetEnabled;
    RuntimeException setError;
    RuntimeException getError;

    @Override
    public Task<Void> setEnabled(Map<String, Object> arguments, boolean enabled) {
      lastSetEnabled = enabled;
      if (setError != null) {
        return Tasks.forException(setError);
      }
      this.enabled = enabled;
      return Tasks.forResult(null);
    }

    @Override
    public boolean isEnabled(Map<String, Object> arguments) {
      if (getError != null) {
        throw getError;
      }
      return enabled;
    }
  }

  @Test
  public void setNotificationDelegationEnabledUpdatesState() throws Exception {
    FakeDelegationHandler handler = new FakeDelegationHandler();
    FlutterFirebaseMessagingPlugin plugin = new FlutterFirebaseMessagingPlugin(handler);

    Map<String, Object> enableArgs = new HashMap<>();
    enableArgs.put("appName", "[DEFAULT]");
    enableArgs.put("enabled", true);
    MethodCall enableCall =
        new MethodCall("Messaging#setNotificationDelegationEnabled", enableArgs);
    RecordingResult enableResult = new RecordingResult();

    plugin.onMethodCall(enableCall, enableResult);
    enableResult.await();

    assertTrue(enableResult.succeeded.get());
    assertNull(enableResult.successValue.get());
    assertEquals(Boolean.TRUE, handler.lastSetEnabled);

    Map<String, Object> disableArgs = new HashMap<>();
    disableArgs.put("appName", "[DEFAULT]");
    disableArgs.put("enabled", false);
    MethodCall disableCall =
        new MethodCall("Messaging#setNotificationDelegationEnabled", disableArgs);
    RecordingResult disableResult = new RecordingResult();

    plugin.onMethodCall(disableCall, disableResult);
    disableResult.await();

    assertTrue(disableResult.succeeded.get());
    assertNull(disableResult.successValue.get());
    assertEquals(Boolean.FALSE, handler.lastSetEnabled);
  }

  @Test
  public void setNotificationDelegationEnabledErrorsWhenArgumentMissing() throws Exception {
    FakeDelegationHandler handler = new FakeDelegationHandler();
    FlutterFirebaseMessagingPlugin plugin = new FlutterFirebaseMessagingPlugin(handler);

    Map<String, Object> args = new HashMap<>();
    args.put("appName", "[DEFAULT]");
    MethodCall call = new MethodCall("Messaging#setNotificationDelegationEnabled", args);
    RecordingResult result = new RecordingResult();

    plugin.onMethodCall(call, result);
    result.await();

    assertFalse(result.succeeded.get());
    assertEquals("firebase_messaging", result.errorCode.get());
    assertNotNull(result.errorDetails.get());
  }

  @Test
  public void setNotificationDelegationEnabledPropagatesTaskFailure() throws Exception {
    FakeDelegationHandler handler = new FakeDelegationHandler();
    handler.setError = new IllegalStateException("delegation failed");
    FlutterFirebaseMessagingPlugin plugin = new FlutterFirebaseMessagingPlugin(handler);

    Map<String, Object> args = new HashMap<>();
    args.put("appName", "[DEFAULT]");
    args.put("enabled", true);
    MethodCall call = new MethodCall("Messaging#setNotificationDelegationEnabled", args);
    RecordingResult result = new RecordingResult();

    plugin.onMethodCall(call, result);
    result.await();

    assertFalse(result.succeeded.get());
    assertEquals("firebase_messaging", result.errorCode.get());
    assertTrue(result.errorMessage.get().contains("delegation failed"));
  }

  @Test
  public void isNotificationDelegationEnabledReturnsCurrentState() throws Exception {
    String key = FlutterFirebaseMessagingUtils.IS_NOTIFICATION_DELEGATION_ENABLED;
    FakeDelegationHandler handler = new FakeDelegationHandler();
    handler.enabled = true;
    FlutterFirebaseMessagingPlugin plugin = new FlutterFirebaseMessagingPlugin(handler);

    Map<String, Object> args = new HashMap<>();
    args.put("appName", "[DEFAULT]");
    MethodCall call = new MethodCall("Messaging#isNotificationDelegationEnabled", args);

    RecordingResult enabledResult = new RecordingResult();
    plugin.onMethodCall(call, enabledResult);
    enabledResult.await();

    assertTrue(enabledResult.succeeded.get());
    @SuppressWarnings("unchecked")
    Map<String, Object> enabledMap = (Map<String, Object>) enabledResult.successValue.get();
    assertEquals(Boolean.TRUE, enabledMap.get(key));

    handler.enabled = false;
    RecordingResult disabledResult = new RecordingResult();
    plugin.onMethodCall(call, disabledResult);
    disabledResult.await();

    assertTrue(disabledResult.succeeded.get());
    @SuppressWarnings("unchecked")
    Map<String, Object> disabledMap = (Map<String, Object>) disabledResult.successValue.get();
    assertEquals(Boolean.FALSE, disabledMap.get(key));
  }

  @Test
  public void isNotificationDelegationEnabledPropagatesException() throws Exception {
    FakeDelegationHandler handler = new FakeDelegationHandler();
    handler.getError = new IllegalStateException("status failed");
    FlutterFirebaseMessagingPlugin plugin = new FlutterFirebaseMessagingPlugin(handler);

    Map<String, Object> args = new HashMap<>();
    args.put("appName", "[DEFAULT]");
    MethodCall call = new MethodCall("Messaging#isNotificationDelegationEnabled", args);
    RecordingResult result = new RecordingResult();

    plugin.onMethodCall(call, result);
    result.await();

    assertFalse(result.succeeded.get());
    assertEquals("firebase_messaging", result.errorCode.get());
    assertEquals("status failed", result.errorMessage.get());
  }
}
