// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.flutter.plugins.firebase.ai

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class FirebaseAIPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "plugins.flutter.io/firebase_ai")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformHeaders" -> {
                val headers = mapOf(
                    "X-Android-Package" to context.packageName,
                    "X-Android-Cert" to (getSigningCertFingerprint() ?: "")
                )
                result.success(headers)
            }
            else -> result.notImplemented()
        }
    }

    @OptIn(ExperimentalStdlibApi::class)
    private fun getSigningCertFingerprint(): String? {
        val packageName = context.packageName
        val signature = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val packageInfo = try {
                context.packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } catch (e: PackageManager.NameNotFoundException) {
                Log.e(TAG, "PackageManager couldn't find the package \"$packageName\"", e)
                return null
            }
            val signingInfo = packageInfo?.signingInfo ?: return null
            if (signingInfo.hasMultipleSigners()) {
                signingInfo.apkContentsSigners.firstOrNull()
            } else {
                signingInfo.signingCertificateHistory.lastOrNull()
            }
        } else {
            @Suppress("DEPRECATION")
            val packageInfo = try {
                context.packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES
                )
            } catch (e: PackageManager.NameNotFoundException) {
                Log.e(TAG, "PackageManager couldn't find the package \"$packageName\"", e)
                return null
            }
            @Suppress("DEPRECATION")
            packageInfo?.signatures?.firstOrNull()
        } ?: return null

        return try {
            val messageDigest = MessageDigest.getInstance("SHA-1")
            val digest = messageDigest.digest(signature.toByteArray())
            digest.toHexString(HexFormat.UpperCase)
        } catch (e: NoSuchAlgorithmException) {
            Log.w(TAG, "No support for SHA-1 algorithm found.", e)
            null
        }
    }

    companion object {
        private const val TAG = "FirebaseAIPlugin"
    }
}
