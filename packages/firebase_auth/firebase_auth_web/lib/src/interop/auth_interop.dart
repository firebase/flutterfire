// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// ignore_for_file: public_member_api_docs

@JS('firebase_auth')
library;

import 'dart:js_interop';

import 'package:firebase_auth_web/src/interop/auth.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
external AuthJsImpl getAuth([AppJsImpl? app]);

@JS()
external AuthJsImpl initializeAuth(AppJsImpl app, AuthOptions authOptions);

@anonymous
@JS()
@staticInterop
abstract class AuthOptions {
  external factory AuthOptions({
    JSObject? errorMap,
    JSArray? persistence,
    JSObject? popupRedirectResolver,
  });
}

@JS('debugErrorMap')
external JSObject get debugErrorMap;

@JS()
external JSPromise applyActionCode(AuthJsImpl auth, JSString oobCode);

@JS()
external Persistence inMemoryPersistence;
@JS()
external Persistence browserSessionPersistence;
@JS()
external Persistence browserLocalPersistence;
@JS()
external Persistence indexedDBLocalPersistence;

@JS()
external JSPromise<ActionCodeInfo> checkActionCode(
    AuthJsImpl auth, JSString oobCode);

@JS()
external JSPromise/*<void>*/ confirmPasswordReset(
  AuthJsImpl auth,
  JSString oobCode,
  JSString newPassword,
);

@JS()
external void connectAuthEmulator(
  AuthJsImpl auth,
  JSString origin,
);

@JS()
external JSPromise setPersistence(AuthJsImpl auth, Persistence persistence);

@JS()
external JSPromise<UserCredentialJsImpl> createUserWithEmailAndPassword(
  AuthJsImpl auth,
  JSString email,
  JSString password,
);

@JS()
external AdditionalUserInfoJsImpl getAdditionalUserInfo(
    UserCredentialJsImpl userCredential);

@JS()
external JSPromise deleteUser(
  UserJsImpl user,
);

@JS()
external JSPromise<JSArray<JSString>> fetchSignInMethodsForEmail(
    AuthJsImpl auth, JSString email);

@JS()
external JSBoolean isSignInWithEmailLink(JSString emailLink);

@JS()
// Promise<UserCredential>
external JSPromise<UserCredentialJsImpl?> getRedirectResult(
  AuthJsImpl auth,
);

@JS()
external JSPromise sendSignInLinkToEmail(
  AuthJsImpl auth,
  JSString email, [
  ActionCodeSettings? actionCodeSettings,
]);

@JS()
external JSPromise sendPasswordResetEmail(
  AuthJsImpl auth,
  JSString email, [
  ActionCodeSettings? actionCodeSettings,
]);

@JS()
external JSPromise<UserCredentialJsImpl> signInWithCredential(
  AuthJsImpl auth,
  OAuthCredential credential,
);

@JS()
external JSPromise<UserCredentialJsImpl> signInAnonymously(AuthJsImpl auth);

@JS()
external JSPromise<UserCredentialJsImpl> signInWithCustomToken(
  AuthJsImpl auth,
  JSString token,
);

@JS()
external JSPromise<UserCredentialJsImpl> signInWithEmailAndPassword(
  AuthJsImpl auth,
  JSString email,
  JSString password,
);

@JS()
external JSPromise<UserCredentialJsImpl> signInWithEmailLink(
  AuthJsImpl auth,
  JSString email,
  JSString emailLink,
);

@JS()
external JSPromise<ConfirmationResultJsImpl> signInWithPhoneNumber(
  AuthJsImpl auth,
  JSString phoneNumber,
  ApplicationVerifierJsImpl applicationVerifier,
);

@JS()
external JSPromise<UserCredentialJsImpl> signInWithPopup(
  AuthJsImpl auth,
  AuthProviderJsImpl provider,
);

@JS()
external JSPromise signInWithRedirect(
  AuthJsImpl auth,
  AuthProviderJsImpl provider,
);

@JS()
external JSPromise<JSString> verifyPasswordResetCode(
  AuthJsImpl auth,
  JSString code,
);

