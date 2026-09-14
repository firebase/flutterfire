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
import java.util.UUID

object FlutterFirebaseAuthPluginException {
  fun parserExceptionToFlutter(nativeException: Exception?): FlutterError {
    if (nativeException == null) {
      return FlutterError("UNKNOWN", null, null)
    }
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
      return FlutterError(
          "network-request-failed",
          "A network error (such as timeout, interrupted connection or unreachable host) has occurred.",
          null)
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
