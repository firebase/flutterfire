// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.auth

import android.app.Activity
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.AuthCredential
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.OAuthProvider
import com.google.firebase.auth.PhoneMultiFactorInfo
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry
import java.util.UUID

/** Flutter plugin for Firebase Auth. */
class FlutterFirebaseAuthPlugin :
    FlutterFirebasePlugin, FlutterPlugin, ActivityAware, FirebaseAuthHostApi {
  private var messenger: BinaryMessenger? = null
  private var channel: MethodChannel? = null
  private var activity: Activity? = null
  private val streamHandlers: MutableMap<EventChannel, StreamHandler> = HashMap()
  private val firebaseAuthUser = FlutterFirebaseAuthUser()
  private val firebaseMultiFactor = FlutterFirebaseMultiFactor()
  private val firebaseTotpMultiFactor = FlutterFirebaseTotpMultiFactor()
  private val firebaseTotpSecret = FlutterFirebaseTotpSecret()

  private fun initInstance(messenger: BinaryMessenger) {
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this)
    channel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
    FirebaseAuthHostApi.setUp(messenger, this)
    FirebaseAuthUserHostApi.setUp(messenger, firebaseAuthUser)
    MultiFactorUserHostApi.setUp(messenger, firebaseMultiFactor)
    MultiFactoResolverHostApi.setUp(messenger, firebaseMultiFactor)
    MultiFactorTotpHostApi.setUp(messenger, firebaseTotpMultiFactor)
    MultiFactorTotpSecretHostApi.setUp(messenger, firebaseTotpSecret)
    this.messenger = messenger
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    initInstance(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)

    val resolvedMessenger = checkNotNull(messenger)
    FirebaseAuthHostApi.setUp(resolvedMessenger, null)
    FirebaseAuthUserHostApi.setUp(resolvedMessenger, null)
    MultiFactorUserHostApi.setUp(resolvedMessenger, null)
    MultiFactoResolverHostApi.setUp(resolvedMessenger, null)
    MultiFactorTotpHostApi.setUp(resolvedMessenger, null)
    MultiFactorTotpSecretHostApi.setUp(resolvedMessenger, null)

    channel = null
    messenger = null
    removeEventListeners()
  }

  override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
    activity = activityPluginBinding.activity
    firebaseAuthUser.setActivity(activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
    firebaseAuthUser.setActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(
      activityPluginBinding: ActivityPluginBinding
  ) {
    activity = activityPluginBinding.activity
    firebaseAuthUser.setActivity(activity)
  }

  override fun onDetachedFromActivity() {
    activity = null
    firebaseAuthUser.setActivity(null)
  }

  private fun getActivity(): Activity? {
    return activity
  }

  override fun registerIdTokenListener(
      app: AuthPigeonFirebaseApp,
      callback: (Result<String>) -> Unit
  ) {
    try {
      val auth = getAuthFromPigeon(app)
      val handler = IdTokenChannelStreamHandler(auth)
      val name = "$METHOD_CHANNEL_NAME/id-token/${auth.app.name}"
      val eventChannel = EventChannel(messenger, name)
      eventChannel.setStreamHandler(handler)
      streamHandlers[eventChannel] = handler
      callback(Result.success(name))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun registerAuthStateListener(
      app: AuthPigeonFirebaseApp,
      callback: (Result<String>) -> Unit
  ) {
    try {
      val auth = getAuthFromPigeon(app)
      val handler = AuthStateChannelStreamHandler(auth)
      val name = "$METHOD_CHANNEL_NAME/auth-state/${auth.app.name}"
      val eventChannel = EventChannel(messenger, name)
      eventChannel.setStreamHandler(handler)
      streamHandlers[eventChannel] = handler
      callback(Result.success(name))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun useEmulator(
      app: AuthPigeonFirebaseApp,
      host: String,
      port: Long,
      callback: (Result<Unit>) -> Unit
  ) {
    try {
      getAuthFromPigeon(app).useEmulator(host, port.toInt())
      callback(Result.success(Unit))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun applyActionCode(
      app: AuthPigeonFirebaseApp,
      code: String,
      callback: (Result<Unit>) -> Unit
  ) {
    getAuthFromPigeon(app).applyActionCode(code).addOnCompleteListener { task ->
      completeVoid(task, callback)
    }
  }

  override fun checkActionCode(
      app: AuthPigeonFirebaseApp,
      code: String,
      callback: (Result<InternalActionCodeInfo>) -> Unit
  ) {
    getAuthFromPigeon(app).checkActionCode(code).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(PigeonParser.parseActionCodeResult(task.result)))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun confirmPasswordReset(
      app: AuthPigeonFirebaseApp,
      code: String,
      newPassword: String,
      callback: (Result<Unit>) -> Unit
  ) {
    getAuthFromPigeon(app).confirmPasswordReset(code, newPassword).addOnCompleteListener { task ->
      completeVoid(task, callback)
    }
  }

  override fun createUserWithEmailAndPassword(
      app: AuthPigeonFirebaseApp,
      email: String,
      password: String,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    getAuthFromPigeon(app).createUserWithEmailAndPassword(email, password).addOnCompleteListener {
        task ->
      completeAuthResult(task, callback)
    }
  }

  override fun signInAnonymously(
      app: AuthPigeonFirebaseApp,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    getAuthFromPigeon(app).signInAnonymously().addOnCompleteListener { task ->
      completeAuthResult(task, callback)
    }
  }

  override fun signInWithCredential(
      app: AuthPigeonFirebaseApp,
      input: Map<String?, Any?>,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val credential = PigeonParser.getCredential(input)
    if (credential == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.invalidCredential()))
      return
    }
    getAuthFromPigeon(app).signInWithCredential(credential).addOnCompleteListener { task ->
      completeAuthResult(task, callback)
    }
  }

  override fun signInWithCustomToken(
      app: AuthPigeonFirebaseApp,
      token: String,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    getAuthFromPigeon(app).signInWithCustomToken(token).addOnCompleteListener { task ->
      completeAuthResult(task, callback)
    }
  }

  override fun signInWithEmailAndPassword(
      app: AuthPigeonFirebaseApp,
      email: String,
      password: String,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    getAuthFromPigeon(app).signInWithEmailAndPassword(email, password).addOnCompleteListener { task
      ->
      completeAuthResult(task, callback)
    }
  }

  override fun signInWithEmailLink(
      app: AuthPigeonFirebaseApp,
      email: String,
      emailLink: String,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    getAuthFromPigeon(app).signInWithEmailLink(email, emailLink).addOnCompleteListener { task ->
      completeAuthResult(task, callback)
    }
  }

  override fun signInWithProvider(
      app: AuthPigeonFirebaseApp,
      signInProvider: InternalSignInProvider,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val firebaseAuth = getAuthFromPigeon(app)
    val provider = OAuthProvider.newBuilder(signInProvider.providerId, firebaseAuth)
    signInProvider.scopes?.filterNotNull()?.let { provider.setScopes(it) }
    signInProvider.customParameters?.let { params ->
      val converted = HashMap<String, String>()
      for ((key, value) in params) {
        if (key != null && value != null) {
          converted[key] = value
        }
      }
      provider.addCustomParameters(converted)
    }

    firebaseAuth
        .startActivityForSignInWithProvider(checkNotNull(getActivity()), provider.build())
        .addOnCompleteListener { task -> completeAuthResult(task, callback) }
  }

  override fun signOut(app: AuthPigeonFirebaseApp, callback: (Result<Unit>) -> Unit) {
    try {
      val firebaseAuth = getAuthFromPigeon(app)
      if (firebaseAuth.currentUser != null) {
        FlutterFirebaseMultiFactor.multiFactorUserMap[app.appName]?.remove(
            firebaseAuth.currentUser!!.uid)
      }
      firebaseAuth.signOut()
      callback(Result.success(Unit))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun fetchSignInMethodsForEmail(
      app: AuthPigeonFirebaseApp,
      email: String,
      callback: (Result<List<String>>) -> Unit
  ) {
    getAuthFromPigeon(app).fetchSignInMethodsForEmail(email).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(task.result.signInMethods?.filterNotNull() ?: emptyList()))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun sendPasswordResetEmail(
      app: AuthPigeonFirebaseApp,
      email: String,
      actionCodeSettings: InternalActionCodeSettings?,
      callback: (Result<Unit>) -> Unit
  ) {
    val firebaseAuth = getAuthFromPigeon(app)
    val task =
        if (actionCodeSettings == null) {
          firebaseAuth.sendPasswordResetEmail(email)
        } else {
          firebaseAuth.sendPasswordResetEmail(
              email, PigeonParser.getActionCodeSettings(actionCodeSettings))
        }
    task.addOnCompleteListener { completed -> completeVoid(completed, callback) }
  }

  override fun sendSignInLinkToEmail(
      app: AuthPigeonFirebaseApp,
      email: String,
      actionCodeSettings: InternalActionCodeSettings,
      callback: (Result<Unit>) -> Unit
  ) {
    getAuthFromPigeon(app)
        .sendSignInLinkToEmail(email, PigeonParser.getActionCodeSettings(actionCodeSettings))
        .addOnCompleteListener { task -> completeVoid(task, callback) }
  }

  override fun setLanguageCode(
      app: AuthPigeonFirebaseApp,
      languageCode: String?,
      callback: (Result<String>) -> Unit
  ) {
    try {
      val firebaseAuth = getAuthFromPigeon(app)
      if (languageCode == null) {
        firebaseAuth.useAppLanguage()
      } else {
        firebaseAuth.setLanguageCode(languageCode)
      }
      callback(Result.success(firebaseAuth.languageCode ?: ""))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun setSettings(
      app: AuthPigeonFirebaseApp,
      settings: InternalFirebaseAuthSettings,
      callback: (Result<Unit>) -> Unit
  ) {
    try {
      val firebaseAuth = getAuthFromPigeon(app)
      firebaseAuth.firebaseAuthSettings.setAppVerificationDisabledForTesting(
          settings.appVerificationDisabledForTesting)

      if (settings.forceRecaptchaFlow != null) {
        firebaseAuth.firebaseAuthSettings.forceRecaptchaFlowForTesting(
            settings.forceRecaptchaFlow!!)
      }

      if (settings.phoneNumber != null && settings.smsCode != null) {
        firebaseAuth.firebaseAuthSettings.setAutoRetrievedSmsCodeForPhoneNumber(
            settings.phoneNumber, settings.smsCode)
      }

      callback(Result.success(Unit))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun verifyPasswordResetCode(
      app: AuthPigeonFirebaseApp,
      code: String,
      callback: (Result<String>) -> Unit
  ) {
    getAuthFromPigeon(app).verifyPasswordResetCode(code).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(task.result ?: ""))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun verifyPhoneNumber(
      app: AuthPigeonFirebaseApp,
      request: InternalVerifyPhoneNumberRequest,
      callback: (Result<String>) -> Unit
  ) {
    try {
      val eventChannelName = "$METHOD_CHANNEL_NAME/phone/${UUID.randomUUID()}"
      val eventChannel = EventChannel(messenger, eventChannelName)

      var multiFactorSession: com.google.firebase.auth.MultiFactorSession? = null
      if (request.multiFactorSessionId != null) {
        multiFactorSession =
            FlutterFirebaseMultiFactor.multiFactorSessionMap[request.multiFactorSessionId]
      }

      val multiFactorInfoId = request.multiFactorInfoId
      var multiFactorInfo: PhoneMultiFactorInfo? = null
      if (multiFactorInfoId != null) {
        for (resolver in FlutterFirebaseMultiFactor.multiFactorResolverMap.values) {
          for (info in resolver.hints) {
            if (info.uid == multiFactorInfoId && info is PhoneMultiFactorInfo) {
              multiFactorInfo = info
              break
            }
          }
        }
      }

      val handler =
          PhoneNumberVerificationStreamHandler(
              getActivity(), app, request, multiFactorSession, multiFactorInfo) { credential ->
                authCredentials[credential.hashCode()] = credential
              }

      eventChannel.setStreamHandler(handler)
      streamHandlers[eventChannel] = handler
      callback(Result.success(eventChannelName))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun revokeTokenWithAuthorizationCode(
      app: AuthPigeonFirebaseApp,
      authorizationCode: String,
      callback: (Result<Unit>) -> Unit
  ) {
    callback(Result.success(Unit))
  }

  override fun revokeAccessToken(
      app: AuthPigeonFirebaseApp,
      accessToken: String,
      callback: (Result<Unit>) -> Unit
  ) {
    getAuthFromPigeon(app).revokeAccessToken(accessToken).addOnCompleteListener { task ->
      completeVoid(task, callback)
    }
  }

  override fun initializeRecaptchaConfig(
      app: AuthPigeonFirebaseApp,
      callback: (Result<Unit>) -> Unit
  ) {
    getAuthFromPigeon(app).initializeRecaptchaConfig().addOnCompleteListener { task ->
      completeVoid(task, callback)
    }
  }

  override fun getPluginConstantsForFirebaseApp(
      firebaseApp: FirebaseApp?
  ): Task<MutableMap<String, Any>> {
    val taskCompletionSource = TaskCompletionSource<MutableMap<String, Any>>()

    cachedThreadPool.execute {
      try {
        val constants = HashMap<String, Any>()
        val firebaseAuth = FirebaseAuth.getInstance(firebaseApp!!)
        val firebaseUser = firebaseAuth.currentUser
        val languageCode = firebaseAuth.languageCode
        val user = PigeonParser.parseFirebaseUser(firebaseUser)

        if (languageCode != null) {
          constants["APP_LANGUAGE_CODE"] = languageCode
        }
        if (user != null) {
          constants["APP_CURRENT_USER"] = PigeonParser.manuallyToList(user)
        }

        taskCompletionSource.setResult(constants)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  override fun didReinitializeFirebaseCore(): Task<Void> {
    val taskCompletionSource = TaskCompletionSource<Void>()

    cachedThreadPool.execute {
      try {
        removeEventListeners()
        authCredentials.clear()
        taskCompletionSource.setResult(null)
      } catch (e: Exception) {
        taskCompletionSource.setException(e)
      }
    }

    return taskCompletionSource.task
  }

  private fun removeEventListeners() {
    for ((eventChannel, streamHandler) in streamHandlers) {
      streamHandler.onCancel(null)
      eventChannel.setStreamHandler(null)
    }
    streamHandlers.clear()
  }

  private fun completeVoid(task: Task<*>, callback: (Result<Unit>) -> Unit) {
    if (task.isSuccessful) {
      callback(Result.success(Unit))
    } else {
      callback(
          Result.failure(
              FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
    }
  }

  private fun completeAuthResult(
      task: Task<com.google.firebase.auth.AuthResult>,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    if (task.isSuccessful) {
      callback(Result.success(PigeonParser.parseAuthResult(task.result)))
    } else {
      callback(
          Result.failure(
              FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
    }
  }

  companion object {
    private const val METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_auth"
    val authCredentials: HashMap<Int, AuthCredential> = HashMap()

    fun getAuthFromPigeon(pigeonApp: AuthPigeonFirebaseApp): FirebaseAuth {
      val app = FirebaseApp.getInstance(pigeonApp.appName)
      val auth = FirebaseAuth.getInstance(app)
      pigeonApp.tenantId?.let { auth.setTenantId(it) }
      val customDomain = FlutterFirebasePlugin.customAuthDomain[pigeonApp.appName]
      if (customDomain != null) {
        auth.setCustomAuthDomain(customDomain)
      }
      pigeonApp.customAuthDomain?.let { auth.setCustomAuthDomain(it) }
      return auth
    }
  }
}