@JS()
external JSPromise<UserCredentialJsImpl> linkWithCredential(
  UserJsImpl user,
  OAuthCredential? credential,
);

@JS()
external JSPromise<ConfirmationResultJsImpl> linkWithPhoneNumber(
  UserJsImpl user,
  JSString phoneNumber,
  ApplicationVerifierJsImpl applicationVerifier,
);

@JS()
external JSPromise<UserCredentialJsImpl> linkWithPopup(
  UserJsImpl user,
  AuthProviderJsImpl provider,
);

@JS()
external JSPromise linkWithRedirect(
  UserJsImpl user,
  AuthProviderJsImpl provider,
);

@JS()
external JSPromise<UserCredentialJsImpl> reauthenticateWithCredential(
  UserJsImpl user,
  OAuthCredential credential,
);

@JS()
external JSPromise<ConfirmationResultJsImpl> reauthenticateWithPhoneNumber(
  UserJsImpl user,
  JSString phoneNumber,
  ApplicationVerifierJsImpl applicationVerifier,
);

@JS()
external JSPromise<UserCredentialJsImpl> reauthenticateWithPopup(
  UserJsImpl user,
  AuthProviderJsImpl provider,
);

@JS()
external JSPromise reauthenticateWithRedirect(
  UserJsImpl user,
  AuthProviderJsImpl provider,
);

@JS()
external JSPromise sendEmailVerification([
  UserJsImpl user,
  ActionCodeSettings? actionCodeSettings,
]);

@JS()
external JSPromise verifyBeforeUpdateEmail(
  UserJsImpl user,
  JSString newEmail, [
  ActionCodeSettings? actionCodeSettings,
]);

@JS()
external JSPromise<UserJsImpl> unlink(UserJsImpl user, JSString providerId);

@JS()
external JSPromise updateEmail(UserJsImpl user, JSString newEmail);

@JS()
external JSPromise updatePassword(
  UserJsImpl user,
  JSString newPassword,
);

@JS()
external JSPromise updatePhoneNumber(
  UserJsImpl user,
  OAuthCredential? phoneCredential,
);

@JS()
external JSPromise updateProfile(
  UserJsImpl user,
  UserProfile profile,
);

@JS()
external void useDeviceLanguage(AuthJsImpl auth);

/// https://firebase.google.com/docs/reference/js/auth.md#multifactor
@JS()
external MultiFactorUserJsImpl multiFactor(
  UserJsImpl user,
);

/// https://firebase.google.com/docs/reference/js/auth.md#multifactor
@JS()
external MultiFactorResolverJsImpl getMultiFactorResolver(
  AuthJsImpl auth,
  AuthError error,
);

@JS('Auth')
@staticInterop
abstract class AuthJsImpl {}

extension AuthJsImplExtension on AuthJsImpl {
  external AppJsImpl get app;
  external UserJsImpl? get currentUser;
  external JSString? get languageCode;
  external set languageCode(JSString? s);
  external AuthSettings get settings;
  external JSString? get tenantId;
  external set tenantId(JSString? s);
  external JSFunction onAuthStateChanged(
    JSFunction nextOrObserver, [
    JSFunction? opt_error,
    JSFunction? opt_completed,
  ]);
  external JSFunction onIdTokenChanged(
    JSFunction nextOrObserver, [
    JSFunction? opt_error,
    JSFunction? opt_completed,
  ]);
  external JSPromise signOut();
}

extension type IdTokenResultImpl._(JSObject _) implements JSObject {
  external JSString get authTime;
  external JSObject get claims;
  external JSString get expirationTime;
  external JSString get issuedAtTime;
  external JSString? get signInProvider;
  external JSString get token;
}

extension type UserInfoJsImpl._(JSObject _) implements JSObject {
  external JSString? get displayName;
  external JSString? get email;
  external JSString? get phoneNumber;
  external JSString? get photoURL;
  external JSString get providerId;
  external JSString get uid;
}

