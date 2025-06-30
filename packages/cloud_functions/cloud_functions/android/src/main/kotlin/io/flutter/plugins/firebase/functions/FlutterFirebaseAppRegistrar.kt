// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.firebase.functions

import androidx.annotation.Keep
import com.google.firebase.components.Component
import com.google.firebase.components.ComponentRegistrar
import com.google.firebase.platforminfo.LibraryVersionComponent

@Keep
class FlutterFirebaseAppRegistrar : ComponentRegistrar {
  override fun getComponents(): List<Component<*>> {
    return listOf(
      LibraryVersionComponent.create(BuildConfig.LIBRARY_NAME, BuildConfig.LIBRARY_VERSION)
    )
  }
}
