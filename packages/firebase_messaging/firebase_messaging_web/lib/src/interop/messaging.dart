// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:js/js.dart';

import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'messaging_interop.dart' as messaging_interop;
import 'firebase_interop.dart' as firebase_interop;

export 'messaging_interop.dart';

/// Given an AppJSImp, return the Messaging instance.
Messaging getMessagingInstance([App app]) {
  return Messaging.getInstance(app != null
      ? firebase_interop.messaging(app.jsObject)
      : firebase_interop.messaging());
}

class Messaging extends JsObjectWrapper<messaging_interop.MessagingJsImpl> {
  static final _expando = Expando<Messaging>();

  static Messaging getInstance(messaging_interop.MessagingJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= Messaging._fromJsObject(jsObject);
  }

  static bool isSupported() => messaging_interop.isSupported();

  Messaging._fromJsObject(messaging_interop.MessagingJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// To forcibly stop a registration token from being used, delete it by calling this method.
  /// Calling this method will stop the periodic data transmission to the FCM backend.
  void deleteToken() {
    jsObject.deleteToken();
  }

  /// After calling [requestPermission] you can call this method to get an FCM registration token
  /// that can be used to send push messages to this user.
  Future<String> getToken({String vapidKey}) =>
      handleThenable(jsObject.getToken(vapidKey == null
          ? null
          : {
              'vapidKey': vapidKey,
            }));

  StreamController<MessagePayload> _onMessageController;
  StreamController<Null> _onTokenRefresh;
  StreamController<MessagePayload> _onBackgroundMessage;

  /// When a push message is received and the user is currently on a page for your origin,
  /// the message is passed to the page and an [onMessage] event is dispatched with the payload of the push message.
  Stream<MessagePayload> get onMessage =>
      _createOnMessageStream(_onMessageController);

  /// FCM directs push messages to your web page's [onMessage] callback if the user currently has it open.
  /// Otherwise, it calls your callback passed into [onBackgroundMessage].
  // Stream<Payload> get onBackgroundMessage =>
  //     _createBackgroundMessagedStream(_onBackgroundMessage);

  Stream<MessagePayload> _createOnMessageStream(
      StreamController<MessagePayload> controller) {
    if (controller == null) {
      controller = StreamController.broadcast(sync: true);
      final nextWrapper = allowInterop((payload) {
        controller.add(MessagePayload._fromJsObject(payload));
      });
      final errorWrapper = allowInterop((e) {
        controller.addError(e);
      });

      jsObject.onMessage(nextWrapper, errorWrapper);
    }
    return controller.stream;
  }

  // Stream<Payload> _createBackgroundMessagedStream(
  //     StreamController<Payload> controller) {
  //   if (controller == null) {
  //     controller = StreamController.broadcast(sync: true);
  //     final nextWrapper = allowInterop((payload) {
  //       controller.add(Payload._fromJsObject(payload));
  //     });
  //     jsObject.setBackgroundMessageHandler(nextWrapper);
  //   }
  //   return controller.stream;
  // }

  // Stream<Null> _createNullStream(StreamController controller) {
  //   if (controller == null) {
  //     final nextWrapper = allowInterop((_) => null);
  //     final errorWrapper = allowInterop((e) {
  //       controller.addError(e);
  //     });
  //     ZoneCallback onSnapshotUnsubscribe;

  //     void startListen() {
  //       onSnapshotUnsubscribe =
  //           jsObject.onTokenRefresh(nextWrapper, errorWrapper);
  //     }

  //     void stopListen() {
  //       onSnapshotUnsubscribe();
  //       onSnapshotUnsubscribe = null;
  //     }

  //     controller = StreamController<Null>.broadcast(
  //         onListen: startListen, onCancel: stopListen, sync: true);
  //   }
  //   return controller.stream;
  // }
}

class NotificationPayload
    extends JsObjectWrapper<messaging_interop.NotificationPayloadJsImpl> {
  NotificationPayload._fromJsObject(
      messaging_interop.NotificationPayloadJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String get title => jsObject.title;
  String get body => jsObject.body;
  String get image => jsObject.image;
}

class MessagePayload
    extends JsObjectWrapper<messaging_interop.MessagePayloadJsImpl> {
  MessagePayload._fromJsObject(messaging_interop.MessagePayloadJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String get collapseKey => jsObject.collapseKey;
  FcmOptions get fcmOptions => jsObject.fcmOptions == null
      ? null
      : FcmOptions._fromJsObject(jsObject.fcmOptions);
  NotificationPayload get notification =>
      NotificationPayload._fromJsObject(jsObject.notification);
  Map<String, dynamic> get data => dartify(jsObject.data);
  String get from => jsObject.from;
}

class FcmOptions extends JsObjectWrapper<messaging_interop.FcmOptionsJsImpl> {
  FcmOptions._fromJsObject(messaging_interop.FcmOptionsJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String get analyticsLabel => jsObject.analyticsLabel;
  String get link => jsObject.link;
}
