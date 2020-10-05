// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/firebase_auth_exception.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user.dart';
import 'package:firebase_auth_platform_interface/src/platform_interface/platform_interface_user_credential.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'method_channel_user_credential.dart';
import 'utils/exception.dart';
import 'utils/phone_auth_callbacks.dart';

/// Method Channel delegate for [FirebaseAuthPlatform].
class MethodChannelFirebaseAuth extends FirebaseAuthPlatform {
  /// Keep an internal reference to whether the [MethodChannelFirebaseAuth]
  /// class has already been initialized.
  static bool _initialized = false;

  /// Keeps an internal handle ID for the channel.
  static int _methodChannelHandleId = 0;

  /// Increments and returns the next channel ID handler for Auth.
  static int get nextMethodChannelHandleId => _methodChannelHandleId++;

  /// The [MethodChannelFirebaseAuth] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  static Map<String, MethodChannelFirebaseAuth>
      _methodChannelFirebaseAuthInstances =
      <String, MethodChannelFirebaseAuth>{};

  static Map<String, StreamController<UserPlatform>>
      _authStateChangesListeners = <String, StreamController<UserPlatform>>{};

  static Map<String, StreamController<UserPlatform>> _idTokenChangesListeners =
      <String, StreamController<UserPlatform>>{};

  static Map<String, StreamController<UserPlatform>> _userChangesListeners =
      <String, StreamController<UserPlatform>>{};

  static Map<int, PhoneAuthCallbacks> _phoneAuthCallbacks = {};

