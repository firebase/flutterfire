// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

String get testEmulatorHost {
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    return '10.0.2.2';
  }
  return 'localhost';
}

bool get isMobile {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
}

Future<void> prepare() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.useAuthEmulator(testEmulatorHost, 9099);
}

Future<void> render(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: widget,
          ),
        ),
      ),
    ),
  );
}

Future<void> deleteAllAccounts() async {
  final id = DefaultFirebaseOptions.currentPlatform.projectId;
  final uriString =
      'http://$testEmulatorHost:9099/emulator/v1/projects/$id/accounts';
  final res = await http.delete(Uri.parse(uriString));

  if (res.statusCode != 200) throw Exception('Delete failed');
}

Future<Map<String, String>> getVerificationCodes() async {
  final id = DefaultFirebaseOptions.currentPlatform.projectId;
  final uriString =
      'http://$testEmulatorHost:9099/emulator/v1/projects/$id/verificationCodes';
  final res = await http.get(Uri.parse(uriString));

  final body = json.decode(res.body);
  final codes = (body['verificationCodes'] as List).fold<Map<String, String>>(
    {},
    (acc, value) {
      return {
        ...acc,
        value['phoneNumber']: value['code'],
      };
    },
  );

  return codes;
}
