// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: file_names, leading_newlines_in_multiline_strings

import 'dart:convert';
import 'dart:io';

/// Examples whose `lib/firebase_options.dart` this script fills in with dummy
/// credentials.
///
/// The nine live-tier examples (ai, analytics, app_check, app_installations,
/// crashlytics, messaging, ml_model_downloader, performance, remote_config)
/// are still listed: their `lib/main.dart` imports `firebase_options.dart`, so
/// without a file here `melos analyze-ci` and every example build in
/// `all_plugins.yaml` fail on an unresolved import.
///
/// Their e2e workflows never take this path. `e2e_tests_<product>.yaml` gets
/// the real values from repository secrets ("Inject Firebase config") and only
/// ever invokes this script through `--live-tier-plist=<product>`, which writes
/// the Apple placeholder plist and nothing else - so a dummy can never clobber
/// an injected credential regardless of step order.
const _firebaseOptionsPaths = <String>[
  'packages/cloud_firestore/cloud_firestore/example/integration_test/firebase_options.dart',
  'packages/cloud_firestore/cloud_firestore/example/lib/firebase_options.dart',
  'packages/cloud_functions/cloud_functions/example/lib/firebase_options.dart',
  'packages/firebase_ai/firebase_ai/example/lib/firebase_options.dart',
  'packages/firebase_analytics/firebase_analytics/example/lib/firebase_options.dart',
  'packages/firebase_app_check/firebase_app_check/example/lib/firebase_options.dart',
  'packages/firebase_app_installations/firebase_app_installations/example/lib/firebase_options.dart',
  'packages/firebase_auth/firebase_auth/example/lib/firebase_options.dart',
  'packages/firebase_core/firebase_core/example/lib/firebase_options.dart',
  'packages/firebase_crashlytics/firebase_crashlytics/example/lib/firebase_options.dart',
  'packages/firebase_data_connect/firebase_data_connect/example/lib/firebase_options.dart',
  'packages/firebase_database/firebase_database/example/lib/firebase_options.dart',
  'packages/firebase_in_app_messaging/firebase_in_app_messaging/example/lib/firebase_options.dart',
  'packages/firebase_messaging/firebase_messaging/example/lib/firebase_options.dart',
  'packages/firebase_ml_model_downloader/firebase_ml_model_downloader/example/lib/firebase_options.dart',
  'packages/firebase_performance/firebase_performance/example/lib/firebase_options.dart',
  'packages/firebase_remote_config/firebase_remote_config/example/lib/firebase_options.dart',
  'packages/firebase_storage/firebase_storage/example/lib/firebase_options.dart',
];

// The project ID must match the emulator fixtures and Firestore bundles.
const _firebaseOptions = '''
// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generated for CI builds and emulator tests. These are not real credentials.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      TargetPlatform.windows => windows,
      _ => throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        ),
    };
  }

  static const web = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:web:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const android = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:android:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const ios = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:ios:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const macos = ios;

  static const windows = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:web:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );
}
''';

/// Example roots of the nine live-tier products, keyed by the name used in
/// `--live-tier-plist=<name>`.
///
/// Every one of these Xcode projects lists `GoogleService-Info.plist` in a
/// Resources build phase, so `flutter build ios/macos` fails outright when the
/// file is absent. The plist is only there to satisfy the build: these products
/// initialise Firebase from the Dart `FirebaseOptions` injected from secrets,
/// not from the plist, and the bundle id below matches the app identity every
/// one of these examples now uses.
///
/// The one caveat found while migrating: the crashlytics example's macOS target
/// runs `upload-symbols --flutter-project firebase_app_id_file.json`, so on that
/// target it is the committed `firebase_app_id_file.json` - not the plist - that
/// is load-bearing at build time.
const _liveTierExampleRoots = <String, String>{
  'ai': 'packages/firebase_ai/firebase_ai/example',
  'analytics': 'packages/firebase_analytics/firebase_analytics/example',
  'app_check': 'packages/firebase_app_check/firebase_app_check/example',
  'app_installations':
      'packages/firebase_app_installations/firebase_app_installations/example',
  'crashlytics': 'packages/firebase_crashlytics/firebase_crashlytics/example',
  'messaging': 'packages/firebase_messaging/firebase_messaging/example',
  'ml_model_downloader':
      'packages/firebase_ml_model_downloader/firebase_ml_model_downloader/example',
  'performance': 'packages/firebase_performance/firebase_performance/example',
  'remote_config':
      'packages/firebase_remote_config/firebase_remote_config/example',
};

/// The app identity shared by the mega `tests` app and the nine live-tier
/// examples: live Firebase backends only accept app ids registered in the
/// `flutterfire-e2e-tests` project.
const _liveTierBundleId = 'io.flutter.plugins.firebase.tests';

