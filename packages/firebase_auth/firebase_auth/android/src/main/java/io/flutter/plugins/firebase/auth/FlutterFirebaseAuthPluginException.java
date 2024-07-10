/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.auth;

import androidx.annotation.Nullable;
import com.google.firebase.FirebaseApiNotAvailableException;
import com.google.firebase.FirebaseNetworkException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseAuthMultiFactorException;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;
import com.google.firebase.auth.FirebaseAuthWeakPasswordException;
import com.google.firebase.auth.MultiFactorInfo;
import com.google.firebase.auth.MultiFactorResolver;
import com.google.firebase.auth.MultiFactorSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class FlutterFirebaseAuthPluginException {

  static GeneratedAndroidFirebaseAuth.FlutterError parserExceptionToFlutter(
      @Nullable Exception nativeException) {
    if (nativeException == null) {
      return new GeneratedAndroidFirebaseAuth.FlutterError("UNKNOWN", null, null);
    }
    String code = "UNKNOWN";

    String message = nativeException.getMessage();
    Map<String, Object> additionalData = new HashMap<>();

    if (nativeException instanceof FirebaseAuthMultiFactorException) {
      final FirebaseAuthMultiFactorException multiFactorException =
          (FirebaseAuthMultiFactorException) nativeException;
      Map<String, Object> output = new HashMap<>();

      MultiFactorResolver multiFactorResolver = multiFactorException.getResolver();
      final List<MultiFactorInfo> hints = multiFactorResolver.getHints();

      final MultiFactorSession session = multiFactorResolver.getSession();
      final String sessionId = UUID.randomUUID().toString();
      FlutterFirebaseMultiFactor.multiFactorSessionMap.put(sessionId, session);

      final String resolverId = UUID.randomUUID().toString();
      FlutterFirebaseMultiFactor.multiFactorResolverMap.put(resolverId, multiFactorResolver);

      final List<List<Object>> pigeonHints = PigeonParser.multiFactorInfoToMap(hints);

      output.put(
          Constants.APP_NAME,
          multiFactorException.getResolver().getFirebaseAuth().getApp().getName());

      output.put(Constants.MULTI_FACTOR_HINTS, pigeonHints);

      output.put(Constants.MULTI_FACTOR_SESSION_ID, sessionId);
      output.put(Constants.MULTI_FACTOR_RESOLVER_ID, resolverId);

      return new GeneratedAndroidFirebaseAuth.FlutterError(
          multiFactorException.getErrorCode(), multiFactorException.getLocalizedMessage(), output);
    }

    if (nativeException instanceof FirebaseNetworkException
        || (nativeException.getCause() != null
            && nativeException.getCause() instanceof FirebaseNetworkException)) {
      return new GeneratedAndroidFirebaseAuth.FlutterError(
          "network-request-failed",
          "A network error (such as timeout, interrupted connection or unreachable host) has occurred.",
          null);
    }

    if (nativeException instanceof FirebaseApiNotAvailableException
        || (nativeException.getCause() != null
            && nativeException.getCause() instanceof FirebaseApiNotAvailableException)) {
      return new GeneratedAndroidFirebaseAuth.FlutterError(
          "api-not-available", "The requested API is not available.", null);
    }

    if (nativeException instanceof FirebaseTooManyRequestsException
        || (nativeException.getCause() != null
            && nativeException.getCause() instanceof FirebaseTooManyRequestsException)) {
      return new GeneratedAndroidFirebaseAuth.FlutterError(
          "too-many-requests",
          "We have blocked all requests from this device due to unusual activity. Try again later.",
          null);
    }

    // Manual message overrides to match other platforms.
    if (nativeException.getMessage() != null
        && nativeException
            .getMessage()
            .startsWith("Cannot create PhoneAuthCredential without either verificationProof")) {
      return new GeneratedAndroidFirebaseAuth.FlutterError(
          "invalid-verification-code",
          "The verification ID used to create the phone auth credential is invalid.",
          null);
    }

    if (message != null
        && message.contains("User has already been linked to the given provider.")) {
      return FlutterFirebaseAuthPluginException.alreadyLinkedProvider();
    }

    if (nativeException instanceof FirebaseAuthException) {
      code = ((FirebaseAuthException) nativeException).getErrorCode();
    }

    if (nativeException instanceof FirebaseAuthWeakPasswordException) {
      message = ((FirebaseAuthWeakPasswordException) nativeException).getReason();
    }

    if (nativeException instanceof FirebaseAuthUserCollisionException) {
      String email = ((FirebaseAuthUserCollisionException) nativeException).getEmail();

      if (email != null) {
        additionalData.put("email", email);
      }

      AuthCredential authCredential =
          ((FirebaseAuthUserCollisionException) nativeException).getUpdatedCredential();

      if (authCredential != null) {
        additionalData.put("authCredential", PigeonParser.parseAuthCredential(authCredential));
      }
    }

    return new GeneratedAndroidFirebaseAuth.FlutterError(code, message, additionalData);
  }

  static GeneratedAndroidFirebaseAuth.FlutterError noUser() {
    return new GeneratedAndroidFirebaseAuth.FlutterError(
        "NO_CURRENT_USER", "No user currently signed in.", null);
  }

  static GeneratedAndroidFirebaseAuth.FlutterError invalidCredential() {
    return new GeneratedAndroidFirebaseAuth.FlutterError(
        "INVALID_CREDENTIAL",
        "The supplied auth credential is malformed, has expired or is not currently supported.",
        null);
  }

  static GeneratedAndroidFirebaseAuth.FlutterError noSuchProvider() {
    return new GeneratedAndroidFirebaseAuth.FlutterError(
        "NO_SUCH_PROVIDER", "User was not linked to an account with the given provider.", null);
  }

  static GeneratedAndroidFirebaseAuth.FlutterError alreadyLinkedProvider() {
    return new GeneratedAndroidFirebaseAuth.FlutterError(
        "PROVIDER_ALREADY_LINKED", "User has already been linked to the given provider.", null);
  }
}
