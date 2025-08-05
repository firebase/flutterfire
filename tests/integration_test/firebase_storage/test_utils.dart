// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:tests/firebase_options.dart';

final String kTestString =
    ([]..length = int.parse('${pow(2, 12)}')).join(_getRandomString(8)) * 100;
const String kTestStorageBucket = 'flutterfire-e2e-tests.appspot.com';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _random = Random();
String _getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_random.nextInt(_chars.length)),
      ),
    );

String get testEmulatorHost {
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    return '10.0.2.2';
  }
  return 'localhost';
}

const int testEmulatorPort = 9199;

// Creates a test file with a specified name to
// a locally directory
Future<File> createFile(
  String name, {
  String? string,
  int sizeInBytes = 209715200,
}) async {
  final Directory systemTempDir = Directory.systemTemp;
  final File file = await File('${systemTempDir.path}/$name').create();

  if (string != null) {
    await file.writeAsString(string);
    return file;
  }

  // Create a 200MB file by writing data in chunks to avoid memory issues
  const chunkSize = 1024 * 1024; // 1MB chunks
  final chunk = Uint8List(chunkSize);

  // Fill chunk with random-ish data to prevent compression
  for (int i = 0; i < chunkSize; i++) {
    chunk[i] = i % 256; // Creates a pattern from 0-255
  }

  final sink = file.openWrite();
  final totalChunks = (sizeInBytes / chunkSize).ceil();

  for (int i = 0; i < totalChunks; i++) {
    if (i == totalChunks - 1) {
      // Last chunk might be smaller
      final remainingBytes = sizeInBytes % chunkSize;
      if (remainingBytes > 0) {
        sink.add(chunk.sublist(0, remainingBytes));
      } else {
        sink.add(chunk);
      }
    } else {
      sink.add(chunk);
    }
  }

  await sink.close();

  return file;
}

Uint8List createBlob(String content) {
  return Uint8List.fromList(content.codeUnits);
}

// Initializes a secondary app with or without a
// default storageBucket value in FirebaseOptions for testing
Future<FirebaseApp> testInitializeSecondaryApp({
  bool withDefaultBucket = true,
}) async {
  final String testAppName =
      withDefaultBucket ? 'testapp' : 'testapp-no-bucket';

  FirebaseOptions testAppOptions;
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    testAppOptions = FirebaseOptions(
      appId: DefaultFirebaseOptions.currentPlatform.appId,
      apiKey: DefaultFirebaseOptions.currentPlatform.apiKey,
      projectId: DefaultFirebaseOptions.currentPlatform.projectId,
      messagingSenderId:
          DefaultFirebaseOptions.currentPlatform.messagingSenderId,
      iosBundleId: DefaultFirebaseOptions.currentPlatform.iosBundleId,
      storageBucket: withDefaultBucket ? kTestStorageBucket : null,
    );
  } else {
    testAppOptions = FirebaseOptions(
      appId: DefaultFirebaseOptions.currentPlatform.appId,
      apiKey: DefaultFirebaseOptions.currentPlatform.apiKey,
      projectId: DefaultFirebaseOptions.currentPlatform.projectId,
      messagingSenderId:
          DefaultFirebaseOptions.currentPlatform.messagingSenderId,
      storageBucket: withDefaultBucket ? kTestStorageBucket : null,
    );
  }

  return Firebase.initializeApp(name: testAppName, options: testAppOptions);
}
