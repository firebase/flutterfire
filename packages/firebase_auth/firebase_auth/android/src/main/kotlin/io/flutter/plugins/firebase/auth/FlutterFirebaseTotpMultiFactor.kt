/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import com.google.firebase.auth.TotpMultiFactorGenerator
import com.google.firebase.auth.TotpSecret
import java.util.UUID

class FlutterFirebaseTotpMultiFactor : MultiFactorTotpHostApi {
  override fun generateSecret(sessionId: String, callback: (Result<InternalTotpSecret>) -> Unit) {
    val multiFactorSession = FlutterFirebaseMultiFactor.multiFactorSessionMap[sessionId]
    checkNotNull(multiFactorSession)
    TotpMultiFactorGenerator.generateSecret(multiFactorSession).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        val secret = task.result
        multiFactorSecret[secret.sharedSecretKey] = secret
        callback(
            Result.success(
                InternalTotpSecret(
                    codeIntervalSeconds = secret.codeIntervalSeconds.toLong(),
                    codeLength = secret.codeLength.toLong(),
                    secretKey = secret.sharedSecretKey,
                    hashingAlgorithm = secret.hashAlgorithm,
                    enrollmentCompletionDeadline = secret.enrollmentCompletionDeadline)))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun getAssertionForEnrollment(
      secretKey: String,
      oneTimePassword: String,
      callback: (Result<String>) -> Unit
  ) {
    val secret = multiFactorSecret[secretKey]
    checkNotNull(secret)
    val assertion = TotpMultiFactorGenerator.getAssertionForEnrollment(secret, oneTimePassword)
    val assertionId = UUID.randomUUID().toString()
    FlutterFirebaseMultiFactor.multiFactorAssertionMap[assertionId] = assertion
    callback(Result.success(assertionId))
  }

  override fun getAssertionForSignIn(
      enrollmentId: String,
      oneTimePassword: String,
      callback: (Result<String>) -> Unit
  ) {
    val assertion = TotpMultiFactorGenerator.getAssertionForSignIn(enrollmentId, oneTimePassword)
    val assertionId = UUID.randomUUID().toString()
    FlutterFirebaseMultiFactor.multiFactorAssertionMap[assertionId] = assertion
    callback(Result.success(assertionId))
  }

  companion object {
    val multiFactorSecret: MutableMap<String, TotpSecret> = HashMap()
  }
}
