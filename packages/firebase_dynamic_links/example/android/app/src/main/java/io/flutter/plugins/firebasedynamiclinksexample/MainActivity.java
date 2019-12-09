package io.flutter.plugins.firebasedynamiclinksexample;

import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.firebasedynamiclinks.FirebaseDynamicLinksPlugin;
import io.flutter.plugins.urllauncher.UrlLauncherPlugin;

public class MainActivity extends FlutterActivity {
  // TODO(bparrishMines): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new FirebaseDynamicLinksPlugin());
    flutterEngine.getPlugins().add(new E2EPlugin());
    flutterEngine.getPlugins().add(new UrlLauncherPlugin());
  }
}
