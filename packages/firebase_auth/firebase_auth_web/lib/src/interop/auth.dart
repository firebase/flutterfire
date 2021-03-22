// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:http_parser/http_parser.dart';
import 'package:js/js.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    hide jsify, dartify;
import 'auth_interop.dart' as auth_interop;
import 'firebase_interop.dart' as firebase_interop;
import 'utils/utils.dart';

export 'auth_interop.dart';

/// Given an AppJSImp, return the Auth instance.
Auth getAuthInstance([App? app]) {
  return Auth.getInstance(app != null
      ? firebase_interop.auth(app.jsObject)
      : firebase_interop.auth());
}

/// User profile information, visible only to the Firebase project's apps.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.UserInfo>.
class UserInfo<T extends auth_interop.UserInfoJsImpl>
    extends JsObjectWrapper<T> {
  /// User's display name.
  String? get displayName => jsObject.displayName;

  /// User's e-mail address.
  String? get email => jsObject.email;

  /// The user's E.164 formatted phone number (if available).
  String? get phoneNumber => jsObject.phoneNumber;

  /// User's profile picture URL.
  String? get photoURL => jsObject.photoURL;

  /// User's authentication provider ID.
  String get providerId => jsObject.providerId;

  /// User's unique ID.
  String get uid => jsObject.uid;

  /// Creates a new UserInfo from a [jsObject].
  UserInfo._fromJsObject(auth_interop.UserInfoJsImpl jsObject)
      : super.fromJsObject(jsObject as T);
}

/// User account.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.User>.
class User extends UserInfo<auth_interop.UserJsImpl> {
  static final _expando = Expando<User>();

  @override
  String get uid => jsObject.uid;

  /// If the user's email address has been already verified.
  bool get emailVerified => jsObject.emailVerified;

  /// If the user is anonymous.
  bool get isAnonymous => jsObject.isAnonymous;

  String? get tenantId => jsObject.tenantId;

  /// Non-null additional metadata about the user.
  auth_interop.UserMetadata get metadata => jsObject.metadata;

  /// List of additional provider-specific information about the user.
  List<UserInfo> get providerData => jsObject.providerData
      // explicitly typing the param as dynamic to work-around
      // https://github.com/dart-lang/sdk/issues/33537
      .map((dynamic data) =>
          UserInfo<auth_interop.UserInfoJsImpl>._fromJsObject(data))
      .toList();

  /// Refresh token for the user account.
  String get refreshToken => jsObject.refreshToken;

  /// Creates a new User from a [jsObject].
  ///
  /// If an instance of [User] is already associated with [jsObject], it is
  /// returned instead of creating a new instance.
  ///
  /// If [jsObject] is `null`, `null` is returned.
  static User? getInstance(auth_interop.UserJsImpl? jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= User._fromJsObject(jsObject);
  }

  User._fromJsObject(auth_interop.UserJsImpl jsObject)
      : super._fromJsObject(jsObject);

  /// Deletes and signs out the user.
  Future<void> delete() => handleThenable(jsObject.delete());

  /// Returns a JWT token used to identify the user to a Firebase service.
  ///
  /// Returns the current token if it has not expired, otherwise this will
  /// refresh the token and return a new one.
  ///
  /// It forces refresh regardless of token expiration if [forceRefresh]
  /// parameter is `true`.
  Future<String> getIdToken([bool forceRefresh = false]) =>
      handleThenable(jsObject.getIdToken(forceRefresh));

  /// Links the user account with the given credentials, and returns any
  /// available additional user information, such as user name.
  Future<UserCredential> linkWithCredential(
          auth_interop.OAuthCredential? credential) =>
      handleThenable(jsObject.linkWithCredential(credential))
          .then((u) => UserCredential.fromJsObject(u));

  /// Links the user account with the given [phoneNumber] in E.164 format
  /// (e.g. +16505550101) and [applicationVerifier].
  Future<ConfirmationResult> linkWithPhoneNumber(
          String phoneNumber, ApplicationVerifier applicationVerifier) =>
      handleThenable(jsObject.linkWithPhoneNumber(
              phoneNumber, applicationVerifier.jsObject))
          .then((c) => ConfirmationResult.fromJsObject(c));

  /// Links the authenticated [provider] to the user account using
  /// a pop-up based OAuth flow.
  /// It returns the [UserCredential] information if linking is successful.
  Future<UserCredential> linkWithPopup(AuthProvider provider) =>
      handleThenable(jsObject.linkWithPopup(provider.jsObject))
          .then((u) => UserCredential.fromJsObject(u));

  /// Links the authenticated [provider] to the user account using
  /// a full-page redirect flow.
  Future<void> linkWithRedirect(AuthProvider provider) =>
      handleThenable(jsObject.linkWithRedirect(provider.jsObject));

