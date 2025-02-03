// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.appcheck;

import androidx.annotation.Keep;
import androidx.annotation.Nullable;
import com.google.firebase.appcheck.debug.InternalDebugSecretProvider;
import com.google.firebase.components.Component;
import com.google.firebase.components.ComponentRegistrar;
import com.google.firebase.platforminfo.LibraryVersionComponent;
import java.util.Arrays;
import java.util.List;

@Keep
public class FlutterFirebaseAppRegistrar
    implements ComponentRegistrar, InternalDebugSecretProvider {
  private static final String DEBUG_SECRET_NAME = "fire-app-check-debug-secret";

  public static String debugToken;

  @Override
  public List<Component<?>> getComponents() {
    Component<?> library =
        LibraryVersionComponent.create(BuildConfig.LIBRARY_NAME, BuildConfig.LIBRARY_VERSION);

    Component<InternalDebugSecretProvider> debugSecretProvider =
        Component.builder(InternalDebugSecretProvider.class)
            .name(DEBUG_SECRET_NAME)
            .factory(container -> this)
            .build();

    return Arrays.<Component<?>>asList(library, debugSecretProvider);
  }

  @Nullable
  @Override
  public String getDebugSecret() {
    return debugToken;
  }
}
