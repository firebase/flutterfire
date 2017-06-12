@JS('firebase')
library firebase.firebase_interop;

import 'package:func/func.dart';
import 'package:js/js.dart';

import 'app_interop.dart';
import 'auth_interop.dart';
import 'database_interop.dart';
import 'storage_interop.dart';

@JS()
external List<AppJsImpl> get apps;

/// The current SDK version.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase#.SDK_VERSION>.
@JS()
external String get SDK_VERSION;

@JS()
external AppJsImpl initializeApp(FirebaseOptions options, [String name]);
@JS()
external AppJsImpl app([String name]);
@JS()
external AuthJsImpl auth([AppJsImpl app]);
@JS()
external DatabaseJsImpl database([AppJsImpl app]);
@JS()
external StorageJsImpl storage([AppJsImpl app]);

@JS('User')
abstract class UserJsImpl extends UserInfoJsImpl {
  external bool get emailVerified;
  external void set emailVerified(bool v);
  external bool get isAnonymous;
  external void set isAnonymous(bool a);
  external List<UserInfoJsImpl> get providerData;
  external void set providerData(List<UserInfoJsImpl> d);
  external String get refreshToken;
  external void set refreshToken(String t);
  external PromiseJsImpl delete();
  external PromiseJsImpl<String> getToken([bool opt_forceRefresh]);
  external PromiseJsImpl<UserJsImpl> link(AuthCredential credential);
  external PromiseJsImpl<UserJsImpl> linkWithCredential(
      AuthCredential credential);
  external PromiseJsImpl<UserCredentialJsImpl> linkWithPopup(
      AuthProviderJsImpl provider);
  external PromiseJsImpl linkWithRedirect(AuthProviderJsImpl provider);
  external PromiseJsImpl reauthenticate(AuthCredential credential);
  external PromiseJsImpl reauthenticateWithCredential(
      AuthCredential credential);
  external PromiseJsImpl<UserCredentialJsImpl> reauthenticateWithPopup(
      AuthProviderJsImpl provider);
  external PromiseJsImpl reauthenticateWithRedirect(
      AuthProviderJsImpl provider);
  external PromiseJsImpl reload();
  external PromiseJsImpl sendEmailVerification();
  external PromiseJsImpl<UserJsImpl> unlink(String providerId);
  external PromiseJsImpl updateEmail(String newEmail);
  external PromiseJsImpl updatePassword(String newPassword);
  external PromiseJsImpl updateProfile(UserProfile profile);
}

@JS('UserInfo')
abstract class UserInfoJsImpl {
  external String get displayName;
  external void set displayName(String s);
  external String get email;
  external void set email(String s);
  external String get photoURL;
  external void set photoURL(String s);
  external String get providerId;
  external void set providerId(String s);
  external String get uid;
  external void set uid(String s);
}

@JS('Promise')
class PromiseJsImpl<T> extends ThenableJsImpl<T> {
  external PromiseJsImpl(Function resolver);
  external static PromiseJsImpl<List> all(List<PromiseJsImpl> values);
  external static PromiseJsImpl reject(error);
  external static PromiseJsImpl resolve(value);
}

@JS('Thenable')
abstract class ThenableJsImpl<T> {
  external ThenableJsImpl JS$catch([Func1 onReject]);
  external ThenableJsImpl then([Func1 onResolve, Func1 onReject]);
}

/// FirebaseError is a subclass of the standard Error object.
/// In addition to a message string, it contains a string-valued code.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.FirebaseError>.
@JS()
abstract class FirebaseError {
  external String get code;
  external void set code(String s);
  external String get message;
  external void set message(String s);
  external String get name;
  external void set name(String s);
  external String get stack;
  external void set stack(String s);
}

/// A structure for [User]'s user profile.
@JS()
@anonymous
class UserProfile {
  external String get displayName;
  external void set displayName(String s);
  external String get photoURL;
  external void set photoURL(String s);

  external factory UserProfile({String displayName, String photoURL});
}

/// A structure for options provided to Firebase.
@JS()
@anonymous
class FirebaseOptions {
  external String get apiKey;
  external void set apiKey(String s);
  external String get authDomain;
  external void set authDomain(String s);
  external String get databaseURL;
  external void set databaseURL(String s);
  external String get storageBucket;
  external void set storageBucket(String s);

  external factory FirebaseOptions(
      {String apiKey,
      String authDomain,
      String databaseURL,
      String storageBucket});
}
