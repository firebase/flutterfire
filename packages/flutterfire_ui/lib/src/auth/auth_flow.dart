// ignore_file: unnecessary_this

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

import 'auth_state.dart';

class AuthCancelledException implements Exception {
  AuthCancelledException([this.message = 'User has cancelled auth']);

  final String message;
}

class AuthFlow<T extends AuthProvider> extends ValueNotifier<AuthState>
    implements AuthController, AuthListener {
  @override
  FirebaseAuth auth;
  final AuthState initialState;
  AuthAction? _action;
  List<VoidCallback> _onDispose = [];

  final T _provider;

  @override
  T get provider => _provider..authListener = this;

  @override
  AuthAction get action {
    if (_action != null) {
      return _action!;
    }

    if (auth.currentUser != null) {
      return AuthAction.link;
    }

    return AuthAction.signIn;
  }

  set action(AuthAction value) {
    _action = value;
  }

  VoidCallback get onDispose {
    return () {
      _onDispose.forEach((callback) => callback());
    };
  }

  set onDispose(VoidCallback callback) {
    _onDispose.add(callback);
  }

  AuthFlow({
    required this.initialState,
    required T provider,
    FirebaseAuth? auth,
    AuthAction? action,
  })  : auth = auth ?? FirebaseAuth.instance,
        _action = action,
        _provider = provider,
        super(initialState) {
    _provider.authListener = this;
    _provider.auth = auth ?? FirebaseAuth.instance;
  }

  @override
  void onBeforeCredentialLinked(AuthCredential credential) {
    value = CredentialReceived(credential);
  }

  @override
  void onBeforeProvidersForEmailFetch() {
    value = const FetchingProvidersForEmail();
  }

  @override
  void onBeforeSignIn() {
    value = const SigningIn();
  }

  @override
  void onCredentialLinked(AuthCredential credential) {
    value = CredentialLinked(credential);
  }

  @override
  void onDifferentProvidersFound(
    String email,
    List<String> providers,
    AuthCredential? credential,
  ) {
    value = DifferentSignInMethodsFound(
      email,
      providers,
      credential,
    );
  }

  @override
  void onSignedIn(UserCredential credential) {
    value = SignedIn(credential.user);
  }

  @override
  void findProvidersForEmail(String email) {
    provider.fetchDifferentProvidersForEmail(email);
  }

  @override
  void reset() {
    value = initialState;
    onDispose();
  }

  @override
  void onError(Object error) {
    try {
      DefaultErrorHandler.onError(provider, error);
    } on AuthCancelledException {
      reset();
    } on Exception catch (err) {
      value = AuthFailed(err);
    }
  }

  @override
  void onCanceled() {
    value = initialState;
  }
}
