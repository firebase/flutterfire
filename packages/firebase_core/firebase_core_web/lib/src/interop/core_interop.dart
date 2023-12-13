// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, non_constant_identifier_names

@JS('firebase_core')
library firebase_interop.core;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
// List<AppJsImpl>
external JSArray getApps();

/// The current SDK version.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase#.SDK_VERSION>.
@JS()
external String get SDK_VERSION;

@JS()
external AppJsImpl initializeApp(FirebaseOptions options, [String? name]);

@JS()
external AppJsImpl getApp([String? name]);

@JS()
external JSPromise deleteApp(AppJsImpl app);

/// FirebaseError is a subclass of the standard Error object.
/// In addition to a message string, it contains a string-valued code.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.FirebaseError>.
@JS()
@anonymous
@staticInterop
abstract class FirebaseError {}

extension FirebaseErrorExtension on FirebaseError {
  external String get code;
  external String get message;
  external String get name;
  external String get stack;

  /// Not part of the core JS API, but occasionally exposed in error objects.
  external JSAny get serverResponse;
}

/// A structure for options provided to Firebase.
@JS()
@anonymous
@staticInterop
class FirebaseOptions {
  external factory FirebaseOptions({
    String? apiKey,
    String? authDomain,
    String? databaseURL,
    String? projectId,
    String? storageBucket,
    String? messagingSenderId,
    String? measurementId,
    String? appId,
  });
}

extension FirebaseOptionsExtension on FirebaseOptions {
  external String get apiKey;
  external set apiKey(String s);
  external String get authDomain;
  external set authDomain(String s);
  external String get databaseURL;
  external set databaseURL(String s);
  external String get projectId;
  external set projectId(String s);
  external String get storageBucket;
  external set storageBucket(String s);
  external String get messagingSenderId;
  external set messagingSenderId(String s);
  external String get measurementId;
  external set measurementId(String s);
  external String get appId;
  external set appId(String s);
}