/// https://firebase.google.com/docs/reference/js/firebase.User
extension type UserJsImpl._(JSObject _) implements UserInfoJsImpl {
  external JSBoolean get emailVerified;
  external JSBoolean get isAnonymous;
  external JSArray get providerData;
  external JSString get refreshToken;
  external JSString? get tenantId;
  external UserMetadata get metadata;
  external JSPromise delete();
  external JSPromise<JSString> getIdToken([JSBoolean? opt_forceRefresh]);
  external JSPromise<IdTokenResultImpl> getIdTokenResult(
      [JSBoolean? opt_forceRefresh]);
  external JSPromise reload();
  external JSObject toJSON();
}

/// An enumeration of the possible persistence mechanism types.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.Auth#.Persistence>
extension type Persistence._(JSObject _) implements JSObject {
  external JSString get type;
}

/// Interface that represents the credentials returned by an auth provider.
/// Implementations specify the details about each auth provider's credential
/// requirements.
///
/// See <https://firebase.google.com/docs/reference/js/firebase.auth.AuthCredential>.
@JS('AuthCredential')
@staticInterop
abstract class AuthCredential {}

extension AuthCredentialExtension on AuthCredential {
  /// The authentication provider ID for the credential. For example,
  /// 'facebook.com', or 'google.com'.
  external JSString get providerId;

  /// The authentication sign in method for the credential. For example,
  /// 'password', or 'emailLink'. This corresponds to the sign-in method
  /// identifier as returned in firebase.auth.Auth.fetchSignInMethodsForEmail.
  external JSString get signInMethod;
}

/// Interface that represents the OAuth credentials returned by an OAuth
/// provider. Implementations specify the details about each auth provider's
/// credential requirements.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.OAuthCredential>.
@JS()
@staticInterop
@anonymous
abstract class OAuthCredential extends AuthCredential {}

extension OAuthCredentialExtension on OAuthCredential {
  /// The OAuth access token associated with the credential if it belongs to
  /// an OAuth provider, such as facebook.com, twitter.com, etc.
  external JSString? get accessToken;

  /// The OAuth ID token associated with the credential if it belongs to an
  /// OIDC provider, such as google.com.
  external JSString? get idToken;

  /// The OAuth access token secret associated with the credential if it
  /// belongs to an OAuth 1.0 provider, such as twitter.com.
  external JSString? get secret;
}

/// Defines the options for initializing an firebase.auth.OAuthCredential.
/// For ID tokens with nonce claim, the raw nonce has to also be provided.

@JS()
@staticInterop
@anonymous
class OAuthCredentialOptions {
  external factory OAuthCredentialOptions({
    JSString? accessToken,
    JSString? idToken,
    JSString? rawNonce,
  });
}

extension OAuthCredentialOptionsExtension on OAuthCredentialOptions {
  /// The OAuth access token used to initialize the OAuthCredential.
  external JSString? get accessToken;
  external set accessToken(JSString? a);

  /// The OAuth ID token used to initialize the OAuthCredential.
  external JSString? get idToken;
  external set idToken(JSString? i);

  /// The raw nonce associated with the ID token. It is required when an ID token with a nonce field is provided.
  /// The SHA-256 hash of the raw nonce must match the nonce field in the ID token.
  external JSString? get rawNonce;
  external set rawNonce(JSString? r);
}

@JS('AuthProvider')
@staticInterop
@anonymous
abstract class AuthProviderJsImpl {}

extension AuthProviderJsImplExtension on AuthProviderJsImpl {
  external JSString get providerId;
}

@JS('EmailAuthProvider')
@staticInterop
abstract class EmailAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory EmailAuthProviderJsImpl();

  external static JSString get PROVIDER_ID;
  external static AuthCredential credential(JSString email, JSString password);
  external static AuthCredential credentialWithLink(
    JSString email,
    JSString emailLink,
  );
}

@JS('FacebookAuthProvider')
@staticInterop
abstract class FacebookAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory FacebookAuthProviderJsImpl();

  external static JSString get PROVIDER_ID;
  external static OAuthCredential credential(JSString token);
}

