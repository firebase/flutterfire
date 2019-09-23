// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmobexample;

import android.graphics.Color;
import android.os.Bundle;
import android.widget.TextView;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    FirebaseAdMobPlugin.setNativeAdFactory(
        (UnifiedNativeAd ad) -> {
          final TextView myAdView = new TextView(this);
          myAdView.setWidth(200);
          myAdView.setHeight(200);
          myAdView.setBackgroundColor(Color.YELLOW);
          myAdView.setText(ad.getBody());
          return myAdView;
        });
  }
}
