/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import android.app.Activity
import android.net.Uri
import com.google.android.gms.tasks.Tasks
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.OAuthProvider
import com.google.firebase.auth.PhoneAuthCredential
import com.google.firebase.auth.UserProfileChangeRequest
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin.cachedThreadPool

class FlutterFirebaseAuthUser : FirebaseAuthUserHostApi {
  private var activity: Activity? = null

  fun setActivity(activity: Activity?) {
    this.activity = activity
  }

  override fun delete(app: AuthPigeonFirebaseApp, callback: (Result<Unit>) -> Unit) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    firebaseUser.delete().addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(Unit))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun getIdToken(
      app: AuthPigeonFirebaseApp,
      forceRefresh: Boolean,
      callback: (Result<InternalIdTokenResult>) -> Unit
  ) {
    cachedThreadPool.execute {
      val firebaseUser = getCurrentUserFromPigeon(app)
      if (firebaseUser == null) {
        callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
        return@execute
      }
      try {
        val response = Tasks.await(firebaseUser.getIdToken(forceRefresh))
        callback(Result.success(PigeonParser.parseTokenResult(response)))
      } catch (exception: Exception) {
        callback(
            Result.failure(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(exception)))
      }
    }
  }

  override fun linkWithCredential(
      app: AuthPigeonFirebaseApp,
      input: Map<String?, Any?>,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    val credential = PigeonParser.getCredential(input)

    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    if (credential == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.invalidCredential()))
      return
    }

    firebaseUser.linkWithCredential(credential).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(PigeonParser.parseAuthResult(task.result)))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun linkWithProvider(
      app: AuthPigeonFirebaseApp,
      signInProvider: InternalSignInProvider,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    val provider = buildOAuthProvider(signInProvider)

    firebaseUser!!
        .startActivityForLinkWithProvider(checkNotNull(activity), provider)
        .addOnCompleteListener { task ->
          if (task.isSuccessful) {
            callback(Result.success(PigeonParser.parseAuthResult(task.result)))
          } else {
            callback(
                Result.failure(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
          }
        }
  }

  override fun reauthenticateWithCredential(
      app: AuthPigeonFirebaseApp,
      input: Map<String?, Any?>,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    val credential = PigeonParser.getCredential(input)

    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    if (credential == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.invalidCredential()))
      return
    }

    firebaseUser.reauthenticateAndRetrieveData(credential).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(PigeonParser.parseAuthResult(task.result)))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun reauthenticateWithProvider(
      app: AuthPigeonFirebaseApp,
      signInProvider: InternalSignInProvider,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    val provider = buildOAuthProvider(signInProvider)

    firebaseUser!!
        .startActivityForReauthenticateWithProvider(checkNotNull(activity), provider)
        .addOnCompleteListener { task ->
          if (task.isSuccessful) {
            callback(Result.success(PigeonParser.parseAuthResult(task.result)))
          } else {
            callback(
                Result.failure(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
          }
        }
  }

  override fun reload(app: AuthPigeonFirebaseApp, callback: (Result<InternalUserDetails>) -> Unit) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    firebaseUser.reload().addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(PigeonParser.parseFirebaseUser(firebaseUser)!!))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  override fun sendEmailVerification(
      app: AuthPigeonFirebaseApp,
      actionCodeSettings: InternalActionCodeSettings?,
      callback: (Result<Unit>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    val task =
        if (actionCodeSettings == null) {
          firebaseUser.sendEmailVerification()
        } else {
          firebaseUser.sendEmailVerification(PigeonParser.getActionCodeSettings(actionCodeSettings))
        }

    task.addOnCompleteListener { completed ->
      if (completed.isSuccessful) {
        callback(Result.success(Unit))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(completed.exception)))
      }
    }
  }

  override fun unlink(
      app: AuthPigeonFirebaseApp,
      providerId: String,
      callback: (Result<InternalUserCredential>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    firebaseUser.unlink(providerId).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        callback(Result.success(PigeonParser.parseAuthResult(task.result)))
      } else {
        val exception = task.exception
        if (exception
            ?.message
            ?.contains("User was not linked to an account with the given provider.") == true) {
          callback(Result.failure(FlutterFirebaseAuthPluginException.noSuchProvider()))
        } else {
          callback(
              Result.failure(
                  FlutterFirebaseAuthPluginException.parserExceptionToFlutter(exception)))
        }
      }
    }
  }

  override fun updateEmail(
      app: AuthPigeonFirebaseApp,
      newEmail: String,
      callback: (Result<InternalUserDetails>) -> Unit
  ) {
    reloadAfterUserUpdate(getCurrentUserFromPigeon(app), callback) { it.updateEmail(newEmail) }
  }

  override fun updatePassword(
      app: AuthPigeonFirebaseApp,
      newPassword: String,
      callback: (Result<InternalUserDetails>) -> Unit
  ) {
    reloadAfterUserUpdate(getCurrentUserFromPigeon(app), callback) {
      it.updatePassword(newPassword)
    }
  }

  override fun updatePhoneNumber(
      app: AuthPigeonFirebaseApp,
      input: Map<String?, Any?>,
      callback: (Result<InternalUserDetails>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    val phoneAuthCredential = PigeonParser.getCredential(input) as? PhoneAuthCredential
    if (phoneAuthCredential == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.invalidCredential()))
      return
    }

    reloadAfterUserUpdate(firebaseUser, callback) { it.updatePhoneNumber(phoneAuthCredential) }
  }

  override fun updateProfile(
      app: AuthPigeonFirebaseApp,
      profile: InternalUserProfile,
      callback: (Result<InternalUserDetails>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    val builder = UserProfileChangeRequest.Builder()
    if (profile.displayNameChanged) {
      builder.setDisplayName(profile.displayName)
    }
    if (profile.photoUrlChanged) {
      builder.setPhotoUri(profile.photoUrl?.let { Uri.parse(it) })
    }

    reloadAfterUserUpdate(firebaseUser, callback) { it.updateProfile(builder.build()) }
  }

  override fun verifyBeforeUpdateEmail(
      app: AuthPigeonFirebaseApp,
      newEmail: String,
      actionCodeSettings: InternalActionCodeSettings?,
      callback: (Result<Unit>) -> Unit
  ) {
    val firebaseUser = getCurrentUserFromPigeon(app)
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    val task =
        if (actionCodeSettings == null) {
          firebaseUser.verifyBeforeUpdateEmail(newEmail)
        } else {
          firebaseUser.verifyBeforeUpdateEmail(
              newEmail, PigeonParser.getActionCodeSettings(actionCodeSettings))
        }

    task.addOnCompleteListener { completed ->
      if (completed.isSuccessful) {
        callback(Result.success(Unit))
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(completed.exception)))
      }
    }
  }

  private fun reloadAfterUserUpdate(
      firebaseUser: FirebaseUser?,
      callback: (Result<InternalUserDetails>) -> Unit,
      update: (FirebaseUser) -> com.google.android.gms.tasks.Task<Void>
  ) {
    if (firebaseUser == null) {
      callback(Result.failure(FlutterFirebaseAuthPluginException.noUser()))
      return
    }

    update(firebaseUser).addOnCompleteListener { task ->
      if (task.isSuccessful) {
        firebaseUser.reload().addOnCompleteListener { reloadTask ->
          if (reloadTask.isSuccessful) {
            callback(Result.success(PigeonParser.parseFirebaseUser(firebaseUser)!!))
          } else {
            callback(
                Result.failure(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        reloadTask.exception)))
          }
        }
      } else {
        callback(
            Result.failure(
                FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.exception)))
      }
    }
  }

  companion object {
    fun getCurrentUserFromPigeon(pigeonApp: AuthPigeonFirebaseApp): FirebaseUser? {
      val app = FirebaseApp.getInstance(pigeonApp.appName)
      val auth = FirebaseAuth.getInstance(app)
      pigeonApp.tenantId?.let { auth.setTenantId(it) }
      return auth.currentUser
    }

    fun buildOAuthProvider(signInProvider: InternalSignInProvider): OAuthProvider {
      val provider = OAuthProvider.newBuilder(signInProvider.providerId)
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
      return provider.build()
    }
  }
}
