// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:melos/melos.dart' as melos;
import 'package:glob/glob.dart';
import 'dart:io';
import 'package:cli_util/cli_logging.dart' as logging;
import 'package:path/path.dart' as path;

// Used to generate a simple txt file for local-config.gradle files to parse in order to use correct java and compilation versions.

void main() async {
  final workspace = await getMelosWorkspace();
  // get version from core
  // To edit versions for all packages, edit the global-config.txt file in firebase_core package
  // located in the android folder for global-config.txt
  final firebaseCorePackage = workspace.filteredPackages.values
      .firstWhere((package) => package.name == 'firebase_core');

  final globalConfig = File(
    '${firebaseCorePackage.path}/android/global-config.txt',
  );
  
  if (!globalConfig.existsSync()) {
    throw Exception(
    'global_config.txt file not found in the expected location.',
    );
  }

  final versions = getVersions(globalConfig);

  for (final package in workspace.filteredPackages.values) {
    final localConfigGradleFile =
        File('${package.path}/android/local-config.gradle');

    if (localConfigGradleFile.existsSync()) {
      final packageVersionFile =
          File('${package.path}/android/generated_android_versions.txt');
      packageVersionFile.writeAsStringSync(await versions);
      final exampleAppVersionFile = File(
          '${package.path}/example/android/app/generated_android_versions.txt');
      exampleAppVersionFile.writeAsStringSync(await versions);
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

Future<String> getVersions(File globalConfig) async {
  if (globalConfig.existsSync()) {
    final contents = globalConfig.readAsStringSync();
    final lines = contents.split('\n');
    final javaVersion =
        lines.firstWhere((line) => line.contains('javaVersion'));
    final compileSdkVersion =
        lines.firstWhere((line) => line.contains('compileSdk'));
    final minSdkVersion =
        lines.firstWhere((line) => line.contains('minSdk'));
    final targetSdkVersion =
        lines.firstWhere((line) => line.contains('targetSdk'));

    return '$javaVersion\n$compileSdkVersion\n$minSdkVersion\n$targetSdkVersion';
  }
  throw Exception('global-config.txt file has wrong format or something missing.');
}