  StreamController<T> _createBroadcastStream<T>() {
    return StreamController<T>.broadcast();
  }

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseAuth get instance {
    return MethodChannelFirebaseAuth._();
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseAuth._() : super(appInstance: null);

  /// Creates a new instance with a given [FirebaseApp].
  MethodChannelFirebaseAuth({FirebaseApp app}) : super(appInstance: app) {
    // Send a request to start listening to change listeners straight away
    channel
        .invokeMethod<void>('Auth#registerChangeListeners', <String, dynamic>{
      'appName': app.name,
    });

    // Create a app instance broadcast stream for native listener events
    _authStateChangesListeners[app.name] =
        _createBroadcastStream<UserPlatform>();
    _idTokenChangesListeners[app.name] = _createBroadcastStream<UserPlatform>();
    _userChangesListeners[app.name] = _createBroadcastStream<UserPlatform>();

    // The channel setMethodCallHandler callback is not app specific, so there
    // is no need to register the caller more than once.
    if (_initialized) return;

    channel.setMethodCallHandler((MethodCall call) async {
      Map<dynamic, dynamic> arguments = call.arguments;

      switch (call.method) {
        case 'Auth#authStateChanges':
          return _handleAuthStateChangesListener(arguments);
        case 'Auth#idTokenChanges':
          return _handleIdTokenChangesListener(arguments);
        case 'Auth#phoneVerificationCompleted':
          return _handlePhoneVerificationCompleted(arguments);
        case 'Auth#phoneVerificationFailed':
          return _handlePhoneVerificationFailed(arguments);
        case 'Auth#phoneCodeSent':
          return _handlePhoneCodeSent(arguments);
        case 'Auth#phoneCodeAutoRetrievalTimeout':
          return _handlePhoneCodeAutoRetrievalTimeout(arguments);
        default:
          throw UnimplementedError("${call.method} has not been implemented");
      }
    });

    _initialized = true;
  }

  UserPlatform _currentUser;

  @override
  UserPlatform get currentUser {
    return _currentUser;
  }

  @override
  set currentUser(UserPlatform userPlatform) {
    _currentUser = userPlatform;
  }

  String languageCode;

  @override
  void sendAuthChangesEvent(String appName, UserPlatform userPlatform) {
    assert(appName != null);
    assert(_userChangesListeners[appName] != null);

    _userChangesListeners[appName].add(userPlatform);
  }

  /// Handles any incoming [authChanges] listener events.
  // Duplicate setting of [currentUser] in [_handleAuthStateChangesListener] & [_handleIdTokenChangesListener]
  // as iOS & Android do not guarantee correct ordering
  Future<void> _handleAuthStateChangesListener(
      Map<dynamic, dynamic> arguments) async {
    String appName = arguments['appName'];
    StreamController<UserPlatform> streamController =
        _authStateChangesListeners[appName];
    MethodChannelFirebaseAuth instance =
        _methodChannelFirebaseAuthInstances[appName];

    if (arguments['user'] == null) {
      instance.currentUser = null;
      streamController.add(null);
    } else {
      final Map<String, dynamic> userMap =
          Map<String, dynamic>.from(arguments['user']);
      MethodChannelUser user = MethodChannelUser(instance, userMap);
      instance.currentUser = user;
      streamController.add(MethodChannelUser(instance, userMap));
    }
  }

  /// Handles any incoming [idTokenChanges] listener events.
  ///
  /// This handler also manages the [currentUser] along with sending events
  /// to any [userChanges] stream subscribers.
  Future<void> _handleIdTokenChangesListener(
      Map<dynamic, dynamic> arguments) async {
    String appName = arguments['appName'];
    StreamController<UserPlatform> idTokenStreamController =
        _idTokenChangesListeners[appName];
    StreamController<UserPlatform> userChangesStreamController =
        _userChangesListeners[appName];
    MethodChannelFirebaseAuth instance =
        _methodChannelFirebaseAuthInstances[appName];

    if (arguments['user'] == null) {
      instance.currentUser = null;
      idTokenStreamController.add(null);
      userChangesStreamController.add(null);
    } else {
      final Map<String, dynamic> userMap =
          Map<String, dynamic>.from(arguments['user']);

      MethodChannelUser user = MethodChannelUser(instance, userMap);
      instance.currentUser = user;
      idTokenStreamController.add(user);
      userChangesStreamController.add(user);
    }
  }

  Future<void> _handlePhoneVerificationCompleted(
      Map<dynamic, dynamic> arguments) async {
    final int handle = arguments['handle'];
    final int token = arguments['token'];
    final String smsCode = arguments['smsCode'];

    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credentialFromToken(token, smsCode: smsCode);
    PhoneAuthCallbacks callbacks = _phoneAuthCallbacks[handle];
    callbacks.verificationCompleted(phoneAuthCredential);
  }

  Future<void> _handlePhoneVerificationFailed(
      Map<dynamic, dynamic> arguments) async {
    final int handle = arguments['handle'];
    final Map<dynamic, dynamic> error = arguments['error'];
    final Map<dynamic, dynamic> details = error['details'];

    PhoneAuthCallbacks callbacks = _phoneAuthCallbacks[handle];

    FirebaseAuthException exception = FirebaseAuthException(
      message: details != null ? details['message'] : error['message'],
      code: details != null ? details['code'] : 'unknown',
    );

    callbacks.verificationFailed(exception);
  }

  Future<void> _handlePhoneCodeSent(Map<dynamic, dynamic> arguments) async {
    final int handle = arguments['handle'];
    final String verificationId = arguments['verificationId'];
    final int forceResendingToken = arguments['forceResendingToken'];

    PhoneAuthCallbacks callbacks = _phoneAuthCallbacks[handle];
    callbacks.codeSent(verificationId, forceResendingToken);
  }

  Future<void> _handlePhoneCodeAutoRetrievalTimeout(
      Map<dynamic, dynamic> arguments) async {
    final int handle = arguments['handle'];
    final String verificationId = arguments['verificationId'];

    PhoneAuthCallbacks callbacks = _phoneAuthCallbacks[handle];
    callbacks.codeAutoRetrievalTimeout(verificationId);
  }

  /// Gets a [FirebaseAuthPlatform] with specific arguments such as a different
  /// [FirebaseApp].
  ///
  /// Instances are cached and reused for incoming event handlers.
  @override
  FirebaseAuthPlatform delegateFor({FirebaseApp app}) {
    if (!_methodChannelFirebaseAuthInstances.containsKey(app.name)) {
      _methodChannelFirebaseAuthInstances[app.name] =
          MethodChannelFirebaseAuth(app: app);
    }

    return _methodChannelFirebaseAuthInstances[app.name];
  }

  @override
  MethodChannelFirebaseAuth setInitialValues({
    Map<String, dynamic> currentUser,
    String languageCode,
  }) {
    if (currentUser != null) {
      this.currentUser = MethodChannelUser(this, currentUser);
    }

    this.languageCode = languageCode;
    return this;
  }

  @override
  Future<void> applyActionCode(String code) async {
    await channel.invokeMethod<void>('Auth#applyActionCode', <String, dynamic>{
      'appName': app.name,
      'code': code,
    }).catchError(catchPlatformException);
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) async {
    Map<String, dynamic> result = await channel
        .invokeMapMethod<String, dynamic>(
            'Auth#checkActionCode', <String, dynamic>{
      'appName': app.name,
      'code': code,
    }).catchError(catchPlatformException);

    return ActionCodeInfo(
      operation: result['operation'],
      data: Map<String, dynamic>.from(result['data']),
    );
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    await channel
        .invokeMethod<void>('Auth#confirmPasswordReset', <String, dynamic>{
      'appName': app.name,
      'code': code,
      'newPassword': newPassword,
    }).catchError(catchPlatformException);
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#createUserWithEmailAndPassword', <String, dynamic>{
      'appName': app.name,
      'email': email,
      'password': password,
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(this, data);

    currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#fetchSignInMethodsForEmail', <String, dynamic>{
      'appName': app.name,
      'email': email,
    }).catchError(catchPlatformException);

