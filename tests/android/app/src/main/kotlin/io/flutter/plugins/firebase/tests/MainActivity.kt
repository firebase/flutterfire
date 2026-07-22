package io.flutter.plugins.firebase.tests

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Test-only channel for manipulating runtime permissions during
        // integration tests. Uses reflection to access InstrumentationRegistry
        // so the code compiles without an androidTest dependency.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tests/permissions")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "grant" -> {
                        val permission = call.argument<String>("permission")
                        if (permission == null) {
                            result.error("INVALID_ARG", "permission is required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            grantPermission(permission)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("GRANT_FAILED", e.message, null)
                        }
                    }
                    "clearSharedPrefs" -> {
                        val name = call.argument<String>("name") ?: "FlutterFirebaseMessaging"
                        getSharedPreferences(name, MODE_PRIVATE).edit().clear().apply()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun grantPermission(permission: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        // Use reflection so this compiles without an androidTest dependency.
        // At runtime under instrumentation, InstrumentationRegistry is available.
        val registry = Class.forName("androidx.test.platform.app.InstrumentationRegistry")
        val instrumentation = registry.getMethod("getInstrumentation").invoke(null)
        val uiAutomation = instrumentation.javaClass.getMethod("getUiAutomation").invoke(instrumentation)
        uiAutomation.javaClass
            .getMethod("grantRuntimePermission", String::class.java, String::class.java)
            .invoke(uiAutomation, packageName, permission)
    }
}