  // FYI: as of 2017-07-03 – the return type of this guy is documented as
  // Promise (Future)<nothing> - Filed a bug internally.
  /// Re-authenticates a user using a fresh credential, and returns any
  /// available additional user information, such as user name.
  Future<UserCredential> reauthenticateWithCredential(
          auth_interop.OAuthCredential credential) =>
      handleThenable(jsObject.reauthenticateWithCredential(credential))
          .then((o) => UserCredential.fromJsObject(o));

  /// Re-authenticates a user using a fresh credential.
  /// Use before operations such as [updatePassword] that require tokens
  /// from recent sign-in attempts.
  ///
  /// The user's phone number is in E.164 format (e.g. +16505550101).
  Future<ConfirmationResult> reauthenticateWithPhoneNumber(
          String phoneNumber, ApplicationVerifier applicationVerifier) =>
      handleThenable(jsObject.reauthenticateWithPhoneNumber(
              phoneNumber, applicationVerifier.jsObject))
          .then((c) => ConfirmationResult.fromJsObject(c));

  /// Reauthenticates a user with the specified provider using
  /// a pop-up based OAuth flow.
  /// It returns the [UserCredential] information if reauthentication is successful.
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) =>
      handleThenable(jsObject.reauthenticateWithPopup(provider.jsObject))
          .then((u) => UserCredential.fromJsObject(u));

  /// Reauthenticates a user with the specified OAuth [provider] using
  /// a full-page redirect flow.
  Future<void> reauthenticateWithRedirect(AuthProvider provider) =>
      handleThenable(jsObject.reauthenticateWithRedirect(provider.jsObject));

  /// If signed in, it refreshes the current user.
  Future<void> reload() => handleThenable(jsObject.reload());

  /// Sends an e-mail verification to a user.
  ///
  /// The optional parameter [actionCodeSettings] is the action code settings.
  /// If specified, the state/continue URL will be set as the 'continueUrl'
  /// parameter in the email verification link.
  /// The default email verification landing page will use this to display
  /// a link to go back to the app if it is installed.
  ///
  /// If the [actionCodeSettings] is not specified, no URL is appended to the
  /// action URL. The state URL provided must belong to a domain that is
  /// whitelisted by the developer in the console. Otherwise an error will be
  /// thrown.
  ///
  /// Mobile app redirects will only be applicable if the developer configures
  /// and accepts the Firebase Dynamic Links terms of condition.
  ///
  /// The Android package name and iOS bundle ID will be respected only if
  /// they are configured in the same Firebase Auth project used.
  Future<void> sendEmailVerification(
          [auth_interop.ActionCodeSettings? actionCodeSettings]) =>
      handleThenable(jsObject.sendEmailVerification(actionCodeSettings));

  /// Sends a verification email to a new email address. The user's email will be updated to the new one
  /// after being verified.
  Future<void> verifyBeforeUpdateEmail(String newEmail,
          [auth_interop.ActionCodeSettings? actionCodeSettings]) =>
      handleThenable(
          jsObject.verifyBeforeUpdateEmail(newEmail, actionCodeSettings));

  /// Unlinks a provider with [providerId] from a user account.
  Future<User> unlink(String providerId) =>
      handleThenable(jsObject.unlink(providerId)).then(
          User.getInstance as FutureOr<User> Function(auth_interop.UserJsImpl));

  /// Updates the user's e-mail address to [newEmail].
  Future<void> updateEmail(String newEmail) =>
      handleThenable(jsObject.updateEmail(newEmail));

  /// Updates the user's password to [newPassword].
  /// Requires the user to have recently signed in. If not, ask the user
  /// to authenticate again and then use [reauthenticate()].
  Future<void> updatePassword(String newPassword) =>
      handleThenable(jsObject.updatePassword(newPassword));

  /// Updates the user's phone number.
  Future<void> updatePhoneNumber(
          auth_interop.OAuthCredential? phoneCredential) =>
      handleThenable(jsObject.updatePhoneNumber(phoneCredential));

  /// Updates a user's profile data.
  Future<void> updateProfile(auth_interop.UserProfile profile) =>
      handleThenable(jsObject.updateProfile(profile));

  Future<IdTokenResult> getIdTokenResult([bool? forceRefresh]) {
    final promise = forceRefresh == null
        ? jsObject.getIdTokenResult()
        : jsObject.getIdTokenResult(forceRefresh);

    return handleThenable(promise)
        .then((object) => IdTokenResult._fromJsObject(object));
  }

  /// Returns a JSON-serializable representation of this object.
  Map<String, dynamic> toJson() => dartify(jsObject.toJSON());

  @override
  String toString() => 'User: $uid';
}

/// Contains the ID token JWT string and other helper properties for getting
/// different data associated with the token as well as all the decoded payload
/// claims.
///
/// Note that these claims are not to be trusted as they are parsed client side.
/// Only server side verification can guarantee the integrity of the token
/// claims.
///
/// See https://firebase.google.com/docs/reference/js/firebase.auth.IDTokenResult.html
class IdTokenResult extends JsObjectWrapper<auth_interop.IdTokenResultImpl> {
  IdTokenResult._fromJsObject(auth_interop.IdTokenResultImpl jsObject)
      : super.fromJsObject(jsObject);

