@JS()
library messaging_demo.service_worker;

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/src/assets/assets.dart';
import 'package:service_worker/worker.dart' as sw;

import 'package:js/js.dart';

main(List<String> args) async {
  importScripts('https://www.gstatic.com/firebasejs/5.1.0/firebase-app.js');
  importScripts(
      'https://www.gstatic.com/firebasejs/5.1.0/firebase-messaging.js');

  await config();

  firebase.initializeApp(messagingSenderId: messagingSenderId);

  final messaging = firebase.messaging();
  messaging.onBackgroundMessage.listen((payload) {
    final options =
        new sw.ShowNotificationOptions(body: payload.notification.body);
    sw.registration.showNotification(payload.notification.title, options);
  });
}

@JS('importScripts')
external void importScripts(String url);