extension FacebookAuthProviderJsImplExtension on FacebookAuthProviderJsImpl {
  external FacebookAuthProviderJsImpl addScope(JSString scope);
  external FacebookAuthProviderJsImpl setCustomParameters(
    JSAny customOAuthParameters,
  );
}

@JS('GithubAuthProvider')
@staticInterop
abstract class GithubAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory GithubAuthProviderJsImpl();

  external static JSString get PROVIDER_ID;
  external static OAuthCredential credential(JSString token);
}

extension GithubAuthProviderJsImplExtension on GithubAuthProviderJsImpl {
  external GithubAuthProviderJsImpl addScope(JSString scope);
  external GithubAuthProviderJsImpl setCustomParameters(
    JSAny customOAuthParameters,
  );
}

@JS('GoogleAuthProvider')
@staticInterop
abstract class GoogleAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory GoogleAuthProviderJsImpl();

  external static JSString get PROVIDER_ID;
  external static OAuthCredential credential(
      [JSString? idToken, JSString? accessToken]);
}

extension GoogleAuthProviderJsImplExtension on GoogleAuthProviderJsImpl {
  external GoogleAuthProviderJsImpl addScope(JSString scope);
  external GoogleAuthProviderJsImpl setCustomParameters(
    JSAny customOAuthParameters,
  );
}

@JS('OAuthProvider')
@staticInterop
class OAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory OAuthProviderJsImpl(JSString providerId);

  external static OAuthCredential? credentialFromResult(
    UserCredentialJsImpl userCredential,
  );

  external static OAuthCredential? credentialFromError(JSError error);
}

extension OAuthProviderJsImplExtension on OAuthProviderJsImpl {
  external OAuthProviderJsImpl addScope(JSString scope);
  external OAuthProviderJsImpl setCustomParameters(
    JSAny customOAuthParameters,
  );
  external OAuthCredential credential(OAuthCredentialOptions credentialOptions);
}

@JS('TwitterAuthProvider')
@staticInterop
class TwitterAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory TwitterAuthProviderJsImpl();
  external static JSString get PROVIDER_ID;

  external static OAuthCredential credential(JSString token, JSString secret);
}

extension TwitterAuthProviderJsImplExtension on TwitterAuthProviderJsImpl {
  external TwitterAuthProviderJsImpl setCustomParameters(
    JSAny customOAuthParameters,
  );
}

@JS('PhoneAuthProvider')
@staticInterop
class PhoneAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory PhoneAuthProviderJsImpl([AuthJsImpl? auth]);
  external static JSString get PROVIDER_ID;

  external static PhoneAuthCredentialJsImpl credential(
    JSString verificationId,
    JSString verificationCode,
  );
}

extension PhoneAuthProviderJsImplExtension on PhoneAuthProviderJsImpl {
  external JSPromise verifyPhoneNumber(
    JSAny /* PhoneInfoOptions | string */ phoneOptions,
    ApplicationVerifierJsImpl applicationVerifier,
  );
}

@JS('SAMLAuthProvider')
@staticInterop
class SAMLAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory SAMLAuthProviderJsImpl(String providerId);

  external static OAuthCredential? credentialFromResult(
    UserCredentialJsImpl userCredential,
  );
}

@JS('ApplicationVerifier')
@staticInterop
abstract class ApplicationVerifierJsImpl {}

extension ApplicationVerifierJsImplExtension on ApplicationVerifierJsImpl {
  external JSString get type;
  external JSPromise verify();
}

@JS('RecaptchaVerifier')
@staticInterop
class RecaptchaVerifierJsImpl extends ApplicationVerifierJsImpl {
  external factory RecaptchaVerifierJsImpl(
    AuthJsImpl authExtern,
    JSAny containerOrId,
    JSAny? parameters,
  );
}

extension RecaptchaVerifierJsImplExtension on RecaptchaVerifierJsImpl {
  external void clear();
  external JSPromise render();
}

