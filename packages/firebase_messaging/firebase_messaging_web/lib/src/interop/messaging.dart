// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:js/js.dart';

import 'messaging_interop.dart' as messaging_interop;

export 'messaging_interop.dart';

/// Given an AppJSImp, return the Messaging instance.
Messaging getMessagingInstance([App? app]) {
  return Messaging.getInstance(app != null
      ? messaging_interop.getMessaging(app.jsObject)
      : messaging_interop.getMessaging());
}

class Messaging extends JsObjectWrapper<messaging_interop.MessagingJsImpl> {
  static final _expando = Expando<Messaging>();

  static Messaging getInstance(messaging_interop.MessagingJsImpl jsObject) {
    return _expando[jsObject] ??= Messaging._fromJsObject(jsObject);
  }

  static Future<bool> isSupported() =>
      handleThenable(messaging_interop.isSupported());

  Messaging._fromJsObject(messaging_interop.MessagingJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// To forcibly stop a registration token from being used, delete it by calling this method.
  /// Calling this method will stop the periodic data transmission to the FCM backend.
  Future<void> deleteToken() =>
      handleThenable(messaging_interop.deleteToken(jsObject));

  /// After calling [requestPermission] you can call this method to get an FCM registration token
  /// that can be used to send push messages to this user.
  Future<String> getToken({String? vapidKey}) =>
      handleThenable(messaging_interop.getToken(
          jsObject,
          vapidKey == null
              ? null
              : messaging_interop.GetTokenOptions(vapidKey: vapidKey)));

  // ignore: close_sinks
  StreamController<MessagePayload>? _onMessageController;

  /// When a push message is received and the user is currently on a page for your origin,
  /// the message is passed to the page and an [onMessage] event is dispatched with the payload of the push message.
  Stream<MessagePayload> get onMessage =>
      _createOnMessageStream(_onMessageController);

  Stream<MessagePayload> _createOnMessageStream(
      StreamController<MessagePayload>? controller) {
    StreamController<MessagePayload>? _controller = controller;
    if (_controller == null) {
      _controller = StreamController.broadcast(sync: true);
      final nextWrapper = allowInterop((payload) {
        _controller!.add(MessagePayload._fromJsObject(payload));
      });
      final errorWrapper = allowInterop((e) {
        _controller!.addError(e);
      });

      messaging_interop.onMessage(jsObject,
          messaging_interop.Observer(next: nextWrapper, error: errorWrapper));
    }
    return _controller.stream;
  }
}

class NotificationPayload
    extends JsObjectWrapper<messaging_interop.NotificationPayloadJsImpl> {
  NotificationPayload._fromJsObject(
      messaging_interop.NotificationPayloadJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String? get title => jsObject.title;
  String? get body => jsObject.body;
  String? get image => jsObject.image;
}

class MessagePayload
    extends JsObjectWrapper<messaging_interop.MessagePayloadJsImpl> {
  MessagePayload._fromJsObject(messaging_interop.MessagePayloadJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String get messageId => jsObject.messageId;
  String? get collapseKey => jsObject.collapseKey;
  FcmOptions? get fcmOptions => jsObject.fcmOptions == null
      ? null
      : FcmOptions._fromJsObject(jsObject.fcmOptions!);
  NotificationPayload? get notification => jsObject.notification == null
      ? null
      : NotificationPayload._fromJsObject(jsObject.notification!);
  Map<String, dynamic>? get data => dartify(jsObject.data);
  String? get from => jsObject.from;
}

class FcmOptions extends JsObjectWrapper<messaging_interop.FcmOptionsJsImpl> {
  FcmOptions._fromJsObject(messaging_interop.FcmOptionsJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String? get analyticsLabel => jsObject.analyticsLabel;
  String? get link => jsObject.link;
}
