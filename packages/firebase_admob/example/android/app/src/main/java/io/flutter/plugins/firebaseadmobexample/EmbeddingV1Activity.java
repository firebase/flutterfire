// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmobexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    final FirebaseAdMobPlugin adMobPlugin =
        valuePublishedByPlugin("io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin");
    adMobPlugin.addNativeAdFactory(
        "adFactoryExample", new NativeAdFactoryExample(getLayoutInflater()));
  }
}
