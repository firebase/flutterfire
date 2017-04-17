import 'dart:async';

import 'package:js/js.dart';

import 'app.dart';
import 'interop/auth_interop.dart';
import 'interop/firebase_interop.dart' as firebase_interop;
import 'js.dart';
import 'utils.dart';

export 'interop/auth_interop.dart'
    show ActionCodeInfo, ActionCodeEmail, AuthCredential;
export 'interop/firebase_interop.dart' show UserProfile;

/// User profile information, visible only to the Firebase project's apps.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.UserInfo>.
class UserInfo<T extends firebase_interop.UserInfoJsImpl>
    extends JsObjectWrapper<T> {
  /// User's display name.
  String get displayName => jsObject.displayName;
  void set displayName(String s) {
    jsObject.displayName = s;
  }

  /// User's e-mail address.
  String get email => jsObject.email;
  void set email(String s) {
    jsObject.email = s;
  }

  /// User's profile picture URL.
  String get photoURL => jsObject.photoURL;
  void set photoURL(String s) {
    jsObject.photoURL = s;
  }

  /// User's authentication provider ID.
  String get providerId => jsObject.providerId;
  void set providerId(String s) {
    jsObject.providerId = s;
  }

  /// User's unique ID.
  String get uid => jsObject.uid;
  void set uid(String s) {
    jsObject.uid = s;
  }

  /// Creates a new UserInfo from a [jsObject].
  UserInfo.fromJsObject(T jsObject) : super.fromJsObject(jsObject);
}

/// User account.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.User>.
class User extends UserInfo<firebase_interop.UserJsImpl> {
  /// If the user's email address has been already verified.
  bool get emailVerified => jsObject.emailVerified;

  /// If the user is anonymous.
  bool get isAnonymous => jsObject.isAnonymous;

  /// List of additional provider-specific information about the user.
  List<UserInfo> get providerData => jsObject.providerData
      .map((data) =>
          new UserInfo<firebase_interop.UserInfoJsImpl>.fromJsObject(data))
      .toList();

  /// Refresh token for the user account.
  String get refreshToken => jsObject.refreshToken;

  /// Creates a new User from a [jsObject].
  User.fromJsObject(firebase_interop.UserJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Deletes and signs out the user.
  Future delete() => handleThenable(jsObject.delete());

  /// Returns a JWT token used to identify the user to a Firebase service.
  /// It forces refresh regardless of token expiration if [forceRefresh]
  /// parameter is [true].
  Future<String> getToken([bool forceRefresh = false]) =>
      handleThenable(jsObject.getToken(forceRefresh));

  /// Links the user account with the given [credential] and returns the user.
  Future<User> link(AuthCredential credential) => handleThenableWithMapper(
      jsObject.link(credential), (u) => new User.fromJsObject(u));

  /// Links the authenticated [provider] to the user account using
  /// a pop-up based OAuth flow.
  /// It returns the [UserCredential] information if linking is successful.
  Future<UserCredential> linkWithPopup(AuthProvider provider) =>
      handleThenableWithMapper(jsObject.linkWithPopup(provider.jsObject),
          (u) => new UserCredential.fromJsObject(u));

  /// Links the authenticated [provider] to the user account using
  /// a full-page redirect flow.
  Future linkWithRedirect(AuthProvider provider) =>
      handleThenable(jsObject.linkWithRedirect(provider.jsObject));

  /// Re-authenticates a user using a fresh [credential]. Should be used
  /// before operations such as [updatePassword()] that require tokens
  /// from recent sign in attempts.
  Future reauthenticate(AuthCredential credential) =>
      handleThenable(jsObject.reauthenticate(credential));

  /// If signed in, it refreshes the current user.
  Future reload() => handleThenable(jsObject.reload());

  /// Sends an e-mail verification to a user.
  Future sendEmailVerification() =>
      handleThenable(jsObject.sendEmailVerification());

  /// Unlinks a provider with [providerId] from a user account.
  Future<User> unlink(String providerId) => handleThenableWithMapper(
      jsObject.unlink(providerId),
      (firebase_interop.UserJsImpl u) => new User.fromJsObject(u));

  /// Updates the user's e-mail address to [newEmail].
  Future updateEmail(String newEmail) =>
      handleThenable(jsObject.updateEmail(newEmail));

  /// Updates the user's password to [newPassword].
  /// Requires the user to have recently signed in. If not, ask the user
  /// to authenticate again and then use [reauthenticate()].
  Future updatePassword(String newPassword) =>
      handleThenable(jsObject.updatePassword(newPassword));

  /// Updates a user's [profile] data.
  /// UserProfile has a displayName and photoURL.
  ///
  ///     UserProfile profile = new UserProfile(displayName: "Smart user");
  ///     await user.updateProfile(profile);
  Future updateProfile(firebase_interop.UserProfile profile) =>
      handleThenable(jsObject.updateProfile(profile));
}

/// The Firebase Auth service class.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.Auth>.
class Auth extends JsObjectWrapper<AuthJsImpl> {
  App _app;

