package io.flutter.plugins.firebase.crashlytics.firebasecrashlyticsexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebase.crashlytics.firebasecrashlytics.FirebaseCrashlyticsPlugin;

public class MainActivity extends FlutterActivity {
  // TODO(<github-username>): Remove this once v2 of GeneratedPluginRegistrant
  // rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseCrashlyticsPlugin());
  }
}