  /// The authentication time.
  ///
  /// This is the time the user authenticated (signed in) and not the time the
  /// token was refreshed.
  DateTime get authTime => parseHttpDate(jsObject.authTime);

  /// The entire payload claims of the ID token including the standard reserved
  /// claims as well as the custom claims.
  Map<String, dynamic>? get claims => dartify(jsObject.claims);

  /// The ID token expiration time.
  DateTime get expirationTime => parseHttpDate(jsObject.expirationTime);

  /// The ID token issued at time.
  DateTime get issuedAtTime => parseHttpDate(jsObject.issuedAtTime);

  /// The sign-in provider through which the ID token was obtained (anonymous,
  /// custom, phone, password, etc).
  ///
  /// Note, this does not map to provider IDs.
  String get signInProvider => jsObject.signInProvider;

  /// The Firebase Auth ID token JWT string.
  String get token => jsObject.token;
}

/// The Firebase Auth service class.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.Auth>.
class Auth extends JsObjectWrapper<auth_interop.AuthJsImpl> {
  static final _expando = Expando<Auth>();

  /// App for this instance of auth service.
  App get app => App.getInstance(jsObject.app);

  /// Currently signed-in [User].
  User? get currentUser => User.getInstance(jsObject.currentUser);

  /// The current Auth instance's language code.
  /// When set to [:null:], the default Firebase Console language setting
  /// is applied.
  /// The language code will propagate to email action templates
  /// (password reset, email verification and email change revocation),
  /// SMS templates for phone authentication, reCAPTCHA verifier and OAuth
  /// popup/redirect operations provided the specified providers support
  /// localization with the language code specified.
  String get languageCode => jsObject.languageCode;

  set languageCode(String s) {
    jsObject.languageCode = s;
  }

  // set settings(auth_interop.AuthSettings s) {
  //   jsObject.settings = s;
  // }

  auth_interop.AuthSettings get settings => jsObject.settings;

  Func0? _onAuthUnsubscribe;
  // TODO(rrousselGit): fix memory leak – the controller isn't closed even in onCancel
  // ignore: close_sinks
  StreamController<User?>? _changeController;

  /// Sends events when the users sign-in state changes.
  ///
  /// After 4.0.0, this is only triggered on sign-in or sign-out.
  /// To keep the old behavior, see [onIdTokenChanged].
  ///
  /// If the value is `null`, there is no signed-in user.
  Stream<User?> get onAuthStateChanged {
    if (_changeController == null) {
      final nextWrapper = allowInterop((auth_interop.UserJsImpl? user) {
        _changeController!.add(User.getInstance(user));
      });

      final errorWrapper = allowInterop((e) => _changeController!.addError(e));

      void startListen() {
        assert(_onAuthUnsubscribe == null);
        _onAuthUnsubscribe =
            jsObject.onAuthStateChanged(nextWrapper, errorWrapper);
      }

      void stopListen() {
        _onAuthUnsubscribe!();
        _onAuthUnsubscribe = null;
      }

      _changeController = StreamController<User?>.broadcast(
        onListen: startListen,
        onCancel: stopListen,
        sync: true,
      );
    }
    return _changeController!.stream;
  }

  Func0? _onIdTokenChangedUnsubscribe;
  // TODO(rrousselGit): fix memory leak – the controller isn't closed even in onCancel
  // ignore: close_sinks
  StreamController<User?>? _idTokenChangedController;

  /// Sends events for changes to the signed-in user's ID token,
  /// which includes sign-in, sign-out, and token refresh events.
  ///
  /// This method has the same behavior as [onAuthStateChanged] had prior to 4.0.0.
  ///
  /// If the value is `null`, there is no signed-in user.
  Stream<User?> get onIdTokenChanged {
    if (_idTokenChangedController == null) {
      final nextWrapper = allowInterop((auth_interop.UserJsImpl? user) {
        _idTokenChangedController!.add(User.getInstance(user));
      });

      final errorWrapper =
          allowInterop((e) => _idTokenChangedController!.addError(e));

      void startListen() {
        assert(_onIdTokenChangedUnsubscribe == null);
        _onIdTokenChangedUnsubscribe =
            jsObject.onIdTokenChanged(nextWrapper, errorWrapper);
      }

      void stopListen() {
        _onIdTokenChangedUnsubscribe!();
        _onIdTokenChangedUnsubscribe = null;
      }

      _idTokenChangedController = StreamController<User?>.broadcast(
        onListen: startListen,
        onCancel: stopListen,
        sync: true,
      );
    }
    return _idTokenChangedController!.stream;
  }