  /// App for this instance of auth service.
  App get app {
    if (_app != null) {
      _app.jsObject = jsObject.app;
    } else {
      _app = new App.fromJsObject(jsObject.app);
    }
    return _app;
  }

  User _currentUser;

  /// Currently signed-in user.
  User get currentUser {
    if (jsObject.currentUser != null) {
      if (_currentUser != null) {
        _currentUser.jsObject = jsObject.currentUser;
      } else {
        _currentUser = new User.fromJsObject(jsObject.currentUser);
      }
    } else {
      _currentUser = null;
    }
    return _currentUser;
  }

  var _onAuthUnsubscribe;
  StreamController<AuthEvent> _changeController;

  /// Stream for an auth state changed event.
  Stream<AuthEvent> get onAuthStateChanged {
    if (_changeController == null) {
      var nextWrapper = allowInterop((firebase_interop.UserJsImpl user) {
        _changeController.add(
            new AuthEvent((user != null) ? new User.fromJsObject(user) : null));
      });

      var errorWrapper = allowInterop((e) => _changeController.addError(e));

      void startListen() {
        _onAuthUnsubscribe =
            jsObject.onAuthStateChanged(nextWrapper, errorWrapper);
      }

      void stopListen() {
        _onAuthUnsubscribe();
      }

      _changeController = new StreamController<AuthEvent>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return _changeController.stream;
  }

  /// Creates a new Auth from a [jsObject].
  Auth.fromJsObject(AuthJsImpl jsObject) : super.fromJsObject(jsObject);

  /// Applies a verification [code] sent to the user by e-mail or by other
  /// out-of-band mechanism.
  Future applyActionCode(String code) =>
      handleThenable(jsObject.applyActionCode(code));

  /// Checks a verification [code] sent to the user by e-mail or by other
  /// out-of-band mechanism.
  /// It returns [ActionCodeInfo], metadata about the code.
  Future<ActionCodeInfo> checkActionCode(String code) =>
      handleThenable(jsObject.checkActionCode(code));

  /// Completes password reset process with a [code] and a [newPassword].
  Future confirmPasswordReset(String code, String newPassword) =>
      handleThenable(jsObject.confirmPasswordReset(code, newPassword));

  /// Creates a new user account with [email] and [password].
  /// After a successful creation, the user will be signed into application
  /// and the [User] object is returned.
  ///
  /// The creation can fail, if the user with given [email] already exists
  /// or the password is not valid.
  Future<User> createUserWithEmailAndPassword(String email, String password) =>
      handleThenableWithMapper(
          jsObject.createUserWithEmailAndPassword(email, password),
          (u) => new User.fromJsObject(u));

  /// Returns the list of provider IDs for the given [email] address,
  /// that can be used to sign in.
  Future<List<String>> fetchProvidersForEmail(String email) =>
      handleThenable(jsObject.fetchProvidersForEmail(email));

  /// Returns a [UserCredential] from the redirect-based sign in flow.
  /// If sign is successful, returns the signed in user. Or fails with an error
  /// if sign is unsuccessful.
  /// The [UserCredential] with a null [User] is returned if no redirect
  /// operation was called.
  Future<UserCredential> getRedirectResult() => handleThenableWithMapper(
      jsObject.getRedirectResult(), (u) => new UserCredential.fromJsObject(u));

  /// Sends a password reset e-mail to the given [email].
  /// To confirm password reset, use the [Auth.confirmPasswordReset].
  Future sendPasswordResetEmail(String email) =>
      handleThenable(jsObject.sendPasswordResetEmail(email));

  /// Signs in as an anonymous user. If an anonymous user is already
  /// signed in, that user will be returned. In other case, new anonymous
  /// [User] identity is created and returned.
  Future<User> signInAnonymously() => handleThenableWithMapper(
      jsObject.signInAnonymously(), (u) => new User.fromJsObject(u));

  /// Signs in with the given [credential] and returns the [User].
  Future<User> signInWithCredential(AuthCredential credential) =>
      handleThenableWithMapper(jsObject.signInWithCredential(credential),
          (u) => new User.fromJsObject(u));

  /// Signs in with the custom [token] and returns the [User].
  /// Custom token must be generated by an auth backend.
  /// Fails with an error if the token is invalid, expired or not accepted
  /// by Firebase Auth service.
  Future<User> signInWithCustomToken(String token) => handleThenableWithMapper(
      jsObject.signInWithCustomToken(token), (u) => new User.fromJsObject(u));

  /// Signs in with [email] and [password] and returns the [User].
  /// Fails with an error if the sign in is not successful.
  Future<User> signInWithEmailAndPassword(String email, String password) =>
      handleThenableWithMapper(
          jsObject.signInWithEmailAndPassword(email, password),
          (u) => new User.fromJsObject(u));

  /// Signs in using a popup-based OAuth authentication flow with the
  /// given [provider].
  /// Returns [UserCredential] if successful, or an error object if unsuccessful.
  Future<UserCredential> signInWithPopup(AuthProvider provider) =>
      handleThenableWithMapper(jsObject.signInWithPopup(provider.jsObject),
          (u) => new UserCredential.fromJsObject(u));

  /// Signs in using a full-page redirect flow with the given [provider].
  Future signInWithRedirect(AuthProvider provider) =>
      handleThenable(jsObject.signInWithRedirect(provider.jsObject));

  /// Signs out the current user.
  Future signOut() => handleThenable(jsObject.signOut());

  /// Verifies a password reset [code] sent to the user by email
  /// or other out-of-band mechanism.
  /// Returns the user's e-mail address if valid.
  Future<String> verifyPasswordResetCode(String code) =>
      handleThenable(jsObject.verifyPasswordResetCode(code));
}

/// Represents an auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.AuthProvider>.
abstract class AuthProvider<T extends AuthProviderJsImpl>
    extends JsObjectWrapper<T> {
  /// Provider id.
  String get providerId => jsObject.providerId;

  /// Creates a new AuthProvider from a [jsObject].
  AuthProvider.fromJsObject(T jsObject) : super.fromJsObject(jsObject);
}

/// E-mail and password auth provider implementation.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.EmailAuthProvider>.
class EmailAuthProvider extends AuthProvider<EmailAuthProviderJsImpl> {
  static String PROVIDER_ID = EmailAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new EmailAuthProvider.
  factory EmailAuthProvider() =>
      new EmailAuthProvider.fromJsObject(new EmailAuthProviderJsImpl());

