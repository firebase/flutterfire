// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import 'auth_interop.dart' as auth_interop;

export 'auth_interop.dart';

/// Given an AppJSImp, return the Auth instance.
Auth getAuthInstance(App app) {
  // Default persistence can be seen here
  // https://github.com/firebase/firebase-js-sdk/blob/main/packages/auth/src/platform_browser/index.ts#L47
  final List<JSAny?> persistences = [
    auth_interop.indexedDBLocalPersistence,
    auth_interop.browserLocalPersistence,
    auth_interop.browserSessionPersistence,
  ];
  return Auth.getInstance(
    auth_interop.initializeAuth(
      app.jsObject,
      auth_interop.AuthOptions(
        errorMap: auth_interop.debugErrorMap,
        persistence: persistences.toJS,
        popupRedirectResolver: auth_interop.browserPopupRedirectResolver,
      ),
    ),
  );
}

/// User profile information, visible only to the Firebase project's apps.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.UserInfo>.
class UserInfo<T extends auth_interop.UserInfoJsImpl>
    extends JsObjectWrapper<T> {
  /// User's display name.
  String? get displayName => jsObject.displayName?.toDart;

  /// User's e-mail address.
  String? get email => jsObject.email?.toDart;

  /// The user's E.164 formatted phone number (if available).
  String? get phoneNumber => jsObject.phoneNumber?.toDart;

  /// User's profile picture URL.
  String? get photoURL => jsObject.photoURL?.toDart;

  /// User's authentication provider ID.
  String get providerId => jsObject.providerId.toDart;

  /// User's unique ID.
  String get uid => jsObject.uid.toDart;

  /// Creates a new UserInfo from a [jsObject].
  UserInfo._fromJsObject(auth_interop.UserInfoJsImpl jsObject)
      : super.fromJsObject(jsObject as T);
}

/// User account.
///
/// See: <https://firebase.google.com/docs/reference/js/auth.user>.
class User extends UserInfo<auth_interop.UserJsImpl> {
  static final _expando = Expando<User>();

  @override
  String get uid => jsObject.uid.toDart;

  /// If the user's email address has been already verified.
  bool get emailVerified => jsObject.emailVerified.toDart;

  /// If the user is anonymous.
  bool get isAnonymous => jsObject.isAnonymous.toDart;

  String? get tenantId => jsObject.tenantId?.toDart;

  /// Non-null additional metadata about the user.
  auth_interop.UserMetadata get metadata => jsObject.metadata;

  /// List of additional provider-specific information about the user.
  List<UserInfo> get providerData => jsObject.providerData.toDart
      // explicitly typing the param as dynamic to work-around
      // https://github.com/dart-lang/sdk/issues/33537
      // ignore: unnecessary_lambdas, false positive, data is dynamic
      .map((dynamic data) =>
          UserInfo<auth_interop.UserInfoJsImpl>._fromJsObject(data))
      .toList();

  /// Refresh token for the user account.
  String get refreshToken => jsObject.refreshToken.toDart;

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
  Future<void> delete() => jsObject.delete().toDart;

  /// Returns a JWT token used to identify the user to a Firebase service.
  ///
  /// Returns the current token if it has not expired, otherwise this will
  /// refresh the token and return a new one.
  ///
  /// It forces refresh regardless of token expiration if [forceRefresh]
  /// parameter is `true`.
  Future<String> getIdToken([bool forceRefresh = false]) => jsObject
      .getIdToken(forceRefresh.toJS)
      .toDart
      .then((value) => value.toDart);

  /// Links the user account with the given credentials, and returns any
  /// available additional user information, such as user name.
  Future<UserCredential> linkWithCredential(
          auth_interop.OAuthCredential? credential) =>
      auth_interop
          .linkWithCredential(jsObject, credential)
          .toDart
          .then(UserCredential.fromJsObject);

  /// Links the user account with the given [phoneNumber] in E.164 format
  /// (e.g. +16505550101) and [applicationVerifier].
  Future<ConfirmationResult> linkWithPhoneNumber(
          String phoneNumber, ApplicationVerifier applicationVerifier) =>
      auth_interop
          .linkWithPhoneNumber(
              jsObject, phoneNumber.toJS, applicationVerifier.jsObject)
          .toDart
          .then(ConfirmationResult.fromJsObject);

