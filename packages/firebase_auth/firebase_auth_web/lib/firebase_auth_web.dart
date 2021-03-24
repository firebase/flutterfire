// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/utils/web_utils.dart';
import 'src/interop/auth.dart' as auth_interop;
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/firebase_auth_web_user.dart';
import 'src/firebase_auth_web_recaptcha_verifier_factory.dart';
import 'src/firebase_auth_web_user_credential.dart';
import 'src/firebase_auth_web_confirmation_result.dart';

/// The web delegate implementation for [FirebaseAuth].
class FirebaseAuthWeb extends FirebaseAuthPlatform {
  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseAuthWeb._()
      : _webAuth = null,
        super(appInstance: null);

  /// The entry point for the [FirebaseAuthWeb] class.
  FirebaseAuthWeb({required FirebaseApp app})
      : _webAuth = auth_interop.getAuthInstance(core_interop.app(app.name)),
        super(appInstance: app) {
    // Create a app instance broadcast stream for both delegate listener events
    _userChangesListeners[app.name] =
        StreamController<UserPlatform?>.broadcast();
    _authStateChangesListeners[app.name] =
        StreamController<UserPlatform?>.broadcast();
    _idTokenChangesListeners[app.name] =
        StreamController<UserPlatform?>.broadcast();

    // TODO(rrousselGit): close StreamSubscription
    _webAuth!.onAuthStateChanged.map((auth_interop.User? webUser) {
      if (webUser == null) {
        return null;
      } else {
        return UserWeb(this, webUser);
      }
    }).listen((UserWeb? webUser) {
      _authStateChangesListeners[app.name]!.add(webUser);
    });

    // TODO(rrousselGit): close StreamSubscription
    // Also triggers `userChanged` events
    _webAuth!.onIdTokenChanged.map((auth_interop.User? webUser) {
      if (webUser == null) {
        return null;
      } else {
        return UserWeb(this, webUser);
      }
    }).listen((UserWeb? webUser) {
      _idTokenChangesListeners[app.name]!.add(webUser);
      _userChangesListeners[app.name]!.add(webUser);
    });
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseAuthPlatform.instance = FirebaseAuthWeb.instance;
    RecaptchaVerifierFactoryPlatform.instance =
        RecaptchaVerifierFactoryWeb.instance;
  }

  static Map<String, StreamController<UserPlatform?>>
      _authStateChangesListeners = <String, StreamController<UserPlatform?>>{};

  static Map<String, StreamController<UserPlatform?>> _idTokenChangesListeners =
      <String, StreamController<UserPlatform?>>{};

  static Map<String, StreamController<UserPlatform?>> _userChangesListeners =
      <String, StreamController<UserPlatform?>>{};

  /// Initializes a stub instance to allow the class to be registered.
  static FirebaseAuthWeb get instance {
    return FirebaseAuthWeb._();
  }

  /// instance of Auth from the web plugin
  final auth_interop.Auth? _webAuth;

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return FirebaseAuthWeb(app: app);
  }

  @override
  FirebaseAuthWeb setInitialValues({
    Map<String, dynamic>? currentUser,
    String? languageCode,
  }) {
    // Values are already set on web
    return this;
  }

  @override
  UserPlatform? get currentUser {
    auth_interop.User? webCurrentUser = _webAuth!.currentUser;

    if (webCurrentUser == null) {
      return null;
    }

    return UserWeb(this, _webAuth!.currentUser!);
  }

  @override
  void sendAuthChangesEvent(String appName, UserPlatform? userPlatform) {
    assert(_userChangesListeners[appName] != null);

    _userChangesListeners[appName]!.add(userPlatform);
  }

  @override
  Future<void> applyActionCode(String code) async {
    try {
      await _webAuth!.applyActionCode(code);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) async {
    try {
      return convertWebActionCodeInfo(await _webAuth!.checkActionCode(code))!;
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _webAuth!.confirmPasswordReset(code, newPassword);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return UserCredentialWeb(
        this,
        await _webAuth!.createUserWithEmailAndPassword(email, password),
      );
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      return await _webAuth!.fetchSignInMethodsForEmail(email);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> getRedirectResult() async {
    try {
      return UserCredentialWeb(this, await _webAuth!.getRedirectResult());
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Stream<UserPlatform?> authStateChanges() =>
      _authStateChangesListeners[app.name]!.stream;

  @override
  Stream<UserPlatform?> idTokenChanges() =>
      _idTokenChangesListeners[app.name]!.stream;

  @override
  Stream<UserPlatform?> userChanges() =>
      _userChangesListeners[app.name]!.stream;

  @override
  Future<void> sendPasswordResetEmail(
    String email, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    try {
      await _webAuth!.sendPasswordResetEmail(
          email, convertPlatformActionCodeSettings(actionCodeSettings));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendSignInLinkToEmail(
    String email, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    try {
      await _webAuth!.sendSignInLinkToEmail(
          email, convertPlatformActionCodeSettings(actionCodeSettings));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  String get languageCode {
    return _webAuth!.languageCode;
  }

  @override
  Future<void> setLanguageCode(String languageCode) async {
    _webAuth!.languageCode = languageCode;
  }

  @override
  Future<void> setSettings(
      {bool? appVerificationDisabledForTesting,
      String? userAccessGroup}) async {
    _webAuth!.settings.appVerificationDisabledForTesting =
        appVerificationDisabledForTesting;
  }

  @override
  Future<void> setPersistence(Persistence persistence) async {
    try {
      return _webAuth!.setPersistence(convertPlatformPersistence(persistence));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInAnonymously() async {
    try {
      return UserCredentialWeb(this, await _webAuth!.signInAnonymously());
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithCredential(
      AuthCredential credential) async {
    try {
      return UserCredentialWeb(
          this,
          await _webAuth!
              .signInWithCredential(convertPlatformCredential(credential)!));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    try {
      return UserCredentialWeb(
          this, await _webAuth!.signInWithCustomToken(token));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return UserCredentialWeb(
          this, await _webAuth!.signInWithEmailAndPassword(email, password));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailLink(
      String email, String emailLink) async {
    try {
      return UserCredentialWeb(
          this, await _webAuth!.signInWithEmailLink(email, emailLink));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<ConfirmationResultPlatform> signInWithPhoneNumber(
    String phoneNumber,
    RecaptchaVerifierFactoryPlatform applicationVerifier,
  ) async {
    try {
      // Do not inline - type is not inferred & error is thrown.
      auth_interop.RecaptchaVerifier verifier = applicationVerifier.delegate;

      return ConfirmationResultWeb(
          this, await _webAuth!.signInWithPhoneNumber(phoneNumber, verifier));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithPopup(AuthProvider provider) async {
    try {
      return UserCredentialWeb(
          this,
          await _webAuth!
              .signInWithPopup(convertPlatformAuthProvider(provider)!));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) async {
    try {
      return _webAuth!
          .signInWithRedirect(convertPlatformAuthProvider(provider)!);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _webAuth!.signOut();
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> useEmulator(String host, int port) async {
    try {
      // The generic platform interface is with host and port split to
      // centralize logic between android/ios native, but web takes the
      // origin as a single string
      _webAuth!.useEmulator('http://$host:$port');
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<String> verifyPasswordResetCode(String code) async {
    try {
      return await _webAuth!.verifyPasswordResetCode(code);
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
  }) {
    throw UnimplementedError(
        'verifyPhoneNumber() is not supported on the web. Please use `signInWithPhoneNumber` instead.');
  }
}
