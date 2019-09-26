// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmobexample;

import android.graphics.Color;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
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
          final UnifiedNativeAdView adView = new UnifiedNativeAdView(this);
          adView.setLayoutParams(
              new ViewGroup.LayoutParams(
                  ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
          adView.setBackgroundColor(Color.GREEN);
          adView.setNativeAd(ad);

          final LinearLayout content = new LinearLayout(this);
          content.setLayoutParams(
              new ViewGroup.LayoutParams(
                  ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
          content.setOrientation(LinearLayout.VERTICAL);

          final TextView headlineView = new TextView(this);
          headlineView.setWidth(100);
          headlineView.setHeight(100);
          headlineView.setText(ad.getHeadline());
          content.addView(headlineView);
          adView.setHeadlineView(headlineView);

          final TextView bodyView = new TextView(this);
          bodyView.setWidth(100);
          bodyView.setHeight(100);
          bodyView.setText(ad.getBody());
          content.addView(bodyView);
          adView.setBodyView(bodyView);

          adView.addView(content);
          return adView;
        });
  }
}
