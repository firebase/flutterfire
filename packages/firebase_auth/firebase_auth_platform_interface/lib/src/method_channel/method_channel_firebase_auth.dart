// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../firebase_auth_platform_interface.dart';
import '../firebase_auth_exception.dart';
import '../platform_interface/platform_interface_user_credential.dart';
import 'method_channel_user.dart';
import 'method_channel_user_credential.dart';
import 'utils/exception.dart';

/// Method Channel delegate for [FirebaseAuthPlatform].
class MethodChannelFirebaseAuth extends FirebaseAuthPlatform {
  /// The [MethodChannelFirebaseAuth] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  static Map<String, MethodChannelFirebaseAuth>
      _methodChannelFirebaseAuthInstances =
      <String, MethodChannelFirebaseAuth>{};

  static final Map<String, StreamController<_ValueWrapper<UserPlatform>>>
      _authStateChangesListeners =
      <String, StreamController<_ValueWrapper<UserPlatform>>>{};

  static final Map<String, StreamController<_ValueWrapper<UserPlatform>>>
      _idTokenChangesListeners =
      <String, StreamController<_ValueWrapper<UserPlatform>>>{};

  static final Map<String, StreamController<_ValueWrapper<UserPlatform>>>
      _userChangesListeners =
      <String, StreamController<_ValueWrapper<UserPlatform>>>{};

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
  MethodChannelFirebaseAuth({required FirebaseApp app})
      : super(appInstance: app) {
    channel.invokeMethod<String>('Auth#registerIdTokenListener', {
      'appName': app.name,
    }).then((channelName) {
      final events = EventChannel(channelName!, channel.codec);
      events.receiveBroadcastStream().listen(
        (arguments) {
          _handleIdTokenChangesListener(app.name, arguments);
        },
      );
    });

    channel.invokeMethod<String>('Auth#registerAuthStateListener', {
      'appName': app.name,
    }).then((channelName) {
      final events = EventChannel(channelName!, channel.codec);
      events.receiveBroadcastStream().listen(
        (arguments) {
          _handleAuthStateChangesListener(app.name, arguments);
        },
      );
    });

    // Create a app instance broadcast stream for native listener events
    _authStateChangesListeners[app.name] =
        _createBroadcastStream<_ValueWrapper<UserPlatform>>();
    _idTokenChangesListeners[app.name] =
        _createBroadcastStream<_ValueWrapper<UserPlatform>>();
    _userChangesListeners[app.name] =
        _createBroadcastStream<_ValueWrapper<UserPlatform>>();
  }

  @override
  UserPlatform? currentUser;

  @override
  String? languageCode;

  @override
  void sendAuthChangesEvent(String appName, UserPlatform? userPlatform) {
    assert(_userChangesListeners[appName] != null);

    _userChangesListeners[appName]!.add(_ValueWrapper(userPlatform));
  }

  /// Handles any incoming [authChanges] listener events.
  // Duplicate setting of [currentUser] in [_handleAuthStateChangesListener] & [_handleIdTokenChangesListener]
  // as iOS & Android do not guarantee correct ordering
  Future<void> _handleAuthStateChangesListener(
      String appName, Map<dynamic, dynamic> arguments) async {
    // ignore: close_sinks
    final streamController = _authStateChangesListeners[appName]!;
    MethodChannelFirebaseAuth instance =
        _methodChannelFirebaseAuthInstances[appName]!;

    final userMap = arguments['user'];
    if (userMap == null) {
      instance.currentUser = null;
      streamController.add(const _ValueWrapper.absent());
    } else {
      final MethodChannelUser user =
          MethodChannelUser(instance, userMap.cast<String, dynamic>());

      // TODO(rousselGit): should this logic be moved to the setter instead?
      instance.currentUser = user;
      streamController.add(_ValueWrapper(instance.currentUser));
    }
  }

