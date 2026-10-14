/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import com.google.firebase.auth.MultiFactor
import com.google.firebase.auth.MultiFactorAssertion
import com.google.firebase.auth.MultiFactorResolver
import com.google.firebase.auth.MultiFactorSession
import com.google.firebase.auth.PhoneAuthProvider
import com.google.firebase.auth.PhoneMultiFactorGenerator
import com.google.firebase.internal.api.FirebaseNoSignedInUserException
import java.util.UUID

class FlutterFirebaseMultiFactor : MultiFactorUserHostApi, MultiFactoResolverHostApi {
  @Throws(FirebaseNoSignedInUserException::class)
  fun getAppMultiFactor(app: AuthPigeonFirebaseApp): MultiFactor {
    val currentUser =
        FlutterFirebaseAuthUser.getCurrentUserFromPigeon(app)
            ?: throw FirebaseNoSignedInUserException("No user is signed in")
    val appMultiFactorUser = multiFactorUserMap.getOrPut(app.appName) { HashMap() }
    return appMultiFactorUser.getOrPut(currentUser.uid) { currentUser.multiFactor }
  }

  override fun enrollPhone(
      app: AuthPigeonFirebaseApp,
      assertion: InternalPhoneMultiFactorAssertion,
      displayName: String?,
      callback: (Result<Unit>) -> Unit
  ) {
    val multiFactor: MultiFactor
    try {
      multiFactor = getAppMultiFactor(app)
    } catch (e: FirebaseNoSignedInUserException) {
      callback(Result.failure(e))
      return
    }

    val credential =
        PhoneAuthProvider.getCredential(assertion.verificationId, assertion.verificationCode)
    val multiFactorAssertion = PhoneMultiFactorGenerator.getAssertion(credential)

    multiFactor.enroll(multiFactorAssertion, displayName).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(Unit))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun enrollTotp(
      app: AuthPigeonFirebaseApp,
      assertionId: String,
      displayName: String?,
      callback: (Result<Unit>) -> Unit
  ) {
    val multiFactor: MultiFactor
    try {
      multiFactor = getAppMultiFactor(app)
    } catch (e: FirebaseNoSignedInUserException) {
      callback(Result.failure(e))
      return
    }

    val multiFactorAssertion = multiFactorAssertionMap[assertionId]
    checkNotNull(multiFactorAssertion)
    multiFactor.enroll(multiFactorAssertion, displayName).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(Unit))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun getSession(
      app: AuthPigeonFirebaseApp,
      callback: (Result<InternalMultiFactorSession>) -> Unit
  ) {
    val multiFactor: MultiFactor
    try {
      multiFactor = getAppMultiFactor(app)
    } catch (e: FirebaseNoSignedInUserException) {
      callback(Result.failure(e))
      return
    }

    multiFactor.session.addOnCompleteListener { task ->
      if (task.isSuccessful) {
        val sessionResult = task.result
        val id = UUID.randomUUID().toString()
        multiFactorSessionMap[id] = sessionResult
        callback(Result.success(InternalMultiFactorSession(id)))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun unenroll(
      app: AuthPigeonFirebaseApp,
      factorUid: String,
      callback: (Result<Unit>) -> Unit
  ) {
    val multiFactor: MultiFactor
    try {
      multiFactor = getAppMultiFactor(app)
    } catch (e: FirebaseNoSignedInUserException) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(e)))
      return
    }

    multiFactor.unenroll(factorUid).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(Unit))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun getEnrolledFactors(
      app: AuthPigeonFirebaseApp,
      callback: (Result<List<InternalMultiFactorInfo>>) -> Unit
  ) {
    val multiFactor: MultiFactor
    try {
      multiFactor = getAppMultiFactor(app)
    } catch (e: FirebaseNoSignedInUserException) {
      callback(Result.failure(e))
      return
    }

    callback(Result.success(PigeonParser.multiFactorInfoToPigeon(multiFactor.enrolledFactors)))
  }

  override fun resolveSignIn(
      resolverId: String,
      assertion: InternalPhoneMultiFactorAssertion?,
      totpAssertionId: String?,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val resolver = multiFactorResolverMap[resolverId]
    if (resolver == null) {
      callback(
          Result.failure(
              FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                  Exception("Resolver not found"))))
      return
    }

    val multiFactorAssertion =
        if (assertion != null) {
          val credential =
              PhoneAuthProvider.getCredential(assertion.verificationId, assertion.verificationCode)
          PhoneMultiFactorGenerator.getAssertion(credential)
        } else {
          multiFactorAssertionMap[totpAssertionId]
        }

    resolver.resolveSignIn(multiFactorAssertion!!).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(PigeonParser.parseAuthResult(task.result)))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  companion object {
    val multiFactorUserMap: MutableMap<String, MutableMap<String, MultiFactor>> = HashMap()
    val multiFactorSessionMap: MutableMap<String, MultiFactorSession> = HashMap()
    val multiFactorResolverMap: MutableMap<String, MultiFactorResolver> = HashMap()
    val multiFactorAssertionMap: MutableMap<String, MultiFactorAssertion> = HashMap()
  }
}