@JS('ConfirmationResult')
extension type ConfirmationResultJsImpl._(JSObject _) implements JSObject {
  external JSString get verificationId;
  external JSPromise<UserCredentialJsImpl> confirm(JSString verificationCode);
}

/// A response from [Auth.checkActionCode].
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.ActionCodeInfo>.
extension type ActionCodeInfo._(JSObject _) implements JSObject {
  external ActionCodeData get data;
}

/// Interface representing a user's metadata.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.UserMetadata>.
@JS()
@staticInterop
abstract class UserMetadata {}

extension UserMetadataExtension on UserMetadata {
  /// The date the user was created, formatted as a UTC string.
  /// For example, 'Fri, 22 Sep 2017 01:49:58 GMT'.
  external JSString? get creationTime;

  /// The date the user last signed in, formatted as a UTC string.
  /// For example, 'Fri, 22 Sep 2017 01:49:58 GMT'.
  external JSString? get lastSignInTime;
}

/// A structure for [User]'s user profile.
@JS()
@staticInterop
@anonymous
class UserProfile {
  external factory UserProfile({JSString? displayName, JSString? photoURL});
}

extension UserProfileExtension on UserProfile {
  external JSString get displayName;
  external set displayName(JSString s);
  external JSString get photoURL;
  external set photoURL(JSString s);
}

@JS()
@staticInterop
abstract class AuthError {}

/// An authentication error.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.Error>.
extension AuthErrorExtension on AuthError {
  external JSString get code;
  external set code(JSString s);
  external JSString get message;
  external set message(JSString s);
  external JSString get email;
  external set email(JSString s);
  external AuthCredential get credential;
  external set credential(AuthCredential c);
  external JSString get tenantId;
  external set tenantId(JSString s);
  external JSString get phoneNumber;
  external set phoneNumber(JSString s);
  external JSObject get customData;
}

extension type AuthErrorCustomData._(JSObject _) implements JSObject {
  external JSString get appName;
  external JSString? get email;
  external JSString? get phoneNumber;
  external JSString? get tenantId;
}

extension type ActionCodeData._(JSObject _) implements JSObject {
  external JSString? get email;
  external JSString? get previousEmail;
}

/// This is the interface that defines the required continue/state URL with
/// optional Android and iOS bundle identifiers.
///
/// The fields are:
///
/// [url] Sets the link continue/state URL, which has different meanings
/// in different contexts:
/// * When the link is handled in the web action widgets, this is the deep link
/// in the continueUrl query parameter.
/// * When the link is handled in the app directly, this is the continueUrl
/// query parameter in the deep link of the Dynamic Link.
///
/// [iOS] Sets the [IosSettings] object.
///
/// [android] Sets the [AndroidSettings] object.
///
/// [handleCodeInApp] The default is [:false:]. When set to [:true:],
/// the action code link will be be sent as a Universal Link or Android App Link
/// and will be opened by the app if installed. In the [:false:] case,
/// the code will be sent to the web widget first and then on continue will
/// redirect to the app if installed.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth#.ActionCodeSettings>
@JS()
@staticInterop
@anonymous
class ActionCodeSettings {
  external factory ActionCodeSettings({
    JSString? url,
    IosSettings? iOS,
    AndroidSettings? android,
    JSBoolean? handleCodeInApp,
    JSString? dynamicLinkDomain,
    JSString? linkDomain,
  });
}

extension ActionCodeSettingsExtension on ActionCodeSettings {
  external JSString get url;
  external set url(JSString s);
  external IosSettings get iOS;
  external set iOS(IosSettings i);
  external AndroidSettings get android;
  external set android(AndroidSettings a);
  external JSBoolean get handleCodeInApp;
  external set handleCodeInApp(JSBoolean b);
  external JSString get dynamicLinkDomain;
  external set dynamicLinkDomain(JSString d);
  external JSString get linkDomain;
  external set linkDomain(JSString d);
}

/// The iOS settings.
///
/// Sets the iOS [bundleId].
/// This will try to open the link in an iOS app if it is installed.
@JS()
@staticInterop
@anonymous
class IosSettings {
  external factory IosSettings({JSString? bundleId});
}

