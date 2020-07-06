// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/firebase_auth_exception.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_user.dart';
import 'package:firebase_auth_platform_interface/src/platform_interface/platform_interface_user_credential.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'method_channel_user_credential.dart';
import 'utils/exception.dart';
import 'utils/phone_auth_callbacks.dart';

class MethodChannelFirebaseAuth extends FirebaseAuthPlatform {
  /// Keep an internal reference to whether the [MethodChannelFirebaseAuth] class
  ///  has already been initialized.
  static bool _initialized = false;

  /// Keeps an internal handle ID for the channel.
  static int _methodChannelHandleId = 0;

  /// Increments and returns the next channel ID handler for Auth.
  static int get nextMethodChannelHandleId => _methodChannelHandleId++;

  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  static Map<String, StreamController<UserPlatform>>
      _authStateChangesListeners = <String, StreamController<UserPlatform>>{};

  static Map<String, StreamController<UserPlatform>> _idTokenChangesListeners =
      <String, StreamController<UserPlatform>>{};

  static Map<String, StreamController<UserPlatform>> _userChangesListeners =
      <String, StreamController<UserPlatform>>{};

  static Map<int, PhoneAuthCallbacks> _phoneAuthCallbacks = {};

  StreamController<T> createBroadcastStream<T>() {
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

  MethodChannelFirebaseAuth({FirebaseApp app}) : super(appInstance: app) {
    // Send a request to start listening to change listeners straight away
    channel
        .invokeMethod<void>('Auth#registerChangeListeners', <String, dynamic>{
      'appName': app.name,
    });

    // Create a app instance broadcast stream for both native listener events
    _authStateChangesListeners[app.name] =
        createBroadcastStream<UserPlatform>();
    _idTokenChangesListeners[app.name] = createBroadcastStream<UserPlatform>();
    _userChangesListeners[app.name] = createBroadcastStream<UserPlatform>();

    // The channel setMethodCallHandler callback is not app specific, so there is no
    // need to register the caller twice.
    if (_initialized) return;

    channel.setMethodCallHandler((MethodCall call) async {
      Map<dynamic, dynamic> arguments = call.arguments;

      switch (call.method) {
        case 'Auth#authStateChanges':
          return _handleChangeListener(
              _authStateChangesListeners[arguments['appName']], arguments);
        case 'Auth#idTokenChanges':
          return _handleChangeListener(
              _idTokenChangesListeners[arguments['appName']], arguments);
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

  /// Returns the current user, or `null` if the user is not signed in.
  /// 
  /// You should not use this getter to determine the users authentication state.
  /// Instead, use the [authStateChanges], [idTokenChanges] or [userChanges] streams.
  UserPlatform currentUser;

  /// The current language code for this instance.
  /// 
  /// If `null`, the language used will be that of your Firebase project. To change
  /// the language, see [setLanguage].
  String languageCode;

  @override
  void setCurrentUser(UserPlatform userPlatform) {
    _userChangesListeners[app.name].add(userPlatform);
    currentUser = userPlatform;
  }

  /// Handles an incoming change listener (authStateChanges or idTokenChanges) and
  /// fans out the result to any subscribers.
  Future<void> _handleChangeListener(
      StreamController<UserPlatform> streamController,
      Map<dynamic, dynamic> arguments) async {
    if (arguments['user'] == null) {
      setCurrentUser(null);
      streamController.add(null);
    } else {
      final Map<String, dynamic> userMap =
          Map<String, dynamic>.from(arguments['user']);

      MethodChannelUser methodChannelUser = MethodChannelUser(this, userMap);
      setCurrentUser(methodChannelUser);
      streamController.add(methodChannelUser);
    }
  }

  Future<void> _handlePhoneVerificationCompleted(
      Map<dynamic, dynamic> arguments) async {
    final int handle = arguments['handle'];
    final int token = arguments['token'];

    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credentialFromToken(token);
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
  @override
  FirebaseAuthPlatform delegateFor({FirebaseApp app}) {
    return MethodChannelFirebaseAuth(app: app);
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
      data: result['data'],
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

    setCurrentUser(userCredential.user);
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
  Future<void> sendSignInWithEmailLink(
      String email, ActionCodeSettings actionCodeSettings) {
    return channel
        .invokeMethod<void>('Auth#sendPasswordResetEmail', <String, dynamic>{
      'appName': app.name,
      'email': email,
      'actionCodeSettings': actionCodeSettings.asMap(),
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> setLanguageCode(String languageCode) async {
    this.languageCode = await channel
        .invokeMethod<String>('Auth#setLanguageCode', <String, dynamic>{
      'appName': app.name,
      'languageCode': languageCode,
    }).catchError(catchPlatformException);
  }

  @override
  Future<void> setSettings({bool appVerificationDisabledForTesting}) async {
    await channel
        .invokeMethod<String>('Auth#setSettings', <String, dynamic>{
      'appName': app.name,
      'appVerificationDisabledForTesting': appVerificationDisabledForTesting,
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

    setCurrentUser(userCredential.user);
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

    setCurrentUser(userCredential.user);
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

    setCurrentUser(userCredential.user);
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

    setCurrentUser(userCredential.user);
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

    setCurrentUser(userCredential.user);
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

    setCurrentUser(null);
  }

  Future<String> verifyPasswordResetCode(String code) async {
    Map<String, dynamic> data = await channel.invokeMapMethod<String, dynamic>(
        'Auth#verifyPasswordResetCode', <String, dynamic>{
      'appName': app.name,
      'code': code,
    }).catchError(catchPlatformException);

    return data['code'];
  }

  Future<void> verifyPhoneNumber({
    String phoneNumber,
    PhoneVerificationCompleted verificationCompleted,
    PhoneVerificationFailed verificationFailed,
    PhoneCodeSent codeSent,
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 30),
    int forceResendingToken,
    bool requireSmsValidation,
  }) {
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
      'requireSmsValidation': requireSmsValidation,
    }).catchError(catchPlatformException);
  }
}
