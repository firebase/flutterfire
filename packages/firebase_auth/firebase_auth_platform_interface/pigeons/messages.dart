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
    kotlinOut:
        '../firebase_auth/android/src/main/kotlin/io/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth.g.kt',
    kotlinOptions: KotlinOptions(package: 'io.flutter.plugins.firebase.auth'),
    swiftOut:
        '../firebase_auth/ios/firebase_auth/Sources/firebase_auth/FirebaseAuthMessages.g.swift',
    cppHeaderOut: '../firebase_auth/windows/messages.g.h',
    cppSourceOut: '../firebase_auth/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_auth_windows'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
class InternalMultiFactorSession {
  const InternalMultiFactorSession({required this.id});

  final String id;
}

class InternalPhoneMultiFactorAssertion {
  const InternalPhoneMultiFactorAssertion({
    required this.verificationId,
    required this.verificationCode,
  });

  final String verificationId;
  final String verificationCode;
}

class InternalMultiFactorInfo {
  const InternalMultiFactorInfo({
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

class InternalActionCodeInfoData {
  const InternalActionCodeInfoData({this.email, this.previousEmail});

  final String? email;
  final String? previousEmail;
}

class InternalActionCodeInfo {
  const InternalActionCodeInfo({required this.operation, required this.data});

  final ActionCodeInfoOperation operation;
  final InternalActionCodeInfoData data;
}

class InternalAdditionalUserInfo {
  const InternalAdditionalUserInfo({
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

class InternalAuthCredential {
  const InternalAuthCredential({
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

class InternalUserInfo {
  const InternalUserInfo({
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

class InternalUserDetails {
  const InternalUserDetails({
    required this.userInfo,
    required this.providerData,
  });

  final InternalUserInfo userInfo;
  final List<Map<Object?, Object?>?> providerData;
}

class InternalUserCredential {
  const InternalUserCredential({
    required this.user,
    required this.additionalUserInfo,
    required this.credential,
  });

  final InternalUserDetails? user;
  final InternalAdditionalUserInfo? additionalUserInfo;
  final InternalAuthCredential? credential;
}

class InternalAuthCredentialInput {
  const InternalAuthCredentialInput({
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

class InternalActionCodeSettings {
  const InternalActionCodeSettings({
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

class InternalFirebaseAuthSettings {
  const InternalFirebaseAuthSettings({
    required this.appVerificationDisabledForTesting,
    required this.userAccessGroup,
    required this.migrateCurrentUser,
    required this.phoneNumber,
    required this.smsCode,
    required this.forceRecaptchaFlow,
  });

  final bool appVerificationDisabledForTesting;
  final String? userAccessGroup;
  final bool migrateCurrentUser;
  final String? phoneNumber;
  final String? smsCode;
  final bool? forceRecaptchaFlow;
}

class InternalSignInProvider {
  const InternalSignInProvider({
    required this.providerId,
    required this.scopes,
    required this.customParameters,
  });

  final String providerId;
  final List<String?>? scopes;
  final Map<String?, String?>? customParameters;
}

class InternalVerifyPhoneNumberRequest {
  const InternalVerifyPhoneNumberRequest({
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
  @asyncCallback
  String registerIdTokenListener(AuthPigeonFirebaseApp app);

  @asyncCallback
  String registerAuthStateListener(AuthPigeonFirebaseApp app);

  @asyncCallback
  void useEmulator(AuthPigeonFirebaseApp app, String host, int port);

  @asyncCallback
  void applyActionCode(AuthPigeonFirebaseApp app, String code);

  @asyncCallback
  InternalActionCodeInfo checkActionCode(
    AuthPigeonFirebaseApp app,
    String code,
  );

  @asyncCallback
  void confirmPasswordReset(
    AuthPigeonFirebaseApp app,
    String code,
    String newPassword,
  );

  @asyncCallback
  InternalUserCredential createUserWithEmailAndPassword(
    AuthPigeonFirebaseApp app,
    String email,
    String password,
  );

  @asyncCallback
  InternalUserCredential signInAnonymously(AuthPigeonFirebaseApp app);

  @asyncCallback
  InternalUserCredential signInWithCredential(
    AuthPigeonFirebaseApp app,
    Map<String?, Object?> input,
  );

  @asyncCallback
  InternalUserCredential signInWithCustomToken(
    AuthPigeonFirebaseApp app,
    String token,
  );

  @asyncCallback
  InternalUserCredential signInWithEmailAndPassword(
    AuthPigeonFirebaseApp app,
    String email,
    String password,
  );

  @asyncCallback
  InternalUserCredential signInWithEmailLink(
    AuthPigeonFirebaseApp app,
    String email,
    String emailLink,
  );

  @asyncCallback
  InternalUserCredential signInWithProvider(
    AuthPigeonFirebaseApp app,
    InternalSignInProvider signInProvider,
  );

  @asyncCallback
  void signOut(AuthPigeonFirebaseApp app);

  @asyncCallback
  List<String> fetchSignInMethodsForEmail(
    AuthPigeonFirebaseApp app,
    String email,
  );

  @asyncCallback
  void sendPasswordResetEmail(
    AuthPigeonFirebaseApp app,
    String email,
    InternalActionCodeSettings? actionCodeSettings,
  );

  @asyncCallback
  void sendSignInLinkToEmail(
    AuthPigeonFirebaseApp app,
    String email,
    InternalActionCodeSettings actionCodeSettings,
  );

  @asyncCallback
  String setLanguageCode(AuthPigeonFirebaseApp app, String? languageCode);

  /// Applies auth settings. When [InternalFirebaseAuthSettings.migrateCurrentUser]
  /// is true and a user was migrated, returns that user so Dart can reconcile
  /// [currentUser] before auth-state events arrive. Otherwise returns null.
  @asyncCallback
  InternalUserDetails? setSettings(
    AuthPigeonFirebaseApp app,
    InternalFirebaseAuthSettings settings,
  );

  @asyncCallback
  String verifyPasswordResetCode(AuthPigeonFirebaseApp app, String code);

  @asyncCallback
  String verifyPhoneNumber(
    AuthPigeonFirebaseApp app,
    InternalVerifyPhoneNumberRequest request,
  );
  @asyncCallback
  void revokeTokenWithAuthorizationCode(
    AuthPigeonFirebaseApp app,
    String authorizationCode,
  );

  @asyncCallback
  void revokeAccessToken(AuthPigeonFirebaseApp app, String accessToken);

  @asyncCallback
  void initializeRecaptchaConfig(AuthPigeonFirebaseApp app);
}

class InternalIdTokenResult {
  const InternalIdTokenResult({
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

class InternalUserProfile {
  const InternalUserProfile({
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
  @asyncCallback
  void delete(AuthPigeonFirebaseApp app);

  @asyncCallback
  InternalIdTokenResult getIdToken(
    AuthPigeonFirebaseApp app,
    bool forceRefresh,
  );

  @asyncCallback
  InternalUserCredential linkWithCredential(
    AuthPigeonFirebaseApp app,
    Map<String?, Object?> input,
  );

  @asyncCallback
  InternalUserCredential linkWithProvider(
    AuthPigeonFirebaseApp app,
    InternalSignInProvider signInProvider,
  );

  @asyncCallback
  InternalUserCredential reauthenticateWithCredential(
    AuthPigeonFirebaseApp app,
    Map<String?, Object?> input,
  );

  @asyncCallback
  InternalUserCredential reauthenticateWithProvider(
    AuthPigeonFirebaseApp app,
    InternalSignInProvider signInProvider,
  );

  @asyncCallback
  InternalUserDetails reload(AuthPigeonFirebaseApp app);

  @asyncCallback
  void sendEmailVerification(
    AuthPigeonFirebaseApp app,
    InternalActionCodeSettings? actionCodeSettings,
  );

  @asyncCallback
  InternalUserCredential unlink(AuthPigeonFirebaseApp app, String providerId);

  @asyncCallback
  InternalUserDetails updateEmail(AuthPigeonFirebaseApp app, String newEmail);

  @asyncCallback
  InternalUserDetails updatePassword(
    AuthPigeonFirebaseApp app,
    String newPassword,
  );

  @asyncCallback
  InternalUserDetails updatePhoneNumber(
    AuthPigeonFirebaseApp app,
    Map<String?, Object?> input,
  );

  @asyncCallback
  InternalUserDetails updateProfile(
    AuthPigeonFirebaseApp app,
    InternalUserProfile profile,
  );

  @asyncCallback
  void verifyBeforeUpdateEmail(
    AuthPigeonFirebaseApp app,
    String newEmail,
    InternalActionCodeSettings? actionCodeSettings,
  );
}

@HostApi(dartHostTestHandler: 'TestMultiFactorUserHostApi')
abstract class MultiFactorUserHostApi {
  @asyncCallback
  void enrollPhone(
    AuthPigeonFirebaseApp app,
    InternalPhoneMultiFactorAssertion assertion,
    String? displayName,
  );

  @asyncCallback
  void enrollTotp(
    AuthPigeonFirebaseApp app,
    String assertionId,
    String? displayName,
  );

  @asyncCallback
  InternalMultiFactorSession getSession(AuthPigeonFirebaseApp app);

  @asyncCallback
  void unenroll(AuthPigeonFirebaseApp app, String factorUid);

  @asyncCallback
  List<InternalMultiFactorInfo> getEnrolledFactors(AuthPigeonFirebaseApp app);
}

@HostApi(dartHostTestHandler: 'TestMultiFactoResolverHostApi')
abstract class MultiFactoResolverHostApi {
  @asyncCallback
  InternalUserCredential resolveSignIn(
    String resolverId,
    InternalPhoneMultiFactorAssertion? assertion,
    String? totpAssertionId,
  );
}

class InternalTotpSecret {
  const InternalTotpSecret({
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
  @asyncCallback
  InternalTotpSecret generateSecret(String sessionId);

  @asyncCallback
  String getAssertionForEnrollment(String secretKey, String oneTimePassword);

  @asyncCallback
  String getAssertionForSignIn(String enrollmentId, String oneTimePassword);
}

@HostApi(dartHostTestHandler: 'TestMultiFactoResolverHostApi')
abstract class MultiFactorTotpSecretHostApi {
  @asyncCallback
  String generateQrCodeUrl(
    String secretKey,
    String? accountName,
    String? issuer,
  );

  @asyncCallback
  void openInOtpApp(String secretKey, String qrCodeUrl);
}

/// Only used to generate the object interface that are use outside of the Pigeon interface
@HostApi()
abstract class GenerateInterfaces {
  void pigeonInterface(InternalMultiFactorInfo info);
}