  /// Handles any incoming [idTokenChanges] listener events.
  ///
  /// This handler also manages the [currentUser] along with sending events
  /// to any [userChanges] stream subscribers.
  Future<void> _handleIdTokenChangesListener(
      String appName, Map<dynamic, dynamic> arguments) async {
    final StreamController<_ValueWrapper<UserPlatform>>
        // ignore: close_sinks
        idTokenStreamController = _idTokenChangesListeners[appName]!;
    final StreamController<_ValueWrapper<UserPlatform>>
        // ignore: close_sinks
        userChangesStreamController = _userChangesListeners[appName]!;
    MethodChannelFirebaseAuth instance =
        _methodChannelFirebaseAuthInstances[appName]!;

    final userMap = arguments['user'];
    if (userMap == null) {
      instance.currentUser = null;
      idTokenStreamController.add(const _ValueWrapper.absent());
      userChangesStreamController.add(const _ValueWrapper.absent());
    } else {
      final MethodChannelUser user =
          MethodChannelUser(instance, userMap.cast<String, dynamic>());

      // TODO(rousselGit): should this logic be moved to the setter instead?
      instance.currentUser = user;
      idTokenStreamController.add(_ValueWrapper(user));
      userChangesStreamController.add(_ValueWrapper(user));
    }
  }

