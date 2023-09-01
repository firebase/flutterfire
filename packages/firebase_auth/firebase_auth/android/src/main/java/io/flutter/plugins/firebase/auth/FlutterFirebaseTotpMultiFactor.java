/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.auth;

import androidx.annotation.NonNull;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.TotpMultiFactorAssertion;
import com.google.firebase.auth.TotpMultiFactorGenerator;
import com.google.firebase.auth.TotpSecret;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class FlutterFirebaseTotpMultiFactor
    implements GeneratedAndroidFirebaseAuth.MultiFactorTotpHostApi {

  // Map an app id to a map of user id to a TotpSecret object.
  static final Map<String, TotpSecret> multiFactorSecret = new HashMap<>();

  @Override
  public void generateSecret(
      @NonNull String sessionId,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonTotpSecret>
              result) {
    MultiFactorSession multiFactorSession =
        FlutterFirebaseMultiFactor.multiFactorSessionMap.get(sessionId);

    assert multiFactorSession != null;
    TotpMultiFactorGenerator.generateSecret(multiFactorSession)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                TotpSecret secret = task.getResult();
                multiFactorSecret.put(secret.getSharedSecretKey(), secret);
                result.success(
                    new GeneratedAndroidFirebaseAuth.PigeonTotpSecret.Builder()
                        .setCodeIntervalSeconds((long) secret.getCodeIntervalSeconds())
                        .setCodeLength((long) secret.getCodeLength())
                        .setSecretKey(secret.getSharedSecretKey())
                        .setHashingAlgorithm(secret.getHashAlgorithm())
                        .setEnrollmentCompletionDeadline(secret.getEnrollmentCompletionDeadline())
                        .build());
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void getAssertionForEnrollment(
      @NonNull String secretKey,
      @NonNull String oneTimePassword,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    final TotpSecret secret = multiFactorSecret.get(secretKey);

    assert secret != null;
    TotpMultiFactorAssertion assertion =
        TotpMultiFactorGenerator.getAssertionForEnrollment(secret, oneTimePassword);
    String assertionId = UUID.randomUUID().toString();
    FlutterFirebaseMultiFactor.multiFactorAssertionMap.put(assertionId, assertion);
    result.success(assertionId);
  }

  @Override
  public void getAssertionForSignIn(
      @NonNull String enrollmentId,
      @NonNull String oneTimePassword,
      @NonNull GeneratedAndroidFirebaseAuth.Result<String> result) {
    TotpMultiFactorAssertion assertion =
        TotpMultiFactorGenerator.getAssertionForSignIn(enrollmentId, oneTimePassword);
    String assertionId = UUID.randomUUID().toString();
    FlutterFirebaseMultiFactor.multiFactorAssertionMap.put(assertionId, assertion);
    result.success(assertionId);
  }
}
