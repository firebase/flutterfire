// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: file_names, leading_newlines_in_multiline_strings

import 'dart:convert';
import 'dart:io';

const _firebaseOptionsPaths = <String>[
  'packages/cloud_firestore/cloud_firestore/example/integration_test/firebase_options.dart',
  'packages/cloud_firestore/cloud_firestore/example/lib/firebase_options.dart',
  'packages/cloud_functions/cloud_functions/example/lib/firebase_options.dart',
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

void main(List<String> arguments) {
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
}

void _writeNativeConfigs({
  required String exampleRoot,
  required String androidPackageName,
  required String appleBundleId,
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

  final appleConfig = '''<?xml version="1.0" encoding="UTF-8"?>
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
\t<string>$appleBundleId</string>
\t<key>PROJECT_ID</key>
\t<string>flutterfire-e2e-tests</string>
\t<key>STORAGE_BUCKET</key>
\t<string>flutterfire-e2e-tests.appspot.com</string>
\t<key>GOOGLE_APP_ID</key>
\t<string>1:123456789012:ios:0000000000000000000000</string>
</dict>
</plist>
''';
  _write('$exampleRoot/ios/Runner/GoogleService-Info.plist', appleConfig);
  _write('$exampleRoot/macos/Runner/GoogleService-Info.plist', appleConfig);
}

void _write(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
