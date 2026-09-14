/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import com.google.firebase.auth.FirebaseAuth
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import java.util.concurrent.atomic.AtomicBoolean

class AuthStateChannelStreamHandler(private val firebaseAuth: FirebaseAuth) : StreamHandler {
  private var authStateListener: FirebaseAuth.AuthStateListener? = null

  override fun onListen(arguments: Any?, events: EventSink) {
    val event: MutableMap<String, Any?> = HashMap()
    event[Constants.APP_NAME] = firebaseAuth.app.name

    val initialAuthState = AtomicBoolean(true)

    authStateListener =
        FirebaseAuth.AuthStateListener { auth: FirebaseAuth ->
          if (initialAuthState.get()) {
            initialAuthState.set(false)
            return@AuthStateListener
          }

          val user = auth.currentUser
          if (user == null) {
            event[Constants.USER] = null
          } else {
            event[Constants.USER] =
                PigeonParser.manuallyToList(PigeonParser.parseFirebaseUser(user)!!)
          }

          events.success(event)
        }

    firebaseAuth.addAuthStateListener(authStateListener!!)
  }

  override fun onCancel(arguments: Any?) {
    if (authStateListener != null) {
      firebaseAuth.removeAuthStateListener(authStateListener!!)
      authStateListener = null
    }
  }
}
