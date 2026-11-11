// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, non_constant_identifier_names

@JS('firebase_core')
library;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
external JSArray<AppJsImpl> getApps();

/// The current SDK version.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase#.SDK_VERSION>.
@JS()
external String get SDK_VERSION;

@JS()
external AppJsImpl initializeApp(FirebaseOptions options, [JSString? name]);

@JS()
external AppJsImpl getApp([JSString? name]);

@JS()
external JSPromise deleteApp(AppJsImpl app);

@JS()
external void registerVersion(
  JSString libraryKeyOrName,
  JSString version, [
  JSString? variant,
]);

/// The provider for the component named [name] in [app]'s container. Internal
/// to the JS SDK; how its modules reach each other's components.
@JS('_getProvider')
external ProviderJsImpl getProvider(AppJsImpl app, JSString name);

/// A component provider of the Firebase JS SDK.
extension type ProviderJsImpl._(JSObject _) implements JSObject {
  /// The component's instance. With `optional: true`, null when the module that
  /// registers the component isn't loaded or hasn't been initialized.
  external JSObject? getImmediate(ProviderGetImmediateOptions options);
}

/// Options for [ProviderJsImpl.getImmediate].
extension type ProviderGetImmediateOptions._(JSObject _) implements JSObject {
  external factory ProviderGetImmediateOptions({bool optional});
}

/// FirebaseError is a subclass of the standard Error object.
/// In addition to a message string, it contains a string-valued code.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.FirebaseError>.
extension type FirebaseErrorJsImpl._(JSObject _) implements JSObject {
  external JSString get code;
  external JSString get message;
  external JSString get name;
  external JSString get stack;

  /// Not part of the core JS API, but occasionally exposed in error objects.
  external JSAny get serverResponse;
}

/// A structure for options provided to Firebase.
extension type FirebaseOptions._(JSObject _) implements JSObject {
  external factory FirebaseOptions({
    JSString? apiKey,
    JSString? authDomain,
    JSString? databaseURL,
    JSString? projectId,
    JSString? storageBucket,
    JSString? messagingSenderId,
    JSString? measurementId,
    JSString? appId,
  });
}

extension FirebaseOptionsExtension on FirebaseOptions {
  external JSString? get apiKey;
  external set apiKey(JSString? s);
  external JSString? get authDomain;
  external set authDomain(JSString? s);
  external JSString? get databaseURL;
  external set databaseURL(JSString? s);
  external JSString? get projectId;
  external set projectId(JSString? s);
  external JSString? get storageBucket;
  external set storageBucket(JSString? s);
  external JSString? get messagingSenderId;
  external set messagingSenderId(JSString? s);
  external JSString? get measurementId;
  external set measurementId(JSString? s);
  external JSString? get appId;
  external set appId(JSString? s);
}
