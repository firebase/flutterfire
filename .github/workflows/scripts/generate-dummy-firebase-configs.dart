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

/// Placeholder API key, shaped so the Firebase SDKs accept it.
///
/// It is not enough for this to be obviously fake. `firebase_core`'s iOS/macOS
/// plugin calls `[FIRApp configureWithOptions:[FIROptions defaultOptions]]` the
/// moment it is registered, whenever a GoogleService-Info.plist is present in
/// the bundle - the plugin registrant runs it before any Dart code, so the Dart
/// `FirebaseOptions` never get a say. `FIRApp` then eagerly instantiates
/// `FIRInstallations`, which is a hard dependency of Analytics, App Check,
/// App Installations, Crashlytics, In-App Messaging, ML Model Downloader,
/// Messaging, Performance and Remote Config. `+[FIRInstallations
/// validateAPIKey:]` raises an ObjC exception - i.e. SIGABRT at launch, before
/// the VM service is up, which `flutter test` only ever sees as
/// "WebSocketChannelException: Connection refused" - unless the key is exactly
/// 39 characters, starts with `A` and contains only base64url characters.
///
/// So: keep the shape, keep the value obviously fake.
const _dummyApiKey = 'AIzaSyDUMMYKEYFORFLUTTERFIRECITESTS0000';

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
    apiKey: '$_dummyApiKey',
    appId: '1:123456789012:web:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    // The database e2e suite asserts refFromURL() mismatch behavior, which
    // only triggers when the instance has a configured databaseURL.
    databaseURL:
        'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
    authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const android = FirebaseOptions(
    apiKey: '$_dummyApiKey',
    appId: '1:123456789012:android:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    // The database e2e suite asserts refFromURL() mismatch behavior, which
    // only triggers when the instance has a configured databaseURL.
    databaseURL:
        'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const ios = FirebaseOptions(
    apiKey: '$_dummyApiKey',
    appId: '1:123456789012:ios:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    // The database e2e suite asserts refFromURL() mismatch behavior, which
    // only triggers when the instance has a configured databaseURL.
    databaseURL:
        'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const macos = ios;

  static const windows = FirebaseOptions(
    apiKey: '$_dummyApiKey',
    appId: '1:123456789012:web:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    // The database e2e suite asserts refFromURL() mismatch behavior, which
    // only triggers when the instance has a configured databaseURL.
    databaseURL:
        'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
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
  // Same reason as the plist: the google-services Gradle plugin turns this file
  // into the string resources `FirebaseApp.initializeApp` reads, so anything
  // missing here is missing from the natively-configured `[DEFAULT]` app that
  // Dart then has to agree with. `firebase_url` is what the database suite's
  // refFromURL assertions need.
  final options = _optionsFromDart(exampleRoot, 'android');

  final androidConfig = <String, Object>{
    'project_info': <String, String>{
      'project_number': options['messagingSenderId']!,
      'project_id': options['projectId']!,
      if (options['storageBucket'] != null)
        'storage_bucket': options['storageBucket']!,
      if (options['databaseURL'] != null)
        'firebase_url': options['databaseURL']!,
    },
    'client': <Object>[
      <String, Object>{
        'client_info': <String, Object>{
          'mobilesdk_app_id': options['appId']!,
          'android_client_info': <String, String>{
            'package_name': androidPackageName,
          },
        },
        'api_key': <Object>[
          <String, String>{'current_key': options['apiKey']!},
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

/// Writes `GoogleService-Info.plist` for whichever Apple targets the example
/// has, with values taken from that example's `lib/firebase_options.dart`.
///
/// Deriving rather than hardcoding is the point. Once a plist is in the bundle,
/// `firebase_core`'s plugin registrant configures the native `[DEFAULT]` app
/// from it before any Dart runs; the Dart `Firebase.initializeApp(options: ...)`
/// that follows then only succeeds if its apiKey, databaseURL and storageBucket
/// agree with what the plist already installed - otherwise
/// `MethodChannelFirebase.initializeApp` throws `[core/duplicate-app]`. Two
/// hand-maintained copies of the same credentials drift the moment one side
/// gains a field (which is exactly how `databaseURL` broke the Apple suites),
/// so there is only one copy here and the plist is projected out of it.
///
/// This works for both tiers because both leave the truth in the same file:
/// the emulator tier because [_firebaseOptions] was just written to it, the
/// live tier because CI's "Inject Firebase config" step writes the real
/// credentials there before invoking `--live-tier-plist`.
void _writeApplePlists({
  required String exampleRoot,
  required String bundleId,
  // Defaults to [bundleId]; only the examples whose macOS target carries a
  // different bundle id need to pass this.
  String? macosBundleId,
}) {
  final options = _optionsFromDart(exampleRoot, 'ios');

  String applePlist(String bundleId) {
    final entries = <String, String>{
      'API_KEY': options['apiKey']!,
      'GCM_SENDER_ID': options['messagingSenderId']!,
      'PLIST_VERSION': '1',
      'BUNDLE_ID': bundleId,
      'PROJECT_ID': options['projectId']!,
      'GOOGLE_APP_ID': options['appId']!,
      // Optional in a real plist too: only projects with the product enabled
      // carry them.
      if (options['storageBucket'] != null)
        'STORAGE_BUCKET': options['storageBucket']!,
      if (options['databaseURL'] != null)
        'DATABASE_URL': options['databaseURL']!,
      if (options['iosClientId'] != null) 'CLIENT_ID': options['iosClientId']!,
    };
    final body = entries.entries
        .map(
          (entry) =>
              '\t<key>${entry.key}</key>\n\t<string>${entry.value}</string>',
        )
        .join('\n');
    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
$body
</dict>
</plist>
''';
  }

  // Not every example has both Apple targets (the performance example has no
  // `macos/`), and creating one would leave a stray directory behind.
  for (final platform in const ['ios', 'macos']) {
    if (!Directory('$exampleRoot/$platform').existsSync()) continue;
    final target = '$exampleRoot/$platform/Runner/GoogleService-Info.plist';
    // A committed plist wins: crashlytics, app_installations and messaging
    // check in real plists for their registered Firebase apps, and the native
    // SDKs configure from the bundled plist before any Dart code runs -
    // overwriting one with a placeholder made crashlytics hang at launch.
    if (File(target).existsSync()) {
      stdout.writeln('Keeping existing $target');
      continue;
    }
    _write(
      target,
      applePlist(platform == 'macos' ? (macosBundleId ?? bundleId) : bundleId),
    );
  }
}

/// Pulls one platform's `static const <platform> = FirebaseOptions(...)` values
/// out of an example's `lib/firebase_options.dart`.
///
/// `macos` is never asked for: every generator (this script and the
/// `flutterfire` CLI) emits the same credentials for both Apple platforms, and
/// the two targets only differ by bundle id, which the caller supplies.
///
/// Exits non-zero rather than falling back to a placeholder: a native config
/// that disagrees with the Dart options fails at runtime, inside the app, as
/// `[core/duplicate-app]` - which is a far worse thing to debug than a build
/// step that says what it could not read.
Map<String, String?> _optionsFromDart(String exampleRoot, String platform) {
  final path = '$exampleRoot/lib/firebase_options.dart';
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln(
      'Cannot write the $platform Firebase config: $path is missing.',
    );
    exit(1);
  }

  // Comments can contain apostrophes ("doesn't"), which would otherwise be
  // picked up as string delimiters by the field pattern below.
  final source = file
      .readAsStringSync()
      .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

  // Both declaration shapes exist: this script's own template writes
  // `static const ios = ...`, while the injected live config (and flutterfire
  // configure output) writes the typed `static const FirebaseOptions ios = ...`.
  final block = RegExp(
    'static\\s+const\\s+(?:FirebaseOptions\\s+)?$platform\\s*=\\s*FirebaseOptions\\(([\\s\\S]*?)\\);',
  ).firstMatch(source);
  if (block == null) {
    stderr.writeln(
      'Cannot write the $platform Firebase config: no '
      '"static const [FirebaseOptions] $platform = FirebaseOptions(...)" '
      'found in $path.',
    );
    exit(1);
  }

  final fields = <String, String>{
    for (final field
        in RegExp(r"(\w+)\s*:\s*'([^']*)'").allMatches(block.group(1)!))
      field.group(1)!: field.group(2)!,
  };

  for (final required in const [
    'apiKey',
    'appId',
    'messagingSenderId',
    'projectId',
  ]) {
    if (fields[required] == null) {
      stderr.writeln(
        'Cannot write the $platform Firebase config: `$required` is missing '
        'from the $platform FirebaseOptions in $path.',
      );
      exit(1);
    }
  }

  return fields;
}

void _write(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}
