// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
class FirebaseFunctionsMock {
  external factory FirebaseFunctionsMock({
    Function useFunctionsEmulator,
    Function httpsCallable,
  });

  external Function get useFunctionsEmulator;
  external Function get httpsCallable;
}

@JS()
@anonymous
class FirebaseHttpsCallableMock {
  external factory FirebaseHttpsCallableMock({
    Function call,
});

  external Function get call;
}

@JS()
@anonymous
class FirebaseMock {
  external factory FirebaseMock({Function app});
  external Function get app;

  external set functions(Function functions);
  external Function get functions;
}

@JS()
class Promise<T> {
  external Promise(void executor(void resolve(T result), Function reject));
  external Promise then(void onFulfilled(T result), [Function onRejected]);
}

// Wire to the global 'window.firebase' object.
@JS('firebase')
external set firebaseMock(FirebaseMock mock);
@JS('firebase')
external FirebaseMock get firebaseMock;
