package io.flutter.plugins.firebasecrashlyticsexample;

import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin;

public class MainActivity extends FlutterActivity {
  // TODO(<github-username>): Remove this once v2 of GeneratedPluginRegistrant
  // rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FlutterFirebaseCorePlugin());
    flutterEngine.getPlugins().add(new FlutterFirebaseCrashlyticsPlugin());
    flutterEngine.getPlugins().add(new E2EPlugin());
  }
}
