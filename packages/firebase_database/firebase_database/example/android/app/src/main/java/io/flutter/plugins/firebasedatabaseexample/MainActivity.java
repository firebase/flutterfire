// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasedatabaseexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebase.core.FirebaseCorePlugin;
import io.flutter.plugins.firebase.database.FirebaseDatabasePlugin;

public class MainActivity extends FlutterActivity {

  // TODO(cyanglaz): Remove this once v2 of GeneratedPluginRegistrant rolls to stable.
  // https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins().add(new FirebaseDatabasePlugin());
    flutterEngine.getPlugins().add(new FirebaseCorePlugin());
  }
}