  /// Gets a [FirebaseAuthPlatform] with specific arguments such as a different
  /// [FirebaseApp].
  ///
  /// Instances are cached and reused for incoming event handlers.
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return _methodChannelFirebaseAuthInstances.putIfAbsent(app.name, () {
      return MethodChannelFirebaseAuth(app: app);
    });
  }

  @override
  MethodChannelFirebaseAuth setInitialValues({
    Map<String, dynamic>? currentUser,
    String? languageCode,
  }) {
    if (currentUser != null) {
      this.currentUser = MethodChannelUser(this, currentUser);
    }

    this.languageCode = languageCode;
    return this;
  }

  @override
  Future<void> useEmulator(String host, int port) async {
    try {
      await channel.invokeMethod<void>('Auth#useEmulator', <String, dynamic>{
        'appName': app.name,
        'host': host,
        'port': port,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> applyActionCode(String code) async {
    try {
      await channel
          .invokeMethod<void>('Auth#applyActionCode', <String, dynamic>{
        'appName': app.name,
        'code': code,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) async {
    try {
      Map<String, dynamic> result = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#checkActionCode', <String, dynamic>{
        'appName': app.name,
        'code': code,
      }))!;

      return ActionCodeInfo(
        operation: result['operation'],
        data: Map<String, dynamic>.from(result['data']),
      );
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await channel
          .invokeMethod<void>('Auth#confirmPasswordReset', <String, dynamic>{
        'appName': app.name,
        'code': code,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#createUserWithEmailAndPassword', <String, dynamic>{
        'appName': app.name,
        'email': email,
        'password': password,
      }))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#fetchSignInMethodsForEmail', <String, dynamic>{
        'appName': app.name,
        'email': email,
      }))!;

      return List<String>.from(data['providers']);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Stream<UserPlatform?> authStateChanges() async* {
    yield currentUser;
    yield* _authStateChangesListeners[app.name]!
        .stream
        .map((event) => event.value);
  }

  @override
  Stream<UserPlatform?> idTokenChanges() async* {
    yield currentUser;
    yield* _idTokenChangesListeners[app.name]!
        .stream
        .map((event) => event.value);
  }

  @override
  Stream<UserPlatform?> userChanges() async* {
    yield currentUser;
    yield* _userChangesListeners[app.name]!.stream.map((event) => event.value);
  }

  @override
  Future<void> sendPasswordResetEmail(
    String email, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    try {
      await channel
          .invokeMethod<void>('Auth#sendPasswordResetEmail', <String, dynamic>{
        'appName': app.name,
        'email': email,
        'actionCodeSettings': actionCodeSettings?.asMap(),
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> sendSignInLinkToEmail(
    String email,
    ActionCodeSettings actionCodeSettings,
  ) async {
    try {
      await channel
          .invokeMethod<void>('Auth#sendSignInLinkToEmail', <String, dynamic>{
        'appName': app.name,
        'email': email,
        'actionCodeSettings': actionCodeSettings.asMap(),
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> setLanguageCode(String languageCode) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#setLanguageCode', <String, dynamic>{
        'appName': app.name,
        'languageCode': languageCode,
      }))!;

      this.languageCode = data['languageCode'];
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> setSettings({
    bool? appVerificationDisabledForTesting,
    String? userAccessGroup,
  }) async {
    try {
      await channel.invokeMethod('Auth#setSettings', <String, dynamic>{
        'appName': app.name,
        'appVerificationDisabledForTesting': appVerificationDisabledForTesting,
        'userAccessGroup': userAccessGroup,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> setPersistence(Persistence persistence) {
    throw UnimplementedError(
        'setPersistence() is only supported on web based platforms');
  }

  @override
  Future<UserCredentialPlatform> signInAnonymously() async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#signInAnonymously', <String, dynamic>{
        'appName': app.name,
      }))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithCredential(
    AuthCredential credential,
  ) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#signInWithCredential', <String, dynamic>{
        'appName': app.name,
        'credential': credential.asMap(),
      }))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#signInWithCustomToken', <String, dynamic>{
        'appName': app.name,
        'token': token,
      }))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#signInWithEmailAndPassword', <String, dynamic>{
        'appName': app.name,
        'email': email,
        'password': password,
      }))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailLink(
      String email, String emailLink) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#signInWithEmailLink', <String, dynamic>{
        'appName': app.name,
        'email': email,
        'emailLink': emailLink,
      }))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithPopup(AuthProvider provider) {
    throw UnimplementedError(
      'signInWithPopup() is only supported on web based platforms',
    );
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) {
    throw UnimplementedError(
      'signInWithRedirect() is only supported on web based platforms',
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await channel.invokeMethod<void>('Auth#signOut', <String, dynamic>{
        'appName': app.name,
      });

      currentUser = null;
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<String> verifyPasswordResetCode(String code) async {
    try {
      Map<String, dynamic> data = (await channel
          .invokeMapMethod<String, dynamic>(
              'Auth#verifyPasswordResetCode', <String, dynamic>{
        'appName': app.name,
        'code': code,
      }))!;

      return data['email'];
    } catch (e) {
      throw convertPlatformException(e);
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
  }) async {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      throw UnimplementedError(
        'verifyPhoneNumber() is not available on MacOS platforms.',
      );
    }

    try {
      final eventChannelName = await channel
          .invokeMethod<String>('Auth#verifyPhoneNumber', <String, dynamic>{
        'appName': app.name,
        'phoneNumber': phoneNumber,
        'timeout': timeout.inMilliseconds,
        'forceResendingToken': forceResendingToken,
        'autoRetrievedSmsCodeForTesting': autoRetrievedSmsCodeForTesting,
      });

      EventChannel(eventChannelName!)
          .receiveBroadcastStream()
          .listen((arguments) {
        final name = arguments['name'];
        if (name == 'Auth#phoneVerificationCompleted') {
          final int token = arguments['token'];
          final String? smsCode = arguments['smsCode'];

          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credentialFromToken(token, smsCode: smsCode);
          verificationCompleted(phoneAuthCredential);
        } else if (name == 'Auth#phoneVerificationFailed') {
          final Map<dynamic, dynamic>? error = arguments['error'];
          final Map<dynamic, dynamic>? details = error?['details'];

          FirebaseAuthException exception = FirebaseAuthException(
            message: details != null ? details['message'] : error?['message'],
            code: details != null ? details['code'] : 'unknown',
          );

          verificationFailed(exception);
        } else if (name == 'Auth#phoneCodeSent') {
          final String verificationId = arguments['verificationId'];
          final int? forceResendingToken = arguments['forceResendingToken'];

          codeSent(verificationId, forceResendingToken);
        } else if (name == 'Auth#phoneCodeAutoRetrievalTimeout') {
          final String verificationId = arguments['verificationId'];

          codeAutoRetrievalTimeout(verificationId);
        }
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }
}

/// Simple helper class to make nullable values transferable through StreamControllers.
class _ValueWrapper<T> {
  const _ValueWrapper(this.value);

  const _ValueWrapper.absent() : value = null;

  final T? value;
}
