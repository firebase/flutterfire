// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:melos/melos.dart' as melos;
import 'package:glob/glob.dart';
import 'dart:io';
import 'package:cli_util/cli_logging.dart' as logging;

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

  for (final package in workspace.filteredPackages.values) {
    final packageSwiftFile =
        File('${package.path}/ios/${package.name}/Package.swift');

    // only want to write this for plugins that support Swift
    // ignore core as it already has canonical firebase_sdk_version.rb
    if (packageSwiftFile.existsSync() && package.name != 'firebase_core') {
      final versionFile =
          File('${package.path}/ios/generated_firebase_sdk_version.txt');
      versionFile.writeAsStringSync(firebaseiOSVersion);
    }
  }
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
