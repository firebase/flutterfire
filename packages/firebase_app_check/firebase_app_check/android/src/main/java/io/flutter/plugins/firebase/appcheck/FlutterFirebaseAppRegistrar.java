// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.appcheck;

import androidx.annotation.Keep;

import com.google.firebase.appcheck.debug.InternalDebugSecretProvider;
import com.google.firebase.components.Component;
import com.google.firebase.components.ComponentRegistrar;
import com.google.firebase.platforminfo.LibraryVersionComponent;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Keep
public class FlutterFirebaseAppRegistrar implements ComponentRegistrar {
  private static final String DEBUG_SECRET_NAME = "fire-app-check-debug-secret";

  @Override
  public List<Component<?>> getComponents() {
    Component<?> library = LibraryVersionComponent.create(BuildConfig.LIBRARY_NAME,
            BuildConfig.LIBRARY_VERSION);

    if (BuildConfig.FIREBASE_APP_CHECK_DEBUG_TOKEN == null)
      return Collections.<Component<?>>singletonList(library);

    Component<InternalDebugSecretProvider> debugSecretProvider = Component.builder(InternalDebugSecretProvider.class)
            .name(DEBUG_SECRET_NAME)
            .factory(container -> () -> BuildConfig.FIREBASE_APP_CHECK_DEBUG_TOKEN).build();

    return Arrays.<Component<?>>asList(library, debugSecretProvider);
  }
}
