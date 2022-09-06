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

  private final int permissionCode = 24;
  @Nullable private RequestPermissionsSuccessCallback successCallback;
  private boolean requestInProgress = false;

  @FunctionalInterface
  interface RequestPermissionsSuccessCallback {
    void onSuccess(int results);
  }

  @Override
  public boolean onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    requestInProgress = false;
    if (requestCode != permissionCode) {
      return false;
    }

    int grantResult = grantResults[0];
    assert this.successCallback != null;
    this.successCallback.onSuccess(grantResult == PackageManager.PERMISSION_GRANTED ? 1 : 0);
    return true;
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
