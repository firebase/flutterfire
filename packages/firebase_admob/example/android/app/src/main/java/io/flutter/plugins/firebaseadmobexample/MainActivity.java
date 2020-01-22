// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmobexample;

import android.graphics.Color;
import android.widget.TextView;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory;
import java.util.Map;

public class MainActivity extends FlutterActivity implements NativeAdFactory {
  // TODO(bparrishMines): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new E2EPlugin());
    flutterEngine.getPlugins().add(new FirebaseAdMobPlugin());
  }

  @Override
  public UnifiedNativeAdView createNativeAd(
      UnifiedNativeAd nativeAd, Map<String, Object> customOptions) {
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
