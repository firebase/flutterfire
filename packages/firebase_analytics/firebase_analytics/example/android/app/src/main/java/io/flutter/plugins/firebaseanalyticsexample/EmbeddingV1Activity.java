package io.flutter.plugins.firebaseanalyticsexample;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
    // TODO(Salakar) rename as part of re-work FirebaseAnalyticsPlugin -> FlutterFirebaseAnalyticsPlugin
    FirebaseAnalyticsPlugin.registerWith(
        registrarFor("io.flutter.plugins.firebaseanalytics.FirebaseAnalyticsPlugin"));
    FlutterFirebaseCorePlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
  }
}
