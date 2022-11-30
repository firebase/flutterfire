// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase_messaging')
library firebase_interop.messaging;

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

@JS()
external MessagingJsImpl getMessaging([AppJsImpl? app]);

@JS()
external PromiseJsImpl<bool> deleteToken(MessagingJsImpl messaging);

@JS()
external PromiseJsImpl<String> getToken(
    MessagingJsImpl messaging, GetTokenOptions? getTokenOptions);

@JS('isSupported')
external PromiseJsImpl<bool> isSupported();

@JS()
external void Function() onMessage(
  MessagingJsImpl messaging,
  Observer observer,
);

@JS('Messaging')
abstract class MessagingJsImpl {}

@JS()
@anonymous
class Observer {
  external dynamic get next;
  external dynamic get error;
  external factory Observer({dynamic next, dynamic error});
}

@JS()
@anonymous
class GetTokenOptions {
  external String get vapidKey;
  // TODO - I imagine we won't be implementing serviceWorkerRegistration type as it extends EventTarget class
  // external String get serviceWorkerRegistration
  external factory GetTokenOptions({
    String? vapidKey,
    /*dynamic serviceWorkerRegistration */
  });
}

@JS()
@anonymous
abstract class NotificationPayloadJsImpl {
  external String? get title;
  external String? get body;
  external String? get image;
}

@JS()
@anonymous
abstract class MessagePayloadJsImpl {
  external String get messageId;
  external String? get collapseKey;
  external FcmOptionsJsImpl? get fcmOptions;
  external NotificationPayloadJsImpl? get notification;
  external dynamic /*Map<String, String>*/ get data;
  external String? get from;
}

@JS()
@anonymous
abstract class FcmOptionsJsImpl {
  external String? get analyticsLabel;
  external String? get link;
}
