package io.flutter.plugins.firebasemlvisionexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.camera.CameraPlugin;
import io.flutter.plugins.firebasemlvision.FirebaseMlVisionPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseMlVisionPlugin());
    flutterEngine.getPlugins().add(new CameraPlugin());

    final ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    PathProviderPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    ImagePickerPlugin.registerWith(
        shimPluginRegistry.registrarFor("io.flutter.plugins.imagepicker.VideoPlayerPlugin"));
  }
}
