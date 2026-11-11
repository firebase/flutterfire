package io.flutter.plugins.firebase.messaging.example

import android.app.ActivityManager
import android.app.KeyguardManager
import android.app.Notification
import android.app.PendingIntent
import android.app.job.JobScheduler
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingReceiver
import io.flutter.view.FlutterCallbackInformation
import java.io.FileInputStream
import java.io.InputStream
import java.io.OutputStream
import java.net.InetSocketAddress
import java.net.Socket
import java.nio.charset.StandardCharsets

class MainActivity : FlutterActivity() {
  private var secondEngine: FlutterEngine? = null
  private val secondEngineMessages = mutableListOf<String>()

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // Test-only channel that hands FCM messages to the plugin's receiver like
    // Google Play services does when pushes arrive, without needing FCM.
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tests/remote_notifications")
        .setMethodCallHandler { call, result ->
          when (call.method) {
            "deliverToReceiver" -> {
              val messageIds = call.argument<List<String>>("messageIds")
              if (messageIds == null) {
                result.error("INVALID_ARG", "messageIds is required", null)
                return@setMethodCallHandler
              }
              val messageType = call.argument<String>("messageType")
              val foreground = unlockAndCheckForeground()
              val receiver = FlutterFirebaseMessagingReceiver()
              for (messageId in messageIds) {
                val intent =
                    Intent("com.google.android.c2dm.intent.RECEIVE").apply {
                      putExtra("google.message_id", messageId)
                      putExtra("from", "e2e")
                      putExtra("test", "remote-notification-delivery")
                      messageType?.let { putExtra("message_type", it) }
                    }
                receiver.onReceive(applicationContext, intent)
              }
              // Keep the main thread busy while the receiver hands the messages over from its
              // own thread, as when pushes arrive faster than the main thread runs.
              Thread.sleep(500)
              result.success(mapOf("foreground" to foreground))
            }
            "dismissFirebaseNotification" -> {
              val foreground = unlockAndCheckForeground()
              val deleteIntent =
                  try {
                    firebaseNotificationDeleteIntent()
                  } catch (e: Exception) {
                    result.error("SDK_CHANGED", errorMessage(e), null)
                    return@setMethodCallHandler
                  }
              if (deleteIntent == null) {
                result.error("SDK_CHANGED", "firebase-messaging set no delete intent", null)
                return@setMethodCallHandler
              }
              // Android sends the delete intent when the user dismisses the notification. With
              // a callback, the broadcast is ordered: the callback runs once every receiver has
              // finished with it, and gets the result code Firebase's own receiver set.
              try {
                deleteIntent.send(
                    applicationContext,
                    0,
                    null,
                    { _, _, resultCode, _, _ ->
                      result.success(mapOf("foreground" to foreground, "resultCode" to resultCode))
                    },
                    Handler(Looper.getMainLooper()),
                )
              } catch (e: PendingIntent.CanceledException) {
                result.error("SEND_FAILED", errorMessage(e), null)
              }
            }
            "startSecondEngine" -> {
              val callbackHandle = call.argument<Number>("callbackHandle")
              val callback =
                  callbackHandle?.let {
                    FlutterCallbackInformation.lookupCallbackInformation(it.toLong())
                  }
              if (callback == null) {
                result.error("INVALID_ARG", "a valid callbackHandle is required", null)
                return@setMethodCallHandler
              }
              startSecondEngine(callback, result)
            }
            "secondEngineMessages" -> result.success(secondEngineMessages.toList())
            "stopSecondEngine" -> {
              secondEngine?.destroy()
              secondEngine = null
              result.success(null)
            }
            "backgroundHandlerEnabled" -> result.success(!backgroundHandlerDisabled())
            "probeBackgroundDelivery" -> {
              val messageId = call.argument<String>("messageId")
              if (messageId.isNullOrEmpty()) {
                result.error("INVALID_ARG", "messageId is required", null)
                return@setMethodCallHandler
              }
              val hasPlugin = call.hasArgument("pluginHandle")
              val hasUser = call.hasArgument("userHandle")
              if (hasPlugin != hasUser) {
                result.error(
                    "INVALID_ARG",
                    "pluginHandle and userHandle are set together",
                    null,
                )
                return@setMethodCallHandler
              }
              val pluginHandle = call.argument<Number>("pluginHandle")?.toLong()
              val userHandle = call.argument<Number>("userHandle")?.toLong()
              // Home is delivered after this handler returns, so the probe waits
              // on another thread until the process is no longer in the foreground.
              Thread {
                    try {
                      result.success(
                          probeBackgroundDelivery(messageId, pluginHandle, userHandle),
                      )
                    } catch (e: Exception) {
                      result.error("PROBE_FAILED", errorMessage(e), null)
                    }
                  }
                  .start()
              try {
                executeShell("input keyevent 3")
              } catch (_: Exception) {
                // The probe reports background=false when the app stays in front.
              }
            }
            else -> result.notImplemented()
          }
        }

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

