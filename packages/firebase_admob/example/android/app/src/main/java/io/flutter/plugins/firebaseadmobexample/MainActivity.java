// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmobexample;

import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin;
import io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    // TODO(bparrishMines): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
    flutterEngine.getPlugins().add(new E2EPlugin());
    flutterEngine.getPlugins().add(new FirebaseAdMobPlugin());

    final NativeAdFactory factory = new NativeAdFactoryExample(getLayoutInflater());
    FirebaseAdMobPlugin.registerNativeAdFactory(flutterEngine, "adFactoryExample", factory);
  }

  @Override
  public void cleanUpFlutterEngine(FlutterEngine flutterEngine) {
    FirebaseAdMobPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample");
  }
}
