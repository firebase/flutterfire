import 'dart:convert';
import 'dart:io';
import 'package:firebase_admin/src/auth/credential.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_example/main.dart';
import 'package:flutter/services.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  patrolTest(
    'counter state is the same after going to home and switching apps',
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(await prepareApp());

      await $('Request Permissions').tap(settlePolicy: SettlePolicy.noSettle);

      if (Platform.isAndroid) {
        await $.native.grantPermissionOnlyThisTime();
      } else if (Platform.isIOS) {
        await $.native.tap(
          Selector(text: 'Allow'),
          appId: 'com.apple.springboard',
        );
      }

      await $.pumpAndSettle();

      await $.native.openNotifications();
      final notification = await $.native.getFirstNotification();
      expect(notification.title, 'title');
      expect(notification.content, 'body');
    },
  );
}

Future<void> sendNotification() async {
  final credential = ServiceAccountCredential.fromJson(
    jsonDecode(
      await rootBundle.loadString('assets/scripts/service-account.json'),
    ),
  );

  final token = await FirebaseMessaging.instance.getToken();
  final accessToken = (await credential.getAccessToken()).accessToken;

  await http.post(
    Uri.parse(
        'https://fcm.googleapis.com/v1/projects/patrol-poc/messages:send'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'message': {
        'token': token,
        'notification': {
          'title': 'title',
          'body': 'body',
        }
      }
    }),
  );
}