  /// Sends a data message the way Play services does, after the app has left
  /// the foreground, and reports whether the background service started.
  private fun probeBackgroundDelivery(
      messageId: String,
      pluginHandle: Long?,
      userHandle: Long?,
  ): Map<String, Any?> {
    if (pluginHandle != null && userHandle != null) {
      callbackPreferences()
          .edit()
          .putLong(CALLBACK_HANDLE_KEY, pluginHandle)
          .putLong(USER_CALLBACK_HANDLE_KEY, userHandle)
          .commit()
    } else {
      callbackPreferences().edit().clear().commit()
    }
    try {
      executeShell("logcat -c")
    } catch (_: Exception) {
      // A missing clear shows up as receiverRan=false.
    }
    val background = waitUntil { !isAppInForeground() }
    if (background) {
      val intent =
          Intent("com.google.android.c2dm.intent.RECEIVE").apply {
            putExtra("google.message_id", messageId)
            putExtra("from", "e2e")
            putExtra("test", "background-handler-gate")
          }
      FlutterFirebaseMessagingReceiver().onReceive(applicationContext, intent)
      Thread.sleep(500)
    }
    val log =
        try {
          captureHostAdbShell(
              "logcat -d -s FLTFireMsgReceiver:D FLTFireMsgService:V",
          )
        } catch (_: Exception) {
          ""
        }
    val report =
        mapOf(
            "background" to background,
            "receiverRan" to log.contains("broadcast received for message"),
            "serviceRan" to log.contains("FLTFireMsgService"),
            "jobScheduled" to backgroundJobPending(),
            "serviceRunning" to backgroundServiceRunning(),
            "pluginHandle" to callbackPreferences().getLong(CALLBACK_HANDLE_KEY, 0L),
            "userHandle" to callbackPreferences().getLong(USER_CALLBACK_HANDLE_KEY, 0L),
            "handlerEnabled" to !backgroundHandlerDisabled(),
        )
    try {
      executeShell(
          "am start -n $packageName/io.flutter.plugins.firebase.messaging.example.MainActivity",
      )
      waitUntil { isAppInForeground() }
    } catch (_: Exception) {
      // The Dart side still receives the report.
    }
    return report
  }

  private fun callbackPreferences() =
      getSharedPreferences(CALLBACK_PREFERENCES, Context.MODE_PRIVATE)

  private fun backgroundHandlerDisabled(): Boolean {
    val info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
    val raw = info.metaData?.get(BACKGROUND_HANDLER_METADATA_KEY) ?: return false
    return when (raw) {
      is Boolean -> !raw
      is String -> raw.equals("false", ignoreCase = true)
      else -> false
    }
  }

  private fun backgroundJobPending(): Boolean {
    val scheduler = getSystemService(JobScheduler::class.java) ?: return false
    return scheduler.allPendingJobs.any { it.id == BACKGROUND_JOB_ID }
  }

  private fun backgroundServiceRunning(): Boolean {
    val manager = getSystemService(ActivityManager::class.java) ?: return false
    @Suppress("DEPRECATION")
    return manager.getRunningServices(Integer.MAX_VALUE).any {
      it.service.className == BACKGROUND_SERVICE_CLASS
    }
  }

  private fun waitUntil(condition: () -> Boolean): Boolean {
    repeat(50) {
      if (condition()) return true
      Thread.sleep(100)
    }
    return condition()
  }

  /// Dismisses the lock screen if needed: the receiver only sends messages to
  /// onMessage while the app is in the foreground. Returns whether it is.
  private fun unlockAndCheckForeground(): Boolean {
    if (!isAppInForeground()) {
      try {
        executeShell("wm dismiss-keyguard")
      } catch (_: Exception) {
        // Reported by the return value.
      }
      // The keyguard goes away asynchronously.
      for (attempt in 0 until 20) {
        if (isAppInForeground()) break
        Thread.sleep(100)
      }
    }
    return isAppInForeground()
  }

