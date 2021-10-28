package io.flutter.plugins.firebasedynamiclinks;

import android.content.Intent;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.PluginRegistry.NewIntentListener;

public class GetLinkStreamHandler implements NewIntentListener, StreamHandler {


  private EventChannel.EventSink events;
  private final FirebaseDynamicLinks dynamicLinks;

  public GetLinkStreamHandler(FirebaseDynamicLinks dynamicLinks) {
    this.dynamicLinks = dynamicLinks;
  }

  @Override
  public boolean onNewIntent(Intent intent) {
    dynamicLinks
      .getDynamicLink(intent)
      .addOnSuccessListener(
        pendingDynamicLinkData -> {
            Map<String, Object> dynamicLink =
              Utils.getMapFromPendingDynamicLinkData(pendingDynamicLinkData);

            events.success(dynamicLink);
        })
      .addOnFailureListener(
        exception -> events.error(
          Constants.DEFAULT_ERROR_CODE,
          exception.getMessage(),
          Utils.getExceptionDetails(exception)
        ));

    return false;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    this.events = events;
  }

  @Override
  public void onCancel(Object arguments) {

  }
}