  /// Links the authenticated [provider] to the user account using
  /// a pop-up based OAuth flow.
  /// It returns the [UserCredential] information if linking is successful.
  Future<UserCredential> linkWithPopup(AuthProvider provider) => auth_interop
      .linkWithPopup(jsObject, provider.jsObject)
      .toDart
      .then(UserCredential.fromJsObject);

  /// Links the authenticated [provider] to the user account using
  /// a full-page redirect flow.
  Future<void> linkWithRedirect(AuthProvider provider) =>
      auth_interop.linkWithRedirect(jsObject, provider.jsObject).toDart;

  /// Re-authenticates a user using a fresh credential, and returns any
  /// available additional user information, such as user name.
  Future<UserCredential> reauthenticateWithCredential(
          auth_interop.OAuthCredential credential) =>
      auth_interop
          .reauthenticateWithCredential(jsObject, credential)
          .toDart
          .then(UserCredential.fromJsObject);

  /// Re-authenticates a user using a fresh credential.
  /// Use before operations such as [updatePassword] that require tokens
  /// from recent sign-in attempts.
  ///
  /// The user's phone number is in E.164 format (e.g. +16505550101).
  Future<ConfirmationResult> reauthenticateWithPhoneNumber(
          String phoneNumber, ApplicationVerifier applicationVerifier) =>
      auth_interop
          .reauthenticateWithPhoneNumber(
              jsObject, phoneNumber.toJS, applicationVerifier.jsObject)
          .toDart
          .then(ConfirmationResult.fromJsObject);

