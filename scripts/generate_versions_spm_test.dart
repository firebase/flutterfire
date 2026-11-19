// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'generate_versions_spm.dart';

void main() {
  _pluginDropsItsExactPin();
  _analyticsDropsItsPinWithoutADoubleBlank();
  _pluginFloorIsTheSdkItWasBuiltAgainst();
  _pluginFloorFollowsTheNextMajor();
  _blankLinesAwayFromThePinStay();
  _coreKeepsAnExactPin();
  _rewriteIsIdempotent();
  _manifestWithoutTheSdkIsLeftAlone();
  if (exitCode != 0) {
    stderr.writeln('generate_versions_spm_test failed');
  }
}

const _plugin = '''
let libraryVersion = "7.1.0"
let firebaseSdkVersion: Version = "12.15.0"

let package = Package(
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
  ],
)
''';

const _core = '''
let libraryVersionString = "5.1.0"
let firebaseSdkVersion: Version = "13.1.1"

let package = Package(
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
  ],
)
''';

void _pluginDropsItsExactPin() {
  final rewritten = rewritePackageSwiftFirebaseSdkPin(
    _plugin,
    sdkVersion: '13.2.0',
    pinExact: false,
  );
  _expect(rewritten, '''
let libraryVersion = "7.1.0"

let package = Package(
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "13.2.0"),
  ],
)
''', 'plugin uses the SDK it was generated against as a floor');
  if (rewritten.contains('firebaseSdkVersion') ||
      rewritten.contains('exact:')) {
    _fail('plugin rewrite still carries an exact pin');
  }
}

void _analyticsDropsItsPinWithoutADoubleBlank() {
  const manifest = '''
import Foundation
import PackageDescription

let firebaseSdkVersion: Version = "13.2.0"

// Set FIREBASE_ANALYTICS_WITHOUT_ADID=true to use FirebaseAnalyticsCore.
let package = Package(
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
  ],
)
''';
  final rewritten = rewritePackageSwiftFirebaseSdkPin(
    manifest,
    sdkVersion: '13.2.0',
    pinExact: false,
  );
  _expect(rewritten, '''
import Foundation
import PackageDescription

// Set FIREBASE_ANALYTICS_WITHOUT_ADID=true to use FirebaseAnalyticsCore.
let package = Package(
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "13.2.0"),
  ],
)
''', 'analytics keeps a single blank line where the pin was');
}

void _pluginFloorIsTheSdkItWasBuiltAgainst() {
  final rewritten = rewritePackageSwiftFirebaseSdkPin(
    _plugin,
    sdkVersion: '13.1.1',
    pinExact: false,
  );
  if (!rewritten.contains('from: "13.1.1"') ||
      rewritten.contains('from: "13.0.0"')) {
    _fail(
      'floor should be the SDK the plugin was generated against:\n$rewritten',
    );
  }
}

void _pluginFloorFollowsTheNextMajor() {
  final onThirteen = rewritePackageSwiftFirebaseSdkPin(
    _plugin,
    sdkVersion: '13.2.0',
    pinExact: false,
  );
  final onFourteen = rewritePackageSwiftFirebaseSdkPin(
    onThirteen,
    sdkVersion: '14.0.0',
    pinExact: false,
  );
  if (!onFourteen.contains('from: "14.0.0"') ||
      onFourteen.contains('from: "13.2.0"')) {
    _fail('major bump did not move the floor to 14.0.0:\n$onFourteen');
  }
}

void _blankLinesAwayFromThePinStay() {
  const manifest =
      'let libraryVersion = "7.1.0"\n'
      'let firebaseSdkVersion: Version = "12.15.0"\n'
      '\n'
      'let package = Package(\n'
      '  dependencies: [\n'
      '    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),\n'
      '  ],\n'
      ')\n'
      '\n'
      '\n'
      '\n'
      '// kept\n';
  final rewritten = rewritePackageSwiftFirebaseSdkPin(
    manifest,
    sdkVersion: '13.2.0',
    pinExact: false,
  );
  const trailing = '\n\n\n// kept\n';
  if (!rewritten.endsWith(trailing)) {
    _fail('rewrite collapsed blank lines away from the pin:\n$rewritten');
  }
  if (!rewritten.startsWith('let libraryVersion = "7.1.0"\n\nlet package')) {
    _fail('pin removal left the wrong blank line:\n$rewritten');
  }
  if (rewritten.contains('firebaseSdkVersion') ||
      !rewritten.contains('from: "13.2.0"')) {
    _fail('rewrite did not drop the pin:\n$rewritten');
  }
}

void _coreKeepsAnExactPin() {
  final rewritten = rewritePackageSwiftFirebaseSdkPin(
    _core,
    sdkVersion: '13.2.0',
    pinExact: true,
  );
  _expect(rewritten, '''
let libraryVersionString = "5.1.0"
let firebaseSdkVersion: Version = "13.2.0"

let package = Package(
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: firebaseSdkVersion),
  ],
)
''', 'core keeps the exact pin and updates it');
}

void _manifestWithoutTheSdkIsLeftAlone() {
  const manifest = '''
let package = Package(
  name: "firebase_ai",
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
)
''';
  final rewritten = rewritePackageSwiftFirebaseSdkPin(
    manifest,
    sdkVersion: '13.2.0',
    pinExact: false,
  );
  _expect(rewritten, manifest, 'a manifest without the SDK is unchanged');
}

void _rewriteIsIdempotent() {
  final plugin = rewritePackageSwiftFirebaseSdkPin(
    _plugin,
    sdkVersion: '13.2.0',
    pinExact: false,
  );
  final pluginAgain = rewritePackageSwiftFirebaseSdkPin(
    plugin,
    sdkVersion: '13.2.0',
    pinExact: false,
  );
  _expect(pluginAgain, plugin, 'plugin rewrite is idempotent');

  final core = rewritePackageSwiftFirebaseSdkPin(
    _core,
    sdkVersion: '13.2.0',
    pinExact: true,
  );
  final coreAgain = rewritePackageSwiftFirebaseSdkPin(
    core,
    sdkVersion: '13.2.0',
    pinExact: true,
  );
  _expect(coreAgain, core, 'core rewrite is idempotent');
}

void _expect(String actual, String expected, String label) {
  if (actual != expected) {
    _fail('$label\nexpected:\n$expected\nactual:\n$actual');
  }
}

void _fail(String message) {
  stderr.writeln(message);
  exitCode = 1;
}
