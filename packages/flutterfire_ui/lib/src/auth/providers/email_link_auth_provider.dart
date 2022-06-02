import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class EmailLinkAuthListener extends AuthListener {
  void onBeforeLinkSent(String email);
  void onLinkSent(String email);
}

class EmailLinkAuthProvider
    extends AuthProvider<EmailLinkAuthListener, AuthCredential> {
  final ActionCodeSettings actionCodeSettings;
  final FirebaseDynamicLinks _dynamicLinks;

  @override
  late EmailLinkAuthListener authListener;

  @override
  final providerId = 'email_link';

  @override
  bool supportsPlatform(TargetPlatform platform) {
    if (kIsWeb) return false;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  EmailLinkAuthProvider({
    required this.actionCodeSettings,
    FirebaseDynamicLinks? dynamicLinks,
  }) : _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  void sendLink(String email) {
    authListener.onBeforeLinkSent(email);

    final future = auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );

    future
        .then((_) => authListener.onLinkSent(email))
        .catchError(authListener.onError);
  }

  void _onLinkReceived(String email, PendingDynamicLinkData linkData) {
    final link = linkData.link.toString();

    if (auth.isSignInWithEmailLink(link)) {
      authListener.onBeforeSignIn();
      _signInWithEmailLink(email, link);
    } else {
      authListener.onError(
        FirebaseAuthException(
          code: 'invalid-email-signin-link',
          message: 'Invalid email sign in link',
        ),
      );
    }
  }

  void awaitLink(String email) {
    _dynamicLinks.onLink.first
        .then((linkData) => _onLinkReceived(email, linkData))
        .catchError(authListener.onError);
  }

  void _signInWithEmailLink(String email, String link) {
    auth
        .signInWithEmailLink(email: email, emailLink: link)
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }
}
