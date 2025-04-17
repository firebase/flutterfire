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
import 'package:path/path.dart' show joinAll;

// Used to generate a simple txt file for local-config.gradle files to parse in order to use correct java and compilation versions.

void main() async {
  final workspace = await getMelosWorkspace();
  // get version from core
  // To edit versions for all packages, edit the global-config.txt file in firebase_core package
  // located in the android folder for global-config.txt
  final globalConfigPath = joinAll(
    [
      Directory.current.path,
      'gradle',
      'global-config.gradle',
    ],
  );

  final authConfigPath = joinAll(
    [
      Directory.current.path,
      'gradle',
      'auth-global-config.gradle',
    ],
  );

  final globalConfig = File(globalConfigPath);
  final authConfig = File(authConfigPath);
  
  if (!globalConfig.existsSync()) {
    throw Exception(
    'global_config.gradle file not found in the expected location.',
    );
  }

  for (final package in workspace.filteredPackages.values) {
    switch (package.name) {
      case 'firebase_vertexai':
        // Skip this package as it does not have gradle in it.
        break;
      case 'firebase_data_connect':
        // Only has gradle in the example application.
        final localConfigGradleFilePath = '${package.path}/example/android/app/local-config.gradle';
        final copiedConfig = await authConfig.copy(
        localConfigGradleFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedConfig.path}');
        break;
      case 'firebase_auth':
        // Needs minimum compile sdk verstion to 23 specifically for this package.
        final localConfigGradleFilePath = '${package.path}/android/local-config.gradle';
        final copiedConfig = await globalConfig.copy(
        localConfigGradleFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedConfig.path}');
        break;
      default:
        // For all other packages, copy the global-config.gradle file to the local-config.gradle file.
        final localConfigGradleFilePath = '${package.path}/android/local-config.gradle';

        final copiedConfig = await globalConfig.copy(
        localConfigGradleFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedConfig.path}');
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
