// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmobexample;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FirebaseAdMobPlugin.registerWith(
        registrarFor("io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));

    final NativeAdFactory factory = new NativeAdFactoryExample(getLayoutInflater());
    FirebaseAdMobPlugin.registerNativeAdFactory(this, "adFactoryExample", factory);
  }
}
