package io.flutter.plugins.firebase.messaging.example

import android.content.Context
import android.os.Build
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Test-only channel for manipulating runtime permissions during
        // integration tests. Uses reflection to access InstrumentationRegistry
        // so the code compiles without an androidTest dependency.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tests/permissions")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSdkInt" -> result.success(Build.VERSION.SDK_INT)
                    "grant" -> {
                        val permission = call.argument<String>("permission")
                        if (permission == null) {
                            result.error("INVALID_ARG", "permission is required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            mutatePermission(permission, grant = true)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("GRANT_FAILED", e.message, null)
                        }
                    }
                    "revoke" -> {
                        val permission = call.argument<String>("permission")
                        if (permission == null) {
                            result.error("INVALID_ARG", "permission is required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            mutatePermission(permission, grant = false)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("REVOKE_FAILED", e.message, null)
                        }
                    }
                    "resetPermission" -> {
                        val permission = call.argument<String>("permission")
                        if (permission == null) {
                            result.error("INVALID_ARG", "permission is required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            // Revoke and clear user-set/user-fixed flags so the
                            // permission returns to a true "never asked" state.
                            mutatePermission(permission, grant = false)
                            executeShell(
                                "pm clear-permission-flags $packageName $permission user-set user-fixed",
                            )
                            // firebase_messaging also records whether it ever showed the
                            // prompt; clear it so "never asked" is reproducible across tests.
                            getSharedPreferences(
                                MESSAGING_PERMISSIONS_PREFERENCES,
                                Context.MODE_PRIVATE,
                            ).edit().clear().commit()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("RESET_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun mutatePermission(permission: String, grant: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val uiAutomation = uiAutomation()
        val methodName = if (grant) "grantRuntimePermission" else "revokeRuntimePermission"
        uiAutomation.javaClass
            .getMethod(methodName, String::class.java, String::class.java)
            .invoke(uiAutomation, packageName, permission)
    }

    private fun executeShell(command: String) {
        val uiAutomation = uiAutomation()
        val pfd =
            uiAutomation.javaClass
                .getMethod("executeShellCommand", String::class.java)
                .invoke(uiAutomation, command) as ParcelFileDescriptor
        // Drain/close so the command is not left hanging.
        FileInputStream(pfd.fileDescriptor).use { input ->
            val buffer = ByteArray(1024)
            while (input.read(buffer) != -1) {
                // discard
            }
        }
        pfd.close()
    }

    private fun uiAutomation(): Any {
        // Use reflection so this compiles without an androidTest dependency.
        // At runtime under instrumentation, InstrumentationRegistry is available.
        val registry = Class.forName("androidx.test.platform.app.InstrumentationRegistry")
        val instrumentation = registry.getMethod("getInstrumentation").invoke(null)
        return instrumentation.javaClass.getMethod("getUiAutomation").invoke(instrumentation)
    }

    private companion object {
        // Keep in sync with FlutterFirebaseMessagingPlugin.PERMISSIONS_PREFERENCES_FILE.
        const val MESSAGING_PERMISSIONS_PREFERENCES =
            "io.flutter.plugins.firebase.messaging.permissions"
    }
}
