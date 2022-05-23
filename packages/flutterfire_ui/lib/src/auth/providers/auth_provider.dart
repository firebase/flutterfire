import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

mixin DefaultErrorHandlerMixin {
  AuthProvider get provider;

  void onError(Object error) {
    if (error is! FirebaseAuthException) {
      throw error;
    }

    if (error.code == 'account-exists-with-different-credential') {
      final email = error.email;
      if (email == null) {
        throw error;
      }

      provider.fetchDifferentProvidersForEmail(email, error.credential);
    }

    throw error;
  }
}

abstract class AuthListener {
  AuthProvider get provider;
  FirebaseAuth get auth;

  void onError(Object error);

  void onBeforeSignIn();
  void onSignedIn(UserCredential credential);

  void onBeforeCredentialLinked(AuthCredential credential);
  void onCredentialLinked(AuthCredential credential);

  void onBeforeProvidersForEmailFetch();
  void onDifferentProvidersFound(
    String email,
    List<String> providers,
    AuthCredential? credential,
  );
}

abstract class AuthProvider<T extends AuthListener, K extends AuthCredential> {
  late final FirebaseAuth auth;
  T get authListener;
  set authListener(T listener);

  String get providerId;
  bool supportsPlatform(TargetPlatform platform);

  AuthProvider();

  void signInWithCredential(AuthCredential credential) {
    authListener.onBeforeSignIn();
    auth
        .signInWithCredential(credential)
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }

  void linkWithCredential(AuthCredential credential) {
    authListener.onBeforeCredentialLinked(credential);
    try {
      final user = auth.currentUser!;
      user
          .linkWithCredential(credential)
          .then((_) => authListener.onCredentialLinked(credential))
          .catchError(authListener.onError);
    } catch (err) {
      authListener.onError(err);
    }
  }

  void fetchDifferentProvidersForEmail(
    String email, [
    AuthCredential? credential,
  ]) {
    authListener.onBeforeProvidersForEmailFetch();

    auth
        .fetchSignInMethodsForEmail(email)
        .then(
          (methods) => authListener.onDifferentProvidersFound(
            email,
            methods,
            credential,
          ),
        )
        .catchError(authListener.onError);
  }

  void onCredentialReceived(K credential, AuthAction action) {
    if (action == AuthAction.link) {
      linkWithCredential(credential);
    } else {
      signInWithCredential(credential);
    }
  }
}
