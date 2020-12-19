// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_remote_config_platform_interface/src/remote_config_settings.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Remote Config Example',
      home: FutureBuilder<RemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
          return snapshot.hasData
              ? WelcomeWidget(remoteConfig: snapshot.data)
              : Container();
        },
      )));
}

class WelcomeWidget extends AnimatedWidget {
  WelcomeWidget({this.remoteConfig}) : super(listenable: remoteConfig);

  final RemoteConfig remoteConfig;

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
            Text('(${remoteConfig.getValue('welcome').source})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () async {
            try {
              // Using zero duration to force fetching from remote server.
              await remoteConfig.setConfigSettings(RemoteConfigSettings(
                Duration(seconds: 10), Duration.zero
              ));
              await remoteConfig.fetchAndActivate();
            } on FetchThrottledException catch (exception) {
              // Fetch throttled.
              print(exception);
            } catch (exception) {
              print(
                  'Unable to fetch remote config. Cached or default values will be '
                  'used');
              print(exception);
            }
          }
      ),
    );
  }
}

Future<RemoteConfig> setupRemoteConfig() async {
  await Firebase.initializeApp();
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
      Duration(seconds: 10), Duration(hours: 1)
  ));
  await remoteConfig.setDefaults(<String, dynamic>{
    'welcome': 'default welcome',
    'hello': 'default hello',
  });
  return remoteConfig;
}
