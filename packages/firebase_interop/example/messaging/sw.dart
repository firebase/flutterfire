@JS()
library messaging_demo.service_worker;

import 'package:firebase_interop/firebase_interop.dart' as fb;
import 'package:firebase_interop/src/assets/assets.dart';
import 'package:service_worker/worker.dart' as sw;

import 'package:js/js.dart';

void main(List<String> args) async {
  importScripts('https://www.gstatic.com/firebasejs/7.13.1/firebase-app.js');
  importScripts(
      'https://www.gstatic.com/firebasejs/7.13.1/firebase-messaging.js');

  await config();

  fb.initializeApp(messagingSenderId: messagingSenderId);

  final messaging = fb.messaging();
  messaging.onBackgroundMessage.listen((payload) {
    final options = sw.ShowNotificationOptions(body: payload.notification.body);
    sw.registration.showNotification(payload.notification.title, options);
  });
}

@JS('importScripts')
external void importScripts(String url);
