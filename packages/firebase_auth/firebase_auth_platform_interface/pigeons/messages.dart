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
    objcHeaderOut:
        '../firebase_auth/ios/firebase_auth/Sources/firebase_auth/include/Public/firebase_auth_messages.g.h',
    objcSourceOut:
        '../firebase_auth/ios/firebase_auth/Sources/firebase_auth/firebase_auth_messages.g.m',
    cppHeaderOut: '../firebase_auth/windows/messages.g.h',
    cppSourceOut: '../firebase_auth/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_auth_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
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

// We prefix the class name with `Auth` to avoid a conflict with
// other classes in other packages.
class AuthPigeonFirebaseApp {
  const AuthPigeonFirebaseApp({
    required this.appName,
    required this.tenantId,
    required this.customAuthDomain,
  });

  final String appName;
  final String? tenantId;
  final String? customAuthDomain;
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

class PigeonActionCodeInfoData {
  const PigeonActionCodeInfoData({
    this.email,
    this.previousEmail,
  });

  final String? email;
  final String? previousEmail;
}

class PigeonActionCodeInfo {
  const PigeonActionCodeInfo({
    required this.operation,
    required this.data,
  });

  final ActionCodeInfoOperation operation;
  final PigeonActionCodeInfoData data;
}

class PigeonAdditionalUserInfo {
  const PigeonAdditionalUserInfo({
    required this.isNewUser,
    required this.providerId,
    required this.username,
    this.profile,
    this.authorizationCode,
  });

  final bool isNewUser;
  final String? providerId;
  final String? username;
  final String? authorizationCode;
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
  final List<Map<Object?, Object?>?> providerData;
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

class PigeonActionCodeSettings {
  const PigeonActionCodeSettings({
    required this.url,
    required this.dynamicLinkDomain,
    required this.linkDomain,
    required this.handleCodeInApp,
    required this.iOSBundleId,
    required this.androidPackageName,
    required this.androidInstallApp,
    required this.androidMinimumVersion,
  });

  final String url;
  final String? dynamicLinkDomain;
  final bool handleCodeInApp;
  final String? iOSBundleId;
  final String? androidPackageName;
  final bool androidInstallApp;
  final String? androidMinimumVersion;
  final String? linkDomain;
}

class PigeonFirebaseAuthSettings {
  const PigeonFirebaseAuthSettings({
    required this.appVerificationDisabledForTesting,
    required this.userAccessGroup,
    required this.phoneNumber,
    required this.smsCode,
    required this.forceRecaptchaFlow,
  });

  final bool appVerificationDisabledForTesting;
  final String? userAccessGroup;
  final String? phoneNumber;
  final String? smsCode;
  final bool? forceRecaptchaFlow;
}

class PigeonSignInProvider {
  const PigeonSignInProvider({
    required this.providerId,
    required this.scopes,
    required this.customParameters,
  });

  final String providerId;
  final List<String?>? scopes;
  final Map<String?, String?>? customParameters;
}

class PigeonVerifyPhoneNumberRequest {
  const PigeonVerifyPhoneNumberRequest({
    required this.phoneNumber,
    required this.timeout,
    required this.forceResendingToken,
    required this.autoRetrievedSmsCodeForTesting,
    required this.multiFactorInfoId,
    required this.multiFactorSessionId,
  });

  final String? phoneNumber;
  final int timeout;
  final int? forceResendingToken;
  final String? autoRetrievedSmsCodeForTesting;
  final String? multiFactorInfoId;
  final String? multiFactorSessionId;
}

@HostApi(dartHostTestHandler: 'TestFirebaseAuthHostApi')
abstract class FirebaseAuthHostApi {
  @async
  String registerIdTokenListener(
    AuthPigeonFirebaseApp app,
  );

  @async
  String registerAuthStateListener(
    AuthPigeonFirebaseApp app,
  );

  @async
  void useEmulator(
    AuthPigeonFirebaseApp app,
    String host,
    int port,
  );

  @async
  void applyActionCode(
    AuthPigeonFirebaseApp app,
    String code,
  );

