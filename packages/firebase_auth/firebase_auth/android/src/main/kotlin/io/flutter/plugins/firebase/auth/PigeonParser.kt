/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import android.net.Uri
import com.google.firebase.auth.ActionCodeEmailInfo
import com.google.firebase.auth.ActionCodeResult
import com.google.firebase.auth.ActionCodeSettings
import com.google.firebase.auth.AdditionalUserInfo
import com.google.firebase.auth.AuthCredential
import com.google.firebase.auth.AuthResult
import com.google.firebase.auth.EmailAuthProvider
import com.google.firebase.auth.FacebookAuthProvider
import com.google.firebase.auth.FirebaseAuthProvider
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GetTokenResult
import com.google.firebase.auth.GithubAuthProvider
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.auth.MultiFactorInfo
import com.google.firebase.auth.OAuthCredential
import com.google.firebase.auth.OAuthProvider
import com.google.firebase.auth.PhoneAuthProvider
import com.google.firebase.auth.PhoneMultiFactorInfo
import com.google.firebase.auth.PlayGamesAuthProvider
import com.google.firebase.auth.TwitterAuthProvider
import com.google.firebase.auth.UserInfo

object PigeonParser {
  fun manuallyToList(pigeonUserDetails: InternalUserDetails): List<Any?> {
    return listOf(pigeonUserDetails.userInfo.toList(), pigeonUserDetails.providerData)
  }

  fun parseAuthResult(authResult: AuthResult): InternalUserCredential {
    return InternalUserCredential(
        additionalUserInfo = parseAdditionalUserInfo(authResult.additionalUserInfo),
        credential = parseAuthCredential(authResult.credential),
        user = parseFirebaseUser(authResult.user))
  }

  private fun parseAdditionalUserInfo(
      additionalUserInfo: AdditionalUserInfo?
  ): InternalAdditionalUserInfo? {
    if (additionalUserInfo == null) {
      return null
    }

    return InternalAdditionalUserInfo(
        isNewUser = additionalUserInfo.isNewUser,
        profile = additionalUserInfo.profile as Map<String?, Any?>?,
        providerId = additionalUserInfo.providerId,
        username = additionalUserInfo.username)
  }

  fun parseAuthCredential(authCredential: AuthCredential?): InternalAuthCredential? {
    if (authCredential == null) {
      return null
    }

    val authCredentialHashCode = authCredential.hashCode()
    FlutterFirebaseAuthPlugin.authCredentials[authCredentialHashCode] = authCredential

    return InternalAuthCredential(
        providerId = authCredential.provider,
        signInMethod = authCredential.signInMethod,
        nativeId = authCredentialHashCode.toLong(),
        accessToken = (authCredential as? OAuthCredential)?.accessToken)
  }

  fun parseFirebaseUser(firebaseUser: FirebaseUser?): InternalUserDetails? {
    if (firebaseUser == null) {
      return null
    }

    val userMetadata = firebaseUser.metadata
    val userInfo =
        InternalUserInfo(
            displayName = firebaseUser.displayName,
            email = firebaseUser.email,
            isEmailVerified = firebaseUser.isEmailVerified,
            isAnonymous = firebaseUser.isAnonymous,
            creationTimestamp = userMetadata?.creationTimestamp,
            lastSignInTimestamp = userMetadata?.lastSignInTimestamp,
            phoneNumber = firebaseUser.phoneNumber,
            photoUrl = parsePhotoUrl(firebaseUser.photoUrl),
            uid = firebaseUser.uid,
            tenantId = firebaseUser.tenantId)

    return InternalUserDetails(
        userInfo = userInfo, providerData = parseUserInfoList(firebaseUser.providerData))
  }

  private fun parseUserInfoList(userInfoList: List<UserInfo>?): List<Map<Any?, Any?>?> {
    val output = ArrayList<Map<Any?, Any?>?>()
    if (userInfoList == null) {
      return output
    }

    for (userInfo in ArrayList(userInfoList)) {
      if (userInfo == null) {
        continue
      }
      if (FirebaseAuthProvider.PROVIDER_ID != userInfo.providerId) {
        output.add(parseUserInfoToMap(userInfo))
      }
    }

    return output
  }

