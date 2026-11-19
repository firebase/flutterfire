// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:melos/melos.dart' as melos;
import 'package:glob/glob.dart';

import 'dart:io';

import 'package:cli_util/cli_logging.dart' as logging;
import 'package:yaml/yaml.dart';

import 'firebase_sdk_version_spm.dart';

// Writes scripts/firebase_sdk_version_spm.dart into each plugin Package.swift.

void main(List<String> args) async {
  final workspace = await getMelosWorkspace();

  // firebase_core keeps an exact pin. Other plugins accept that version up
  // to the next major, so SwiftPM selects the pin from firebase_core and
  // rejects an older one. CocoaPods keeps its own pin in
  // firebase_sdk_version.rb.
  updatePluginPackageSwiftVersions(workspace, firebaseSpmSdkVersion);
  // Update plugin version in Constants.swift for pure Swift plugins. Unable to pass macros in pure Swift implementations
  updateLibraryVersionPureSwiftPlugins();
}

Future<melos.MelosWorkspace> getMelosWorkspace() async {
  final packageFilters = melos.PackageFilters(
    includePrivatePackages: false,
    ignore: [Glob('*web*'), Glob('*platform*'), Glob('*internals*')],
  );
  final workspace = await melos.MelosWorkspace.fromConfig(
    await melos.MelosWorkspaceConfig.fromWorkspaceRoot(Directory.current),
    logger: melos.MelosLogger(logging.Logger.standard()),
    packageFilters: packageFilters,
  );
  return workspace;
}

/// Rewrites the `firebase-ios-sdk` requirement in one `Package.swift`.
///
/// [pinExact] is true for `firebase_core`, which is the package every other
/// plugin depends on. Its exact version is the one SwiftPM must select.
/// Other plugins get `from` the SDK version they were generated against.
/// `from` stops before the next major, so a current `firebase_core` pin still
/// resolves, and an older pin conflicts instead of compiling the plugin
/// against an SDK that is missing APIs it uses.
String rewritePackageSwiftFirebaseSdkPin(
  String content, {
  required String sdkVersion,
  required bool pinExact,
}) {
  final requirement = pinExact
      ? '.package(url: "$_firebaseIosSdkUrl", exact: firebaseSdkVersion)'
      : '.package(url: "$_firebaseIosSdkUrl", from: "${_spmFromVersion(sdkVersion)}")';

  if (!content.contains(_firebaseSdkRequirement)) {
    if (content.contains('firebase-ios-sdk')) {
      throw StateError(
        'Package.swift depends on firebase-ios-sdk in a form this generator '
        'does not know how to rewrite.',
      );
    }
    return content;
  }

  final withRequirement = content.replaceAll(
    _firebaseSdkRequirement,
    requirement,
  );

  if (pinExact) {
    if (!withRequirement.contains('let firebaseSdkVersion: Version =')) {
      throw StateError(
        'firebase_core Package.swift is missing its firebaseSdkVersion pin.',
      );
    }
    return withRequirement.replaceAll(
      RegExp('let firebaseSdkVersion: Version = "[^"]+"'),
      'let firebaseSdkVersion: Version = "$sdkVersion"',
    );
  }

  final pinDeclaration = RegExp(
    '\nlet firebaseSdkVersion: Version = "[^"]+"\n',
  );
  final match = pinDeclaration.firstMatch(withRequirement);
  if (match == null) {
    return withRequirement;
  }

  final removed = withRequirement.replaceRange(match.start, match.end, '\n');
  return _collapseBlankLinesAt(removed, match.start);
}

/// Collapses the newline run at [index] to one blank line.
///
/// Removing `firebaseSdkVersion` can leave the blank line that surrounded
/// that declaration. Blank lines anywhere else in the manifest stay put.
String _collapseBlankLinesAt(String content, int index) {
  var start = index;
  var end = index;
  while (start > 0 && content[start - 1] == '\n') {
    start--;
  }
  while (end < content.length && content[end] == '\n') {
    end++;
  }
  if (end - start <= 2) {
    return content;
  }
  return content.replaceRange(start, end, '\n\n');
}

