package io.flutter.plugins.firebasemlcustomexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.firebasemlcustom.FirebaseMLCustomPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import sq.flutter.tflite.TflitePlugin;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseMLCustomPlugin());

    final ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    PathProviderPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    ImagePickerPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    TflitePlugin.registerWith(shimPluginRegistry.registrarFor("sq.flutter.tflite.TflitePlugin"));
  }
}
