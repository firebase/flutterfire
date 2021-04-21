package com.example.firebase_in_app_messaging_example;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebase.inappmessaging.FirebaseInAppMessagingPlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FlutterFirebaseCorePlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    // TODO(Salakar) rename as part of re-work FirebaseInAppMessagingPlugin -> FlutterFirebaseInAppMessagingPlugin
    FirebaseInAppMessagingPlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.inappmessaging.FirebaseInAppMessagingPlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }
}
