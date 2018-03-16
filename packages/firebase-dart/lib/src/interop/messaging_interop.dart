@JS('firebase.messaging')
library firebase.messaging_interop;

import 'package:js/js.dart';

import '../func.dart';
import 'firebase_interop.dart';

@JS('Messaging')
abstract class MessagingJsImpl {
  external void usePublicVapidKey(String key);
  external PromiseJsImpl requestPermission();
  external PromiseJsImpl<String> getToken();
  external VoidFunc0 onMessage(
      optionsOrObserverOrOnNext, observerOrOnNextOrOnError);
  external VoidFunc0 onTokenRefresh(
      optionsOrObserverOrOnNext, observerOrOnNextOrOnError);
  external void setBackgroundMessageHandler(Func1 f);
  external void useServiceWorker(registration);
  external void deleteToken(String token);
}

@JS()
@anonymous
abstract class NotificationJsImpl {
  external String get title;
  external String get body;
  // ignore: non_constant_identifier_names
  external String get click_action;
  external String get icon;
}

@JS()
@anonymous
abstract class PayloadJsImpl {
  // ignore: non_constant_identifier_names
  external String get collapse_key;
  external String get from;
  external NotificationJsImpl get notification;
  external dynamic /*Map<String, String>*/ get data;
}
