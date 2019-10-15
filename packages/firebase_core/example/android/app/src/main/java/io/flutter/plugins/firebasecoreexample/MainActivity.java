package io.flutter.plugins.firebasecoreexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebase.core.FirebaseCorePlugin;

public class MainActivity extends FlutterActivity {
  // TODO(bparrishMines): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseCorePlugin());
  }
}
