// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase_messaging')
library firebase_interop.messaging;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external MessagingJsImpl getMessaging([AppJsImpl? app]);

@JS()
@staticInterop
external JSPromise /* bool */ deleteToken(MessagingJsImpl messaging);

@JS()
@staticInterop
external JSPromise /* String */ getToken(
    MessagingJsImpl messaging, GetTokenOptions? getTokenOptions);

@JS('isSupported')
@staticInterop
external JSPromise /* bool */ isSupported();

@JS()
@staticInterop
external JSFunction onMessage(
  MessagingJsImpl messaging,
  Observer observer,
);

@JS('Messaging')
@staticInterop
abstract class MessagingJsImpl {}

@JS()
@staticInterop
@anonymous
class Observer {
  external factory Observer({JSAny next, JSAny error});
}

extension ObserverJsImplX on Observer {
  external JSAny get next;
  external JSAny get error;
}

@JS()
@staticInterop
@anonymous
class GetTokenOptions {
  // TODO - I imagine we won't be implementing serviceWorkerRegistration type as it extends EventTarget class
  // external String get serviceWorkerRegistration
  external factory GetTokenOptions({
    JSString? vapidKey,
    /*dynamic serviceWorkerRegistration */
  });
}

extension GetTokenOptionsJsImplX on GetTokenOptions {
  external JSString get vapidKey;
}

@JS()
@staticInterop
@anonymous
abstract class NotificationPayloadJsImpl {}

extension NotificationPayloadJsImplX on NotificationPayloadJsImpl {
  external JSString? get title;
  external JSString? get body;
  external JSString? get image;
}

@JS()
@staticInterop
@anonymous
abstract class MessagePayloadJsImpl {}

extension MessagePayloadJsImplX on MessagePayloadJsImpl {
  external JSString get messageId;
  external JSString? get collapseKey;
  external FcmOptionsJsImpl? get fcmOptions;
  external NotificationPayloadJsImpl? get notification;
  external JSObject? get data;
  external JSString? get from;
}

@JS()
@staticInterop
@anonymous
abstract class FcmOptionsJsImpl {}

extension FcmOptionsJsImplX on FcmOptionsJsImpl {
  external JSString? get analyticsLabel;
  external JSString? get link;
}
