@JS()
library messaging_demo.service_worker;

import 'package:firebase/firebase.dart' as firebase;
import 'package:service_worker/worker.dart' as sw;

import 'package:js/js.dart';

const config = const {
  'apiKey': "TODO",
  'authDomain': "TODO",
  'databaseURL': "TODO",
  'projectId': "TODO",
  'storageBucket': "TODO",
  'messagingSenderId': "TODO",
};

void main(List<String> args) {
  importScripts('https://www.gstatic.com/firebasejs/4.10.1/firebase-app.js');
  importScripts(
      'https://www.gstatic.com/firebasejs/4.10.1/firebase-messaging.js');

  firebase.initializeApp(
    apiKey: config['apiKey'],
    authDomain: config['authDomain'],
    databaseURL: config['databaseUrl'],
    storageBucket: config['storageBucket'],
    messagingSenderId: config['messagingSenderId'],
  );

  final messaging = firebase.messaging();
  messaging.onBackgroundMessage.listen((payload) {
    final options =
        new sw.ShowNotificationOptions(body: payload.notification.body);
    sw.registration.showNotification(payload.notification.title, options);
  });
}

@JS('importScripts')
external void importScripts(String url);