  /// Creates a new Auth from a [jsObject].
  static Auth getInstance(auth_interop.AuthJsImpl jsObject) {
    return _expando[jsObject] ??= Auth._fromJsObject(jsObject);
  }

  Auth._fromJsObject(auth_interop.AuthJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Applies a verification [code] sent to the user by e-mail or by other
  /// out-of-band mechanism.
  Future applyActionCode(String code) =>
      handleThenable(jsObject.applyActionCode(code));

  /// Checks a verification [code] sent to the user by e-mail or by other
  /// out-of-band mechanism.
  /// It returns [ActionCodeInfo], metadata about the code.
  Future<auth_interop.ActionCodeInfo> checkActionCode(String code) =>
      handleThenable(jsObject.checkActionCode(code));

  /// Completes password reset process with a [code] and a [newPassword].
  Future confirmPasswordReset(String code, String newPassword) =>
      handleThenable(jsObject.confirmPasswordReset(code, newPassword));

  /// Creates a new user account associated with the specified email address and
  /// password.
  ///
  /// On successful creation of the user account, this user will also be signed
  /// in to your application.
  ///
  /// User account creation can fail if the account already exists or the
  /// password is invalid.
  ///
  /// Note: The email address acts as a unique identifier for the user and
  /// enables an email-based password reset. This function will create a new
  /// user account and set the initial user password.
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final u = await handleThenable(
      jsObject.createUserWithEmailAndPassword(email, password),
    );

    return UserCredential.fromJsObject(u);
  }

  /// Gets the list of possible sign in methods for the given email address.
  ///
  /// This is useful to differentiate methods of sign-in for the same provider,
  /// eg. EmailAuthProvider which has 2 methods of sign-in, email/password and
  /// email/link.
  Future<List<String>> fetchSignInMethodsForEmail(String email) =>
      handleThenable(jsObject.fetchSignInMethodsForEmail(email))
          .then((list) => List<String>.from(list));

  /// Checks if an incoming link is a sign-in with email link.
  bool isSignInWithEmailLink(String emailLink) =>
      jsObject.isSignInWithEmailLink(emailLink);

  /// Returns a [UserCredential] from the redirect-based sign in flow.
  /// If sign is successful, returns the signed in user. Or fails with an error
  /// if sign is unsuccessful.
  /// The [UserCredential] with a null [User] is returned if no redirect
  /// operation was called.
  Future<UserCredential> getRedirectResult() =>
      handleThenable(jsObject.getRedirectResult())
          .then((u) => UserCredential.fromJsObject(u));

  /// Sends a sign-in email link to the user with the specified email.
  ///
  /// The sign-in operation has to always be completed in the app unlike other out
  /// of band email actions (password reset and email verifications). This is
  /// because, at the end of the flow, the user is expected to be signed in and
  /// their Auth state persisted within the app.
  ///
  /// To complete sign in with the email link, call
  /// [Auth.signInWithEmailLink] with the email address and
  /// the email link supplied in the email sent to the user.
  Future sendSignInLinkToEmail(String email,
          [auth_interop.ActionCodeSettings? actionCodeSettings]) =>
      handleThenable(jsObject.sendSignInLinkToEmail(email, actionCodeSettings));

  /// Sends a password reset e-mail to the given [email].
  /// To confirm password reset, use the [Auth.confirmPasswordReset].
  ///
  /// The optional parameter [actionCodeSettings] is the action code settings.
  /// If specified, the state/continue URL will be set as the 'continueUrl'
  /// parameter in the password reset link.
  /// The default password reset landing page will use this to display
  /// a link to go back to the app if it is installed.
  ///
  /// If the [actionCodeSettings] is not specified, no URL is appended to the
  /// action URL. The state URL provided must belong to a domain that is
  /// whitelisted by the developer in the console. Otherwise an error will be
  /// thrown.
  ///
  /// Mobile app redirects will only be applicable if the developer configures
  /// and accepts the Firebase Dynamic Links terms of condition.
  ///
  /// The Android package name and iOS bundle ID will be respected only if
  /// they are configured in the same Firebase Auth project used.
  Future sendPasswordResetEmail(String email,
          [auth_interop.ActionCodeSettings? actionCodeSettings]) =>
      handleThenable(
          jsObject.sendPasswordResetEmail(email, actionCodeSettings));

  /// Changes the current type of persistence on the current Auth instance for
  /// the currently saved Auth session and applies this type of persistence
  /// for future sign-in requests, including sign-in with redirect requests.
  /// This will return a Future that will resolve once the state finishes
  /// copying from one type of storage to the other.
  /// Calling a sign-in method after changing persistence will wait for that
  /// persistence change to complete before applying it on the new Auth state.
  ///
  /// This makes it easy for a user signing in to specify whether their session
  /// should be remembered or not. It also makes it easier to never persist
  /// the Auth state for applications that are shared by other users or have
  /// sensitive data.
  ///
  /// The default is [:'local':] (provided the browser supports this mechanism).
  ///
  /// The [persistence] string is the auth state persistence mechanism.
  /// See allowed [persistence] values in [Persistence] class.
  Future setPersistence(String persistence) =>
      handleThenable(jsObject.setPersistence(persistence));

