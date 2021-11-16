package android.src.main.java.io.flutter.plugins.firebase.dynamiclinks;

import android.content.Intent;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import java.util.Map;

public class OnLinkStreamHandler implements StreamHandler {
  private EventChannel.EventSink events;
  private final FirebaseDynamicLinks dynamicLinks;

  public OnLinkStreamHandler(FirebaseDynamicLinks dynamicLinks) {
    this.dynamicLinks = dynamicLinks;
  }

  public void sinkEvent(Intent intent) {
    dynamicLinks
        .getDynamicLink(intent)
        .addOnSuccessListener(
            pendingDynamicLinkData -> {
              Map<String, Object> dynamicLink =
                  Utils.getMapFromPendingDynamicLinkData(pendingDynamicLinkData);
              events.success(dynamicLink);
            })
        .addOnFailureListener(
            exception ->
                events.error(
                    Constants.DEFAULT_ERROR_CODE,
                    exception.getMessage(),
                    Utils.getExceptionDetails(exception)));
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    this.events = events;
  }

  @Override
  public void onCancel(Object arguments) {
    // Do nothing
  }
}
