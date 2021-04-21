package io.flutter.plugins.firebasecrashlyticsexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FlutterFirebaseCorePlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    FlutterFirebaseCrashlyticsPlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin"));
  }
}
