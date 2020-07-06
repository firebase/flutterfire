// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_auth_web/firebase_auth_web_confirmation_result.dart';
import 'package:firebase_auth_web/firebase_auth_web_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

import 'firebase_auth_web_recaptcha_verifier_factory.dart';
import 'firebase_auth_web_user_credential.dart';
import 'utils.dart';

class FirebaseAuthWeb extends FirebaseAuthPlatform {
  /// instance of Auth from the web plugin
  final firebase.Auth _webAuth;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseAuthPlatform.instance = FirebaseAuthWeb();
    RecaptchaVerifierFactoryPlatform.instance =
        RecaptchaVerifierFactoryWeb.instance;
  }

  FirebaseAuthWeb({FirebaseApp app})
      : _webAuth = firebase.auth(firebase.app(app?.name)),
        super(appInstance: app);

  @override
  FirebaseAuthPlatform delegateFor({FirebaseApp app}) {
    return FirebaseAuthWeb(app: app);
  }

  // todo initial values

  @override
  UserPlatform get currentUser {
    firebase.User webCurrentUser = _webAuth.currentUser;

    if (webCurrentUser == null) {
      return null;
    }

    return UserWeb(this, _webAuth.currentUser);
  }

  @override
  Future<void> applyActionCode(String code) {
    return _webAuth.applyActionCode(code);
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) async {
    return convertWebActionCodeInfo(await _webAuth.checkActionCode(code));
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) async {
    return UserCredentialWeb(
        this, await _webAuth.createUserWithEmailAndPassword(email, password));
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    return _webAuth.fetchSignInMethodsForEmail(email);
  }

  @override
  Future<UserCredentialPlatform> getRedirectResult() async {
    return UserCredentialWeb(this, await _webAuth.getRedirectResult());
  }

  @override
  Stream<UserPlatform> authStateChanges() {
    return _webAuth.onAuthStateChanged.map((firebase.User webUser) {
      return UserWeb(this, webUser);
    });
  }

  @override
  Stream<UserPlatform> idTokenChanges() {
    return _webAuth.onIdTokenChanged.map((firebase.User webUser) {
      return UserWeb(this, webUser);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email,
      [ActionCodeSettings actionCodeSettings]) {
    return _webAuth.sendPasswordResetEmail(
        email, convertPlatformActionCodeSettings(actionCodeSettings));
  }

  @override
  Future<void> sendSignInWithEmailLink(String email,
      [ActionCodeSettings actionCodeSettings]) {
    return _webAuth.sendSignInLinkToEmail(
        email, convertPlatformActionCodeSettings(actionCodeSettings));
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
    return _webAuth.setPersistence(convertPlatformPersistence(persistence));
  }

  @override
  Future<UserCredentialPlatform> signInAnonymously() async {
    return UserCredentialWeb(this, await _webAuth.signInAnonymously());
  }

  Future<UserCredentialPlatform> signInWithCredential(
      AuthCredential credential) async {
    return UserCredentialWeb(
        this,
        await _webAuth
            .signInWithCredential(convertPlatformCredential(credential)));
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    return UserCredentialWeb(this, await _webAuth.signInWithCustomToken(token));
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    return UserCredentialWeb(
        this, await _webAuth.signInWithEmailAndPassword(email, password));
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailLink(
      String email, String emailLink) async {
    return UserCredentialWeb(
        this, await _webAuth.signInWithEmailLink(email, emailLink));
  }

  @override
  Future<ConfirmationResultPlatform> signInWithPhoneNumber(
      String phoneNumber, RecaptchaVerifierPlatform applicationVerifier) async {
    return ConfirmationResultlWeb(
        this,
        await _webAuth.signInWithPhoneNumber(phoneNumber,
            RecaptchaVerifierPlatform.getDelegate(applicationVerifier)));
  }

  @override
  Future<UserCredentialPlatform> signInWithPopup(AuthProvider provider) async {
    return UserCredentialWeb(this,
        await _webAuth.signInWithPopup(convertPlatformAuthProvider(provider)));
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) async {
    return _webAuth.signInWithRedirect(convertPlatformAuthProvider(provider));
  }

  @override
  Future<void> signOut() {
    return _webAuth.signOut();
  }

  @override
  Future<String> verifyPasswordResetCode(String code) {
    return _webAuth.verifyPasswordResetCode(code);
  }

  @override
  Future<void> verifyPhoneNumber(
      {@required String phoneNumber,
      @required PhoneVerificationCompleted verificationCompleted,
      @required PhoneVerificationFailed verificationFailed,
      @required PhoneCodeSent codeSent,
      @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      Duration timeout = const Duration(seconds: 30),
      int forceResendingToken,
      bool requireSmsValidation}) {
    throw UnimplementedError(
        'verifyPhoneNumber() is not supported on the web. Please use `signInWithPhoneNumber` instead.');
  }
}