extension IosSettingsExtension on IosSettings {
  external JSString get bundleId;
  external set bundleId(JSString s);
}

/// The Android settings.
///
/// Sets the Android [packageName]. This will try to open the link
/// in an android app if it is installed.
///
/// If [installApp] is passed, it specifies whether to install the Android app
/// if the device supports it and the app is not already installed.
/// If this field is provided without a [packageName], an error is thrown
/// explaining that the [packageName] must be provided in conjunction with
/// this field.
///
/// If [minimumVersion] is specified, and an older version of the app
/// is installed, the user is taken to the Play Store to upgrade the app.
@JS()
@staticInterop
@anonymous
class AndroidSettings {
  external factory AndroidSettings({
    JSString? packageName,
    JSString? minimumVersion,
    JSBoolean? installApp,
  });
}

extension AndroidSettingsExtension on AndroidSettings {
  external JSString get packageName;
  external set packageName(JSString s);
  external JSString get minimumVersion;
  external set minimumVersion(JSString s);
  external JSBoolean get installApp;
  external set installApp(JSBoolean b);
}

/// https://firebase.google.com/docs/reference/js/auth.usercredential
extension type UserCredentialJsImpl._(JSObject _) implements JSObject {
  external UserJsImpl get user;
  external JSString get operationType;
  external AdditionalUserInfoJsImpl get additionalUserInfo;
}

/// https://firebase.google.com/docs/reference/js/firebase.auth#.AdditionalUserInfo
@JS()
@staticInterop
@anonymous
class AdditionalUserInfoJsImpl {}

extension AdditionalUserInfoJsImplExtension on AdditionalUserInfoJsImpl {
  external JSString? get providerId;
  external JSObject? get profile;
  external JSString? get username;
  external JSBoolean get isNewUser;
}

/// https://firebase.google.com/docs/reference/js/firebase.auth#.AdditionalUserInfo
@JS()
@staticInterop
@anonymous
class AuthSettings {
// external factory AuthSettings({JSBoolean appVerificationDisabledForTesting});
}

extension AuthSettingsExtension on AuthSettings {
  external JSBoolean get appVerificationDisabledForTesting;
  external set appVerificationDisabledForTesting(JSBoolean? b);
}

@JS()
@staticInterop
external JSObject get browserPopupRedirectResolver;

/// https://firebase.google.com/docs/reference/js/auth.multifactoruser.md#multifactoruser_interface
@JS()
@staticInterop
@anonymous
class MultiFactorUserJsImpl {}

extension MultiFactorUserJsImplExtension on MultiFactorUserJsImpl {
  external JSArray<MultiFactorInfoJsImpl> get enrolledFactors;
  external JSPromise enroll(
      MultiFactorAssertionJsImpl assertion, JSString? displayName);
  external JSPromise<MultiFactorSessionJsImpl> getSession();
  external JSPromise unenroll(JSAny /* MultiFactorInfo | string */ option);
}

/// https://firebase.google.com/docs/reference/js/auth.multifactorinfo
extension type MultiFactorInfoJsImpl._(JSObject _) implements JSObject {
  external JSString? get displayName;
  external JSString get enrollmentTime;
  external JSString get factorId;
  external JSString get uid;
}

/// https://firebase.google.com/docs/reference/js/auth.multifactorassertion
@JS()
@staticInterop
@anonymous
class MultiFactorAssertionJsImpl {}

extension MultiFactorAssertionJsImplExtension on MultiFactorAssertionJsImpl {
  external JSString get factorId;
}

/// https://firebase.google.com/docs/reference/js/auth.multifactorresolver
@JS()
@staticInterop
@anonymous
class MultiFactorResolverJsImpl {}

extension MultiFactorResolverJsImplExtension on MultiFactorResolverJsImpl {
  external JSArray<MultiFactorInfoJsImpl> get hints;
  external MultiFactorSessionJsImpl get session;
  external JSPromise<UserCredentialJsImpl> resolveSignIn(
      MultiFactorAssertionJsImpl assertion);
}

