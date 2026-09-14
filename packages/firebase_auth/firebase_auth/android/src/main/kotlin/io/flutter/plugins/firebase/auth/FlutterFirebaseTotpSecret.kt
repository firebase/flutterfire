/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.auth

import com.google.firebase.auth.TotpSecret

class FlutterFirebaseTotpSecret : MultiFactorTotpSecretHostApi {
  override fun generateQrCodeUrl(
      secretKey: String,
      accountName: String?,
      issuer: String?,
      callback: (Result<String>) -> Unit
  ) {
    val secret: TotpSecret? = FlutterFirebaseTotpMultiFactor.multiFactorSecret[secretKey]
    checkNotNull(secret)
    if (accountName == null || issuer == null) {
      callback(Result.success(secret.generateQrCodeUrl()))
      return
    }
    callback(Result.success(secret.generateQrCodeUrl(accountName, issuer)))
  }

  override fun openInOtpApp(
      secretKey: String,
      qrCodeUrl: String,
      callback: (Result<Unit>) -> Unit
  ) {
    val secret: TotpSecret? = FlutterFirebaseTotpMultiFactor.multiFactorSecret[secretKey]
    checkNotNull(secret)
    secret.openInOtpApp(qrCodeUrl)
    callback(Result.success(Unit))
  }
}
