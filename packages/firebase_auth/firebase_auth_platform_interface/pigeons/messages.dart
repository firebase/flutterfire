// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // We export in the lib folder to expose the class to other packages.
    dartTestOut: 'test/pigeon/test_api.dart',
    javaOut:
        '../firebase_auth/android/src/main/java/io/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.auth',
      className: 'GeneratedAndroidFirebaseAuth',
    ),
    objcHeaderOut: '../firebase_auth/ios/Classes/Public/messages.g.h',
    objcSourceOut: '../firebase_auth/ios/Classes/messages.g.m',
  ),
)
class PigeonMultiFactorSession {
  const PigeonMultiFactorSession({
    required this.id,
  });

  final String id;
}

class PigeonPhoneMultiFactorAssertion {
  const PigeonPhoneMultiFactorAssertion({
    required this.verificationId,
    required this.verificationCode,
  });

  final String verificationId;
  final String verificationCode;
}

class PigeonMultiFactorInfo {
  const PigeonMultiFactorInfo({
    this.displayName,
    required this.enrollmentTimestamp,
    this.factorId,
    required this.uid,
    required this.phoneNumber,
  });

  final String? displayName;
  final double enrollmentTimestamp;
  final String? factorId;
  final String uid;
  final String? phoneNumber;
}

class PigeonFirebaseApp {
  const PigeonFirebaseApp({
    required this.appName,
    required this.tenantId,
  });

  final String appName;
  final String? tenantId;
}

/// The type of operation that generated the action code from calling
/// [checkActionCode].
enum ActionCodeInfoOperation {
  /// Unknown operation.
  unknown,

  /// Password reset code generated via [sendPasswordResetEmail].
  passwordReset,

  /// Email verification code generated via [User.sendEmailVerification].
  verifyEmail,

  /// Email change revocation code generated via [User.updateEmail].
  recoverEmail,

  /// Email sign in code generated via [sendSignInLinkToEmail].
  emailSignIn,

  /// Verify and change email code generated via [User.verifyBeforeUpdateEmail].
  verifyAndChangeEmail,

  /// Action code for reverting second factor addition.
  revertSecondFactorAddition,
}

class PigeonActionCodeInfo {
  const PigeonActionCodeInfo({
    required this.operation,
    required this.data,
  });

  final ActionCodeInfoOperation operation;
  final PigeonActionCodeInfoData data;
}

class PigeonActionCodeInfoData {
  const PigeonActionCodeInfoData({
    this.email,
    this.previousEmail,
  });

  final String? email;
  final String? previousEmail;
}

class PigeonUserCredential {
  const PigeonUserCredential({
    required this.user,
    required this.additionalUserInfo,
    required this.credential,
  });

  final PigeonUserDetails? user;
  final PigeonAdditionalUserInfo? additionalUserInfo;
  final PigeonAuthCredential? credential;
}

class PigeonAdditionalUserInfo {
  const PigeonAdditionalUserInfo({
    required this.isNewUser,
    required this.providerId,
    required this.username,
    this.profile,
  });

  final bool isNewUser;
  final String? providerId;
  final String? username;
  final Map<String?, Object?>? profile;
}

class PigeonAuthCredential {
  const PigeonAuthCredential({
    required this.providerId,
    required this.signInMethod,
    required this.nativeId,
    required this.accessToken,
  });

  final String providerId;
  final String signInMethod;
  final int nativeId;
  final String? accessToken;
}

class PigeonUserInfo {
  const PigeonUserInfo({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.phoneNumber,
    required this.isAnonymous,
    required this.isEmailVerified,
    required this.tenantId,
    required this.providerId,
    required this.creationTimestamp,
    required this.lastSignInTimestamp,
    required this.refreshToken,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isAnonymous;
  final bool isEmailVerified;
  final String? providerId;
  final String? tenantId;
  final String? refreshToken;
  final int? creationTimestamp;
  final int? lastSignInTimestamp;
}

class PigeonUserDetails {
  const PigeonUserDetails({
    required this.userInfo,
    required this.providerData,
  });

  final PigeonUserInfo userInfo;
  final List<PigeonUserInfo?> providerData;
}

class PigeonAuthCredentialInput {
  const PigeonAuthCredentialInput({
    required this.providerId,
    required this.signInMethod,
    required this.token,
    required this.accessToken,
  });

  final String providerId;
  final String signInMethod;
  final String? token;
  final String? accessToken;
}

@HostApi(dartHostTestHandler: 'TesFirebaseAuthHostApi')
abstract class FirebaseAuthHostApi {
  @async
  String registerIdTokenListener(
    PigeonFirebaseApp app,
  );

  @async
  String registerAuthStateListener(
    PigeonFirebaseApp app,
  );

  @async
  void useEmulator(
    PigeonFirebaseApp app,
    String host,
    int port,
  );

  @async
  void applyActionCode(
    PigeonFirebaseApp app,
    String code,
  );

  @async
  PigeonActionCodeInfo checkActionCode(
    PigeonFirebaseApp app,
    String code,
  );

  @async
  void confirmPasswordReset(
    PigeonFirebaseApp app,
    String code,
    String newPassword,
  );

  @async
  PigeonUserCredential createUserWithEmailAndPassword(
    PigeonFirebaseApp app,
    String email,
    String password,
  );

  @async
  PigeonUserCredential signInAnonymously(
    PigeonFirebaseApp app,
  );

  @async
  PigeonUserCredential signInWithCredential(
    PigeonFirebaseApp app,
    Map<String, Object> input,
  );
}

@HostApi(dartHostTestHandler: 'TestMultiFactorUserHostApi')
abstract class MultiFactorUserHostApi {
  @async
  void enrollPhone(
    String appName,
    PigeonPhoneMultiFactorAssertion assertion,
    String? displayName,
  );

  @async
  PigeonMultiFactorSession getSession(String appName);

  @async
  void unenroll(
    String appName,
    String? factorUid,
  );

  @async
  List<PigeonMultiFactorInfo> getEnrolledFactors(String appName);
}

@HostApi(dartHostTestHandler: 'TestMultiFactoResolverHostApi')
abstract class MultiFactoResolverHostApi {
  @async
  Map<String, Object> resolveSignIn(
    String resolverId,
    PigeonPhoneMultiFactorAssertion assertion,
  );
}

/// Only used to generate the object interface that are use outside of the Pigeon interface
@HostApi()
abstract class GenerateInterfaces {
  void generateInterfaces(PigeonMultiFactorInfo info);
}
