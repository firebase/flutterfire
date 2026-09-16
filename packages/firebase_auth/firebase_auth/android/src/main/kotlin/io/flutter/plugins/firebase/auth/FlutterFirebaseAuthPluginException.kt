/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import com.google.firebase.FirebaseApiNotAvailableException
import com.google.firebase.FirebaseNetworkException
import com.google.firebase.FirebaseTooManyRequestsException
import com.google.firebase.auth.FirebaseAuthException
import com.google.firebase.auth.FirebaseAuthMultiFactorException
import com.google.firebase.auth.FirebaseAuthUserCollisionException
import com.google.firebase.auth.FirebaseAuthWeakPasswordException
import java.io.IOException
import java.util.UUID
import java.util.concurrent.ExecutionException

object FlutterFirebaseAuthPluginException {
  /** The wrapper the Android SDK puts around a failure it has no code for. */
  private const val INTERNAL_ERROR_PREFIX = "An internal error has occurred."

  /**
   * Phrases that only ever describe a transport failure. Matched inside the wrapper's brackets,
   * never against arbitrary text, and never widened without a production message that needs it.
   */
  private val IO_MESSAGE_FRAGMENTS =
      arrayOf(
          "unexpected end of stream",
          "Unable to resolve host",
          "Failed to connect",
          "Connection reset",
          "Network is unreachable",
          "Software caused connection abort",
          "timed out",
          "SSL",
          "Broken pipe")

  /**
   * True when the exception, or anything it was caused by, is an [IOException]. Walks at most five
   * levels, so a cause chain that loops cannot spin here.
   */
  private fun isIoFailure(throwable: Throwable?): Boolean {
    var current = throwable
    var depth = 0
    while (current != null && depth < 5) {
      if (current is IOException) {
        return true
      }
      val cause = current.cause
      if (cause === current) {
        break
      }
      current = cause
      depth++
    }
    return false
  }

  /**
   * True when the message is the SDK's "internal error" wrapper and what it wrapped reads as an IO
   * failure. Only the text between the brackets is examined.
   */
  private fun isWrappedIoMessage(message: String?): Boolean {
    if (message == null || !message.startsWith(INTERNAL_ERROR_PREFIX)) {
      return false
    }
    val open = message.indexOf('[')
    val close = message.lastIndexOf(']')
    if (open < 0 || close < open) {
      return false
    }
    val wrapped = message.substring(open + 1, close)
    return IO_MESSAGE_FRAGMENTS.any { wrapped.contains(it) }
  }

  private fun networkRequestFailed(): FlutterError {
    return FlutterError(
        "network-request-failed",
        "A network error (such as timeout, interrupted connection or unreachable host) has occurred.",
        null)
  }

