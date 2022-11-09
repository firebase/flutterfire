/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.messaging;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;

class FlutterFirebasePermissionManager implements PluginRegistry.RequestPermissionsResultListener {

  private final int permissionCode = 240;
  @Nullable private RequestPermissionsSuccessCallback successCallback;
  private boolean requestInProgress = false;

  @FunctionalInterface
  interface RequestPermissionsSuccessCallback {
    void onSuccess(int results);
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (requestInProgress && requestCode == permissionCode && this.successCallback != null) {
      requestInProgress = false;
      boolean granted =
          grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;

      this.successCallback.onSuccess(granted ? 1 : 0);
      return true;
    } else {
      return false;
    }
  }

  @RequiresApi(api = 33)
  public void requestPermissions(
      Activity activity,
      RequestPermissionsSuccessCallback successCallback,
      ErrorCallback errorCallback) {
    if (requestInProgress) {
      errorCallback.onError(
          "A request for permissions is already running, please wait for it to finish before doing another request.");
      return;
    }

    if (activity == null) {
      errorCallback.onError("Unable to detect current Android Activity.");
      return;
    }

    this.successCallback = successCallback;
    final ArrayList<String> permissions = new ArrayList<String>();
    permissions.add(Manifest.permission.POST_NOTIFICATIONS);
    final String[] requestNotificationPermission = permissions.toArray(new String[0]);

    if (!requestInProgress) {
      ActivityCompat.requestPermissions(activity, requestNotificationPermission, permissionCode);
      requestInProgress = true;
    }
  }
}
