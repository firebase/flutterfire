// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.installations.firebase_app_installations

import com.google.firebase.installations.FirebaseInstallations
import com.google.firebase.installations.internal.FidListener
import io.flutter.plugin.common.EventChannel

class TokenChannelStreamHandler(private val firebaseInstallations: FirebaseInstallations) :
    EventChannel.StreamHandler {

  private var listener: FidListener? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    listener = createTokenEventListener(events)
    firebaseInstallations.registerFidListener(listener!!)
  }

  override fun onCancel(arguments: Any?) {
    listener = null
  }

  internal fun createTokenEventListener(events: EventChannel.EventSink): FidListener {
    return FidListener { token -> events.success(mapOf("token" to token)) }
  }
}