  private fun parseUserInfoToMap(userInfo: UserInfo): Map<Any?, Any?> {
    return mapOf(
        "displayName" to userInfo.displayName,
        "email" to userInfo.email,
        "isEmailVerified" to userInfo.isEmailVerified,
        "phoneNumber" to userInfo.phoneNumber,
        "photoUrl" to parsePhotoUrl(userInfo.photoUrl),
        "uid" to (userInfo.uid ?: ""),
        "providerId" to userInfo.providerId,
        "isAnonymous" to false)
  }

  private fun parsePhotoUrl(photoUri: Uri?): String? {
    if (photoUri == null) {
      return null
    }

    val photoUrl = photoUri.toString()
    return if (photoUrl == "") null else photoUrl
  }

  fun getCredential(credentialMap: Map<String?, Any?>): AuthCredential? {
    if (credentialMap[Constants.TOKEN] != null) {
      val token = (credentialMap[Constants.TOKEN] as Number).toInt()
      return FlutterFirebaseAuthPlugin.authCredentials[token]
          ?: throw FlutterFirebaseAuthPluginException.invalidCredential()
    }

    val signInMethod = credentialMap[Constants.SIGN_IN_METHOD] as String
    val secret = credentialMap[Constants.SECRET] as String?
    val idToken = credentialMap[Constants.ID_TOKEN] as String?
    val accessToken = credentialMap[Constants.ACCESS_TOKEN] as String?
    val rawNonce = credentialMap[Constants.RAW_NONCE] as String?

    return when (signInMethod) {
      Constants.SIGN_IN_METHOD_PASSWORD ->
          EmailAuthProvider.getCredential(credentialMap[Constants.EMAIL] as String, secret!!)
      Constants.SIGN_IN_METHOD_EMAIL_LINK ->
          EmailAuthProvider.getCredentialWithLink(
              credentialMap[Constants.EMAIL] as String,
              credentialMap[Constants.EMAIL_LINK] as String)
      Constants.SIGN_IN_METHOD_FACEBOOK -> FacebookAuthProvider.getCredential(accessToken!!)
      Constants.SIGN_IN_METHOD_GOOGLE -> GoogleAuthProvider.getCredential(idToken, accessToken)
      Constants.SIGN_IN_METHOD_TWITTER -> TwitterAuthProvider.getCredential(accessToken!!, secret!!)
      Constants.SIGN_IN_METHOD_GITHUB -> GithubAuthProvider.getCredential(accessToken!!)
      Constants.SIGN_IN_METHOD_PHONE -> {
        val verificationId = credentialMap[Constants.VERIFICATION_ID] as String
        val smsCode = credentialMap[Constants.SMS_CODE] as String
        PhoneAuthProvider.getCredential(verificationId, smsCode)
      }
      Constants.SIGN_IN_METHOD_OAUTH -> {
        val providerId = credentialMap[Constants.PROVIDER_ID] as String
        val builder = OAuthProvider.newCredentialBuilder(providerId)
        if (accessToken != null) {
          builder.setAccessToken(accessToken)
        }
        if (rawNonce == null) {
          builder.setIdToken(idToken!!)
        } else {
          builder.setIdTokenWithRawNonce(idToken!!, rawNonce)
        }
        builder.build()
      }
      Constants.SIGN_IN_METHOD_PLAY_GAMES -> {
        val serverAuthCode = credentialMap[Constants.SERVER_AUTH_CODE] as String
        PlayGamesAuthProvider.getCredential(serverAuthCode)
      }
      else -> null
    }
  }

  fun getActionCodeSettings(
      pigeonActionCodeSettings: InternalActionCodeSettings
  ): ActionCodeSettings {
    val builder = ActionCodeSettings.newBuilder()
    builder.setUrl(pigeonActionCodeSettings.url)

    if (pigeonActionCodeSettings.dynamicLinkDomain != null) {
      builder.setDynamicLinkDomain(pigeonActionCodeSettings.dynamicLinkDomain)
    }

    if (pigeonActionCodeSettings.linkDomain != null) {
      builder.setLinkDomain(pigeonActionCodeSettings.linkDomain)
    }

    builder.setHandleCodeInApp(pigeonActionCodeSettings.handleCodeInApp)

    if (pigeonActionCodeSettings.androidPackageName != null) {
      builder.setAndroidPackageName(
          pigeonActionCodeSettings.androidPackageName,
          pigeonActionCodeSettings.androidInstallApp,
          pigeonActionCodeSettings.androidMinimumVersion)
    }

    if (pigeonActionCodeSettings.iOSBundleId != null) {
      builder.setIOSBundleId(pigeonActionCodeSettings.iOSBundleId)
    }

    return builder.build()
  }

