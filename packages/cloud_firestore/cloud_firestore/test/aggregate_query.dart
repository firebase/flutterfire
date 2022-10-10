// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import './mock.dart';
import './test_firestore_message_codec.dart';

int kCount = 4;

void main() {
  setupCloudFirestoreMocks();
  MethodChannelFirebaseFirestore.channel = const MethodChannel(
    'plugins.flutter.io/firebase_firestore',
    StandardMethodCodec(TestFirestoreMessageCodec()),
  );

  MethodChannelFirebaseFirestore.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'AggregateQuery#countGet' ) {
      return {
        'count': kCount,
      };
    }

    return null;
  });

  FirebaseFirestore? firestore;

  group('$AggregateQuery', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      firestore = FirebaseFirestore.instance;
    });

    test('returns the correct `AggregateQuerySnapshot` with correct `count`', () async {
      print('WWWWWWW');
      Query query = firestore!.collection('flutter-tests');
      AggregateQuery aggregateQuery = query.count();

      expect(query, aggregateQuery.query);
      AggregateQuerySnapshot snapshot = await aggregateQuery.get();

      expect(snapshot.count, equals(kCount));
    });
  });
}
