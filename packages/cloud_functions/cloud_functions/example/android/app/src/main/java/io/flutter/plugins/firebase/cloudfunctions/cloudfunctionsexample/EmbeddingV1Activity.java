package io.flutter.plugins.firebasestorageexample;


import android.os.Bundle;	import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;	import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;	import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebase.storage.FirebaseStoragePlugin;


public class EmbeddingV1Activity extends FlutterActivity {	public class EmbeddingV1Activity extends FlutterActivity {
  @Override	  @Override
  protected void onCreate(Bundle savedInstanceState) {	  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);	    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);	    FlutterFirebaseCorePlugin.registerWith(
      registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    // TODO(Salakar) rename as part of re-work CloudFunctionsPlugin -> FlutterFirebaseFunctionsPlugin
    CloudFunctionsPlugin.registerWith(
      registrarFor("io.flutter.plugins.firebase.cloudfunctions.CloudFunctionsPlugin"));
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }	  }
}	}
