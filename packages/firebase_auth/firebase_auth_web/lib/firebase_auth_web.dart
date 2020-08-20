// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
// import 'package:firebase_auth_web/firebase_auth_web_confirmation_result.dart';
import 'package:firebase_auth_web/firebase_auth_web_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

import 'firebase_auth_web_recaptcha_verifier_factory.dart';
import 'firebase_auth_web_user_credential.dart';
import 'utils.dart';

/// The web delegate implementation for [FirebaseAuth].
class FirebaseAuthWeb extends FirebaseAuthPlatform {
  /// instance of Auth from the web plugin
  final firebase.Auth _webAuth;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseAuthPlatform.instance = FirebaseAuthWeb.instance;
    RecaptchaVerifierFactoryPlatform.instance =
        RecaptchaVerifierFactoryWeb.instance;
  }

  static Map<String, StreamController<UserPlatform>>
      _authStateChangesListeners = <String, StreamController<UserPlatform>>{};

  static Map<String, StreamController<UserPlatform>> _idTokenChangesListeners =
      <String, StreamController<UserPlatform>>{};

  static Map<String, StreamController<UserPlatform>> _userChangesListeners =
      <String, StreamController<UserPlatform>>{};

  /// Initializes a stub instance to allow the class to be registered.
  static FirebaseAuthWeb get instance {
    return FirebaseAuthWeb._();
  }

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseAuthWeb._()
      : _webAuth = null,
        super(appInstance: null);

  /// The entry point for the [FirebaseAuthWeb] class.
  FirebaseAuthWeb({FirebaseApp app})
      : _webAuth = firebase.auth(firebase.app(app?.name)),
        super(appInstance: app) {
    if (app != null) {
      // Create a app instance broadcast stream for both delegate listener events
      _userChangesListeners[app.name] =
          StreamController<UserPlatform>.broadcast();
      _authStateChangesListeners[app.name] =
          StreamController<UserPlatform>.broadcast();
      _idTokenChangesListeners[app.name] =
          StreamController<UserPlatform>.broadcast();

      _webAuth.onAuthStateChanged.map((firebase.User webUser) {
        if (webUser == null) {
          return null;
        } else {
          return UserWeb(this, webUser);
        }
      }).listen((UserWeb webUser) {
        _authStateChangesListeners[app.name].add(webUser);
      });

      // Also triggers `userChanged` events
      _webAuth.onIdTokenChanged.map((firebase.User webUser) {
        if (webUser == null) {
          return null;
        } else {
          return UserWeb(this, webUser);
        }
      }).listen((UserWeb webUser) {
        _idTokenChangesListeners[app.name].add(webUser);
        _userChangesListeners[app.name].add(webUser);
      });
    }
  }

  @override
  FirebaseAuthPlatform delegateFor({FirebaseApp app}) {
    return FirebaseAuthWeb(app: app);
  }

  @override
  FirebaseAuthWeb setInitialValues({
    Map<String, dynamic> currentUser,
    String languageCode,
  }) {
    // Values are already set on web
    return this;
  }

  @override
  UserPlatform get currentUser {
    firebase.User webCurrentUser = _webAuth.currentUser;

    if (webCurrentUser == null) {
      return null;
    }

    return UserWeb(this, _webAuth.currentUser);
  }

  @override
  void sendAuthChangesEvent(String appName, UserPlatform userPlatform) {
    assert(appName != null);
    assert(_userChangesListeners[appName] != null);

    _userChangesListeners[appName].add(null);
  }

  @override
  Future<void> applyActionCode(String code) {
    try {
      return _webAuth.applyActionCode(code);
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) async {
    return convertWebActionCodeInfo(await _webAuth.checkActionCode(code));
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return UserCredentialWeb(
          this, await _webAuth.createUserWithEmailAndPassword(email, password));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    try {
      return _webAuth.fetchSignInMethodsForEmail(email);
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> getRedirectResult() async {
    try {
      return UserCredentialWeb(this, await _webAuth.getRedirectResult());
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Stream<UserPlatform> authStateChanges() =>
      _authStateChangesListeners[app.name].stream;

  @override
  Stream<UserPlatform> idTokenChanges() =>
      _idTokenChangesListeners[app.name].stream;

  @override
  Stream<UserPlatform> userChanges() => _userChangesListeners[app.name].stream;

  @override
  Future<void> sendPasswordResetEmail(String email,
      [ActionCodeSettings actionCodeSettings]) {
    try {
      return _webAuth.sendPasswordResetEmail(
          email, convertPlatformActionCodeSettings(actionCodeSettings));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendSignInLinkToEmail(String email,
      [ActionCodeSettings actionCodeSettings]) {
    try {
      return _webAuth.sendSignInLinkToEmail(
          email, convertPlatformActionCodeSettings(actionCodeSettings));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<void> setLanguageCode(String languageCode) async {
    _webAuth.languageCode = languageCode;
  }

  // TODO: not supported in firebase-dart
  // @override
  // Future<void> setSettings({bool appVerificationDisabledForTesting}) async {
  //   //
  // }

  @override
  Future<void> setPersistence(Persistence persistence) async {
    try {
      return _webAuth.setPersistence(convertPlatformPersistence(persistence));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInAnonymously() async {
    try {
      return UserCredentialWeb(this, await _webAuth.signInAnonymously());
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  Future<UserCredentialPlatform> signInWithCredential(
      AuthCredential credential) async {
    try {
      return UserCredentialWeb(
          this,
          await _webAuth
              .signInWithCredential(convertPlatformCredential(credential)));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    try {
      return UserCredentialWeb(
          this, await _webAuth.signInWithCustomToken(token));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return UserCredentialWeb(
          this, await _webAuth.signInWithEmailAndPassword(email, password));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailLink(
      String email, String emailLink) async {
    try {
      return UserCredentialWeb(
          this, await _webAuth.signInWithEmailLink(email, emailLink));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  // TODO(ehesp): This is currently unimplemented due to an underlying firebase.ApplicationVerifier issue on the firebase-dart repository.
  // @override
  // Future<ConfirmationResultPlatform> signInWithPhoneNumber(String phoneNumber,
  //     RecaptchaVerifierFactoryPlatform applicationVerifier) async {
  //   return ConfirmationResultWeb(
  //       this,
  //       await _webAuth.signInWithPhoneNumber(phoneNumber,
  //           applicationVerifier.getDelegate<firebase.ApplicationVerifier>()));
  // }

  @override
  Future<UserCredentialPlatform> signInWithPopup(AuthProvider provider) async {
    try {
      return UserCredentialWeb(
          this,
          await _webAuth
              .signInWithPopup(convertPlatformAuthProvider(provider)));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) async {
    try {
      return _webAuth.signInWithRedirect(convertPlatformAuthProvider(provider));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() {
    try {
      return _webAuth.signOut();
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<String> verifyPasswordResetCode(String code) {
    try {
      return _webAuth.verifyPasswordResetCode(code);
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<void> verifyPhoneNumber(
      {@required String phoneNumber,
      @required PhoneVerificationCompleted verificationCompleted,
      @required PhoneVerificationFailed verificationFailed,
      @required PhoneCodeSent codeSent,
      @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      String autoRetrievedSmsCodeForTesting,
      Duration timeout = const Duration(seconds: 30),
      int forceResendingToken}) {
    throw UnimplementedError(
        'verifyPhoneNumber() is not supported on the web. Please use `signInWithPhoneNumber` instead.');
  }
}
