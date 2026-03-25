// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:melos/melos.dart' as melos;
import 'package:glob/glob.dart';
import 'dart:io';
import 'package:cli_util/cli_logging.dart' as logging;
import 'package:yaml/yaml.dart';

// Used to generate a simple txt file for Package.swift file to parse in order to use correct firebase-ios-sdk version

void main(List<String> args) async {
  final workspace = await getMelosWorkspace();
  // get version from core
  final firebaseCorePackage = workspace.filteredPackages.values
      .firstWhere((package) => package.name == 'firebase_core');

  final firebaseCoreIosVersionFile = File(
    '${firebaseCorePackage.path}/ios/firebase_sdk_version.rb',
  );

  final firebaseiOSVersion = getFirebaseiOSVersion(firebaseCoreIosVersionFile);

  // Update hard-coded versions in all plugin Package.swift files
  final firebaseCoreVersion =
      loadYaml(File('${firebaseCorePackage.path}/pubspec.yaml').readAsStringSync())['version']
          .toString();
  updatePluginPackageSwiftVersions(
    workspace,
    firebaseiOSVersion,
    firebaseCoreVersion,
  );
  // Update plugin version in Constants.swift for pure Swift plugins. Unable to pass macros in pure Swift implementations
  updateLibraryVersionPureSwiftPlugins();
}

Future<melos.MelosWorkspace> getMelosWorkspace() async {
  final packageFilters = melos.PackageFilters(
    includePrivatePackages: false,
    ignore: [
      Glob('*web*'),
      Glob('*platform*'),
      Glob('*internals*'),
    ],
  );
  final workspace = await melos.MelosWorkspace.fromConfig(
    await melos.MelosWorkspaceConfig.fromWorkspaceRoot(Directory.current),
    logger: melos.MelosLogger(logging.Logger.standard()),
    packageFilters: packageFilters,
  );

  return workspace;
}

String getFirebaseiOSVersion(File firebaseCoreIosSdkVersion) {
  if (firebaseCoreIosSdkVersion.existsSync()) {
    final content = firebaseCoreIosSdkVersion.readAsStringSync();
    final versionMatch = RegExp(r"'(\d+\.\d+\.\d+)'").firstMatch(content);

    if (versionMatch != null && versionMatch.group(1) != null) {
      return versionMatch.group(1)!;
    } else {
      throw Exception(
        'Firebase iOS SDK version not found in firebase_sdk_version.rb.',
      );
    }
  } else {
    throw Exception('firebase_sdk_version.rb file does not exist.');
  }
}

void updatePluginPackageSwiftVersions(
  melos.MelosWorkspace workspace,
  String firebaseiOSVersion,
  String firebaseCoreVersion,
) {
  for (final package in workspace.filteredPackages.values) {
    for (final platform in ['ios', 'macos']) {
      final packageSwiftFile =
          File('${package.path}/$platform/${package.name}/Package.swift');

      if (!packageSwiftFile.existsSync()) continue;

      var content = packageSwiftFile.readAsStringSync();

      // Update firebase_sdk_version
      content = content.replaceAll(
        RegExp('let firebase_sdk_version: Version = "[^"]+"'),
        'let firebase_sdk_version: Version = "$firebaseiOSVersion"',
      );

      // Update shared_spm_version
      content = content.replaceAll(
        RegExp('let shared_spm_version: Version = "[^"]+"'),
        'let shared_spm_version: Version = "$firebaseCoreVersion-firebase-core-swift"',
      );

      // Update library_version or library_version_string from pubspec version
      final pubspecFile = File('${package.path}/pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
        final version = pubspecYaml['version']?.toString();
        if (version != null) {
          final spmVersion = version.replaceAll('+', '-');
          content = content.replaceAll(
            RegExp('let library_version_string = "[^"]+"'),
            'let library_version_string = "$spmVersion"',
          );
          content = content.replaceAll(
            RegExp('let library_version = "[^"]+"'),
            'let library_version = "$spmVersion"',
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
    'firebase_ml_model_downloader',
    'firebase_app_installations',
    'cloud_functions',
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
