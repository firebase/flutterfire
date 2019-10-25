import 'dart:async';
import 'dart:convert';

import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

// TODO(bparrishMines): Setup environment variable to run onMessage test on CI/Firebase Testlab.
// Replace with server token from firebase console settings.
final String serverToken = '<Server-Token>';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseMessaging', () {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    setUpAll(() async {
      await firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true),
      );
    });

    // We skip this test because it requires a valid server token specified at the top of this file.
    // It also requires agreeing to receive messages by hand on ios.
    test('onMessage', () async {
      await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'this is a body',
              'title': 'this is a title'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': await firebaseMessaging.getToken(),
          },
        ),
      );

      final Completer<Map<String, dynamic>> completer =
          Completer<Map<String, dynamic>>();

      firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          completer.complete(message);
        },
      );

      final Map<String, dynamic> message = await completer.future;
      expect(
        message,
        containsPair('notification', containsPair('title', 'this is a title')),
      );
      expect(
        message,
        containsPair('notification', containsPair('body', 'this is a body')),
      );
    }, timeout: const Timeout(Duration(seconds: 5)), skip: true);

    test('autoInitEnabled', () async {
      await firebaseMessaging.setAutoInitEnabled(false);
      expect(await firebaseMessaging.autoInitEnabled(), false);
      await firebaseMessaging.setAutoInitEnabled(true);
      expect(await firebaseMessaging.autoInitEnabled(), true);
    });

    // TODO(jackson): token retrieval isn't working on test devices yet
    test('subscribeToTopic', () async {
      await firebaseMessaging.subscribeToTopic('foo');
    }, skip: true);

    // TODO(jackson): token retrieval isn't working on test devices yet
    test('unsubscribeFromTopic', () async {
      await firebaseMessaging.unsubscribeFromTopic('foo');
    }, skip: true);

    test('deleteInstanceID', () async {
      final bool result = await firebaseMessaging.deleteInstanceID();
      expect(result, isTrue);
    });
  });
}