  fun parserExceptionToFlutter(rawException: Exception?): FlutterError {
    if (rawException == null) {
      return FlutterError("UNKNOWN", null, null)
    }
    // Tasks.await() reports a failed Task as an ExecutionException wrapping the
    // Task's own exception, so the FirebaseAuthException carrying the error
    // code is the cause. Unwrap it, otherwise every such failure reaches Dart
    // as "unknown".
    val nativeException =
        (rawException as? ExecutionException)?.cause as? Exception ?: rawException
    var code = "UNKNOWN"
    var message = nativeException.message
    val additionalData = HashMap<String, Any?>()

    if (nativeException is FirebaseAuthMultiFactorException) {
      val output = HashMap<String, Any?>()
      val multiFactorResolver = nativeException.resolver
      val hints = multiFactorResolver.hints
      val session = multiFactorResolver.session
      val sessionId = UUID.randomUUID().toString()
      FlutterFirebaseMultiFactor.multiFactorSessionMap[sessionId] = session

      val resolverId = UUID.randomUUID().toString()
      FlutterFirebaseMultiFactor.multiFactorResolverMap[resolverId] = multiFactorResolver

      val pigeonHints = PigeonParser.multiFactorInfoToMap(hints)

      output[Constants.APP_NAME] = nativeException.resolver.firebaseAuth.app.name
      output[Constants.MULTI_FACTOR_HINTS] = pigeonHints
      output[Constants.MULTI_FACTOR_SESSION_ID] = sessionId
      output[Constants.MULTI_FACTOR_RESOLVER_ID] = resolverId

      return FlutterError(nativeException.errorCode, nativeException.localizedMessage, output)
    }

    if (nativeException is FirebaseNetworkException ||
        nativeException.cause is FirebaseNetworkException) {
      return networkRequestFailed()
    }

    // A token refresh that loses the connection does not always arrive as a
    // FirebaseNetworkException. Production (2026-09-05) showed two other shapes,
    // both reaching Dart as [firebase_auth/unknown]:
    //
    //   An internal error has occurred.
    //       [ unexpected end of stream on com.android.okhttp.Address@f7f69f0a ]
    //   Failure in SSL library, usually a protocol error
    //       error:100000d7:SSL routines:OPENSSL_internal:SSL_HANDSHAKE_FAILURE ...
    //
    // The second is the IOException itself, so the type check comes first: it
    // reads what the exception *is*, which covers SSLException,
    // SocketTimeoutException, UnknownHostException and ConnectException alike
    // without depending on anyone's wording.
    if (isIoFailure(nativeException)) {
      return networkRequestFailed()
    }

    // The first shape is not reachable by type. The Android SDK wraps the IO
    // failure in a plain FirebaseException, keeps its text inside the brackets
    // and drops the cause — verified on the emulator, where the chain is one
    // level deep and getCause() is null. Only the message survives, so this arm
    // reads it, and is kept narrow on purpose: the exact wrapper prefix, a fixed
    // list of IO phrases, matched only inside the brackets, and never against a
    // FirebaseAuthException, which carries a real error code that must never be
    // relabelled.
    if (nativeException !is FirebaseAuthException && isWrappedIoMessage(nativeException.message)) {
      return networkRequestFailed()
    }

    if (nativeException is FirebaseApiNotAvailableException ||
        nativeException.cause is FirebaseApiNotAvailableException) {
      return FlutterError("api-not-available", "The requested API is not available.", null)
    }

    if (nativeException is FirebaseTooManyRequestsException ||
        nativeException.cause is FirebaseTooManyRequestsException) {
      return FlutterError(
          "too-many-requests",
          "We have blocked all requests from this device due to unusual activity. Try again later.",
          null)
    }

    if (nativeException.message != null &&
        nativeException.message!!.startsWith(
            "Cannot create PhoneAuthCredential without either verificationProof")) {
      return FlutterError(
          "invalid-verification-code",
          "The verification ID used to create the phone auth credential is invalid.",
          null)
    }

    if (message != null &&
        message.contains("User has already been linked to the given provider.")) {
      return alreadyLinkedProvider()
    }

    if (nativeException is FirebaseAuthException) {
      code = nativeException.errorCode
    }

    if (nativeException is FirebaseAuthWeakPasswordException) {
      message = nativeException.reason
    }

    if (nativeException is FirebaseAuthUserCollisionException) {
      val email = nativeException.email
      if (email != null) {
        additionalData["email"] = email
      }

      val authCredential = nativeException.updatedCredential
      if (authCredential != null) {
        additionalData["authCredential"] = PigeonParser.parseAuthCredential(authCredential)
      }
    }

    return FlutterError(code, message, additionalData)
  }

  fun noUser(): FlutterError {
    return FlutterError("NO_CURRENT_USER", "No user currently signed in.", null)
  }

  fun invalidCredential(): FlutterError {
    return FlutterError(
        "INVALID_CREDENTIAL",
        "The supplied auth credential is malformed, has expired or is not currently supported.",
        null)
  }

  fun noSuchProvider(): FlutterError {
    return FlutterError(
        "NO_SUCH_PROVIDER", "User was not linked to an account with the given provider.", null)
  }

  fun alreadyLinkedProvider(): FlutterError {
    return FlutterError(
        "PROVIDER_ALREADY_LINKED", "User has already been linked to the given provider.", null)
  }
}