  /// The delete intent firebase-messaging sets on a notification it displays,
  /// which Android sends when the user dismisses the notification. Built by
  /// the SDK rather than by hand, so the test follows any change to that
  /// broadcast. The builder is hidden SDK API: reflection keeps a change to it
  /// from breaking the build, and fails only this test.
  private fun firebaseNotificationDeleteIntent(): PendingIntent? {
    // A notification message as FCM delivers it. The SDK only sets a delete
    // intent when analytics is enabled for the message (google.c.a.e).
    val data =
        Bundle().apply {
          putString("gcm.n.e", "1")
          putString("gcm.notification.title", "e2e")
          putString("google.c.a.e", "1")
        }
    val paramsClass = Class.forName("com.google.firebase.messaging.NotificationParams")
    val params = paramsClass.getConstructor(Bundle::class.java).newInstance(data)
    val info =
        Class.forName("com.google.firebase.messaging.CommonNotificationBuilder")
            .getMethod(
                "createNotificationInfo",
                Context::class.java,
                Context::class.java,
                paramsClass,
                String::class.java,
                Bundle::class.java,
            )
            .invoke(null, applicationContext, applicationContext, params, "e2e", Bundle())!!
    val builder = info.javaClass.getField("notificationBuilder").get(info)!!
    val notification = builder.javaClass.getMethod("build").invoke(builder) as Notification
    return notification.deleteIntent
  }

  private fun isAppInForeground(): Boolean {
    val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
    if (keyguard.isKeyguardLocked) return false
    val state = ActivityManager.RunningAppProcessInfo()
    ActivityManager.getMyMemoryState(state)
    return state.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
  }

  /// Starts another engine running `secondEngineMain` from the test, which
  /// listens to onMessage and reports what it receives. The messaging plugin
  /// is attached once its Dart runs, like an engine created after messages
  /// were received.
  private fun startSecondEngine(
      callback: FlutterCallbackInformation,
      result: MethodChannel.Result
  ) {
    secondEngine?.destroy()
    secondEngineMessages.clear()
    val engine = FlutterEngine(applicationContext, null, /* automaticallyRegisterPlugins= */ false)
    secondEngine = engine
    MethodChannel(engine.dartExecutor.binaryMessenger, "tests/second_engine")
        .setMethodCallHandler { call, reply ->
          when (call.method) {
            "ready" -> {
              engine.plugins.add(FlutterFirebaseMessagingPlugin())
              reply.success(null)
            }
            "listening" -> {
              reply.success(null)
              result.success(null)
            }
            "onMessage" -> {
              secondEngineMessages.add(call.arguments as String)
              reply.success(null)
            }
            else -> reply.notImplemented()
          }
        }
    // Looked up by callback handle: in test builds the root library is a
    // generated wrapper that only has `main`.
    engine.dartExecutor.executeDartCallback(
        DartExecutor.DartCallback(
            assets,
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            callback,
        ),
    )
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
    captureHostAdbShell(command)
  }

  private fun captureHostAdbShell(command: String): String {
    val output = arrayOfNulls<String>(1)
    val error = arrayOfNulls<Exception>(1)
    val thread = Thread {
      try {
        output[0] = executeHostAdbShellBlocking(command)
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
    return output[0] ?: ""
  }

  private fun executeHostAdbShellBlocking(command: String): String {
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
      val captured = StringBuilder()
      val buffer = ByteArray(1024)
      while (true) {
        val read = input.read(buffer)
        if (read < 0) {
          break
        }
        captured.append(String(buffer, 0, read, StandardCharsets.UTF_8))
      }
      return captured.toString()
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
    const val CALLBACK_PREFERENCES = "io.flutter.firebase.messaging.callback"
    const val CALLBACK_HANDLE_KEY = "callback_handle"
    const val USER_CALLBACK_HANDLE_KEY = "user_callback_handle"
    const val BACKGROUND_HANDLER_METADATA_KEY = "firebase_messaging_background_handler_enabled"
    const val BACKGROUND_JOB_ID = 2020
    const val BACKGROUND_SERVICE_CLASS =
        "io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService"
  }
}