  /// Reauthenticates a user with the specified provider using
  /// a pop-up based OAuth flow.
  /// It returns the [UserCredential] information if reauthentication is successful.
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) =>
      auth_interop
          .reauthenticateWithPopup(jsObject, provider.jsObject)
          .toDart
          .then(UserCredential.fromJsObject);

  /// Reauthenticates a user with the specified OAuth [provider] using
  /// a full-page redirect flow.
  Future<void> reauthenticateWithRedirect(AuthProvider provider) => auth_interop
      .reauthenticateWithRedirect(jsObject, provider.jsObject)
      .toDart;

  /// If signed in, it refreshes the current user.
  Future<void> reload() => jsObject.reload().toDart;

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
      auth_interop.sendEmailVerification(jsObject, actionCodeSettings).toDart;

  /// Sends a verification email to a new email address. The user's email will be updated to the new one
  /// after being verified.
  Future<void> verifyBeforeUpdateEmail(String newEmail,
          [auth_interop.ActionCodeSettings? actionCodeSettings]) =>
      auth_interop
          .verifyBeforeUpdateEmail(jsObject, newEmail.toJS, actionCodeSettings)
          .toDart;

  /// Unlinks a provider with [providerId] from a user account.
  Future<User> unlink(String providerId) => auth_interop
      .unlink(jsObject, providerId.toJS)
      .toDart
      .then((user) => User.getInstance(user)!);

  /// Updates the user's e-mail address to [newEmail].
  Future<void> updateEmail(String newEmail) =>
      auth_interop.updateEmail(jsObject, newEmail.toJS).toDart;

  /// Updates the user's password to [newPassword].
  /// Requires the user to have recently signed in. If not, ask the user
  /// to authenticate again and then use [reauthenticate()].
  Future<void> updatePassword(String newPassword) =>
      auth_interop.updatePassword(jsObject, newPassword.toJS).toDart;

  /// Updates the user's phone number.
  Future<void> updatePhoneNumber(
          auth_interop.OAuthCredential? phoneCredential) =>
      auth_interop.updatePhoneNumber(jsObject, phoneCredential).toDart;

  /// Updates a user's profile data.
  Future<void> updateProfile(auth_interop.UserProfile profile) =>
      auth_interop.updateProfile(jsObject, profile).toDart;

  /// Retrieves the ID token result for the current user, optionally forcing a refresh.
  Future<IdTokenResult> getIdTokenResult([bool? forceRefresh]) {
    final promise = forceRefresh == null
        ? jsObject.getIdTokenResult()
        : jsObject.getIdTokenResult(forceRefresh.toJS);

    return promise.toDart.then(IdTokenResult._fromJsObject);
  }

  /// Returns a JSON-serializable representation of this object.
  Map<String, dynamic> toJson() {
    final result = jsObject.toJSON();
    return (result as JSAny).dartify()! as Map<String, dynamic>;
  }

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
  DateTime get authTime => parseHttpDate(jsObject.authTime.toDart);

  /// The entire payload claims of the ID token including the standard reserved
  /// claims as well as the custom claims.
  Map<String, dynamic>? get claims {
    final claims = jsObject.claims.dartify();
    return claims == null ? null : (claims as Map).cast<String, dynamic>();
  }

  /// The ID token expiration time.
  DateTime get expirationTime => parseHttpDate(jsObject.expirationTime.toDart);

  /// The ID token issued at time.
  DateTime get issuedAtTime => parseHttpDate(jsObject.issuedAtTime.toDart);

  /// The sign-in provider through which the ID token was obtained (anonymous,
  /// custom, phone, password, etc).
  ///
  /// Note, this does not map to provider IDs.
  String? get signInProvider => jsObject.signInProvider?.toDart;

  /// The Firebase Auth ID token JWT string.
  String get token => jsObject.token.toDart;
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

  // Returns the current tenantId for the instance.
  String? get tenantId {
    return jsObject.tenantId?.toDart;
  }

  set tenantId(String? tenantId) {
    jsObject.tenantId = tenantId?.toJS;
  }

  /// The current Auth instance's language code.
  /// When set to [:null:], the default Firebase Console language setting
  /// is applied.
  /// The language code will propagate to email action templates
  /// (password reset, email verification and email change revocation),
  /// SMS templates for phone authentication, reCAPTCHA verifier and OAuth
  /// popup/redirect operations provided the specified providers support
  /// localization with the language code specified.
  String? get languageCode => jsObject.languageCode?.toDart;

  set languageCode(String? s) {
    jsObject.languageCode = s?.toJS;
  }

  // set settings(auth_interop.AuthSettings s) {
  //   jsObject.settings = s;
  // }

  auth_interop.AuthSettings get settings => jsObject.settings;

  User? _initUser;

  /// On web we need to wait for the first onAuthStateChanged event to fire
  /// in order to be sure that the currentUser is set.
  /// To preserve behavior on web and mobile we store the initial user
  /// in `_initUser` and add it manually to the `_changeController`.
  Future<void> onWaitInitState() async {
    final completer = Completer();
    final nextWrapper = (auth_interop.UserJsImpl? user) {
      _initUser = User.getInstance(user);
      completer.complete();
    };

    final errorWrapper = (JSAny e) => _changeController!.addError(e);

    final unsubscribe =
        jsObject.onAuthStateChanged(nextWrapper.toJS, errorWrapper.toJS);

    await completer.future;
    unsubscribe.callAsFunction();
  }

  JSFunction? _onAuthUnsubscribe;

  StreamController<User?>? get authStateController => _changeController;
  StreamController<User?>? get idTokenController => _idTokenChangedController;

  // ignore: close_sinks
  StreamController<User?>? _changeController;

  // purely for debug mode and tracking listeners to clean up on "hot restart"
  final Map<String, int> _authStateListeners = {};
  String _authStateWindowsKey() {
    if (kDebugMode) {
      final key = 'flutterfire-${app.name}_authStateChanges';
      if (_authStateListeners.containsKey(key)) {
        _authStateListeners[key] = _authStateListeners[key]! + 1;
      } else {
        _authStateListeners[key] = 0;
      }
      return '$key-${_authStateListeners[key]}';
    }
    return 'no-op';
  }

