// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_multi_factor.dart';
import 'package:firebase_auth_web/src/utils/web_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'src/firebase_auth_version.dart';

import 'src/firebase_auth_web_confirmation_result.dart';
import 'src/firebase_auth_web_recaptcha_verifier_factory.dart';
import 'src/firebase_auth_web_user.dart';
import 'src/firebase_auth_web_user_credential.dart';
import 'src/interop/auth.dart' as auth_interop;
import 'src/interop/multi_factor.dart' as multi_factor;

enum StateListener { authStateChange, userStateChange, idTokenChange }

/// The web delegate implementation for [FirebaseAuth].
class FirebaseAuthWeb extends FirebaseAuthPlatform {
  static const String _libraryName = 'flutter-fire-auth';

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseAuthWeb._()
      : _webAuth = null,
        super(appInstance: null);

  Completer<void> _initialized = Completer();

  /// The entry point for the [FirebaseAuthWeb] class.
  FirebaseAuthWeb({required FirebaseApp app}) : super(appInstance: app) {
    // Create a app instance broadcast stream for both delegate listener events
    _createStreamListener(app.name, StateListener.authStateChange);
    _createStreamListener(app.name, StateListener.idTokenChange);
    _createStreamListener(app.name, StateListener.userStateChange);
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerLibraryVersion(_libraryName, packageVersion);

    FirebaseCoreWeb.registerService(
      'auth',
      ensurePluginInitialized: (firebaseApp) async {
        final authDelegate = auth_interop.getAuthInstance(firebaseApp);
        // if localhost, and emulator was previously set in localStorage, use it
        if (web.window.location.hostname == 'localhost' && kDebugMode) {
          final String? emulatorOrigin = web.window.sessionStorage
              .getItem(getOriginName(firebaseApp.name));

          if (emulatorOrigin != null) {
            try {
              authDelegate.useAuthEmulator(emulatorOrigin);
              // ignore: avoid_print
              print(
                'Using previously configured Auth emulator at $emulatorOrigin for ${firebaseApp.name} \nTo switch back to production, restart your app with the emulator turned off.',
              );
            } catch (e) {
              if (e.toString().contains('sooner')) {
                // Happens during hot reload when the emulator is already configured
                // ignore: avoid_print
                print(
                  'Auth emulator is already configured at $emulatorOrigin for ${firebaseApp.name} and kept across hot reload.\nTo switch back to production, restart your app with the emulator turned off.',
                );
              } else {
                rethrow;
              }
            }
          }
        }
        await authDelegate.onWaitInitState();
      },
    );
    FirebaseAuthPlatform.instance = FirebaseAuthWeb.instance;
    PhoneMultiFactorGeneratorPlatform.instance = PhoneMultiFactorGeneratorWeb();
    TotpMultiFactorGeneratorPlatform.instance = TotpMultiFactorGeneratorWeb();
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

  bool _cancelUserStream = false;
  bool _cancelIdTokenStream = false;

  void _createStreamListener(String appName, StateListener stateListener) {
    switch (stateListener) {
      case StateListener.authStateChange:
        _authStateChangesListeners[appName] =
            StreamController<UserPlatform?>.broadcast(
          onCancel: () {
            _authStateChangesListeners[appName]!.close();
            _authStateChangesListeners.remove(appName);
            delegate.authStateController?.close();
          },
        );
        delegate.onAuthStateChanged.map((auth_interop.User? webUser) {
          if (!_initialized.isCompleted) {
            _initialized.complete();
          }

          if (webUser == null) {
            return null;
          } else {
            return UserWeb(
              this,
              MultiFactorWeb(this, multi_factor.multiFactor(webUser)),
              webUser,
              _webAuth,
            );
          }
        }).listen((UserWeb? webUser) {
          _authStateChangesListeners[app.name]!.add(webUser);
        });
        break;
      case StateListener.idTokenChange:
        _cancelIdTokenStream = false;
        _idTokenChangesListeners[appName] =
            StreamController<UserPlatform?>.broadcast(
          onCancel: () {
            if (_userChangesListeners[appName] == null) {
              // We cannot remove if there is a userChanges listener as we use this stream for it
              _idTokenChangesListeners[appName]!.close();
              _idTokenChangesListeners.remove(appName);
              delegate.idTokenController?.close();
            } else {
              // We need to do this because if idTokenListener and userChanges are being listened to
              // We need to cancel both at the same time otherwise neither will be closed & removed
              _cancelIdTokenStream = true;
            }

            if (_cancelUserStream) {
              _userChangesListeners[appName]!.close();
              _userChangesListeners.remove(appName);
            }
          },
        );

        // Also triggers `userChanged` events
        delegate.onIdTokenChanged.map((auth_interop.User? webUser) {
          if (webUser == null) {
            return null;
          } else {
            return UserWeb(
              this,
              MultiFactorWeb(this, multi_factor.multiFactor(webUser)),
              webUser,
              _webAuth,
            );
          }
        }).listen((UserWeb? webUser) {
          _idTokenChangesListeners[app.name]!.add(webUser);
          _userChangesListeners[app.name]!.add(webUser);
        });
        break;
      case StateListener.userStateChange:
        _cancelUserStream = false;
        _userChangesListeners[appName] =
            StreamController<UserPlatform?>.broadcast(
          onCancel: () {
            if (_idTokenChangesListeners[appName] == null) {
              _userChangesListeners[appName]!.close();
              _userChangesListeners.remove(appName);
              // There is no delegate for userChanges as we use idTokenChanges
            } else {
              _cancelUserStream = true;
            }

            if (_cancelIdTokenStream) {
              // We need to do this because if idTokenListener and userChanges are being listened to
              // We need to cancel both at the same time otherwise neither will be closed & removed
              _idTokenChangesListeners[appName]!.close();
              _idTokenChangesListeners.remove(appName);
              delegate.idTokenController?.close();
            }
          },
        );
        break;
    }
  }

  /// instance of Auth from the web plugin
  auth_interop.Auth? _webAuth;

  auth_interop.Auth get delegate {
    _webAuth = auth_interop.getAuthInstance(core_interop.app(app.name));
    return _webAuth!;
  }

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return FirebaseAuthWeb(app: app);
  }

