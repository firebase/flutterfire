// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart' as logging;
import 'package:glob/glob.dart';
import 'package:melos/melos.dart' as melos;
import 'package:pub_semver/pub_semver.dart' as melos;

import 'generate_bom.dart';

void main(List<String> arguments) async {
  final newBoMVersion = await getBoMNextVersion(shouldLog: true);
  if (newBoMVersion == null) {
    print('No changes detected');
  } else {
    print('New BoM Version: $newBoMVersion');
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

Future<String?> getBoMNextVersion({bool shouldLog = false}) async {
  File currentVersionsJson = File(versionsJsonFile);
  Map<String, dynamic> currentVersions =
      jsonDecode(currentVersionsJson.readAsStringSync());
  // We always append the latest version to the top of the file
  // and it's preserved during parsing
  final currentVersionNumber = currentVersions.keys.first;

  final currentBoMVersion = melos.Version.parse(currentVersionNumber);
  final previousBoMPackageNameAndVersions =
      currentVersions[currentVersionNumber]['packages']
              as Map<String, dynamic>? ??
          {};

  final currentPackageNameAndVersionsMap = await getPackagesUsingMelos();
  final changes = <String, int>{};
  final changedPackages = <String, List<String>>{};
  for (final entry in currentPackageNameAndVersionsMap.entries) {
    final previousVersion = previousBoMPackageNameAndVersions[entry.key];
    if (previousVersion == null) {
      changes['new'] = (changes['new'] ?? 0) + 1;
      if (shouldLog) {
        print('New package: ${entry.key} ${entry.value}');
      }
    } else {
      final previous = melos.Version.parse(previousVersion);
      final current = entry.value.version;
      if (current.major > previous.major) {
        changes['major'] = (changes['major'] ?? 0) + 1;
        changedPackages[entry.key] = [previousVersion, current.toString()];
      } else if (current.minor > previous.minor) {
        changes['minor'] = (changes['minor'] ?? 0) + 1;
        changedPackages[entry.key] = [previousVersion, current.toString()];
      } else if (current.patch > previous.patch) {
        changes['patch'] = (changes['patch'] ?? 0) + 1;
        changedPackages[entry.key] = [previousVersion, current.toString()];
      } else if (current.build.isNotEmpty) {
        final previousBuild =
            previous.build.isEmpty ? 0 : previous.build.first as int;
        final currentBuild = current.build.first as int;
        if (currentBuild > previousBuild) {
          changes['patch'] = (changes['patch'] ?? 0) + 1;
          changedPackages[entry.key] = [previousVersion, current.toString()];
        }
      }
    }
  }

  if (shouldLog) {
    print(
      'Previous BoM Package Name and Versions: $previousBoMPackageNameAndVersions',
    );
    print(
      'Current Package Name and Versions: $currentPackageNameAndVersionsMap',
    );
    print('-' * 80);
    print('Changes: $changes');
    print('Changed Packages: $changedPackages');
    print('-' * 80);
    print('Current BoM Version: $currentBoMVersion');
  }

  var newBoMVersion = currentBoMVersion;

  if (changes.isNotEmpty) {
    if (changes['major'] != null) {
      newBoMVersion = newBoMVersion.nextMajor;
    } else if (changes['minor'] != null) {
      newBoMVersion = newBoMVersion.nextMinor;
    } else if (changes['patch'] != null) {
      newBoMVersion = newBoMVersion.nextPatch;
    } else if (changes['new'] != null) {
      newBoMVersion = newBoMVersion.nextMinor;
    }
    return newBoMVersion.toString();
  } else if (shouldLog) {
    print('No changes detected');
  }
  return null;
}