// purely for debug mode and tracking listeners to clean up on "hot restart"
  final Map<String, int> _idTokenStateListeners = {};
  String _idTokenStateWindowsKey() {
    if (kDebugMode) {
      final key = 'flutterfire-${app.name}_idTokenChanges';
      if (_idTokenStateListeners.containsKey(key)) {
        _idTokenStateListeners[key] = _idTokenStateListeners[key]! + 1;
      } else {
        _idTokenStateListeners[key] = 0;
      }
      return '$key-${_idTokenStateListeners[key]}';
    }
    return 'no-op';
  }

  /// Sends events when the users sign-in state changes.
  ///
  /// After 4.0.0, this is only triggered on sign-in or sign-out.
  /// To keep the old behavior, see [onIdTokenChanged].
  ///
  /// If the value is `null`, there is no signed-in user.
  Stream<User?> get onAuthStateChanged {
    final authStateKey = _authStateWindowsKey();
    unsubscribeWindowsListener(authStateKey);

    if (_changeController == null) {
      final nextWrapper = (auth_interop.UserJsImpl? user) {
        _changeController!.add(User.getInstance(user));
      };

      final errorWrapper = (JSAny e) => _changeController!.addError(e);

      void startListen() {
        assert(_onAuthUnsubscribe == null);
        final unsubscribe =
            jsObject.onAuthStateChanged(nextWrapper.toJS, errorWrapper.toJS);
        _onAuthUnsubscribe = unsubscribe;
        setWindowsListener(
          authStateKey,
          unsubscribe,
        );
      }

      void stopListen() {
        _onAuthUnsubscribe!.callAsFunction();
        _onAuthUnsubscribe = null;
        _changeController = null;
        removeWindowsListener(authStateKey);
      }

      _changeController = StreamController<User?>.broadcast(
        onListen: startListen,
        onCancel: stopListen,
        sync: true,
      );

      _changeController!.add(_initUser);
    }
    return _changeController!.stream;
  }

  JSFunction? _onIdTokenChangedUnsubscribe;

  // ignore: close_sinks
  StreamController<User?>? _idTokenChangedController;

  /// Sends events for changes to the signed-in user's ID token,
  /// which includes sign-in, sign-out, and token refresh events.
  ///
  /// This method has the same behavior as [onAuthStateChanged] had prior to 4.0.0.
  ///
  /// If the value is `null`, there is no signed-in user.
  Stream<User?> get onIdTokenChanged {
    final idTokenKey = _idTokenStateWindowsKey();
    unsubscribeWindowsListener(idTokenKey);
    if (_idTokenChangedController == null) {
      final nextWrapper = (auth_interop.UserJsImpl? user) {
        _idTokenChangedController!.add(User.getInstance(user));
      };

      final errorWrapper = (JSAny e) => _idTokenChangedController!.addError(e);

      void startListen() {
        assert(_onIdTokenChangedUnsubscribe == null);
        final unsubscribe =
            jsObject.onIdTokenChanged(nextWrapper.toJS, errorWrapper.toJS);
        _onIdTokenChangedUnsubscribe = unsubscribe;
        setWindowsListener(
          idTokenKey,
          unsubscribe,
        );
      }

      void stopListen() {
        _onIdTokenChangedUnsubscribe!.callAsFunction();
        _onIdTokenChangedUnsubscribe = null;
        _idTokenChangedController = null;
        removeWindowsListener(idTokenKey);
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

  /// Applies a verification [oobCode] sent to the user by e-mail or by other
  /// out-of-band mechanism.
  Future applyActionCode(String oobCode) =>
      auth_interop.applyActionCode(jsObject, oobCode.toJS).toDart;

  /// Checks a verification [code] sent to the user by e-mail or by other
  /// out-of-band mechanism.
  /// It returns [ActionCodeInfo], metadata about the code.
  Future<auth_interop.ActionCodeInfo> checkActionCode(String code) =>
      auth_interop.checkActionCode(jsObject, code.toJS).toDart;

  /// Completes password reset process with a [code] and a [newPassword].
  Future confirmPasswordReset(String code, String newPassword) => auth_interop
      .confirmPasswordReset(jsObject, code.toJS, newPassword.toJS)
      .toDart;

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
    final u = await auth_interop
        .createUserWithEmailAndPassword(jsObject, email.toJS, password.toJS)
        .toDart;

    return UserCredential.fromJsObject(u);
  }

  /// Gets the list of possible sign in methods for the given email address.
  ///
  /// This is useful to differentiate methods of sign-in for the same provider,
  /// eg. EmailAuthProvider which has 2 methods of sign-in, email/password and
  /// email/link.
  Future<List<String>> fetchSignInMethodsForEmail(String email) => auth_interop
      .fetchSignInMethodsForEmail(jsObject, email.toJS)
      .toDart
      .then((value) => List<String>.from(value.toDart));

  /// Checks if an incoming link is a sign-in with email link.
  bool isSignInWithEmailLink(String emailLink) =>
      auth_interop.isSignInWithEmailLink(emailLink.toJS).toDart;

  /// Returns a [UserCredential] from the redirect-based sign in flow.
  /// If sign is successful, returns the signed in user. Or fails with an error
  /// if sign is unsuccessful.
  /// The [UserCredential] with a null [User] is returned if no redirect
  /// operation was called.
  Future<UserCredential?> getRedirectResult() =>
      auth_interop.getRedirectResult(jsObject).toDart.then(
          (value) => value == null ? null : UserCredential.fromJsObject(value));

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
      auth_interop
          .sendSignInLinkToEmail(jsObject, email.toJS, actionCodeSettings)
          .toDart;

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
  Future setPersistence(Persistence persistence) {
    auth_interop.Persistence instance;
    switch (persistence) {
      case Persistence.LOCAL:
        instance = auth_interop.browserLocalPersistence;
        break;
      case Persistence.INDEXED_DB:
        instance = auth_interop.indexedDBLocalPersistence;
        break;
      case Persistence.SESSION:
        instance = auth_interop.browserSessionPersistence;
        break;
      case Persistence.NONE:
        instance = auth_interop.inMemoryPersistence;
        break;
    }
    return auth_interop.setPersistence(jsObject, instance).toDart;
  }

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
      auth_interop
          .sendPasswordResetEmail(jsObject, email.toJS, actionCodeSettings)
          .toDart;

  /// Asynchronously signs in with the given credentials, and returns any
  /// available additional user information, such as user name.
  Future<UserCredential> signInWithCredential(
          auth_interop.OAuthCredential credential) =>
      auth_interop
          .signInWithCredential(jsObject, credential)
          .toDart
          .then(UserCredential.fromJsObject);

  /// Asynchronously signs in as an anonymous user.
  //
  // If there is already an anonymous user signed in, that user will be
  // returned; otherwise, a new anonymous user identity will be created and
  // returned.
  Future<UserCredential> signInAnonymously() => auth_interop
      .signInAnonymously(jsObject)
      .toDart
      .then(UserCredential.fromJsObject);

  /// Asynchronously signs in using a custom token.
  ///
  /// Custom tokens are used to integrate Firebase Auth with existing auth
  /// systems, and must be generated by the auth backend.
  ///
  /// Fails with an error if the token is invalid, expired, or not accepted by
  /// the Firebase Auth service.
  Future<UserCredential> signInWithCustomToken(String token) => auth_interop
      .signInWithCustomToken(jsObject, token.toJS)
      .toDart
      .then(UserCredential.fromJsObject);

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
      signInWithCustomToken(token);

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
      auth_interop
          .signInWithEmailAndPassword(jsObject, email.toJS, password.toJS)
          .toDart
          .then(UserCredential.fromJsObject);

  /// Signs in using [email] and [emailLink] link.
  Future<UserCredential> signInWithEmailLink(String email, String emailLink) =>
      auth_interop
          .signInWithEmailLink(jsObject, email.toJS, emailLink.toJS)
          .toDart
          .then(UserCredential.fromJsObject);

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
    String phoneNumber,
    ApplicationVerifier applicationVerifier,
  ) async {
    final result = await auth_interop
        .signInWithPhoneNumber(
          jsObject,
          phoneNumber.toJS,
          applicationVerifier.jsObject,
        )
        .toDart;

    return ConfirmationResult.fromJsObject(
      result,
    );
  }

  /// Signs in using a popup-based OAuth authentication flow with the
  /// given [provider].
  /// Returns [UserCredential] if successful, or an error object if unsuccessful.
  Future<UserCredential> signInWithPopup(AuthProvider provider) => auth_interop
      .signInWithPopup(jsObject, provider.jsObject)
      .toDart
      .then(UserCredential.fromJsObject);

  /// Signs in using a full-page redirect flow with the given [provider].
  Future signInWithRedirect(AuthProvider provider) =>
      auth_interop.signInWithRedirect(jsObject, provider.jsObject).toDart;

  /// Signs out the current user.
  Future signOut() => jsObject.signOut().toDart;

  /// Configures the Auth instance to work with a local emulator
  ///
  /// Call with [origin] like 'http://localhost:9099'
  ///
  /// Note: must be called before using auth methods, do not use
  /// with production credentials as local connections are unencrypted
  void useAuthEmulator(String origin) =>
      auth_interop.connectAuthEmulator(jsObject, origin.toJS);

  /// Sets the current language to the default device/browser preference.
  void useDeviceLanguage() => auth_interop.useDeviceLanguage(jsObject);

  /// Verifies a password reset [code] sent to the user by email
  /// or other out-of-band mechanism.
  /// Returns the user's e-mail address if valid.
  Future<String> verifyPasswordResetCode(String code) => auth_interop
      .verifyPasswordResetCode(jsObject, code.toJS)
      .toDart
      .then((value) => value.toDart);

  /// Initializes the reCAPTCHA Enterprise client proactively to enhance reCAPTCHA signal collection and
  /// to complete reCAPTCHA-protected flows in a single attempt.
  Future initializeRecaptchaConfig() =>
      auth_interop.initializeRecaptchaConfig(jsObject).toDart;
}

