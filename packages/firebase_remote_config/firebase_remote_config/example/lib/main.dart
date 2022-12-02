// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Remote Config Example',
      home: FutureBuilder<FirebaseRemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context,
            AsyncSnapshot<FirebaseRemoteConfig> snapshot) {
          return snapshot.hasData
              ? WelcomeWidget(remoteConfig: snapshot.requireData)
              : Container();
        },
      )));
}

class WelcomeWidget extends AnimatedWidget {
  WelcomeWidget({
    required this.remoteConfig,
  }) : super(listenable: remoteConfig);

  final FirebaseRemoteConfig remoteConfig;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${remoteConfig.getString('welcome')}'),
            const SizedBox(
              height: 20,
            ),
            Text('(${remoteConfig.getValue('welcome').source})'),
            Text('(${remoteConfig.lastFetchTime})'),
            Text('(${remoteConfig.lastFetchStatus})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Using zero duration to force fetching from remote server.
            await remoteConfig.setConfigSettings(RemoteConfigSettings(
              fetchTimeout: const Duration(seconds: 10),
              minimumFetchInterval: Duration.zero,
            ));
            await remoteConfig.fetchAndActivate();
          } on PlatformException catch (exception) {
            // Fetch exception.
            print(exception);
          } catch (exception) {
            print(
                'Unable to fetch remote config. Cached or default values will be '
                'used');
            print(exception);
          }
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

Future<FirebaseRemoteConfig> setupRemoteConfig() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(<String, dynamic>{
    'welcome': 'default welcome',
    'hello': 'default hello',
  });
  RemoteConfigValue(null, ValueSource.valueStatic);
  return remoteConfig;
}
