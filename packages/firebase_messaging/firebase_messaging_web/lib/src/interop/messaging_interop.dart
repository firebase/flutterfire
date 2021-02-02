// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase.messaging')
library firebase_interop.messaging;

import 'package:js/js.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS('isSupported')
external bool isSupported();

@JS('Messaging')
abstract class MessagingJsImpl {
  external void deleteToken();
  external PromiseJsImpl<String> getToken(dynamic getTokenOptions);
  external void Function() onMessage(
    dynamic optionsOrObserverOrOnNext,
    dynamic observerOrOnNextOrOnError,
  );
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
