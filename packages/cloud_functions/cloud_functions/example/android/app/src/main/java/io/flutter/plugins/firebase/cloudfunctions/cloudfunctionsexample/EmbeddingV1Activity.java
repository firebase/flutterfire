package io.flutter.plugins.firebasestorageexample;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebase.cloudfunctions.CloudFunctionsPlugin;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    FlutterFirebaseCorePlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    // TODO(Salakar) rename as part of re-work CloudFunctionsPlugin -> FlutterFirebaseFunctionsPlugin
    CloudFunctionsPlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.cloudfunctions.CloudFunctionsPlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }
}
