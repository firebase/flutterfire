// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_firestore.dart';
import 'test_firestore_message_codec.dart';

typedef MethodCallCallback = dynamic Function(MethodCall methodCall);

const kCollectionId = "foo";
const kDocumentId = "bar";

const Map<String, dynamic> kMockSnapshotMetadata = <String, dynamic>{
  "hasPendingWrites": false,
  "isFromCache": false,
};

const Map<String, dynamic> kMockDocumentSnapshotData = <String, dynamic>{
  '1': 2
};

int mockHandleId = 0;

int get nextMockHandleId => mockHandleId++;

void initializeMethodChannel() {
  // Install the Codec that is able to decode FieldValues.
  MethodChannelFirebaseFirestore.channel = MethodChannel(
    'plugins.flutter.io/firebase_firestore',
    StandardMethodCodec(TestFirestoreMessageCodec()),
  );

  TestWidgetsFlutterBinding.ensureInitialized();
  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }
    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }
    return null;
  });
}

void handleMethodCall(MethodCallCallback methodCallCallback) =>
    MethodChannelFirebaseFirestore.channel
        .setMockMethodCallHandler((call) async {
      return await methodCallCallback(call);
    });