/// Represents an auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.AuthProvider>.
abstract class AuthProvider<T extends auth_interop.AuthProviderJsImpl>
    extends JsObjectWrapper<T> {
  /// Provider id.
  String get providerId => jsObject.providerId.toDart;

  /// Creates a new AuthProvider from a [jsObject].
  AuthProvider.fromJsObject(T jsObject) : super.fromJsObject(jsObject);
}

/// E-mail and password auth provider implementation.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.EmailAuthProvider>.
class EmailAuthProvider
    extends AuthProvider<auth_interop.EmailAuthProviderJsImpl> {
  static String PROVIDER_ID =
      auth_interop.EmailAuthProviderJsImpl.PROVIDER_ID.toDart;

  /// Creates a new EmailAuthProvider.
  factory EmailAuthProvider() =>
      EmailAuthProvider.fromJsObject(auth_interop.EmailAuthProviderJsImpl());

  /// Creates a new EmailAuthProvider from a [jsObject].
  EmailAuthProvider.fromJsObject(auth_interop.EmailAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Creates a credential for e-mail.
  static auth_interop.OAuthCredential credential(
          String email, String password) =>
      auth_interop.EmailAuthProviderJsImpl.credential(email.toJS, password.toJS)
          as auth_interop.OAuthCredential;

  /// Creates a credential for e-mail with link.
  static auth_interop.OAuthCredential credentialWithLink(
          String email, String emailLink) =>
      auth_interop.EmailAuthProviderJsImpl.credentialWithLink(
          email.toJS, emailLink.toJS) as auth_interop.OAuthCredential;
}

/// Facebook auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.FacebookAuthProvider>.
class FacebookAuthProvider
    extends AuthProvider<auth_interop.FacebookAuthProviderJsImpl> {
  static String PROVIDER_ID =
      auth_interop.FacebookAuthProviderJsImpl.PROVIDER_ID.toDart;

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
      FacebookAuthProvider.fromJsObject(jsObject.addScope(scope.toJS));

  /// Sets the OAuth custom parameters to pass in a Facebook OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'auth_type', 'display' and 'locale'.
  /// For a detailed list, check the Facebook documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state' are not allowed
  /// and ignored.
  FacebookAuthProvider setCustomParameters(
    Map<Object?, Object?> customOAuthParameters,
  ) {
    return FacebookAuthProvider.fromJsObject(
      jsObject.setCustomParameters(customOAuthParameters.jsify()!),
    );
  }

  /// Creates a credential for Facebook.
  static auth_interop.OAuthCredential credential(String token) =>
      auth_interop.FacebookAuthProviderJsImpl.credential(token.toJS);
}

/// Github auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GithubAuthProvider>.
class GithubAuthProvider
    extends AuthProvider<auth_interop.GithubAuthProviderJsImpl> {
  static String PROVIDER_ID =
      auth_interop.GithubAuthProviderJsImpl.PROVIDER_ID.toDart;

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
      GithubAuthProvider.fromJsObject(jsObject.addScope(scope.toJS));

  /// Sets the OAuth custom parameters to pass in a GitHub OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'allow_signup'.
  /// For a detailed list, check the GitHub documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state'
  /// are not allowed and ignored.
  GithubAuthProvider setCustomParameters(
    Map<Object?, Object?> customOAuthParameters,
  ) {
    return GithubAuthProvider.fromJsObject(
      jsObject.setCustomParameters(customOAuthParameters.jsify()!),
    );
  }

  /// Creates a credential for GitHub.
  static auth_interop.OAuthCredential credential(String token) =>
      auth_interop.GithubAuthProviderJsImpl.credential(token.toJS);
}

/// Google auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GoogleAuthProvider>.
class GoogleAuthProvider
    extends AuthProvider<auth_interop.GoogleAuthProviderJsImpl> {
  static String PROVIDER_ID =
      auth_interop.GoogleAuthProviderJsImpl.PROVIDER_ID.toDart;

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
      GoogleAuthProvider.fromJsObject(jsObject.addScope(scope.toJS));

  /// Sets the OAuth custom parameters to pass in a Google OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'hd', 'hl', 'include_granted_scopes',
  /// 'login_hint' and 'prompt'.
  /// For a detailed list, check the Google documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state'
  /// are not allowed and ignored.
  GoogleAuthProvider setCustomParameters(
    Map<Object?, Object?> customOAuthParameters,
  ) {
    return GoogleAuthProvider.fromJsObject(
      jsObject.setCustomParameters(customOAuthParameters.jsify()!),
    );
  }

  /// Creates a credential for Google.
  /// At least one of [idToken] and [accessToken] is required.
  static auth_interop.OAuthCredential credential(
          [String? idToken, String? accessToken]) =>
      auth_interop.GoogleAuthProviderJsImpl.credential(
          idToken?.toJS, accessToken?.toJS);
}

/// OAuth auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GoogleAuthProvider>.
class OAuthProvider extends AuthProvider<auth_interop.OAuthProviderJsImpl> {
  /// Creates a new OAuthProvider.
  factory OAuthProvider(String providerId) => OAuthProvider.fromJsObject(
      auth_interop.OAuthProviderJsImpl(providerId.toJS));

  /// Creates a new OAuthProvider from a [jsObject].
  OAuthProvider.fromJsObject(auth_interop.OAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  OAuthProvider addScope(String scope) =>
      OAuthProvider.fromJsObject(jsObject.addScope(scope.toJS));

  /// Sets the OAuth custom parameters to pass in an OAuth request for popup
  /// and redirect sign-in operations. For a detailed list, check the reserved
  /// required OAuth 2.0 parameters such as client_id, redirect_uri, scope,
  /// response_type and state are not allowed and will be ignored.
  OAuthProvider setCustomParameters(
    Map<Object?, Object?> customOAuthParameters,
  ) {
    return OAuthProvider.fromJsObject(
      jsObject.setCustomParameters(customOAuthParameters.jsify()!),
    );
  }

  /// Creates a credential for Google.
  /// At least one of [idToken] and [accessToken] is required.
  auth_interop.OAuthCredential credential(
          auth_interop.OAuthCredentialOptions credentialOptions) =>
      jsObject.credential(credentialOptions);

  /// Used to extract the underlying OAuthCredential from a UserCredential.
  static auth_interop.OAuthCredential? credentialFromResult(
          auth_interop.UserCredentialJsImpl userCredential) =>
      auth_interop.OAuthProviderJsImpl.credentialFromResult(userCredential);
}

/// Twitter auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.TwitterAuthProvider>.
class TwitterAuthProvider
    extends AuthProvider<auth_interop.TwitterAuthProviderJsImpl> {
  static String PROVIDER_ID =
      auth_interop.TwitterAuthProviderJsImpl.PROVIDER_ID.toDart;

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
    Map<Object?, Object?> customOAuthParameters,
  ) {
    return TwitterAuthProvider.fromJsObject(
      jsObject.setCustomParameters(customOAuthParameters.jsify()!),
    );
  }

  /// Creates a credential for Twitter.
  static auth_interop.OAuthCredential credential(String token, String secret) =>
      auth_interop.TwitterAuthProviderJsImpl.credential(
          token.toJS, secret.toJS);
}

/// SAML auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/auth.samlauthprovider>.
class SAMLAuthProvider
    extends AuthProvider<auth_interop.SAMLAuthProviderJsImpl> {
  /// Creates a new SAMLAuthProvider with the providerId.
  /// The providerId must start with "saml."
  factory SAMLAuthProvider(String providerId) => SAMLAuthProvider.fromJsObject(
      auth_interop.SAMLAuthProviderJsImpl(providerId));

  /// Creates a new SAMLAuthProvider from a [jsObject].
  SAMLAuthProvider.fromJsObject(auth_interop.SAMLAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Used to extract the underlying OAuthCredential from a UserCredential.
  static auth_interop.OAuthCredential? credentialFromResult(
          auth_interop.UserCredentialJsImpl userCredential) =>
      auth_interop.SAMLAuthProviderJsImpl.credentialFromResult(userCredential);
}

/// Phone number auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.PhoneAuthProvider>.
class PhoneAuthProvider
    extends AuthProvider<auth_interop.PhoneAuthProviderJsImpl> {
  static String get PROVIDER_ID =>
      auth_interop.PhoneAuthProviderJsImpl.PROVIDER_ID.toDart;

  /// Creates a new PhoneAuthProvider with the optional [Auth] instance
  /// in which sign-ins should occur.
  factory PhoneAuthProvider([Auth? auth]) =>
      PhoneAuthProvider.fromJsObject(auth != null
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
          dynamic phoneOptions, ApplicationVerifier applicationVerifier) =>
      jsObject
          .verifyPhoneNumber(phoneOptions, applicationVerifier.jsObject)
          .toDart
          .then((value) => (value! as JSString).toDart);

  /// Creates a phone auth credential given the verification ID
  /// from [verifyPhoneNumber] and the [verificationCode] that was sent to the
  /// user's mobile device.
  static auth_interop.PhoneAuthCredentialJsImpl credential(
          String verificationId, String verificationCode) =>
      auth_interop.PhoneAuthProviderJsImpl.credential(
          verificationId.toJS, verificationCode.toJS);
}

/// A verifier for domain verification and abuse prevention.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.ApplicationVerifier>
abstract class ApplicationVerifier<
        T extends auth_interop.ApplicationVerifierJsImpl>
    extends JsObjectWrapper<T> {
  /// Returns the type of application verifier (e.g. 'recaptcha').
  String get type => jsObject.type.toDart;

  /// Creates a new ApplicationVerifier from a [jsObject].
  ApplicationVerifier.fromJsObject(T jsObject) : super.fromJsObject(jsObject);

  /// Executes the verification process.
  /// Returns a Future containing string for a token that can be used to
  /// assert the validity of a request.
  Future<String> verify() =>
      jsObject.verify().toDart.then((value) => (value! as JSString).toDart);
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
  factory RecaptchaVerifier(
      JSAny container, Map<String, dynamic> parameters, Auth auth) {
    return RecaptchaVerifier.fromJsObject(
      auth_interop.RecaptchaVerifierJsImpl(
        auth.jsObject,
        container,
        parameters.jsify(),
      ),
    );
  }

  /// Creates a new RecaptchaVerifier from a [jsObject].
  RecaptchaVerifier.fromJsObject(auth_interop.RecaptchaVerifierJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Clears the reCAPTCHA widget from the page and destroys the current instance.
  void clear() => jsObject.clear();

  /// Renders the reCAPTCHA widget on the page.
  /// Returns a Future that resolves with the reCAPTCHA widget ID.
  Future<int> render() =>
      jsObject.render().toDart.then((value) => (value! as JSNumber).toDartInt);
}

/// A result from a phone number sign-in, link, or reauthenticate call.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.ConfirmationResult>
class ConfirmationResult
    extends JsObjectWrapper<auth_interop.ConfirmationResultJsImpl> {
  /// Returns the phone number authentication operation's verification ID.
  /// This can be used along with the verification code to initialize a phone
  /// auth credential.
  String get verificationId => jsObject.verificationId.toDart;

  /// Creates a new ConfirmationResult from a [jsObject].
  ConfirmationResult.fromJsObject(
      auth_interop.ConfirmationResultJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Finishes a phone number sign-in, link, or reauthentication, given
  /// the code that was sent to the user's mobile device.
  Future<UserCredential> confirm(String verificationCode) => jsObject
      .confirm(verificationCode.toJS)
      .toDart
      .then(UserCredential.fromJsObject);
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

  /// Returns the operation type.
  String get operationType => jsObject.operationType.toDart;

  /// Returns additional user information from a federated identity provider.
  AdditionalUserInfo? get additionalUserInfo => AdditionalUserInfo.fromJsObject(
      auth_interop.getAdditionalUserInfo(jsObject));

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
  String? get providerId => jsObject.providerId?.toDart;

  /// Returns the profile.
  Map<String, dynamic>? get profile => jsObject.profile != null
      ? ((jsObject.profile!).dartify()! as Map).cast<String, dynamic>()
      : null;

  /// Returns the user name.
  String? get username => jsObject.username?.toDart;

  /// Returns whether a user is a new or returning user.
  bool get isNewUser => jsObject.isNewUser.toDart;

  /// Creates a new AdditionalUserInfo from a [jsObject].
  AdditionalUserInfo.fromJsObject(
      auth_interop.AdditionalUserInfoJsImpl jsObject)
      : super.fromJsObject(jsObject);
}
