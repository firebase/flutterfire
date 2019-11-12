// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import '../firebase_core_platform_interface.dart';

class MethodChannelFirebaseCore extends FirebaseCorePlatform {
  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  @override
  Future<PlatformFirebaseApp> appNamed(String name) async {
    final Map<String, dynamic> app =
        await channel.invokeMapMethod<String, dynamic>(
      'FirebaseApp#appNamed',
      name,
    );
    if (app == null) return null;
    return PlatformFirebaseApp(
        app['name'], FirebaseOptions.from(app['options']));
  }

  @override
  Future<void> configure(String name, FirebaseOptions options) {
    return channel.invokeMethod<void>(
      'FirebaseApp#configure',
      <String, dynamic>{'name': name, 'options': options.asMap},
    );
  }

  @override
  Future<List<PlatformFirebaseApp>> allApps() async {
    final List<dynamic> result = await channel.invokeListMethod<dynamic>(
      'FirebaseApp#allApps',
    );
    return result
        ?.map<PlatformFirebaseApp>(
          (dynamic app) => PlatformFirebaseApp(
            app['name'],
            FirebaseOptions.from(app['options']),
          ),
        )
        ?.toList();
  }
}
