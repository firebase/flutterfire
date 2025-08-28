/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.appcheck

import com.google.firebase.appcheck.FirebaseAppCheck
import io.flutter.plugin.common.EventChannel

class TokenChannelStreamHandler(private val firebaseAppCheck: FirebaseAppCheck) : EventChannel.StreamHandler {

    private var listener: FirebaseAppCheck.AppCheckListener? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        listener = FirebaseAppCheck.AppCheckListener { result ->
            val event = mapOf("token" to result.token)
            events?.success(event)
        }

        firebaseAppCheck.addAppCheckListener(listener)
    }

    override fun onCancel(arguments: Any?) {
        listener?.let {
            firebaseAppCheck.removeAppCheckListener(it)
            listener = null
        }
    }
} 