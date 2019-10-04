package dev.flutter.plugins.firebaseperformanceexample;

import dev.flutter.plugins.firebaseperformance.FirebasePerformancePlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebasePerformancePlugin());
  }
}