    return List<String>.from(data['providers']);
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
    return channel
        .invokeMethod<void>('Auth#sendPasswordResetEmail', <String, dynamic>{
      'appName': app.name,
      'email': email,
      'actionCodeSettings': actionCodeSettings?.asMap(),
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> sendSignInLinkToEmail(
      String email, ActionCodeSettings actionCodeSettings) {
    return channel
        .invokeMethod<void>('Auth#sendSignInLinkToEmail', <String, dynamic>{
      'appName': app.name,
      'email': email,
      'actionCodeSettings': actionCodeSettings.asMap(),
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> setLanguageCode(String languageCode) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#setLanguageCode', <String, dynamic>{
      'appName': app.name,
      'languageCode': languageCode,
    }).catchError(catchPlatformException);

    this.languageCode = data['languageCode'];
  }

  @override
  Future<void> setSettings(
      {bool appVerificationDisabledForTesting, String userAccessGroup}) async {
    await channel.invokeMethod('Auth#setSettings', <String, dynamic>{
      'appName': app.name,
      'appVerificationDisabledForTesting': appVerificationDisabledForTesting,
      'userAccessGroup': userAccessGroup,
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> setPersistence(Persistence persistence) {
    throw UnimplementedError(
        'setPersistence() is only supported on web based platforms');
  }

  @override
  Future<UserCredentialPlatform> signInAnonymously() async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#signInAnonymously', <String, dynamic>{
      'appName': app.name,
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(this, data);

    currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<UserCredentialPlatform> signInWithCredential(
      AuthCredential credential) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#signInWithCredential', <String, dynamic>{
      'appName': app.name,
      'credential': credential.asMap(),
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(this, data);

    currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#signInWithCustomToken', <String, dynamic>{
      'appName': app.name,
      'token': token,
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(this, data);

    currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#signInWithEmailAndPassword', <String, dynamic>{
      'appName': app.name,
      'email': email,
      'password': password,
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(this, data);

    currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailLink(
      String email, String emailLink) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#signInWithEmailLink', <String, dynamic>{
      'appName': app.name,
      'email': email,
      'emailLink': emailLink,
    }).catchError(catchPlatformException);

    MethodChannelUserCredential userCredential =
        MethodChannelUserCredential(this, data);

    currentUser = userCredential.user;
    return userCredential;
  }

  @override
  Future<UserCredentialPlatform> signInWithPopup(AuthProvider provider) {
    throw UnimplementedError(
        'signInWithPopup() is only supported on web based platforms');
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) {
    throw UnimplementedError(
        'signInWithRedirect() is only supported on web based platforms');
  }

  Future<void> signOut() async {
    await channel.invokeMethod<void>('Auth#signOut', <String, dynamic>{
      'appName': app.name,
    }).catchError(catchPlatformException);

    currentUser = null;
  }

  Future<String> verifyPasswordResetCode(String code) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#verifyPasswordResetCode', <String, dynamic>{
      'appName': app.name,
      'code': code,
    }).catchError(catchPlatformException);

    return data['email'];
  }

  Future<void> verifyPhoneNumber({
    String phoneNumber,
    PhoneVerificationCompleted verificationCompleted,
    PhoneVerificationFailed verificationFailed,
    PhoneCodeSent codeSent,
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    String autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int forceResendingToken,
  }) {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      throw UnimplementedError(
          "verifyPhoneNumber() is not available on MacOS platforms.");
    }

    int handle = MethodChannelFirebaseAuth.nextMethodChannelHandleId;

    _phoneAuthCallbacks[handle] = PhoneAuthCallbacks(verificationCompleted,
        verificationFailed, codeSent, codeAutoRetrievalTimeout);

    return channel
        .invokeMethod<void>('Auth#verifyPhoneNumber', <String, dynamic>{
      'appName': app.name,
      'handle': handle,
      'phoneNumber': phoneNumber,
      'timeout': timeout.inMilliseconds,
      'forceResendingToken': forceResendingToken,
      'autoRetrievedSmsCodeForTesting': autoRetrievedSmsCodeForTesting,
    }).catchError(catchPlatformException);
  }
}
