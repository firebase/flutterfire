// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:firebase_core_js/firebase_core_js.dart';

Future<void> main() async {
  FirebaseCoreWeb.registerWith();
  try {
    final app = await FirebasePlatform.instance.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      ),
    );
    print(app.name);
  } on FirebaseException catch (e) {
    print('${e.plugin}/${e.code}: ${e.message}');
  }
}
