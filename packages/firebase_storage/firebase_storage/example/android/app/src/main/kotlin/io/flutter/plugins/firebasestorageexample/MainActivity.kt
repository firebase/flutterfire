package io.flutter.plugins.firebasestorageexample

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.storage.FlutterFirebaseStoragePlugin

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // Test-only channel used by the integration tests.
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tests/engines")
        .setMethodCallHandler { call, result ->
          when (call.method) {
            // Attaches firebase_storage to a second engine, then destroys that
            // engine, as a background engine does when its work is done.
            "attachAndDetachSecondEngine" -> {
              val engine = FlutterEngine(applicationContext, null, false)
              engine.plugins.add(FlutterFirebaseStoragePlugin())
              engine.destroy()
              result.success(null)
            }
            else -> result.notImplemented()
          }
        }
  }
}
