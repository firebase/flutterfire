// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../firebase_core.dart';

String getMappedHost(String originalHost) {
  String mappedHost = originalHost;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    if (mappedHost == 'localhost' || mappedHost == '127.0.0.1') {
      // ignore: avoid_print
      print('Mapping Auth Emulator host "$mappedHost" to "10.0.2.2".');
      mappedHost = '10.0.2.2';
    }
  }
  return mappedHost;
}
