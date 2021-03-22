package io.flutter.plugins.firebaseadmobexample;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.widget.TextView;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory;
import java.util.Map;

class NativeAdFactoryExample implements NativeAdFactory {
  private final LayoutInflater layoutInflater;

  NativeAdFactoryExample(LayoutInflater layoutInflater) {
    this.layoutInflater = layoutInflater;
  }

  @Override
  public UnifiedNativeAdView createNativeAd(
      UnifiedNativeAd nativeAd, Map<String, Object> customOptions) {
    final UnifiedNativeAdView adView =
        (UnifiedNativeAdView) layoutInflater.inflate(R.layout.my_native_ad, null);
    final TextView headlineView = adView.findViewById(R.id.ad_headline);
    final TextView bodyView = adView.findViewById(R.id.ad_body);

    headlineView.setText(nativeAd.getHeadline());
    bodyView.setText(nativeAd.getBody());

    adView.setBackgroundColor(Color.YELLOW);

    adView.setNativeAd(nativeAd);
    adView.setBodyView(bodyView);
    adView.setHeadlineView(headlineView);
    return adView;
  }
}
