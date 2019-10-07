package io.flutter.plugins.firebasemlvisionexample;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebasemlvision.FirebaseMlVisionPlugin;

public class MainActivity2 extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseMlVisionPlugin());
  }
}