  @async
  PigeonActionCodeInfo checkActionCode(
    AuthPigeonFirebaseApp app,
    String code,
  );

  @async
  void confirmPasswordReset(
    AuthPigeonFirebaseApp app,
    String code,
    String newPassword,
  );

  @async
  PigeonUserCredential createUserWithEmailAndPassword(
    AuthPigeonFirebaseApp app,
    String email,
    String password,
  );

  @async
  PigeonUserCredential signInAnonymously(
    AuthPigeonFirebaseApp app,
  );

  @async
  PigeonUserCredential signInWithCredential(
    AuthPigeonFirebaseApp app,
    Map<String, Object> input,
  );

  @async
  PigeonUserCredential signInWithCustomToken(
    AuthPigeonFirebaseApp app,
    String token,
  );

  @async
  PigeonUserCredential signInWithEmailAndPassword(
    AuthPigeonFirebaseApp app,
    String email,
    String password,
  );

  @async
  PigeonUserCredential signInWithEmailLink(
    AuthPigeonFirebaseApp app,
    String email,
    String emailLink,
  );

  @async
  PigeonUserCredential signInWithProvider(
    AuthPigeonFirebaseApp app,
    PigeonSignInProvider signInProvider,
  );

  @async
  void signOut(
    AuthPigeonFirebaseApp app,
  );

  @async
  List<String> fetchSignInMethodsForEmail(
    AuthPigeonFirebaseApp app,
    String email,
  );

  @async
  void sendPasswordResetEmail(
    AuthPigeonFirebaseApp app,
    String email,
    PigeonActionCodeSettings? actionCodeSettings,
  );

  @async
  void sendSignInLinkToEmail(
    AuthPigeonFirebaseApp app,
    String email,
    PigeonActionCodeSettings actionCodeSettings,
  );

  @async
  String setLanguageCode(
    AuthPigeonFirebaseApp app,
    String? languageCode,
  );

  @async
  void setSettings(
    AuthPigeonFirebaseApp app,
    PigeonFirebaseAuthSettings settings,
  );

  @async
  String verifyPasswordResetCode(
    AuthPigeonFirebaseApp app,
    String code,
  );

  @async
  String verifyPhoneNumber(
    AuthPigeonFirebaseApp app,
    PigeonVerifyPhoneNumberRequest request,
  );
  @async
  void revokeTokenWithAuthorizationCode(
    AuthPigeonFirebaseApp app,
    String authorizationCode,
  );

  @async
  void initializeRecaptchaConfig(
    AuthPigeonFirebaseApp app,
  );
}

class PigeonIdTokenResult {
  const PigeonIdTokenResult({
    required this.token,
    required this.expirationTimestamp,
    required this.authTimestamp,
    required this.issuedAtTimestamp,
    required this.signInProvider,
    required this.claims,
    required this.signInSecondFactor,
  });

  final String? token;
  final int? expirationTimestamp;
  final int? authTimestamp;
  final int? issuedAtTimestamp;
  final String? signInProvider;
  final Map<String?, Object?>? claims;
  final String? signInSecondFactor;
}

class PigeonUserProfile {
  const PigeonUserProfile({
    required this.displayName,
    required this.photoUrl,
    required this.displayNameChanged,
    required this.photoUrlChanged,
  });

  final String? displayName;
  final String? photoUrl;
  final bool displayNameChanged;
  final bool photoUrlChanged;
}

@HostApi(dartHostTestHandler: 'TestFirebaseAuthUserHostApi')
abstract class FirebaseAuthUserHostApi {
  @async
  void delete(
    AuthPigeonFirebaseApp app,
  );

  @async
  PigeonIdTokenResult getIdToken(
    AuthPigeonFirebaseApp app,
    bool forceRefresh,
  );

  @async
  PigeonUserCredential linkWithCredential(
    AuthPigeonFirebaseApp app,
    Map<String, Object> input,
  );

