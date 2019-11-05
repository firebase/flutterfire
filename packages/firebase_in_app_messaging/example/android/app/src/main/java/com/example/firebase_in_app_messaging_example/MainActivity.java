package com.example.firebase_in_app_messaging_example;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import com.example.firebase_in_app_messaging.FirebaseInAppMessagingPlugin;
import io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;


public class MainActivity extends FlutterActivity {
  // TODO(<github-username>): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseInAppMessagingPlugin());
    final ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    FirebaseAnalyticsPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin"));
  }
}
