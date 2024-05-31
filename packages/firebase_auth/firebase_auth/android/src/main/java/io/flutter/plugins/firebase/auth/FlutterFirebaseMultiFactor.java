/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.auth;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.MultiFactor;
import com.google.firebase.auth.MultiFactorAssertion;
import com.google.firebase.auth.MultiFactorInfo;
import com.google.firebase.auth.MultiFactorResolver;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorGenerator;
import com.google.firebase.internal.api.FirebaseNoSignedInUserException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class FlutterFirebaseMultiFactor
    implements GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi,
        GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi {

  // Map an app id to a map of user id to a MultiFactorUser object.
  static final Map<String, Map<String, MultiFactor>> multiFactorUserMap = new HashMap<>();

  // Map an id to a MultiFactorSession object.
  static final Map<String, MultiFactorSession> multiFactorSessionMap = new HashMap<>();

  // Map an id to a MultiFactorResolver object.
  static final Map<String, MultiFactorResolver> multiFactorResolverMap = new HashMap<>();

  static final Map<String, MultiFactorAssertion> multiFactorAssertionMap = new HashMap<>();

  MultiFactor getAppMultiFactor(@NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app)
      throws FirebaseNoSignedInUserException {
    final FirebaseUser currentUser = FlutterFirebaseAuthUser.getCurrentUserFromPigeon(app);
    if (currentUser == null) {
      throw new FirebaseNoSignedInUserException("No user is signed in");
    }
    if (multiFactorUserMap.get(app.getAppName()) == null) {
      multiFactorUserMap.put(app.getAppName(), new HashMap<>());
    }

    final Map<String, MultiFactor> appMultiFactorUser = multiFactorUserMap.get(app.getAppName());
    if (appMultiFactorUser.get(currentUser.getUid()) == null) {
      appMultiFactorUser.put(currentUser.getUid(), currentUser.getMultiFactor());
    }

    return appMultiFactorUser.get(currentUser.getUid());
  }

  @Override
  public void enrollPhone(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion assertion,
      @Nullable String displayName,
      @NonNull GeneratedAndroidFirebaseAuth.VoidResult result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    PhoneAuthCredential credential =
        PhoneAuthProvider.getCredential(
            assertion.getVerificationId(), assertion.getVerificationCode());

    MultiFactorAssertion multiFactorAssertion = PhoneMultiFactorGenerator.getAssertion(credential);

    multiFactor
        .enroll(multiFactorAssertion, displayName)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success();
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void enrollTotp(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull String assertionId,
      @Nullable String displayName,
      @NonNull GeneratedAndroidFirebaseAuth.VoidResult result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    final MultiFactorAssertion multiFactorAssertion = multiFactorAssertionMap.get(assertionId);

    assert multiFactorAssertion != null;
    multiFactor
        .enroll(multiFactorAssertion, displayName)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success();
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void getSession(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession>
              result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    multiFactor
        .getSession()
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                final MultiFactorSession sessionResult = task.getResult();
                final String id = UUID.randomUUID().toString();
                multiFactorSessionMap.put(id, sessionResult);
                result.success(
                    new GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession.Builder()
                        .setId(id)
                        .build());
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void unenroll(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull String factorUid,
      @NonNull GeneratedAndroidFirebaseAuth.VoidResult result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(e));
      return;
    }

    multiFactor
        .unenroll(factorUid)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                result.success();
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }

  @Override
  public void getEnrolledFactors(
      @NonNull GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp app,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<
                  List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo>>
              result) {
    final MultiFactor multiFactor;
    try {
      multiFactor = getAppMultiFactor(app);
    } catch (FirebaseNoSignedInUserException e) {
      result.error(e);
      return;
    }

    final List<MultiFactorInfo> factors = multiFactor.getEnrolledFactors();

    final List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo> resultFactors =
        PigeonParser.multiFactorInfoToPigeon(factors);

    result.success(resultFactors);
  }

  @Override
  public void resolveSignIn(
      @NonNull String resolverId,
      @Nullable GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion assertion,
      @Nullable String totpAssertionId,
      @NonNull
          GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential>
              result) {
    final MultiFactorResolver resolver = multiFactorResolverMap.get(resolverId);

    if (resolver == null) {
      result.error(
          FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
              new Exception("Resolver not found")));
      return;
    }

    MultiFactorAssertion multiFactorAssertion;

    if (assertion != null) {
      PhoneAuthCredential credential =
          PhoneAuthProvider.getCredential(
              assertion.getVerificationId(), assertion.getVerificationCode());
      multiFactorAssertion = PhoneMultiFactorGenerator.getAssertion(credential);
    } else {
      multiFactorAssertion = multiFactorAssertionMap.get(totpAssertionId);
    }

    resolver
        .resolveSignIn(multiFactorAssertion)
        .addOnCompleteListener(
            task -> {
              if (task.isSuccessful()) {
                final AuthResult authResult = task.getResult();
                result.success(PigeonParser.parseAuthResult(authResult));
              } else {
                result.error(
                    FlutterFirebaseAuthPluginException.parserExceptionToFlutter(
                        task.getException()));
              }
            });
  }
}
