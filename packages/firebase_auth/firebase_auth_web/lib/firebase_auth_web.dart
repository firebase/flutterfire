// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http_parser/http_parser.dart';

class FirebaseAuthWeb extends FirebaseAuthPlatform {
  static void registerWith(Registrar registrar) {
    FirebaseAuthPlatform.instance = FirebaseAuthWeb();
  }

  firebase.Auth _getAuth(String name) {
    final firebase.App app = firebase.app(name);
    return firebase.auth(app);
  }

  PlatformAdditionalUserInfo _fromJsAdditionalUserInfo(
      firebase.AdditionalUserInfo additionalUserInfo) {
    return PlatformAdditionalUserInfo(
      isNewUser: additionalUserInfo.isNewUser,
      providerId: additionalUserInfo.providerId,
      username: additionalUserInfo.username,
      profile: additionalUserInfo.profile,
    );
  }

  PlatformUserInfo _fromJsUserInfo(firebase.UserInfo userInfo) {
    return PlatformUserInfo(
      providerId: userInfo.providerId,
      uid: userInfo.providerId,
      displayName: userInfo.displayName,
      photoUrl: userInfo.photoURL,
      email: userInfo.email,
      phoneNumber: userInfo.phoneNumber,
    );
  }

  PlatformUser _fromJsUser(firebase.User user) {
    if (user == null) {
      return null;
    }
    return PlatformUser(
      providerId: user.providerId,
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      email: user.email,
      phoneNumber: user.phoneNumber,
      creationTimestamp:
          parseHttpDate(user.metadata.creationTime).millisecondsSinceEpoch,
      lastSignInTimestamp:
          parseHttpDate(user.metadata.lastSignInTime).millisecondsSinceEpoch,
      isAnonymous: user.isAnonymous,
      isEmailVerified: user.emailVerified,
      providerData:
          user.providerData.map<PlatformUserInfo>(_fromJsUserInfo).toList(),
    );
  }

  PlatformAuthResult _fromJsUserCredential(firebase.UserCredential credential) {
    return PlatformAuthResult(
      user: _fromJsUser(credential.user),
      additionalUserInfo: _fromJsAdditionalUserInfo(
        credential.additionalUserInfo,
      ),
    );
  }

  PlatformIdTokenResult _fromJsIdTokenResult(
      firebase.IdTokenResult idTokenResult) {
    return PlatformIdTokenResult(
      token: idTokenResult.token,
      expirationTimestamp: idTokenResult.expirationTime.millisecondsSinceEpoch,
      authTimestamp: idTokenResult.authTime.millisecondsSinceEpoch,
      issuedAtTimestamp: idTokenResult.issuedAtTime.millisecondsSinceEpoch,
      claims: idTokenResult.claims,
      signInProvider: idTokenResult.signInProvider,
    );
  }

  firebase.User _getCurrentUserOrThrow(firebase.Auth auth) {
    final firebase.User user = auth.currentUser;
    if (user == null) {
      throw PlatformException(
        code: 'USER_REQUIRED',
        message: 'Please authenticate with Firebase first',
      );
    }
    return user;
  }

  firebase.OAuthCredential _getCredential(AuthCredential credential) {
    if (credential is EmailAuthCredential) {
      return firebase.EmailAuthProvider.credential(
        credential.email,
        credential.password,
      );
    }
    if (credential is GoogleAuthCredential) {
      return firebase.GoogleAuthProvider.credential(
        credential.idToken,
        credential.accessToken,
      );
    }
    if (credential is FacebookAuthCredential) {
      return firebase.FacebookAuthProvider.credential(credential.accessToken);
    }
    if (credential is TwitterAuthCredential) {
      return firebase.TwitterAuthProvider.credential(
        credential.authToken,
        credential.authTokenSecret,
      );
    }
    if (credential is GithubAuthCredential) {
      return firebase.GithubAuthProvider.credential(credential.token);
    }
    if (credential is PhoneAuthCredential) {
      return firebase.PhoneAuthProvider.credential(
        credential.verificationId,
        credential.smsCode,
      );
    }
    return null;
  }

