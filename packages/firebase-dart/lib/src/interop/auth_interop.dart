@JS('firebase.auth')
library firebase.auth_interop;

import 'package:func/func.dart';
import 'package:js/js.dart';

import 'app_interop.dart';
import 'firebase_interop.dart';

@JS('Auth')
abstract class AuthJsImpl {
  external AppJsImpl get app;
  external void set app(AppJsImpl a);
  external UserJsImpl get currentUser;
  external void set currentUser(UserJsImpl u);
  external PromiseJsImpl applyActionCode(String code);
  external PromiseJsImpl<ActionCodeInfo> checkActionCode(String code);
  external PromiseJsImpl confirmPasswordReset(String code, String newPassword);
  external PromiseJsImpl<UserJsImpl> createUserWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<List<String>> fetchProvidersForEmail(String email);
  external PromiseJsImpl<UserCredentialJsImpl> getRedirectResult();
  external Func0 onAuthStateChanged(nextOrObserver,
      [Func1 opt_error, Func0 opt_completed]);
  external PromiseJsImpl sendPasswordResetEmail(String email);
  external PromiseJsImpl<UserJsImpl> signInAnonymously();
  external PromiseJsImpl<UserJsImpl> signInWithCredential(
      AuthCredential credential);
  external PromiseJsImpl<UserJsImpl> signInWithCustomToken(String token);
  external PromiseJsImpl<UserJsImpl> signInWithEmailAndPassword(
      String email, String password);
  external PromiseJsImpl<UserCredentialJsImpl> signInWithPopup(
      AuthProviderJsImpl provider);
  external PromiseJsImpl signInWithRedirect(AuthProviderJsImpl provider);
  external PromiseJsImpl signOut();
  external PromiseJsImpl<String> verifyPasswordResetCode(String code);
}

/// Represents the credentials returned by an auth provider.
/// Implementations specify the details about each auth provider's credential
/// requirements.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.AuthCredential>.
@JS()
abstract class AuthCredential {
  external String get provider;
  external String get accessToken;
  external String get secret;
}

@JS('AuthProvider')
abstract class AuthProviderJsImpl {
  external String get providerId;
}

@JS('EmailAuthProvider')
class EmailAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory EmailAuthProviderJsImpl();
  external static String get PROVIDER_ID;
  external static AuthCredential credential(String email, String password);
}

@JS('FacebookAuthProvider')
class FacebookAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory FacebookAuthProviderJsImpl();
  external static String get PROVIDER_ID;
  external FacebookAuthProviderJsImpl addScope(String scope);
  external FacebookAuthProviderJsImpl setCustomParameters(
      customOAuthParameters);
  external static AuthCredential credential(String token);
}

@JS('GithubAuthProvider')
class GithubAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory GithubAuthProviderJsImpl();
  external static String get PROVIDER_ID;
  external GithubAuthProviderJsImpl addScope(String scope);
  external GithubAuthProviderJsImpl setCustomParameters(customOAuthParameters);
  external static AuthCredential credential(String token);
}

@JS('GoogleAuthProvider')
class GoogleAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory GoogleAuthProviderJsImpl();
  external static String get PROVIDER_ID;
  external GoogleAuthProviderJsImpl addScope(String scope);
  external GoogleAuthProviderJsImpl setCustomParameters(customOAuthParameters);
  external static AuthCredential credential(
      [String idToken, String accessToken]);
}

@JS('TwitterAuthProvider')
class TwitterAuthProviderJsImpl extends AuthProviderJsImpl {
  external factory TwitterAuthProviderJsImpl();
  external static String get PROVIDER_ID;
  external TwitterAuthProviderJsImpl setCustomParameters(customOAuthParameters);
  external static AuthCredential credential(String token, String secret);
}

/// A response from [Auth.checkActionCode].
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.ActionCodeInfo>.
@JS()
abstract class ActionCodeInfo {
  external ActionCodeEmail get data;
}

/// An authentication error.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.Error>.
@JS('Error')
abstract class AuthError {
  external String get code;
  external void set code(String s);
  external String get message;
  external void set message(String s);
}

@JS()
@anonymous
class ActionCodeEmail {
  external String get email;
}

@JS()
@anonymous
class UserCredentialJsImpl {
  external UserJsImpl get user;
  external void set user(UserJsImpl u);
  external AuthCredential get credential;
  external void set credential(AuthCredential c);

  external factory UserCredentialJsImpl(
      {UserJsImpl user, AuthCredential credential});
}