  /// Asynchronously signs in with the given credentials, and returns any
  /// available additional user information, such as user name.
  Future<UserCredential> signInWithCredential(
          auth_interop.OAuthCredential credential) =>
      handleThenable(jsObject.signInWithCredential(credential))
          .then((u) => UserCredential.fromJsObject(u));

  /// Asynchronously signs in as an anonymous user.
  //
  // If there is already an anonymous user signed in, that user will be
  // returned; otherwise, a new anonymous user identity will be created and
  // returned.
  Future<UserCredential> signInAnonymously() =>
      handleThenable(jsObject.signInAnonymously())
          .then((u) => UserCredential.fromJsObject(u));

  /// Asynchronously signs in using a custom token.
  ///
  /// Custom tokens are used to integrate Firebase Auth with existing auth
  /// systems, and must be generated by the auth backend.
  ///
  /// Fails with an error if the token is invalid, expired, or not accepted by
  /// the Firebase Auth service.
  Future<UserCredential> signInWithCustomToken(String token) =>
      handleThenable(jsObject.signInWithCustomToken(token))
          .then((u) => UserCredential.fromJsObject(u));

  /// Signs in a user asynchronously using a custom [token] and returns any
  /// additional user info data or credentials.
  ///
  /// This method will be renamed to [signInWithCustomToken()] replacing
  /// the existing method with the same name in the next major version change.
  ///
  /// Custom tokens are used to integrate Firebase Auth with existing auth
  /// systems, and must be generated by the auth backend.
  ///
  /// Fails with an error if the token is invalid, expired, or not accepted by
  /// the Firebase Auth service.
  Future<UserCredential> signInAndRetrieveDataWithCustomToken(String token) =>
      handleThenable(jsObject.signInAndRetrieveDataWithCustomToken(token))
          .then((u) => UserCredential.fromJsObject(u));

  /// Asynchronously signs in using an email and password.
  ///
  /// Fails with an error if the email address and password do not match.
  ///
  /// Note: The user's password is NOT the password used to access the user's
  /// email account. The email address serves as a unique identifier for the
  /// user, and the password is used to access the user's account in your
  /// Firebase project.
  Future<UserCredential> signInWithEmailAndPassword(
          String email, String password) =>
      handleThenable(jsObject.signInWithEmailAndPassword(email, password))
          .then((u) => UserCredential.fromJsObject(u));

  /// Signs in using [email] and [emailLink] link.
  Future<UserCredential> signInWithEmailLink(String email, String emailLink) =>
      handleThenable(jsObject.signInWithEmailLink(email, emailLink))
          .then((u) => UserCredential.fromJsObject(u));

  /// Asynchronously signs in using a phone number in E.164 format
  /// (e.g. +16505550101).
  ///
  /// This method sends a code via SMS to the given phone number, and returns
  /// a [ConfirmationResult].
  /// After the user provides the code sent to their phone, call
  /// [ConfirmationResult.confirm] with the code to sign the user in.
  ///
  /// For abuse prevention, this method also requires a [ApplicationVerifier].
  /// The Firebase Auth SDK includes a reCAPTCHA-based implementation, [RecaptchaVerifier].
  Future<ConfirmationResult> signInWithPhoneNumber(
          String phoneNumber, ApplicationVerifier applicationVerifier) =>
      handleThenable(jsObject.signInWithPhoneNumber(
              phoneNumber, applicationVerifier.jsObject))
          .then((c) => ConfirmationResult.fromJsObject(c));

  /// Signs in using a popup-based OAuth authentication flow with the
  /// given [provider].
  /// Returns [UserCredential] if successful, or an error object if unsuccessful.
  Future<UserCredential> signInWithPopup(AuthProvider provider) =>
      handleThenable(jsObject.signInWithPopup(provider.jsObject))
          .then((u) => UserCredential.fromJsObject(u));

  /// Signs in using a full-page redirect flow with the given [provider].
  Future signInWithRedirect(AuthProvider provider) =>
      handleThenable(jsObject.signInWithRedirect(provider.jsObject));

  /// Signs out the current user.
  Future signOut() => handleThenable(jsObject.signOut());

  /// Configures the Auth instance to work with a local emulator
  ///
  /// Call with [origin] like 'http://localhost:9099'
  ///
  /// Note: must be called before using auth methods, do not use
  /// with production credentials as local connections are unencrypted
  void useEmulator(String origin) => jsObject.useEmulator(origin);

  /// Sets the current language to the default device/browser preference.
  void useDeviceLanguage() => jsObject.useDeviceLanguage();

