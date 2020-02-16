package io.flutter.plugins.firebase.firestoreexample;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebase.cloudfirestore.CloudFirestorePlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    CloudFirestorePlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.cloudfirestore.CloudFirestorePlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }
}