void main(List<String> arguments) {
  const plistFlag = '--live-tier-plist=';
  final plistProducts = arguments
      .where((argument) => argument.startsWith(plistFlag))
      .map((argument) => argument.substring(plistFlag.length))
      .toList();

  if (plistProducts.isNotEmpty) {
    // Deliberately exclusive: a live-tier e2e job must never write a Dart
    // options file, because the real one arrives from a repository secret.
    for (final product in plistProducts) {
      final exampleRoot = _liveTierExampleRoots[product];
      if (exampleRoot == null) {
        stderr.writeln(
          'Unknown --live-tier-plist target "$product". '
          'Known: ${_liveTierExampleRoots.keys.join(', ')}.',
        );
        exit(1);
      }
      _writeApplePlists(exampleRoot: exampleRoot, bundleId: _liveTierBundleId);
    }
    return;
  }

  for (final path in _firebaseOptionsPaths) {
    _write(path, _firebaseOptions);
  }

  if (arguments.contains('--firestore-native')) {
    _writeNativeConfigs(
      exampleRoot: 'packages/cloud_firestore/cloud_firestore/example',
      androidPackageName: 'io.flutter.plugins.firebase.firestore.example',
      appleBundleId: 'io.flutter.plugins.firebase.firestore.example',
    );
  }

  if (arguments.contains('--storage-native')) {
    // The storage example's Android app applies the `google-services` plugin
    // (which validates the package name against google-services.json) and both
    // its Xcode projects list GoogleService-Info.plist in a Resources build
    // phase, so the native builds fail outright when these files are absent.
    // Its Android applicationId and Apple bundle id differ from each other.
    _writeNativeConfigs(
      exampleRoot: 'packages/firebase_storage/firebase_storage/example',
      androidPackageName: 'io.flutter.plugins.firebasestorageexample',
      appleBundleId: 'io.flutter.plugins.firebase.storage.example',
    );
  }

  if (arguments.contains('--auth-native')) {
    // The auth example's Android app applies the `google-services` plugin and
    // both its Xcode projects list GoogleService-Info.plist in a Resources
    // build phase, so the native builds fail outright without these files.
    _writeNativeConfigs(
      exampleRoot: 'packages/firebase_auth/firebase_auth/example',
      androidPackageName: 'io.flutter.plugins.firebase.auth.example',
      appleBundleId: 'io.flutter.plugins.firebase.auth.example',
    );
  }

  if (arguments.contains('--database-native')) {
    // The database example's Android app applies the `google-services` plugin,
    // and its macOS Xcode project lists GoogleService-Info.plist in a Resources
    // build phase. Its iOS project does not reference the plist, but the file
    // is written anyway so both Apple targets stay consistent - hence the
    // separate macOS bundle id, which differs from the iOS one here.
    _writeNativeConfigs(
      exampleRoot: 'packages/firebase_database/firebase_database/example',
      androidPackageName: 'io.flutter.plugins.firebase.database.example',
      appleBundleId: 'io.flutter.plugins.firebase.database.example',
      macosBundleId: 'io.flutter.plugins.firebaseDatabaseExample',
    );
  }

  if (arguments.contains('--functions-native')) {
    // The functions example's Android app applies the `google-services` plugin
    // and both its Xcode projects list GoogleService-Info.plist in a Resources
    // build phase.
    _writeNativeConfigs(
      exampleRoot: 'packages/cloud_functions/cloud_functions/example',
      androidPackageName: 'io.flutter.plugins.firebase.functions.example',
      appleBundleId: 'io.flutter.plugins.firebase.functions.example',
    );
  }
}

void _writeNativeConfigs({
  required String exampleRoot,
  required String androidPackageName,
  required String appleBundleId,
  // Defaults to [appleBundleId]; only the examples whose macOS target carries a
  // different bundle id need to pass this.
  String? macosBundleId,
}) {
  final androidPath = '$exampleRoot/android/app/google-services.json';

  final androidConfig = <String, Object>{
    'project_info': <String, String>{
      'project_number': '123456789012',
      'project_id': 'flutterfire-e2e-tests',
      'storage_bucket': 'flutterfire-e2e-tests.appspot.com',
    },
    'client': <Object>[
      <String, Object>{
        'client_info': <String, Object>{
          'mobilesdk_app_id': '1:123456789012:android:0000000000000000000000',
          'android_client_info': <String, String>{
            'package_name': androidPackageName,
          },
        },
        'api_key': <Object>[
          <String, String>{'current_key': 'dummy-api-key'},
        ],
      },
    ],
    'configuration_version': '1',
  };
  _write(
    androidPath,
    '${const JsonEncoder.withIndent('  ').convert(androidConfig)}\n',
  );

  _writeApplePlists(
    exampleRoot: exampleRoot,
    bundleId: appleBundleId,
    macosBundleId: macosBundleId,
  );
}

void _writeApplePlists({
  required String exampleRoot,
  required String bundleId,
  // Defaults to [bundleId]; only the examples whose macOS target carries a
  // different bundle id need to pass this.
  String? macosBundleId,
}) {
  String applePlist(String bundleId) =>
      '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>API_KEY</key>
\t<string>dummy-api-key</string>
\t<key>GCM_SENDER_ID</key>
\t<string>123456789012</string>
\t<key>PLIST_VERSION</key>
\t<string>1</string>
\t<key>BUNDLE_ID</key>
\t<string>$bundleId</string>
\t<key>PROJECT_ID</key>
\t<string>flutterfire-e2e-tests</string>
\t<key>STORAGE_BUCKET</key>
\t<string>flutterfire-e2e-tests.appspot.com</string>
\t<key>GOOGLE_APP_ID</key>
\t<string>1:123456789012:ios:0000000000000000000000</string>
</dict>
</plist>
''';

  // Not every example has both Apple targets (the performance example has no
  // `macos/`), and creating one would leave a stray directory behind.
  for (final platform in const ['ios', 'macos']) {
    if (!Directory('$exampleRoot/$platform').existsSync()) continue;
    _write(
      '$exampleRoot/$platform/Runner/GoogleService-Info.plist',
      applePlist(platform == 'macos' ? (macosBundleId ?? bundleId) : bundleId),
    );
  }
}

void _write(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