  @override
  Future<PlatformAuthResult> createUserWithEmailAndPassword(
      String app, String email, String password) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.UserCredential credential =
        await auth.createUserWithEmailAndPassword(email, password);
    return _fromJsUserCredential(credential);
  }

  @override
  Future<void> delete(String app) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User user = _getCurrentUserOrThrow(auth);
    await user.delete();
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String app, String email) {
    final firebase.Auth auth = _getAuth(app);
    return auth.fetchSignInMethodsForEmail(email);
  }

  @override
  Future<PlatformUser> getCurrentUser(String app) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = auth.currentUser;
    return _fromJsUser(currentUser);
  }

  @override
  Future<PlatformIdTokenResult> getIdToken(String app, bool refresh) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = auth.currentUser;
    final firebase.IdTokenResult idTokenResult =
        await currentUser.getIdTokenResult(refresh);
    return _fromJsIdTokenResult(idTokenResult);
  }

  @override
  Future<bool> isSignInWithEmailLink(String app, String link) {
    final firebase.Auth auth = _getAuth(app);
    return Future.value(auth.isSignInWithEmailLink(link));
  }

  @override
  Future<PlatformAuthResult> linkWithCredential(
      String app, AuthCredential credential) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    final firebase.OAuthCredential firebaseCredential =
        _getCredential(credential);
    final firebase.UserCredential userCredential =
        await currentUser.linkWithCredential(firebaseCredential);
    return _fromJsUserCredential(userCredential);
  }

  @override
  Stream<PlatformUser> onAuthStateChanged(String app) {
    final firebase.Auth auth = _getAuth(app);
    return auth.onAuthStateChanged.map<PlatformUser>(_fromJsUser);
  }

  @override
  Future<PlatformAuthResult> reauthenticateWithCredential(
      String app, AuthCredential credential) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    final firebase.OAuthCredential firebaseCredential =
        _getCredential(credential);
    final firebase.UserCredential userCredential =
        await currentUser.reauthenticateWithCredential(firebaseCredential);
    return _fromJsUserCredential(userCredential);
  }

  @override
  Future<void> reload(String app) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    await currentUser.reload();
  }

  @override
  Future<void> sendEmailVerification(String app) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    await currentUser.sendEmailVerification();
  }

  @override
  Future<void> sendLinkToEmail(String app,
      {String email,
      String url,
      bool handleCodeInApp,
      String iOSBundleID,
      String androidPackageName,
      bool androidInstallIfNotAvailable,
      String androidMinimumVersion}) {
    final firebase.Auth auth = _getAuth(app);
    final actionCodeSettings = firebase.ActionCodeSettings(
      url: url,
      handleCodeInApp: handleCodeInApp,
      iOS: firebase.IosSettings(
        bundleId: iOSBundleID,
      ),
      android: firebase.AndroidSettings(
        packageName: androidPackageName,
        installApp: androidInstallIfNotAvailable,
        minimumVersion: androidMinimumVersion,
      ),
    );
    return auth.sendSignInLinkToEmail(email, actionCodeSettings);
  }

  @override
  Future<void> sendPasswordResetEmail(String app, String email) async {
    final firebase.Auth auth = _getAuth(app);
    await auth.sendPasswordResetEmail(email);
  }

  @override
  Future<void> setLanguageCode(String app, String language) async {
    final firebase.Auth auth = _getAuth(app);
    auth.languageCode = language;
  }

  @override
  Future<PlatformAuthResult> signInAnonymously(String app) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.UserCredential userCredential =
        await auth.signInAnonymously();
    return _fromJsUserCredential(userCredential);
  }

  @override
  Future<PlatformAuthResult> signInWithCredential(
      String app, AuthCredential credential) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.OAuthCredential firebaseCredential =
        _getCredential(credential);
    final firebase.UserCredential userCredential =
        await auth.signInWithCredential(firebaseCredential);
    return _fromJsUserCredential(userCredential);
  }

  @override
  Future<PlatformAuthResult> signInWithCustomToken(
      String app, String token) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.UserCredential userCredential =
        await auth.signInWithCustomToken(token);
    return _fromJsUserCredential(userCredential);
  }

  @override
  Future<PlatformAuthResult> signInWithEmailAndLink(
      String app, String email, String link) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.UserCredential userCredential =
        await auth.signInWithEmailLink(email, link);
    return _fromJsUserCredential(userCredential);
  }

  @override
  Future<void> signOut(String app) async {
    final firebase.Auth auth = _getAuth(app);
    await auth.signOut();
  }

  @override
  Future<void> unlinkFromProvider(String app, String provider) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    await currentUser.unlink(provider);
  }

  @override
  Future<void> updateEmail(String app, String email) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    await currentUser.updateEmail(email);
  }

  @override
  Future<void> updatePassword(String app, String password) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    await currentUser.updatePassword(password);
  }

  @override
  Future<void> updatePhoneNumberCredential(
      String app, PhoneAuthCredential phoneAuthCredential) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    final firebase.OAuthCredential credential =
        _getCredential(phoneAuthCredential);
    await currentUser.updatePhoneNumber(credential);
  }

  @override
  Future<void> updateProfile(String app,
      {String displayName, String photoUrl}) async {
    final firebase.Auth auth = _getAuth(app);
    final firebase.User currentUser = _getCurrentUserOrThrow(auth);
    final firebase.UserProfile profile = firebase.UserProfile();
    if (displayName != null) {
      profile.displayName = displayName;
    }
    if (photoUrl != null) {
      profile.photoURL = photoUrl;
    }
    await currentUser.updateProfile(profile);
  }

  @override
  Future<void> verifyPhoneNumber(String app,
      {String phoneNumber,
      Duration timeout,
      int forceResendingToken,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed,
      PhoneCodeSent codeSent,
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout}) async {
    // TODO(hterkelsen): Figure out how to do this on Web. We need to display
    // a DOM element to contain the reCaptcha.
    // See https://github.com/flutter/flutter/issues/46021
    throw UnimplementedError('verifyPhoneNumber');
  }
}
