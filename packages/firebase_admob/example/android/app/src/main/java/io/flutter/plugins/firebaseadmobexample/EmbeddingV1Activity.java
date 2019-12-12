// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmobexample;

import android.graphics.Color;
import android.os.Bundle;
import android.widget.TextView;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory;

public class EmbeddingV1Activity extends FlutterActivity implements NativeAdFactory {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  @Override
  public UnifiedNativeAdView createNativeAd(UnifiedNativeAd nativeAd) {
    final UnifiedNativeAdView adView =
        (UnifiedNativeAdView) getLayoutInflater().inflate(R.layout.my_native_ad, null);
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
