package io.flutter.plugins.firebasemessagingexample;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    FirebaseMessagingPlugin.registerWith(
        registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }
}