  /// Creates a new EmailAuthProvider from a [jsObject].
  EmailAuthProvider.fromJsObject(EmailAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Creates a credential for e-mail.
  static AuthCredential credential(String email, String password) =>
      EmailAuthProviderJsImpl.credential(email, password);
}

/// Facebook auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.FacebookAuthProvider>.
class FacebookAuthProvider extends AuthProvider<FacebookAuthProviderJsImpl> {
  static String PROVIDER_ID = FacebookAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new FacebookAuthProvider.
  factory FacebookAuthProvider() =>
      new FacebookAuthProvider.fromJsObject(new FacebookAuthProviderJsImpl());

  /// Creates a new FacebookAuthProvider from a [jsObject].
  FacebookAuthProvider.fromJsObject(FacebookAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  FacebookAuthProvider addScope(String scope) =>
      new FacebookAuthProvider.fromJsObject(jsObject.addScope(scope));

  /// Sets the OAuth custom parameters to pass in a Facebook OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'auth_type', 'display' and 'locale'.
  /// For a detailed list, check the Facebook documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state' are not allowed
  /// and ignored.
  FacebookAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      new FacebookAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Facebook.
  static AuthCredential credential(String token) =>
      FacebookAuthProviderJsImpl.credential(token);
}

/// Github auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GithubAuthProvider>.
class GithubAuthProvider extends AuthProvider<GithubAuthProviderJsImpl> {
  static String PROVIDER_ID = GithubAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new GithubAuthProvider.
  factory GithubAuthProvider() =>
      new GithubAuthProvider.fromJsObject(new GithubAuthProviderJsImpl());

