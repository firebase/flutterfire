import 'dart:async';

import 'package:js/js.dart';

import 'interop/messaging_interop.dart' as messaging_interop;
import 'js.dart';
import 'utils.dart';

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

  /// To set your own server application key,
  /// you can specify here the public key you set up from the Firebase Console under the Settings options.
  void usePublicVapidKey(String key) {
    jsObject.usePublicVapidKey(key);
  }

  /// To use your own service worker for receiving push messages,
  /// you can pass in your service worker registration in this method.
  void useServiceWorker(registration) {
    jsObject.useServiceWorker(registration);
  }

  /// To forcibly stop a registration token from being used, delete it by calling this method.
  /// Calling this method will stop the periodic data transmission to the FCM backend.
  void deleteToken(String token) {
    jsObject.deleteToken(token);
  }

  /// Notification permissions are required to send a user push messages.
  /// Calling this method displays the permission dialog to the user and resolves if the permission is granted.
  Future requestPermission() async {
    await handleThenable(jsObject.requestPermission()).then(dartify);
  }

  /// After calling [requestPermission] you can call this method to get an FCM registration token
  /// that can be used to send push messages to this user.
  Future<String> getToken() => handleThenable(jsObject.getToken());

  StreamController<Payload> _onMessageController;
  StreamController<Null> _onTokenRefresh;
  StreamController<Payload> _onBackgroundMessage;

  /// When a push message is received and the user is currently on a page for your origin,
  /// the message is passed to the page and an [onMessage] event is dispatched with the payload of the push message.
  Stream<Payload> get onMessage => _createOnMessageStream(_onMessageController);

  /// FCM directs push messages to your web page's [onMessage] callback if the user currently has it open.
  /// Otherwise, it calls your callback passed into [onBackgroundMessage].
  Stream<Payload> get onBackgroundMessage =>
      _createBackgroundMessagedStream(_onBackgroundMessage);

  /// You should listen for token refreshes so your web app knows when FCM
  /// has invalidated your existing token and you need to call [getToken] to get a new token.
  Stream<Null> get onTokenRefresh => _createNullStream(_onTokenRefresh);

  Stream<Payload> _createOnMessageStream(StreamController<Payload> controller) {
    if (controller == null) {
      controller = StreamController.broadcast(sync: true);
      final nextWrapper = allowInterop((payload) {
        controller.add(Payload._fromJsObject(payload));
      });
      final errorWrapper = allowInterop((e) {
        controller.addError(e);
      });
      jsObject.onMessage(nextWrapper, errorWrapper);
    }
    return controller.stream;
  }

  Stream<Payload> _createBackgroundMessagedStream(
      StreamController<Payload> controller) {
    if (controller == null) {
      controller = StreamController.broadcast(sync: true);
      final nextWrapper = allowInterop((payload) {
        controller.add(Payload._fromJsObject(payload));
      });
      jsObject.setBackgroundMessageHandler(nextWrapper);
    }
    return controller.stream;
  }

  Stream<Null> _createNullStream(StreamController controller) {
    if (controller == null) {
      final nextWrapper = allowInterop((_) => null);
      final errorWrapper = allowInterop((e) {
        controller.addError(e);
      });
      ZoneCallback onSnapshotUnsubscribe;

      void startListen() {
        onSnapshotUnsubscribe =
            jsObject.onTokenRefresh(nextWrapper, errorWrapper);
      }

      void stopListen() {
        onSnapshotUnsubscribe();
        onSnapshotUnsubscribe = null;
      }

      controller = StreamController<Null>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return controller.stream;
  }
}

class Notification
    extends JsObjectWrapper<messaging_interop.NotificationJsImpl> {
  Notification._fromJsObject(messaging_interop.NotificationJsImpl jsObject)
      : super.fromJsObject(jsObject);

  String get title => jsObject.title;
  String get body => jsObject.body;
  String get clickAction => jsObject.click_action;
  String get icon => jsObject.icon;
}

class Payload extends JsObjectWrapper<messaging_interop.PayloadJsImpl> {
  Payload._fromJsObject(messaging_interop.PayloadJsImpl jsObject)
      : super.fromJsObject(jsObject);

  Notification get notification =>
      Notification._fromJsObject(jsObject.notification);
  String get collapseKey => jsObject.collapse_key;
  String get from => jsObject.from;
  Map<String, dynamic> get data => dartify(jsObject.data);
}