  /// Verifies a password reset [code] sent to the user by email
  /// or other out-of-band mechanism.
  /// Returns the user's e-mail address if valid.
  Future<String> verifyPasswordResetCode(String code) =>
      handleThenable(jsObject.verifyPasswordResetCode(code));
}

/// Represents an auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.AuthProvider>.
abstract class AuthProvider<T extends auth_interop.AuthProviderJsImpl>
    extends JsObjectWrapper<T> {
  /// Provider id.
  String get providerId => jsObject.providerId;

  /// Creates a new AuthProvider from a [jsObject].
  AuthProvider.fromJsObject(T jsObject) : super.fromJsObject(jsObject);
}

/// E-mail and password auth provider implementation.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.EmailAuthProvider>.
class EmailAuthProvider
    extends AuthProvider<auth_interop.EmailAuthProviderJsImpl> {
  static String PROVIDER_ID = auth_interop.EmailAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new EmailAuthProvider.
  factory EmailAuthProvider() =>
      EmailAuthProvider.fromJsObject(auth_interop.EmailAuthProviderJsImpl());

  /// Creates a new EmailAuthProvider from a [jsObject].
  EmailAuthProvider.fromJsObject(auth_interop.EmailAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Creates a credential for e-mail.
  static auth_interop.OAuthCredential credential(
          String email, String password) =>
      auth_interop.EmailAuthProviderJsImpl.credential(email, password)
          as auth_interop.OAuthCredential;

  /// Creates a credential for e-mail with link.
  static auth_interop.OAuthCredential credentialWithLink(
          String email, String emailLink) =>
      auth_interop.EmailAuthProviderJsImpl.credentialWithLink(email, emailLink)
          as auth_interop.OAuthCredential;
}

/// Facebook auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.FacebookAuthProvider>.
class FacebookAuthProvider
    extends AuthProvider<auth_interop.FacebookAuthProviderJsImpl> {
  static String PROVIDER_ID =
      auth_interop.FacebookAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new FacebookAuthProvider.
  factory FacebookAuthProvider() => FacebookAuthProvider.fromJsObject(
      auth_interop.FacebookAuthProviderJsImpl());

  /// Creates a new FacebookAuthProvider from a [jsObject].
  FacebookAuthProvider.fromJsObject(
      auth_interop.FacebookAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  FacebookAuthProvider addScope(String scope) =>
      FacebookAuthProvider.fromJsObject(jsObject.addScope(scope));

  /// Sets the OAuth custom parameters to pass in a Facebook OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'auth_type', 'display' and 'locale'.
  /// For a detailed list, check the Facebook documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state' are not allowed
  /// and ignored.
  FacebookAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      FacebookAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Facebook.
  static auth_interop.OAuthCredential credential(String token) =>
      auth_interop.FacebookAuthProviderJsImpl.credential(token);
}

/// Github auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GithubAuthProvider>.
class GithubAuthProvider
    extends AuthProvider<auth_interop.GithubAuthProviderJsImpl> {
  static String PROVIDER_ID = auth_interop.GithubAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new GithubAuthProvider.
  factory GithubAuthProvider() =>
      GithubAuthProvider.fromJsObject(auth_interop.GithubAuthProviderJsImpl());

  /// Creates a new GithubAuthProvider from a [jsObject].
  GithubAuthProvider.fromJsObject(
      auth_interop.GithubAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  GithubAuthProvider addScope(String scope) =>
      GithubAuthProvider.fromJsObject(jsObject.addScope(scope));

  /// Sets the OAuth custom parameters to pass in a GitHub OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'allow_signup'.
  /// For a detailed list, check the GitHub documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state'
  /// are not allowed and ignored.
  GithubAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      GithubAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for GitHub.
  static auth_interop.OAuthCredential credential(String token) =>
      auth_interop.GithubAuthProviderJsImpl.credential(token);
}

/// Google auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GoogleAuthProvider>.
class GoogleAuthProvider
    extends AuthProvider<auth_interop.GoogleAuthProviderJsImpl> {
  static String PROVIDER_ID = auth_interop.GoogleAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new GoogleAuthProvider.
  factory GoogleAuthProvider() =>
      GoogleAuthProvider.fromJsObject(auth_interop.GoogleAuthProviderJsImpl());

  /// Creates a new GoogleAuthProvider from a [jsObject].
  GoogleAuthProvider.fromJsObject(
      auth_interop.GoogleAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  GoogleAuthProvider addScope(String scope) =>
      GoogleAuthProvider.fromJsObject(jsObject.addScope(scope));

  /// Sets the OAuth custom parameters to pass in a Google OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'hd', 'hl', 'include_granted_scopes',
  /// 'login_hint' and 'prompt'.
  /// For a detailed list, check the Google documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state'
  /// are not allowed and ignored.
  GoogleAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      GoogleAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Google.
  /// At least one of [idToken] and [accessToken] is required.
  static auth_interop.OAuthCredential credential(
          [String? idToken, String? accessToken]) =>
      auth_interop.GoogleAuthProviderJsImpl.credential(idToken, accessToken);
}

/// OAuth auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GoogleAuthProvider>.
class OAuthProvider extends AuthProvider<auth_interop.OAuthProviderJsImpl> {
  /// Creates a new OAuthProvider.
  factory OAuthProvider(String providerId) =>
      OAuthProvider.fromJsObject(auth_interop.OAuthProviderJsImpl(providerId));

  /// Creates a new OAuthProvider from a [jsObject].
  OAuthProvider.fromJsObject(auth_interop.OAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  OAuthProvider addScope(String scope) =>
      OAuthProvider.fromJsObject(jsObject.addScope(scope));

  /// Sets the OAuth custom parameters to pass in an OAuth request for popup
  /// and redirect sign-in operations. For a detailed list, check the reserved
  /// required OAuth 2.0 parameters such as client_id, redirect_uri, scope,
  /// response_type and state are not allowed and will be ignored.
  OAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      OAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Google.
  /// At least one of [idToken] and [accessToken] is required.
  auth_interop.OAuthCredential credential(
          [String? idToken, String? accessToken]) =>
      jsObject.credential(idToken, accessToken);
}

/// Twitter auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.TwitterAuthProvider>.
class TwitterAuthProvider
    extends AuthProvider<auth_interop.TwitterAuthProviderJsImpl> {
  static String PROVIDER_ID =
      auth_interop.TwitterAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new TwitterAuthProvider.
  factory TwitterAuthProvider() => TwitterAuthProvider.fromJsObject(
      auth_interop.TwitterAuthProviderJsImpl());

  /// Creates a new TwitterAuthProvider from a [jsObject].
  TwitterAuthProvider.fromJsObject(
      auth_interop.TwitterAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Sets the OAuth custom parameters to pass in a Twitter OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'lang'. Reserved required OAuth 1.0 parameters
  /// such as 'oauth_consumer_key', 'oauth_token', 'oauth_signature', etc
  /// are not allowed and will be ignored.
  TwitterAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      TwitterAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Twitter.
  static auth_interop.OAuthCredential credential(String token, String secret) =>
      auth_interop.TwitterAuthProviderJsImpl.credential(token, secret);
}

/// Phone number auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.PhoneAuthProvider>.
class PhoneAuthProvider
    extends AuthProvider<auth_interop.PhoneAuthProviderJsImpl> {
  static String get PROVIDER_ID =>
      auth_interop.PhoneAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new PhoneAuthProvider with the optional [Auth] instance
  /// in which sign-ins should occur.
  factory PhoneAuthProvider([Auth? auth]) =>
      PhoneAuthProvider.fromJsObject((auth != null)
          ? auth_interop.PhoneAuthProviderJsImpl(auth.jsObject)
          : auth_interop.PhoneAuthProviderJsImpl());

  /// Creates a new PhoneAuthProvider from a [jsObject].
  PhoneAuthProvider.fromJsObject(auth_interop.PhoneAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Starts a phone number authentication flow by sending a verification code
  /// to the given [phoneNumber] in E.164 format (e.g. +16505550101).
  /// Returns an ID that can be passed to [PhoneAuthProvider.credential]
  /// to identify this flow.
  ///
  /// For abuse prevention, this method also requires an [ApplicationVerifier].
  Future<String> verifyPhoneNumber(
          String phoneNumber, ApplicationVerifier applicationVerifier) =>
      handleThenable(jsObject.verifyPhoneNumber(
          phoneNumber, applicationVerifier.jsObject));

  /// Creates a phone auth credential given the verification ID
  /// from [verifyPhoneNumber] and the [verificationCode] that was sent to the
  /// user's mobile device.
  static auth_interop.OAuthCredential credential(
          String verificationId, String verificationCode) =>
      auth_interop.PhoneAuthProviderJsImpl.credential(
          verificationId, verificationCode) as auth_interop.OAuthCredential;
}

/// A verifier for domain verification and abuse prevention.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.ApplicationVerifier>
abstract class ApplicationVerifier<
        T extends auth_interop.ApplicationVerifierJsImpl>
    extends JsObjectWrapper<T> {
  /// Returns the type of application verifier (e.g. 'recaptcha').
  String get type => jsObject.type;

  /// Creates a new ApplicationVerifier from a [jsObject].
  ApplicationVerifier.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Executes the verification process.
  /// Returns a Future containing string for a token that can be used to
  /// assert the validity of a request.
  Future<String> verify() => handleThenable(jsObject.verify());
}

/// reCAPTCHA verifier.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.RecaptchaVerifier>
/// See: <https://www.google.com/recaptcha/>
class RecaptchaVerifier
    extends ApplicationVerifier<auth_interop.RecaptchaVerifierJsImpl> {
  /// Creates a new RecaptchaVerifier from [container], [parameters] and [app].
  ///
  /// The [container] has different meaning depending on whether the reCAPTCHA
  /// is hidden or visible. For a visible reCAPTCHA it must be empty.
  /// If a string is used, it has to correspond to an element ID.
  /// The corresponding element must also must be in the DOM at the time
  /// of initialization.
  ///
  /// The [parameters] are optional [Map] of Recaptcha parameters.
  /// See: <https://developers.google.com/recaptcha/docs/display#render_param>.
  /// All parameters are accepted except for the sitekey.
  /// Firebase Auth backend provisions a reCAPTCHA for each project
  /// and will configure this upon rendering.
  /// For an invisible reCAPTCHA, a size key must have the value 'invisible'.
  ///
  /// The [app] is the corresponding Firebase app.
  /// If none is provided, the default Firebase App instance is used.
  ///
  ///     verifier = new fb.RecaptchaVerifier('register', {
  ///       'size': 'invisible',
  ///       'callback': (resp) {
  ///         print('Successful reCAPTCHA response');
  ///       },
  ///       'expired-callback': () {
  ///         print('Response expired');
  ///       }
  ///     });
  factory RecaptchaVerifier(container,
          [Map<String, dynamic>? parameters, App? app]) =>
      (parameters != null)
          ? ((app != null)
              ? RecaptchaVerifier.fromJsObject(
                  auth_interop.RecaptchaVerifierJsImpl(
                      container, jsify(parameters), app.jsObject))
              : RecaptchaVerifier.fromJsObject(
                  auth_interop.RecaptchaVerifierJsImpl(
                      container, jsify(parameters))))
          : RecaptchaVerifier.fromJsObject(
              auth_interop.RecaptchaVerifierJsImpl(container));

  /// Creates a new RecaptchaVerifier from a [jsObject].
  RecaptchaVerifier.fromJsObject(auth_interop.RecaptchaVerifierJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Clears the reCAPTCHA widget from the page and destroys the current instance.
  void clear() => jsObject.clear();

  /// Renders the reCAPTCHA widget on the page.
  /// Returns a Future that resolves with the reCAPTCHA widget ID.
  Future<num> render() => handleThenable(jsObject.render());
}

/// A result from a phone number sign-in, link, or reauthenticate call.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.ConfirmationResult>
class ConfirmationResult
    extends JsObjectWrapper<auth_interop.ConfirmationResultJsImpl> {
  /// Returns the phone number authentication operation's verification ID.
  /// This can be used along with the verification code to initialize a phone
  /// auth credential.
  String get verificationId => jsObject.verificationId;

  /// Creates a new ConfirmationResult from a [jsObject].
  ConfirmationResult.fromJsObject(
      auth_interop.ConfirmationResultJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Finishes a phone number sign-in, link, or reauthentication, given
  /// the code that was sent to the user's mobile device.
  Future<UserCredential> confirm(String verificationCode) =>
      handleThenable(jsObject.confirm(verificationCode))
          .then((u) => UserCredential.fromJsObject(u));
}

/// A structure containing a [User], an [OAuthCredential] and [operationType].
/// operationType could be 'signIn' for a sign-in operation, 'link' for a
/// linking operation and 'reauthenticate' for a reauthentication operation.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth#.UserCredential>
class UserCredential
    extends JsObjectWrapper<auth_interop.UserCredentialJsImpl> {
  /// Returns the user.
  User? get user => User.getInstance(jsObject.user);

  /// Returns the auth credential.
  auth_interop.OAuthCredential get credential => jsObject.credential;

  /// Returns the operation type.
  String get operationType => jsObject.operationType;

  /// Returns additional user information from a federated identity provider.
  AdditionalUserInfo get additionalUserInfo =>
      AdditionalUserInfo.fromJsObject(jsObject.additionalUserInfo);

  /// Creates a new UserCredential from a [jsObject].
  UserCredential.fromJsObject(auth_interop.UserCredentialJsImpl jsObject)
      : super.fromJsObject(jsObject);
}

/// A structure containing additional user information from
/// a federated identity provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth#.AdditionalUserInfo>
class AdditionalUserInfo
    extends JsObjectWrapper<auth_interop.AdditionalUserInfoJsImpl> {
  /// Returns the provider id.
  String get providerId => jsObject.providerId;

  /// Returns the profile.
  Map<String, dynamic>? get profile => dartify(jsObject.profile);

  /// Returns the user name.
  String get username => jsObject.username;

  /// Returns whether a user is a new or returning user.
  bool get isNewUser => jsObject.isNewUser;

  /// Creates a new AdditionalUserInfo from a [jsObject].
  AdditionalUserInfo.fromJsObject(
      auth_interop.AdditionalUserInfoJsImpl jsObject)
      : super.fromJsObject(jsObject);
}