String _spmFromVersion(String sdkVersion) {
  final parts = sdkVersion.split('.');
  if (parts.length != 3 ||
      parts.any((part) => part.isEmpty || int.tryParse(part) == null)) {
    throw FormatException(
      'Invalid Swift Package Manager SDK version: $sdkVersion',
    );
  }
  return sdkVersion;
}

const _firebaseIosSdkUrl = 'https://github.com/firebase/firebase-ios-sdk';

final _firebaseSdkRequirement = RegExp(
  r'\.package\(url: "https://github.com/firebase/firebase-ios-sdk", (?:exact: firebaseSdkVersion|from: "[0-9]+\.[0-9]+\.[0-9]+")\)',
);

void updatePluginPackageSwiftVersions(
  melos.MelosWorkspace workspace,
  String firebaseiOSVersion,
) {
  for (final package in workspace.filteredPackages.values) {
    for (final platform in ['ios', 'macos']) {
      final packageSwiftFile = File(
        '${package.path}/$platform/${package.name}/Package.swift',
      );

      if (!packageSwiftFile.existsSync()) continue;

      var content = packageSwiftFile.readAsStringSync();

      content = rewritePackageSwiftFirebaseSdkPin(
        content,
        sdkVersion: firebaseiOSVersion,
        pinExact: package.name == 'firebase_core',
      );

      // Update libraryVersion / libraryVersionString from pubspec version.
      final pubspecFile = File('${package.path}/pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
        final version = pubspecYaml['version']?.toString();
        if (version != null) {
          final spmVersion = version.replaceAll('+', '-');
          content = content.replaceAll(
            RegExp('let libraryVersionString = "[^"]+"'),
            'let libraryVersionString = "$spmVersion"',
          );
          content = content.replaceAll(
            RegExp('let libraryVersion = "[^"]+"'),
            'let libraryVersion = "$spmVersion"',
          );
        }
      }

      packageSwiftFile.writeAsStringSync(content);
      print('Updated ${package.name}/$platform/Package.swift');
    }
  }
}

void updateLibraryVersionPureSwiftPlugins() {
  // Packages that require updating library versions
  const packages = [
    'firebase_app_installations',
    'cloud_functions',
    'firebase_remote_config',
    'firebase_app_check',
    'firebase_in_app_messaging',
    'firebase_crashlytics',
    'firebase_core',
    'firebase_ai',
    'cloud_firestore',
  ];

  for (final package in packages) {
    final pubspecPath = 'packages/$package/$package/pubspec.yaml';
    final pubspecFile = File(pubspecPath);
    if (!pubspecFile.existsSync()) {
      print('Error: pubspec.yaml file not found at $pubspecFile');
      return;
    }

    // Read the pubspec.yaml file
    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspecYaml = loadYaml(pubspecContent);

    // Extract the version
    final version = pubspecYaml['version'];
    if (version == null) {
      print('Error: Version not found in pubspec.yaml');
      return;
    }

    // Define the path to the Constants.swift file
    final packageSwiftPath =
        'packages/$package/$package/ios/$package/Sources/$package/Constants.swift';

    // Read the Constants.swift file
    final constantsSwiftFile = File(packageSwiftPath);
    if (!constantsSwiftFile.existsSync()) {
      print('Error: Constants.swift file not found at $packageSwiftPath');
      return;
    }

    // Read the content of Constants.swift
    final constantsFileContent = constantsSwiftFile.readAsStringSync();

    // Update the versionNumber with the new version
    final updatedConstantsFileContent = constantsFileContent.replaceAll(
      RegExp('public let versionNumber = "[^"]+"'),
      'public let versionNumber = "$version"',
    );

    // Write the updated content back to Constants.swift
    constantsSwiftFile.writeAsStringSync(updatedConstantsFileContent);

    print('Updated Constants.swift with $package version: $version');
  }
}
