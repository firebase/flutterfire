package io.flutter.plugins.firebaseadmob;

import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.HashMap;

public class BannerAdFactory extends PlatformViewFactory {

  private BinaryMessenger messenger;

  BannerAdFactory(BinaryMessenger messenger) {
    super(StandardMessageCodec.INSTANCE);
    this.messenger = messenger;
  }

  @Override
  public PlatformView create(Context context, int viewId, Object args) {
    return new BannerAd(context, messenger, viewId, (HashMap) args);
  }
}
