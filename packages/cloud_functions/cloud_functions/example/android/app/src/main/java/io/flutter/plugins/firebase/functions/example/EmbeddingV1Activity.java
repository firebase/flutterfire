package io.flutter.plugins.firebase.functions.example;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebase.functions.FlutterFirebaseFunctionsPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FlutterFirebaseCorePlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    FlutterFirebaseFunctionsPlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.functions.FlutterFirebaseFunctionsPlugin"));
  }
}