  /// Creates a new GithubAuthProvider from a [jsObject].
  GithubAuthProvider.fromJsObject(GithubAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  GithubAuthProvider addScope(String scope) =>
      new GithubAuthProvider.fromJsObject(jsObject.addScope(scope));

  /// Sets the OAuth custom parameters to pass in a GitHub OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'allow_signup'.
  /// For a detailed list, check the GitHub documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state'
  /// are not allowed and ignored.
  GithubAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      new GithubAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Github.
  static AuthCredential credential(String token) =>
      GithubAuthProviderJsImpl.credential(token);
}

/// Google auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.GoogleAuthProvider>.
class GoogleAuthProvider extends AuthProvider<GoogleAuthProviderJsImpl> {
  static String PROVIDER_ID = GoogleAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new GoogleAuthProvider.
  factory GoogleAuthProvider() =>
      new GoogleAuthProvider.fromJsObject(new GoogleAuthProviderJsImpl());

  /// Creates a new GoogleAuthProvider from a [jsObject].
  GoogleAuthProvider.fromJsObject(GoogleAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Adds additional OAuth 2.0 scopes that you want to request from the
  /// authentication provider.
  GoogleAuthProvider addScope(String scope) =>
      new GoogleAuthProvider.fromJsObject(jsObject.addScope(scope));

  /// Sets the OAuth custom parameters to pass in a Google OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'hd', 'hl', 'include_granted_scopes',
  /// 'login_hint' and 'prompt'.
  /// For a detailed list, check the Google documentation.
  /// Reserved required OAuth 2.0 parameters such as 'client_id',
  /// 'redirect_uri', 'scope', 'response_type' and 'state'
  /// are not allowed and ignored.
  GoogleAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      new GoogleAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Google.
  /// At least one of [idToken] and [accessToken] is required.
  static AuthCredential credential([String idToken, String accessToken]) =>
      GoogleAuthProviderJsImpl.credential(idToken, accessToken);
}

/// Twitter auth provider.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.TwitterAuthProvider>.
class TwitterAuthProvider extends AuthProvider<TwitterAuthProviderJsImpl> {
  static String PROVIDER_ID = TwitterAuthProviderJsImpl.PROVIDER_ID;

  /// Creates a new TwitterAuthProvider.
  factory TwitterAuthProvider() =>
      new TwitterAuthProvider.fromJsObject(new TwitterAuthProviderJsImpl());

  /// Creates a new TwitterAuthProvider from a [jsObject].
  TwitterAuthProvider.fromJsObject(TwitterAuthProviderJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Sets the OAuth custom parameters to pass in a Twitter OAuth request
  /// for popup and redirect sign-in operations.
  /// Valid parameters include 'lang'. Reserved required OAuth 1.0 parameters
  /// such as 'oauth_consumer_key', 'oauth_token', 'oauth_signature', etc
  /// are not allowed and will be ignored.
  TwitterAuthProvider setCustomParameters(
          Map<String, dynamic> customOAuthParameters) =>
      new TwitterAuthProvider.fromJsObject(
          jsObject.setCustomParameters(jsify(customOAuthParameters)));

  /// Creates a credential for Twitter.
  static AuthCredential credential(String token, String secret) =>
      TwitterAuthProviderJsImpl.credential(token, secret);
}

/// Event propagated in Stream controllers when an auth state changes.
class AuthEvent {
  /// The user.
  final User user;

  /// Creates a new AuthEvent with user.
  AuthEvent(this.user);
}

/// A structure containing [User] and [AuthCredential].
class UserCredential extends JsObjectWrapper<UserCredentialJsImpl> {
  User _user;

  /// Returns the user.
  User get user {
    if (jsObject.user != null) {
      if (_user != null) {
        _user.jsObject = jsObject.user;
      } else {
        _user = new User.fromJsObject(jsObject.user);
      }
    } else {
      _user = null;
    }
    return _user;
  }

  /// Sets the user to [u].
  void set user(User u) {
    _user = u;
    jsObject.user = u.jsObject;
  }

  /// Returns the auth credential.
  AuthCredential get credential => jsObject.credential;

  /// Sets the auth credential to [c].
  void set credential(AuthCredential c) {
    jsObject.credential = c;
  }

  /// Creates a new UserCredential with optional [user] and [credential].
  factory UserCredential({User user, AuthCredential credential}) =>
      new UserCredential.fromJsObject(new UserCredentialJsImpl(
          user: user.jsObject, credential: credential));

  /// Creates a new UserCredential from a [jsObject].
  UserCredential.fromJsObject(UserCredentialJsImpl jsObject)
      : super.fromJsObject(jsObject);
}
