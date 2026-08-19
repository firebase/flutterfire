package io.flutter.plugins.firebase.messaging.example

import android.content.Context
import android.os.Build
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.io.InputStream
import java.io.OutputStream
import java.net.InetSocketAddress
import java.net.Socket
import java.nio.charset.StandardCharsets

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // Test-only channel for manipulating runtime permissions during
    // integration tests. `flutter test` launches the app without Android
    // instrumentation, so UiAutomation via InstrumentationRegistry is often
    // unavailable; we fall back to the host adb server via 10.0.2.2.
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
                result.error("GRANT_FAILED", errorMessage(e), null)
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
                result.error("REVOKE_FAILED", errorMessage(e), null)
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
                    )
                    .edit()
                    .clear()
                    .commit()
                result.success(true)
              } catch (e: Exception) {
                result.error("RESET_FAILED", errorMessage(e), null)
              }
            }
            else -> result.notImplemented()
          }
        }
  }

  private fun mutatePermission(permission: String, grant: Boolean) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
    val action = if (grant) "grant" else "revoke"
    try {
      executeHostAdbShell("pm $action $packageName $permission")
    } catch (adbError: Exception) {
      try {
        val uiAutomation = uiAutomation()
        val methodName = if (grant) "grantRuntimePermission" else "revokeRuntimePermission"
        uiAutomation.javaClass
            .getMethod(methodName, String::class.java, String::class.java)
            .invoke(uiAutomation, packageName, permission)
      } catch (uiError: Exception) {
        throw IllegalStateException(
            "pm $action failed: ${errorMessage(adbError)}; UiAutomation: ${errorMessage(uiError)}",
            uiError,
        )
      }
    }
  }

  private fun executeShell(command: String) {
    try {
      executeHostAdbShell(command)
    } catch (adbError: Exception) {
      try {
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
      } catch (uiError: Exception) {
        throw IllegalStateException(
            "shell `$command` failed: ${errorMessage(adbError)}; UiAutomation: ${errorMessage(uiError)}",
            uiError,
        )
      }
    }
  }

  private fun uiAutomation(): Any {
    try {
      val activityThreadClass = Class.forName("android.app.ActivityThread")
      val current = activityThreadClass.getMethod("currentActivityThread").invoke(null)
      val instrumentation = activityThreadClass.getMethod("getInstrumentation").invoke(current)
      val uiAutomation =
          instrumentation.javaClass.getMethod("getUiAutomation").invoke(instrumentation)
      if (uiAutomation != null) {
        return uiAutomation
      }
    } catch (_: Exception) {
      // Fall through to InstrumentationRegistry (instrumented runs).
    }
    // Use reflection so this compiles without an androidTest dependency.
    val registry = Class.forName("androidx.test.platform.app.InstrumentationRegistry")
    val instrumentation = registry.getMethod("getInstrumentation").invoke(null)
    return instrumentation.javaClass.getMethod("getUiAutomation").invoke(instrumentation)
  }

  /// Talks to the host adb server from inside the emulator (`10.0.2.2:5037`)
  /// so `pm grant`/`revoke` run as shell. `flutter test` does not start an
  /// instrumented process, so UiAutomation is usually unavailable.
  ///
  /// Must not run on the platform thread: Android throws
  /// [android.os.NetworkOnMainThreadException] for socket I/O on the main
  /// thread, and that exception has a null message.
  private fun executeHostAdbShell(command: String) {
    val error = arrayOfNulls<Exception>(1)
    val thread = Thread {
      try {
        executeHostAdbShellBlocking(command)
      } catch (e: Exception) {
        error[0] = e
      }
    }
    thread.start()
    thread.join(ADB_TIMEOUT_MS.toLong() * 2)
    if (thread.isAlive) {
      throw IllegalStateException("adb shell timed out: $command")
    }
    error[0]?.let { throw it }
  }

  private fun executeHostAdbShellBlocking(command: String) {
    val socket = Socket()
    try {
      socket.connect(InetSocketAddress(EMULATOR_HOST_LOOPBACK, ADB_SERVER_PORT), ADB_TIMEOUT_MS)
      socket.soTimeout = ADB_TIMEOUT_MS
      val out = socket.getOutputStream()
      val input = socket.getInputStream()
      sendAdb(out, "host:transport-any")
      readAdbStatus(input)
      sendAdb(out, "shell:$command")
      readAdbStatus(input)
      // Drain command output so adbd does not see a premature close.
      val buffer = ByteArray(1024)
      while (input.read(buffer) != -1) {
        // discard
      }
    } finally {
      socket.close()
    }
  }

  private fun sendAdb(out: OutputStream, message: String) {
    val payload = message.toByteArray(StandardCharsets.UTF_8)
    val prefix = String.format("%04x", payload.size).toByteArray(StandardCharsets.UTF_8)
    out.write(prefix)
    out.write(payload)
    out.flush()
  }

  private fun readAdbStatus(input: InputStream) {
    val status = ByteArray(4)
    var offset = 0
    while (offset < 4) {
      val read = input.read(status, offset, 4 - offset)
      if (read < 0) {
        throw IllegalStateException("adb connection closed")
      }
      offset += read
    }
    val token = String(status, StandardCharsets.UTF_8)
    if (token == "OKAY") {
      return
    }
    val lengthBytes = ByteArray(4)
    offset = 0
    while (offset < 4) {
      val read = input.read(lengthBytes, offset, 4 - offset)
      if (read < 0) {
        throw IllegalStateException("adb $token")
      }
      offset += read
    }
    val length = String(lengthBytes, StandardCharsets.UTF_8).toInt(16)
    val detail = ByteArray(length)
    offset = 0
    while (offset < length) {
      val read = input.read(detail, offset, length - offset)
      if (read < 0) {
        break
      }
      offset += read
    }
    throw IllegalStateException(
        "adb $token: ${String(detail, 0, offset, StandardCharsets.UTF_8)}",
    )
  }

  private fun errorMessage(error: Throwable): String {
    var current: Throwable = error
    while (current.cause != null && current is java.lang.reflect.InvocationTargetException) {
      current = current.cause!!
    }
    val message = current.message
    return if (message.isNullOrBlank()) current.toString() else message
  }

  private companion object {
    // Keep in sync with FlutterFirebaseMessagingPlugin.PERMISSIONS_PREFERENCES_FILE.
    const val MESSAGING_PERMISSIONS_PREFERENCES =
        "io.flutter.plugins.firebase.messaging.permissions"
    const val EMULATOR_HOST_LOOPBACK = "10.0.2.2"
    const val ADB_SERVER_PORT = 5037
    const val ADB_TIMEOUT_MS = 5000
  }
}
