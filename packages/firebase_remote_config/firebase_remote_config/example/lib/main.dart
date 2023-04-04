// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config_example/home_page.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RemoteConfigApp());
}

class RemoteConfigApp extends StatelessWidget {
  const RemoteConfigApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Config Example',
      home: const HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}
