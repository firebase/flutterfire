package io.flutter.plugins.firebaseadmob;

import android.content.Context;
import android.view.View;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;
import java.util.HashMap;

public class BannerAd implements MethodCallHandler, PlatformView {

  private MethodChannel channel;

  private AdView adView;

  BannerAd(Context context, BinaryMessenger messenger, int id, HashMap args) {
    channel = new MethodChannel(messenger, "plugins.flutter.io/firebase_admob/banner_" + id);
    adView = new AdView(context);
    channel.setMethodCallHandler(this);
    adView.setAdSize(getSize((HashMap) args.get("adSize")));
    adView.setAdUnitId((String) args.get("adUnitId"));

    AdRequest adRequest = new AdRequest.Builder().build();
    adView.loadAd(adRequest);
  }

  public AdListener createAdListener(final MethodChannel channel) {
    return new AdListener() {
      @Override
      public void onAdClicked() {
        super.onAdClicked();
        channel.invokeMethod("clicked", null);
      }

      @Override
      public void onAdFailedToLoad(int i) {
        super.onAdFailedToLoad(i);
        HashMap map = new HashMap();
        map.put("errorCode", i);
        channel.invokeMethod("failedToLoad", map);
      }

      @Override
      public void onAdLoaded() {
        super.onAdLoaded();
        channel.invokeMethod("loaded", null);
      }

      @Override
      public void onAdImpression() {
        super.onAdImpression();
        channel.invokeMethod("impression", null);
      }

      @Override
      public void onAdOpened() {
        super.onAdOpened();
        channel.invokeMethod("opened", null);
      }

      @Override
      public void onAdLeftApplication() {
        super.onAdLeftApplication();
        channel.invokeMethod("leftApplication", null);
      }

      @Override
      public void onAdClosed() {
        super.onAdClosed();
        channel.invokeMethod("closed", null);
      }
    };
  }

  private AdSize getSize(HashMap size) {
    int width = (int) size.get("width");
    int height = (int) size.get("height");
    String name = (String) size.get("name");

    switch (name) {
      case "BANNER":
        return AdSize.BANNER;
      case "LARGE_BANNER":
        return AdSize.LARGE_BANNER;
      case "MEDIUM_RECTANGLE":
        return AdSize.MEDIUM_RECTANGLE;
      case "FULL_BANNER":
        return AdSize.FULL_BANNER;
      case "LEADERBOARD":
        return AdSize.LEADERBOARD;
      case "SMART_BANNER":
        return AdSize.SMART_BANNER;
      default:
        return new AdSize(width, height);
    }
  }

  @Override
  public void onMethodCall(MethodCall methodCall, Result result) {
    switch (methodCall.method) {
      case "setListener":
        adView.setAdListener(createAdListener(channel));
        break;
      case "dispose":
        dispose();
      default:
        result.notImplemented();
    }
  }

  @Override
  public View getView() {
    return adView;
  }

  @Override
  public void dispose() {
    adView.setVisibility(View.GONE);
    adView.destroy();
    channel.setMethodCallHandler(null);
  }
}
