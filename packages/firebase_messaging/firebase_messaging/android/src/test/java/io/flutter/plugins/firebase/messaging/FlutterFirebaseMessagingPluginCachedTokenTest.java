// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.os.Bundle;
import android.os.Looper;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.Shadows;
import org.robolectric.annotation.Config;

/** {@code Messaging#getCachedToken} and the installation ID manifest flag. */
@RunWith(RobolectricTestRunner.class)
@Config(sdk = 28)
public class FlutterFirebaseMessagingPluginCachedTokenTest {
  private Context context;

  @Before
  public void setUp() {
    context = RuntimeEnvironment.getApplication();
    ContextHolder.setApplicationContext(context);
  }

  @After
  public void tearDown() {
    setManifestValue(null);
    ContextHolder.setApplicationContext(null);
  }

  @Test
  public void installationIdIsEnabledWhenTheManifestSaysTrue() {
    setManifestValue(Boolean.TRUE);

    assertTrue(FlutterFirebaseMessagingPlugin.installationIdEnabled(context));
  }

  @Test
  public void installationIdIsEnabledWhenTheManifestSaysTrueAsAString() {
    setManifestValue("true");

    assertTrue(FlutterFirebaseMessagingPlugin.installationIdEnabled(context));
  }

  @Test
  public void installationIdIsDisabledWhenTheManifestSaysFalse() {
    setManifestValue(Boolean.FALSE);

    assertFalse(FlutterFirebaseMessagingPlugin.installationIdEnabled(context));
  }

  @Test
  public void installationIdIsDisabledWhenTheManifestHasNoEntry() {
    assertFalse(FlutterFirebaseMessagingPlugin.installationIdEnabled(context));
  }

  @Test
  public void installationIdIsDisabledWhenThePackageManagerCannotReadTheManifest() {
    setManifestValue(Boolean.TRUE);
    Shadows.shadowOf(context.getPackageManager()).removePackage(context.getPackageName());

    assertFalse(FlutterFirebaseMessagingPlugin.installationIdEnabled(context));
  }

  @Test
  public void getCachedTokenAnswersNoTokenWhenTheInstallationIdIsEnabled() {
    setManifestValue(Boolean.TRUE);
    RecordingResult result = new RecordingResult();

    new FlutterFirebaseMessagingPlugin()
        .onMethodCall(new MethodCall("Messaging#getCachedToken", null), result);
    Shadows.shadowOf(Looper.getMainLooper()).idle();

    assertNull(result.error);
    assertTrue(result.succeeded);
    Map<?, ?> answer = (Map<?, ?>) result.value;
    assertTrue(answer.containsKey("token"));
    assertNull(answer.get("token"));
  }

  private void setManifestValue(Object value) {
    PackageInfo info =
        Shadows.shadowOf(context.getPackageManager())
            .getInternalMutablePackageInfo(context.getPackageName());
    if (info == null) {
      // Removed by the PackageManager failure test.
      return;
    }
    if (info.applicationInfo.metaData == null) {
      info.applicationInfo.metaData = new Bundle();
    }
    info.applicationInfo.metaData.remove(
        FlutterFirebaseMessagingPlugin.INSTALLATION_ID_ENABLED_KEY);
    if (value instanceof Boolean) {
      info.applicationInfo.metaData.putBoolean(
          FlutterFirebaseMessagingPlugin.INSTALLATION_ID_ENABLED_KEY, (Boolean) value);
    } else if (value instanceof String) {
      info.applicationInfo.metaData.putString(
          FlutterFirebaseMessagingPlugin.INSTALLATION_ID_ENABLED_KEY, (String) value);
    }
  }

  private static final class RecordingResult implements MethodChannel.Result {
    boolean succeeded;
    Object value;
    String error;

    @Override
    public void success(Object result) {
      succeeded = true;
      value = result;
    }

    @Override
    public void error(String code, String message, Object details) {
      error = code + ": " + message;
    }

    @Override
    public void notImplemented() {
      error = "notImplemented";
    }
  }
}