  @async
  PigeonUserCredential linkWithProvider(
    AuthPigeonFirebaseApp app,
    PigeonSignInProvider signInProvider,
  );

  @async
  PigeonUserCredential reauthenticateWithCredential(
    AuthPigeonFirebaseApp app,
    Map<String, Object> input,
  );

  @async
  PigeonUserCredential reauthenticateWithProvider(
    AuthPigeonFirebaseApp app,
    PigeonSignInProvider signInProvider,
  );

  @async
  PigeonUserDetails reload(
    AuthPigeonFirebaseApp app,
  );

  @async
  void sendEmailVerification(
    AuthPigeonFirebaseApp app,
    PigeonActionCodeSettings? actionCodeSettings,
  );

  @async
  PigeonUserCredential unlink(
    AuthPigeonFirebaseApp app,
    String providerId,
  );

  @async
  PigeonUserDetails updateEmail(
    AuthPigeonFirebaseApp app,
    String newEmail,
  );

  @async
  PigeonUserDetails updatePassword(
    AuthPigeonFirebaseApp app,
    String newPassword,
  );

  @async
  PigeonUserDetails updatePhoneNumber(
    AuthPigeonFirebaseApp app,
    Map<String, Object> input,
  );

  @async
  PigeonUserDetails updateProfile(
    AuthPigeonFirebaseApp app,
    PigeonUserProfile profile,
  );

  @async
  void verifyBeforeUpdateEmail(
    AuthPigeonFirebaseApp app,
    String newEmail,
    PigeonActionCodeSettings? actionCodeSettings,
  );
}

@HostApi(dartHostTestHandler: 'TestMultiFactorUserHostApi')
abstract class MultiFactorUserHostApi {
  @async
  void enrollPhone(
    AuthPigeonFirebaseApp app,
    PigeonPhoneMultiFactorAssertion assertion,
    String? displayName,
  );

  @async
  void enrollTotp(
    AuthPigeonFirebaseApp app,
    String assertionId,
    String? displayName,
  );

  @async
  PigeonMultiFactorSession getSession(
    AuthPigeonFirebaseApp app,
  );

  @async
  void unenroll(
    AuthPigeonFirebaseApp app,
    String factorUid,
  );

  @async
  List<PigeonMultiFactorInfo> getEnrolledFactors(
    AuthPigeonFirebaseApp app,
  );
}

@HostApi(dartHostTestHandler: 'TestMultiFactoResolverHostApi')
abstract class MultiFactoResolverHostApi {
  @async
  PigeonUserCredential resolveSignIn(
    String resolverId,
    PigeonPhoneMultiFactorAssertion? assertion,
    String? totpAssertionId,
  );
}

class PigeonTotpSecret {
  const PigeonTotpSecret({
    required this.codeIntervalSeconds,
    required this.codeLength,
    required this.enrollmentCompletionDeadline,
    required this.hashingAlgorithm,
    required this.secretKey,
  });

  final int? codeIntervalSeconds;
  final int? codeLength;
  final int? enrollmentCompletionDeadline;
  final String? hashingAlgorithm;
  final String secretKey;
}

@HostApi(dartHostTestHandler: 'TestMultiFactoResolverHostApi')
abstract class MultiFactorTotpHostApi {
  @async
  PigeonTotpSecret generateSecret(
    String sessionId,
  );

  @async
  String getAssertionForEnrollment(
    String secretKey,
    String oneTimePassword,
  );

  @async
  String getAssertionForSignIn(
    String enrollmentId,
    String oneTimePassword,
  );
}

@HostApi(dartHostTestHandler: 'TestMultiFactoResolverHostApi')
abstract class MultiFactorTotpSecretHostApi {
  @async
  String generateQrCodeUrl(
    String secretKey,
    String? accountName,
    String? issuer,
  );

  @async
  void openInOtpApp(
    String secretKey,
    String qrCodeUrl,
  );
}

/// Only used to generate the object interface that are use outside of the Pigeon interface
@HostApi()
abstract class GenerateInterfaces {
  void pigeonInterface(PigeonMultiFactorInfo info);
}
