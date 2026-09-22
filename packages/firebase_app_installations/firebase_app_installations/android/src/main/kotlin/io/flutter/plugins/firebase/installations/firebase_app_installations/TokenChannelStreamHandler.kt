// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.installations.firebase_app_installations

import android.os.Handler
import android.os.Looper
import com.google.firebase.installations.FirebaseInstallations
import com.google.firebase.installations.internal.FidListener
import com.google.firebase.installations.internal.FidListenerHandle
import io.flutter.plugin.common.EventChannel

class TokenChannelStreamHandler(private val firebaseInstallations: FirebaseInstallations) :
    EventChannel.StreamHandler {

  private var listener: FidListener? = null
  private var listenerHandle: FidListenerHandle? = null
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    listener = createTokenEventListener(events)
    listenerHandle = firebaseInstallations.registerFidListener(listener!!)
  }

  override fun onCancel(arguments: Any?) {
    listenerHandle?.unregister()
    listenerHandle = null
    listener = null
  }

  internal fun createTokenEventListener(events: EventChannel.EventSink): FidListener {
    return FidListener { token ->
      // FidListener is invoked on Firebase's blocking executor. EventSink
      // must be used on the main thread.
      mainHandler.post { events.success(mapOf("token" to token)) }
    }
  }
}
