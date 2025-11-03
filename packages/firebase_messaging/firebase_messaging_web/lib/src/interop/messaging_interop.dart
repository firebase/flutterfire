// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase_messaging')
library;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external MessagingJsImpl getMessaging([AppJsImpl? app]);

@JS()
@staticInterop
external JSPromise<JSBoolean> deleteToken(MessagingJsImpl messaging);

@JS()
@staticInterop
external JSPromise<JSString> getToken(
    MessagingJsImpl messaging, GetTokenOptions? getTokenOptions);

@JS('isSupported')
@staticInterop
external JSPromise<JSBoolean> isSupported();

@JS()
@staticInterop
external JSFunction onMessage(
  MessagingJsImpl messaging,
  Observer observer,
);

extension type MessagingJsImpl._(JSObject _) implements JSObject {}

extension type Observer._(JSObject _) implements JSObject {
  external factory Observer({JSAny next, JSAny error});
  external JSAny get next;
  external JSAny get error;
}

extension type GetTokenOptions._(JSObject _) implements JSObject {
  // TODO - I imagine we won't be implementing serviceWorkerRegistration type as it extends EventTarget class
  // external String get serviceWorkerRegistration
  external factory GetTokenOptions({
    JSString? vapidKey,
    /*dynamic serviceWorkerRegistration */
  });
  external JSString get vapidKey;
}

extension type NotificationPayloadJsImpl._(JSObject _) implements JSObject {
  external JSString? get title;
  external JSString? get body;
  external JSString? get image;
}

extension type MessagePayloadJsImpl._(JSObject _) implements JSObject {
  external JSString get messageId;
  external JSString? get collapseKey;
  external FcmOptionsJsImpl? get fcmOptions;
  external NotificationPayloadJsImpl? get notification;
  external JSObject? get data;
  external JSString? get from;
}

extension type FcmOptionsJsImpl._(JSObject _) implements JSObject {
  external JSString? get analyticsLabel;
  external JSString? get link;
}
