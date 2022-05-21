import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

mixin PlatformSignInMixin {
  FirebaseAuth get auth;
  OAuthListener get authListener;
  dynamic get firebaseAuthProvider;
  AuthAction get action;

  void platformSignIn(TargetPlatform platform) {
    Future<UserCredential> credentialFuture;

    if (action == AuthAction.link) {
      credentialFuture = auth.currentUser!.linkWithPopup(firebaseAuthProvider);
    } else {
      credentialFuture = auth.signInWithPopup(firebaseAuthProvider);
    }

    credentialFuture
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }
}
