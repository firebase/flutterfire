@JS()
library firebase_mock;

import 'package:js/js.dart';

@JS()
@anonymous
class FirebaseAppOptionsMock {
  external factory FirebaseAppOptionsMock({String appId});
  external String get appId;
}

@JS()
@anonymous
class FirebaseAppMock {
  external factory FirebaseAppMock({
    String name,
    FirebaseAppOptionsMock options,
  });
  external String get name;
  external FirebaseAppOptionsMock get options;
}

@JS()
@anonymous
class FirebaseAuthMock {
  external factory FirebaseAuthMock({
    Function signInAnonymously,
    Function onAuthStateChanged,
  });
  external Function get signInAnonymously;
  external Function get onAuthStateChanged;
}

@JS()
@anonymous
class FirebaseMock {
  external factory FirebaseMock({Function app});
  external Function get app;

  external set auth(Function auth);
  external Function get auth;
}

@JS()
class Promise<T> {
  external Promise(void executor(void resolve(T result), Function reject));
  external Promise then(void onFulfilled(T result), [Function onRejected]);
}

@JS()
@anonymous
class MockUserMetadata {
  external factory MockUserMetadata({
    String creationTime,
    String lastSignInTime,
  });
  external String get creationTime;
  external String get lastSignInTime;
}

@JS()
@anonymous
class MockUser {
  external factory MockUser({
    String providerId,
    MockUserMetadata metadata,
    List providerData,
  });
  external String get providerId;
  external MockUserMetadata get metadata;
  external List get providerData;
}

@JS()
@anonymous
class MockAdditionalUserInfo {
  external factory MockAdditionalUserInfo();
}

@JS()
@anonymous
class MockUserCredential {
  external factory MockUserCredential({
    MockUser user,
    MockAdditionalUserInfo additionalUserInfo,
  });
  external MockUser get user;
  external MockAdditionalUserInfo get additionalUserInfo;
}

// Wire to the global 'window.firebase' object.
@JS('firebase')
external set firebaseMock(FirebaseMock mock);
@JS('firebase')
external FirebaseMock get firebaseMock;
