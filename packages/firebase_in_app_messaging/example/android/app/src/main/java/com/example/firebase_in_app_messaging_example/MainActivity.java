package com.example.firebase_in_app_messaging_example;

import com.example.firebase_in_app_messaging.FirebaseInAppMessagingPlugin;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin;

public class MainActivity extends FlutterActivity {
  // TODO(gaaclarke): Remove this once v2 of GeneratedPluginRegistrant rolls to stable.
  // https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new E2EPlugin());
    flutterEngine.getPlugins().add(new FirebaseInAppMessagingPlugin());
    final ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    FirebaseAnalyticsPlugin.registerWith(
        shimPluginRegistry.registrarFor(
            "io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin"));
  }
}
