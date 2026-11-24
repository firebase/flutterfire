// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.io.IOException;
import java.net.SocketTimeoutException;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import org.junit.Test;

public class FlutterFirebaseMessagingPluginExceptionTest {

  @Test
  public void includesUnderlyingCauseForFcmRegistrationFailure() {
    ExecutionException exception =
        new ExecutionException(
            new IOException(
                "FCM Registration failed!",
                new ExecutionException(new IOException("SERVICE_NOT_AVAILABLE"))));

    Map<String, Object> details = FlutterFirebaseMessagingPlugin.getExceptionDetails(exception);

    assertEquals("unknown", details.get("code"));
    assertEquals(
        "java.io.IOException: FCM Registration failed! Caused by: java.io.IOException:"
            + " SERVICE_NOT_AVAILABLE",
        details.get("message"));
  }

  @Test
  public void includesMultipleDistinctCausesInOrder() {
    ExecutionException exception =
        new ExecutionException(
            new IOException(
                "FCM Registration failed!",
                new ExecutionException(
                    new IOException(
                        "Registration RPC failed", new SocketTimeoutException("timed out")))));

    assertEquals(
        "java.io.IOException: FCM Registration failed! Caused by: java.io.IOException:"
            + " Registration RPC failed Caused by: java.net.SocketTimeoutException: timed out",
        FlutterFirebaseMessagingPlugin.formatExceptionMessage(exception));
  }

  @Test
  public void preservesExecutionExceptionWithCustomMessage() {
    ExecutionException exception =
        new ExecutionException(
            new IOException(
                "FCM Registration failed!",
                new ExecutionException(
                    "Custom wrapper", new IOException("AUTHENTICATION_FAILED"))));

    assertEquals(
        "java.io.IOException: FCM Registration failed! Caused by:"
            + " java.util.concurrent.ExecutionException: Custom wrapper Caused by:"
            + " java.io.IOException: AUTHENTICATION_FAILED",
        FlutterFirebaseMessagingPlugin.formatExceptionMessage(exception));
  }

  @Test
  public void doesNotDuplicateCauseAlreadyInOuterMessage() {
    ExecutionException exception =
        new ExecutionException(
            new IOException(new ExecutionException(new IOException("SERVICE_NOT_AVAILABLE"))));

    assertEquals(
        "java.io.IOException: java.util.concurrent.ExecutionException: java.io.IOException:"
            + " SERVICE_NOT_AVAILABLE",
        FlutterFirebaseMessagingPlugin.formatExceptionMessage(exception));
  }

  @Test
  public void keepsSingleWrappedExceptionMessageUnchanged() {
    ExecutionException exception =
        new ExecutionException(new IllegalStateException("API disabled"));

    assertEquals(
        "java.lang.IllegalStateException: API disabled",
        FlutterFirebaseMessagingPlugin.formatExceptionMessage(exception));
  }

  @Test
  public void keepsPlainExceptionWithoutCauseUnchanged() {
    Exception exception = new Exception("Permission denied");

    assertEquals(
        "Permission denied", FlutterFirebaseMessagingPlugin.formatExceptionMessage(exception));
  }

  @Test
  public void usesCauseWhenOuterMessageIsNull() {
    IOException exception =
        new IOException((String) null, new ExecutionException(new IOException("TIMEOUT")));

    assertEquals(
        "java.io.IOException: TIMEOUT",
        FlutterFirebaseMessagingPlugin.formatExceptionMessage(exception));
  }

  @Test
  public void handlesNullExceptionAndNullMessage() {
    assertNull(FlutterFirebaseMessagingPlugin.formatExceptionMessage(null));
    assertEquals(
        "An unknown error has occurred.",
        FlutterFirebaseMessagingPlugin.getExceptionDetails(null).get("message"));

    Exception noMessage = new Exception((String) null);
    assertNull(FlutterFirebaseMessagingPlugin.formatExceptionMessage(noMessage));
    assertEquals(
        "An unknown error has occurred.",
        FlutterFirebaseMessagingPlugin.getExceptionDetails(noMessage).get("message"));
  }

  @Test
  public void stopsOnCyclicCauseChain() {
    IOException first = new IOException("first");
    IOException second = new IOException("second", first);
    first.initCause(second);

    assertEquals(
        "first Caused by: java.io.IOException: second",
        FlutterFirebaseMessagingPlugin.formatExceptionMessage(first));
  }
}