/// https://firebase.google.com/docs/reference/js/auth.multifactorresolver
extension type MultiFactorSessionJsImpl._(JSObject _) implements JSObject {}

/// https://firebase.google.com/docs/reference/js/auth.phonemultifactorinfo
@JS('PhoneMultiFactorInfo')
extension type PhoneMultiFactorInfoJsImpl._(JSObject _)
    implements MultiFactorInfoJsImpl {
  external JSString get phoneNumber;
}

/// https://firebase.google.com/docs/reference/js/auth.totpmultifactorinfo
@JS('TotpMultiFactorInfo')
extension type TotpMultiFactorInfoJsImpl._(JSObject _)
    implements MultiFactorInfoJsImpl {}

/// https://firebase.google.com/docs/reference/js/auth.phonemultifactorenrollinfooptions
@JS()
@staticInterop
@anonymous
class PhoneMultiFactorEnrollInfoOptionsJsImpl {}

extension PhoneMultiFactorEnrollInfoOptionsJsImplExtension
    on PhoneMultiFactorEnrollInfoOptionsJsImpl {
  external JSString get phoneNumber;
  external MultiFactorSessionJsImpl? get session;
}

/// https://firebase.google.com/docs/reference/js/auth.phonemultifactorgenerator
@JS('PhoneMultiFactorGenerator')
@staticInterop
class PhoneMultiFactorGeneratorJsImpl {
  external static JSString get FACTOR_ID;
  external static PhoneMultiFactorAssertionJsImpl? assertion(
      PhoneAuthCredentialJsImpl credential);
}

extension PhoneMultiFactorGeneratorJsImplExtension
    on PhoneMultiFactorGeneratorJsImpl {}

/// https://firebase.google.com/docs/reference/js/auth.totpsecret
@JS('TotpSecret')
extension type TotpSecretJsImpl._(JSObject _) implements JSObject {
  external JSNumber get codeIntervalSeconds;
  external JSNumber get codeLength;
  external JSString get enrollmentCompletionDeadline;
  external JSString get hashingAlgorithm;
  external JSString get secretKey;

  external JSString generateQrCodeUrl(JSString? accountName, JSString? issuer);
}

/// https://firebase.google.com/docs/reference/js/auth.totpmultifactorgenerator
@JS('TotpMultiFactorGenerator')
@staticInterop
class TotpMultiFactorGeneratorJsImpl {
  external static JSString get FACTOR_ID;
  external static TotpMultiFactorAssertionJsImpl? assertionForEnrollment(
      TotpSecretJsImpl secret, JSString oneTimePassword);
  external static TotpMultiFactorAssertionJsImpl? assertionForSignIn(
      JSString enrollmentId, JSString oneTimePassword);
  external static JSPromise<TotpSecretJsImpl> generateSecret(
      MultiFactorSessionJsImpl session);
}

extension TotpMultiFactorGeneratorJsImplExtension
    on TotpMultiFactorGeneratorJsImpl {}

/// https://firebase.google.com/docs/reference/js/auth.phonemultifactorassertion
@JS()
@staticInterop
@anonymous
class PhoneMultiFactorAssertionJsImpl extends MultiFactorAssertionJsImpl {}

/// https://firebase.google.com/docs/reference/js/auth.totpmultifactorassertion
@JS()
@staticInterop
@anonymous
class TotpMultiFactorAssertionJsImpl extends MultiFactorAssertionJsImpl {}

/// https://firebase.google.com/docs/reference/js/auth.phoneauthcredential
@JS()
@staticInterop
@anonymous
class PhoneAuthCredentialJsImpl extends AuthCredential {
  external static PhoneAuthCredentialJsImpl fromJSON(
      JSAny /*object | string*/ json);
}

extension PhoneAuthCredentialJsImplExtension on PhoneAuthCredentialJsImpl {
  external JSObject toJSON();
}

@JS()
external JSPromise initializeRecaptchaConfig(AuthJsImpl auth);