  fun multiFactorInfoToPigeon(hints: List<MultiFactorInfo>): List<InternalMultiFactorInfo> {
    val pigeonHints = ArrayList<InternalMultiFactorInfo>()
    for (info in hints) {
      if (info is PhoneMultiFactorInfo) {
        pigeonHints.add(
            InternalMultiFactorInfo(
                phoneNumber = info.phoneNumber,
                displayName = info.displayName,
                enrollmentTimestamp = info.enrollmentTimestamp.toDouble(),
                uid = info.uid,
                factorId = info.factorId))
      } else {
        pigeonHints.add(
            InternalMultiFactorInfo(
                displayName = info.displayName,
                enrollmentTimestamp = info.enrollmentTimestamp.toDouble(),
                uid = info.uid,
                factorId = info.factorId))
      }
    }
    return pigeonHints
  }

  fun multiFactorInfoToMap(hints: List<MultiFactorInfo>): List<List<Any?>> {
    val pigeonHints = ArrayList<List<Any?>>()
    for (info in multiFactorInfoToPigeon(hints)) {
      pigeonHints.add(info.toList())
    }
    return pigeonHints
  }

  fun parseActionCodeResult(actionCodeResult: ActionCodeResult): InternalActionCodeInfo {
    val operation =
        when (actionCodeResult.operation) {
          ActionCodeResult.PASSWORD_RESET -> ActionCodeInfoOperation.PASSWORD_RESET
          ActionCodeResult.VERIFY_EMAIL -> ActionCodeInfoOperation.VERIFY_EMAIL
          ActionCodeResult.RECOVER_EMAIL -> ActionCodeInfoOperation.RECOVER_EMAIL
          ActionCodeResult.SIGN_IN_WITH_EMAIL_LINK -> ActionCodeInfoOperation.EMAIL_SIGN_IN
          ActionCodeResult.VERIFY_BEFORE_CHANGE_EMAIL ->
              ActionCodeInfoOperation.VERIFY_AND_CHANGE_EMAIL
          ActionCodeResult.REVERT_SECOND_FACTOR_ADDITION ->
              ActionCodeInfoOperation.REVERT_SECOND_FACTOR_ADDITION
          else -> ActionCodeInfoOperation.UNKNOWN
        }

    val actionCodeInfo = actionCodeResult.info
    val data =
        if (actionCodeInfo != null &&
            (actionCodeResult.operation == ActionCodeResult.VERIFY_EMAIL ||
                actionCodeResult.operation == ActionCodeResult.PASSWORD_RESET)) {
          InternalActionCodeInfoData(email = actionCodeInfo.email)
        } else if (actionCodeResult.operation == ActionCodeResult.RECOVER_EMAIL ||
            actionCodeResult.operation == ActionCodeResult.VERIFY_BEFORE_CHANGE_EMAIL) {
          val actionCodeEmailInfo = actionCodeInfo as ActionCodeEmailInfo
          InternalActionCodeInfoData(
              email = actionCodeEmailInfo.email, previousEmail = actionCodeEmailInfo.previousEmail)
        } else {
          InternalActionCodeInfoData()
        }

    return InternalActionCodeInfo(operation = operation, data = data)
  }

  fun parseTokenResult(tokenResult: GetTokenResult): InternalIdTokenResult {
    return InternalIdTokenResult(
        token = tokenResult.token,
        signInProvider = tokenResult.signInProvider,
        authTimestamp = tokenResult.authTimestamp * 1000,
        expirationTimestamp = tokenResult.expirationTimestamp * 1000,
        issuedAtTimestamp = tokenResult.issuedAtTimestamp * 1000,
        claims = tokenResult.claims as Map<String?, Any?>?,
        signInSecondFactor = tokenResult.signInSecondFactor)
  }
}