  @override
  FirebaseAuthWeb setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) {
    // Values are already set on web
    return this;
  }

  @override
  UserPlatform? get currentUser {
    auth_interop.User? webCurrentUser = delegate.currentUser;

    if (webCurrentUser == null) {
      return null;
    }

    return UserWeb(
      this,
      MultiFactorWeb(this, multi_factor.multiFactor(delegate.currentUser!)),
      delegate.currentUser!,
      _webAuth,
    );
  }

  @override
  String? get tenantId {
    return delegate.tenantId;
  }

  @override
  set tenantId(String? tenantId) {
    delegate.tenantId = tenantId;
  }

  @override
  void sendAuthChangesEvent(String appName, UserPlatform? userPlatform) {
    assert(_userChangesListeners[appName] != null);

    _userChangesListeners[appName]!.add(userPlatform);
  }

  @override
  Future<void> applyActionCode(String code) async {
    await guardAuthExceptions(
      () => delegate.applyActionCode(code),
    );
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String code) async {
    final actionCode = await guardAuthExceptions(
      () => delegate.checkActionCode(code),
    );

    return convertWebActionCodeInfo(actionCode)!;
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    return guardAuthExceptions(
      () => delegate.confirmPasswordReset(code, newPassword),
    );
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await guardAuthExceptions(
      () => delegate.createUserWithEmailAndPassword(email, password),
    );

    return UserCredentialWeb(
      this,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    return guardAuthExceptions(
      () => delegate.fetchSignInMethodsForEmail(email),
    );
  }

  @override
  Future<UserCredentialPlatform> getRedirectResult() async {
    final userCredential =
        await guardAuthExceptions(delegate.getRedirectResult);

    return UserCredentialWeb(
      this,
      userCredential,
      _webAuth,
    );
  }

  @override
  Stream<UserPlatform?> authStateChanges() async* {
    await _initialized.future;
    yield currentUser;
    if (_authStateChangesListeners[app.name] == null) {
      _createStreamListener(app.name, StateListener.authStateChange);
    }
    yield* _authStateChangesListeners[app.name]!.stream;
  }

  @override
  Stream<UserPlatform?> idTokenChanges() async* {
    await _initialized.future;
    yield currentUser;
    if (_idTokenChangesListeners[app.name] == null) {
      _createStreamListener(app.name, StateListener.idTokenChange);
    }
    yield* _idTokenChangesListeners[app.name]!.stream;
  }

  @override
  Stream<UserPlatform?> userChanges() async* {
    await _initialized.future;
    yield currentUser;
    if (_userChangesListeners[app.name] == null) {
      _createStreamListener(app.name, StateListener.userStateChange);
    }
    yield* _userChangesListeners[app.name]!.stream;
  }

  @override
  Future<void> sendPasswordResetEmail(
    String email, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    return guardAuthExceptions(
      () => delegate.sendPasswordResetEmail(
        email,
        convertPlatformActionCodeSettings(
          actionCodeSettings,
        ),
      ),
    );
  }

  @override
  Future<void> sendSignInLinkToEmail(
    String email, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    return guardAuthExceptions(
      () => delegate.sendSignInLinkToEmail(
        email,
        convertPlatformActionCodeSettings(
          actionCodeSettings,
        ),
      ),
    );
  }

  @override
  String get languageCode {
    return delegate.languageCode ?? 'en';
  }

  @override
  Future<void> setLanguageCode(String? languageCode) async {
    if (languageCode == null) {
      delegate.useDeviceLanguage();
    } else {
      delegate.languageCode = languageCode;
    }
  }

  @override
  Future<void> setSettings({
    bool? appVerificationDisabledForTesting,
    String? userAccessGroup,
    String? phoneNumber,
    String? smsCode,
    bool? forceRecaptchaFlow,
  }) async {
    delegate.settings.appVerificationDisabledForTesting =
        appVerificationDisabledForTesting?.toJS;
  }

  @override
  Future<void> setPersistence(Persistence persistence) async {
    return guardAuthExceptions(
      () => delegate.setPersistence(
        persistence,
      ),
    );
  }

  @override
  Future<UserCredentialPlatform> signInAnonymously() async {
    final userCredential = await guardAuthExceptions(
      delegate.signInAnonymously,
      auth: _webAuth,
    );

    return UserCredentialWeb(
      this,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithCredential(
    AuthCredential credential,
  ) async {
    final authCredential = await guardAuthExceptions(
      () =>
          delegate.signInWithCredential(convertPlatformCredential(credential)!),
      auth: _webAuth,
    );

    return UserCredentialWeb(
      this,
      authCredential,
      _webAuth,
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    final userCredential = await guardAuthExceptions(
      () => delegate.signInWithCustomToken(token),
      auth: _webAuth,
    );

    return UserCredentialWeb(
      this,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await guardAuthExceptions(
      () => delegate.signInWithEmailAndPassword(email, password),
      auth: _webAuth,
    );

    return UserCredentialWeb(
      this,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailLink(
      String email, String emailLink) async {
    final userCredential = await guardAuthExceptions(
      () => delegate.signInWithEmailLink(email, emailLink),
      auth: _webAuth,
    );

    return UserCredentialWeb(
      this,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<ConfirmationResultPlatform> signInWithPhoneNumber(
    String phoneNumber,
    RecaptchaVerifierFactoryPlatform applicationVerifier,
  ) async {
    // Do not inline - type is not inferred & error is thrown.
    auth_interop.RecaptchaVerifier verifier = applicationVerifier.delegate;

    final confirmationResult = await guardAuthExceptions(
      () => delegate.signInWithPhoneNumber(
        phoneNumber,
        verifier,
      ),
    );
    return ConfirmationResultWeb(
      this,
      confirmationResult,
      _webAuth,
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithPopup(AuthProvider provider) async {
    final userCredential = await guardAuthExceptions(
      () => delegate.signInWithPopup(
        convertPlatformAuthProvider(provider),
      ),
      auth: _webAuth,
    );

    return UserCredentialWeb(
      this,
      userCredential,
      _webAuth,
    );
  }

  @override
  Future<void> signInWithRedirect(AuthProvider provider) async {
    return guardAuthExceptions(
      () => delegate.signInWithRedirect(
        convertPlatformAuthProvider(provider),
      ),
      auth: _webAuth,
    );
  }

  @override
  Future<void> signOut() async {
    return guardAuthExceptions(delegate.signOut);
  }

  @override
  Future<void> useAuthEmulator(String host, int port) async {
    try {
      // Get current session storage value
      final String? emulatorOrigin =
          web.window.sessionStorage.getItem(getOriginName(delegate.app.name));

      // The generic platform interface is with host and port split to
      // centralize logic between android/ios native, but web takes the
      // origin as a single string
      final String origin = 'http://$host:$port';

      if (origin == emulatorOrigin) {
        // If the origin is the same as the current one, do nothing
        // The emulator was already started at the app start
        return;
      }

      delegate.useAuthEmulator(origin);
      // Save to session storage so that the emulator is used on refresh
      // only in debug mode
      if (kDebugMode) {
        web.window.sessionStorage
            .setItem(getOriginName(delegate.app.name), origin);
      }
    } catch (e) {
      // Cannot be done with 3.2 constraints
      // ignore: invalid_runtime_check_with_js_interop_types
      if (e is auth_interop.AuthError) {
        final String code = e.code.toDart;
        // this catches Firebase Error from web that occurs after hot reloading & hot restarting
        if (code != 'auth/emulator-config-failed') {
          throw getFirebaseAuthException(e);
        }
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<String> verifyPasswordResetCode(String code) async {
    return guardAuthExceptions(
      () => delegate.verifyPasswordResetCode(code),
    );
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
  }) async {
    try {
      Map<String, dynamic>? data;
      if (multiFactorSession != null) {
        final _webMultiFactorSession =
            multiFactorSession as MultiFactorSessionWeb;
        if (multiFactorInfo != null) {
          data = {
            'multiFactorUid': multiFactorInfo.uid,
            'session': _webMultiFactorSession.webSession.jsObject,
          };
        } else {
          data = {
            'phoneNumber': phoneNumber,
            'session': _webMultiFactorSession.webSession.jsObject,
          };
        }
      }

      final phoneOptions = (data ?? phoneNumber)!;

      final provider = auth_interop.PhoneAuthProvider(_webAuth);
      final verifier = RecaptchaVerifierFactoryWeb(
        auth: this,
      ).delegate;

      /// We add the passthrough method for LegacyJsObject
      final verificationId =
          await provider.verifyPhoneNumber(phoneOptions.jsify(), verifier);

      codeSent(verificationId, null);
    } catch (e) {
      verificationFailed(getFirebaseAuthException(e));
    }
  }

  @override
  Future<void> revokeTokenWithAuthorizationCode(
      String authorizationCode) async {
    throw UnimplementedError(
      'revokeTokenWithAuthorizationCode() is only available on apple platforms.',
    );
  }

  @override
  Future<void> initializeRecaptchaConfig() async {
    await guardAuthExceptions(
      () => delegate.initializeRecaptchaConfig(),
    );
  }
}

String getOriginName(String appName) {
  return '$appName-firebaseEmulatorOrigin';
}
