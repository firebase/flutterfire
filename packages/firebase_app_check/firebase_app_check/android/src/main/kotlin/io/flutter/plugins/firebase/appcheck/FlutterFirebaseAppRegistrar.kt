// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.appcheck

import androidx.annotation.Keep
import com.google.firebase.appcheck.debug.InternalDebugSecretProvider
import com.google.firebase.components.Component
import com.google.firebase.components.ComponentRegistrar
import com.google.firebase.platforminfo.LibraryVersionComponent

@Keep
class FlutterFirebaseAppRegistrar : ComponentRegistrar, InternalDebugSecretProvider {

  companion object {
    private const val DEBUG_SECRET_NAME = "fire-app-check-debug-secret"

    @JvmStatic
    var debugToken: String? = null
  }

  override fun getComponents(): List<Component<*>> {
    val library = LibraryVersionComponent.create(
      BuildConfig.LIBRARY_NAME, BuildConfig.LIBRARY_VERSION
    )

    val debugSecretProvider = Component.builder(InternalDebugSecretProvider::class.java)
      .name(DEBUG_SECRET_NAME)
      .factory { this }
      .build()

    return listOf(library, debugSecretProvider)
  }

  override fun getDebugSecret(): String? {
    return debugToken
  }
}
