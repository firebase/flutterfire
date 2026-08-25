/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import android.app.Activity
import com.google.firebase.FirebaseException
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.MultiFactorSession
import com.google.firebase.auth.PhoneAuthCredential
import com.google.firebase.auth.PhoneAuthOptions
import com.google.firebase.auth.PhoneAuthProvider
import com.google.firebase.auth.PhoneAuthProvider.ForceResendingToken
import com.google.firebase.auth.PhoneMultiFactorInfo
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import java.util.Locale
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

class PhoneNumberVerificationStreamHandler(
    activity: Activity?,
    app: AuthPigeonFirebaseApp,
    request: InternalVerifyPhoneNumberRequest,
    private val multiFactorSession: MultiFactorSession?,
    private val multiFactorInfo: PhoneMultiFactorInfo?,
    private val onCredentialsListener: OnCredentialsListener
) : StreamHandler {
  fun interface OnCredentialsListener {
    fun onCredentialsReceived(credential: PhoneAuthCredential)
  }

  private val activityRef = AtomicReference<Activity?>(null)
  private val firebaseAuth: FirebaseAuth = FlutterFirebaseAuthPlugin.getAuthFromPigeon(app)
  private val phoneNumber: String? = request.phoneNumber
  private val timeout: Int = Math.toIntExact(request.timeout)
  private var autoRetrievedSmsCodeForTesting: String? = request.autoRetrievedSmsCodeForTesting
  private var forceResendingToken: Int? = request.forceResendingToken?.let { Math.toIntExact(it) }

  private var eventSink: EventSink? = null

  init {
    activityRef.set(activity)
  }

  override fun onListen(arguments: Any?, events: EventSink) {
    eventSink = events

    val callbacks =
        object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
          override fun onVerificationCompleted(phoneAuthCredential: PhoneAuthCredential) {
            val phoneAuthCredentialHashCode = phoneAuthCredential.hashCode()
            onCredentialsListener.onCredentialsReceived(phoneAuthCredential)

            val event: MutableMap<String, Any?> = HashMap()
            event[Constants.TOKEN] = phoneAuthCredentialHashCode

            if (phoneAuthCredential.smsCode != null) {
              event[Constants.SMS_CODE] = phoneAuthCredential.smsCode
            }

            event[Constants.NAME] = "Auth#phoneVerificationCompleted"

            eventSink?.success(event)
          }

          override fun onVerificationFailed(e: FirebaseException) {
            val event: MutableMap<String, Any?> = HashMap()
            val error: MutableMap<String, Any?> = HashMap()
            val flutterError = FlutterFirebaseAuthPluginException.parserExceptionToFlutter(e)
            error["code"] =
                flutterError.code.replace("ERROR_", "").lowercase(Locale.ROOT).replace("_", "-")
            error["message"] = flutterError.message
            error["details"] = flutterError.details
            event["error"] = error
            event[Constants.NAME] = "Auth#phoneVerificationFailed"

            eventSink?.success(event)
          }

          override fun onCodeSent(verificationId: String, token: ForceResendingToken) {
            val forceResendingTokenHashCode = token.hashCode()
            forceResendingTokens[forceResendingTokenHashCode] = token

            val event: MutableMap<String, Any?> = HashMap()
            event[Constants.VERIFICATION_ID] = verificationId
            event[Constants.FORCE_RESENDING_TOKEN] = forceResendingTokenHashCode
            event[Constants.NAME] = "Auth#phoneCodeSent"

            eventSink?.success(event)
          }

          override fun onCodeAutoRetrievalTimeOut(verificationId: String) {
            val event: MutableMap<String, Any?> = HashMap()
            event[Constants.VERIFICATION_ID] = verificationId
            event[Constants.NAME] = "Auth#phoneCodeAutoRetrievalTimeout"

            eventSink?.success(event)
          }
        }

    if (autoRetrievedSmsCodeForTesting != null) {
      firebaseAuth.firebaseAuthSettings.setAutoRetrievedSmsCodeForPhoneNumber(
          phoneNumber, autoRetrievedSmsCodeForTesting)
    }

    val phoneAuthOptionsBuilder = PhoneAuthOptions.Builder(firebaseAuth)
    activityRef.get()?.let { phoneAuthOptionsBuilder.setActivity(it) }
    phoneAuthOptionsBuilder.setCallbacks(callbacks)

    if (phoneNumber != null) {
      phoneAuthOptionsBuilder.setPhoneNumber(phoneNumber)
    }
    if (multiFactorSession != null) {
      phoneAuthOptionsBuilder.setMultiFactorSession(multiFactorSession)
    }
    if (multiFactorInfo != null) {
      phoneAuthOptionsBuilder.setMultiFactorHint(multiFactorInfo)
    }
    phoneAuthOptionsBuilder.setTimeout(timeout.toLong(), TimeUnit.MILLISECONDS)

    val tokenKey = forceResendingToken
    if (tokenKey != null) {
      val storedToken = forceResendingTokens[tokenKey]
      if (storedToken != null) {
        phoneAuthOptionsBuilder.setForceResendingToken(storedToken)
      }
    }

    PhoneAuthProvider.verifyPhoneNumber(phoneAuthOptionsBuilder.build())
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
    activityRef.set(null)
  }

  companion object {
    private val forceResendingTokens = HashMap<Int, ForceResendingToken>()
  }
}
