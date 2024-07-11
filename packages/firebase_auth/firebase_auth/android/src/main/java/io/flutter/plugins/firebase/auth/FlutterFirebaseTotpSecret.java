/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.auth;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.auth.TotpSecret;

public class FlutterFirebaseTotpSecret
    implements GeneratedAndroidFirebaseAuth.MultiFactorTotpSecretHostApi {

  @Override
  public void generateQrCodeUrl(
      @NonNull String secretKey,
      @Nullable String accountName,
      @Nullable String issuer,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    final TotpSecret secret = FlutterFirebaseTotpMultiFactor.multiFactorSecret.get(secretKey);

    assert secret != null;
    if (accountName == null || issuer == null) {
      result.success(secret.generateQrCodeUrl());
      return;
    }
    result.success(secret.generateQrCodeUrl(accountName, issuer));
  }

  @Override
  public void openInOtpApp(
      @NonNull String secretKey,
      @NonNull String qrCodeUrl,
      @NonNull GeneratedAndroidFirebaseAuth.VoidResult result) {
    final TotpSecret secret = FlutterFirebaseTotpMultiFactor.multiFactorSecret.get(secretKey);
    assert secret != null;
    secret.openInOtpApp(qrCodeUrl);
    result.success();
  }
}
