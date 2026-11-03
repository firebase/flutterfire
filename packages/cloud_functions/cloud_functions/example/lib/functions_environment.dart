// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The deployed project's settings are build-time values from
// `--dart-define-from-file`, which is what this lint warns about.
// ignore_for_file: do_not_use_environment

import 'package:cloud_functions_example/emulator_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Where the example's calls go: the local emulators or a deployed project.
///
/// Each environment has its own [FirebaseApp]. Pointing an app at the
/// emulators can't be undone, so the deployed project gets a second app that
/// is never pointed at them.
class FunctionsEnvironment {
  const FunctionsEnvironment({
    required this.label,
    required this.app,
    required this.usesEmulator,
    String? listFruitsUrl,
  }) : _listFruitsUrl = listFruitsUrl;

  /// The local emulators, through the `[DEFAULT]` app.
  ///
  /// Callers point the app's instances at the emulators, as `main()` and the
  /// e2e tests do.
  factory FunctionsEnvironment.emulator() => FunctionsEnvironment(
        label: 'Emulator',
        app: Firebase.app(),
        usesEmulator: true,
      );

  /// A short name for the environment, shown in the UI.
  final String label;

  /// The app whose Functions and Auth instances make the calls.
  final FirebaseApp app;

  /// Whether calls go to the local emulators.
  final bool usesEmulator;

  final String? _listFruitsUrl;

  /// The URL of the function called [name] in `us-central1`.
  String functionUrl(String name) {
    final projectId = app.options.projectId;
    return usesEmulator
        ? 'http://$emulatorUrlHost:5001/$projectId/us-central1/$name'
        : 'https://us-central1-$projectId.cloudfunctions.net/$name';
  }

  /// The URL that "Call by URL" calls.
  String get listFruitsUrl => _listFruitsUrl ?? functionUrl('listfruits2ndgen');
}

/// A deployed Firebase project's settings, from
/// `--dart-define-from-file=deployed.env.json`.
///
/// Each value is empty when the app runs without that file. The example's
/// README lists where each one comes from.
abstract final class DeployedConfig {
  static const projectId = String.fromEnvironment('DEPLOYED_PROJECT_ID');
  static const apiKey = String.fromEnvironment('DEPLOYED_API_KEY');
  static const messagingSenderId =
      String.fromEnvironment('DEPLOYED_MESSAGING_SENDER_ID');
  static const androidAppId = String.fromEnvironment('DEPLOYED_ANDROID_APP_ID');
  static const iosAppId = String.fromEnvironment('DEPLOYED_IOS_APP_ID');
  static const webAppId = String.fromEnvironment('DEPLOYED_WEB_APP_ID');

  /// Optional: the URL "Call by URL" calls, such as the function's `run.app`
  /// URL. Without it, the call uses the function's `cloudfunctions.net` URL.
  static const listFruitsUrl =
      String.fromEnvironment('DEPLOYED_LIST_FRUITS_URL');
}

/// This platform's app ID setting, as a `(key, value)` record.
(String, String) get _appIdSetting {
  const android = ('DEPLOYED_ANDROID_APP_ID', DeployedConfig.androidAppId);
  const ios = ('DEPLOYED_IOS_APP_ID', DeployedConfig.iosAppId);
  const web = ('DEPLOYED_WEB_APP_ID', DeployedConfig.webAppId);
  if (kIsWeb) return web;
  // macOS reuses the iOS app, and other platforms the web app, as in
  // `DefaultFirebaseOptions`.
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => android,
    TargetPlatform.iOS || TargetPlatform.macOS => ios,
    _ => web,
  };
}

/// The settings this platform needs, as `(key, value)` records.
List<(String, String)> get _deployedSettings => [
      ('DEPLOYED_PROJECT_ID', DeployedConfig.projectId),
      ('DEPLOYED_API_KEY', DeployedConfig.apiKey),
      ('DEPLOYED_MESSAGING_SENDER_ID', DeployedConfig.messagingSenderId),
      _appIdSetting,
    ];

/// The settings this platform needs that the build doesn't have: all of them
/// when the app runs without `deployed.env.json`.
List<String> get missingDeployedSettings => [
      for (final (key, value) in _deployedSettings)
        if (value.isEmpty) key,
    ];

/// Explains how to set up the deployed project, for when it's missing.
String get deployedSetupHint {
  final missing = missingDeployedSettings;
  if (missing.length == _deployedSettings.length) {
    return 'To call your deployed functions, run with '
        '--dart-define-from-file=deployed.env.json (see the README).';
  }
  return 'deployed.env.json is missing ${missing.join(', ')}.';
}

/// Creates the `deployed` app for the project in `deployed.env.json`, or
/// returns `null` when the build is missing settings this platform needs.
Future<FunctionsEnvironment?> initializeDeployedEnvironment() async {
  if (missingDeployedSettings.isNotEmpty) return null;
  final app = await Firebase.initializeApp(
    name: 'deployed',
    options: FirebaseOptions(
      apiKey: DeployedConfig.apiKey,
      appId: _appIdSetting.$2,
      messagingSenderId: DeployedConfig.messagingSenderId,
      projectId: DeployedConfig.projectId,
      authDomain: '${DeployedConfig.projectId}.firebaseapp.com',
    ),
  );
  return FunctionsEnvironment(
    label: 'Deployed',
    app: app,
    usesEmulator: false,
    listFruitsUrl: DeployedConfig.listFruitsUrl.isEmpty
        ? null
        : DeployedConfig.listFruitsUrl,
  );
}
