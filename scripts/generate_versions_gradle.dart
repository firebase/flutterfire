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

// Used to generate config files from ../gradle/local-config.gradle in order to use correct java and compilation versions.
// Also works on every example app in the packages.
void main() async {
  final workspace = await getMelosWorkspace();
  // To edit versions for all packages, edit the global-config.gradle file in FlutterFire/Gradle
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

  final exampleAppConfigPath = joinAll(
    [
      Directory.current.path,
      'gradle',
      'example-app-settings.gradle',
    ],
  );

  final perfExampleAppConfigPath = joinAll(
    [
      Directory.current.path,
      'gradle',
      'perf-example-app-settings.gradle',
    ],
  );

  final crashlyticsExampleAppConfigPath = joinAll(
    [
      Directory.current.path,
      'gradle',
      'crashlytics-example-app-settings.gradle',
    ],
  );

  // Define files using paths
  final globalConfig = File(globalConfigPath);
  final authConfig = File(authConfigPath);
  final exampleAppConfig = File(exampleAppConfigPath);
  final perfExampleAppConfig = File(perfExampleAppConfigPath);
  final crashlyticsExampleAppConfig = File(crashlyticsExampleAppConfigPath);
  
  // Check if the files exist
  if (!globalConfig.existsSync()) {
    throw Exception(
    'global_config.gradle file not found in the expected location.',
    );
  }

  if (!authConfig.existsSync()) {
    throw Exception(
    'global_config.gradle file not found in the expected location.',
    );
  }

  if (!exampleAppConfig.existsSync()) {
    throw Exception(
    'example-app-settings.gradle file not found in the expected location.',
    );
  }

  if (!perfExampleAppConfig.existsSync()) {
    throw Exception(
    'per-example-app-settings.gradle file not found in the expected location.',
    );
  }

  if (!crashlyticsExampleAppConfig.existsSync()) {
    throw Exception(
    'crashlytics-example-app-settings.gradle file not found in the expected location.',
    );
  }

  for (final package in workspace.filteredPackages.values) {
    switch (package.name) {
      case 'firebase_vertexai':
        final exampleAppConfigFilePath = '${package.path}/example/android/settings.gradle';
        final copiedExampleAppConfig = await exampleAppConfig.copy(
        exampleAppConfigFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedExampleAppConfig.path}');
        // Only has gradle in example app.
        break;
      case 'firebase_data_connect':
        // Only has gradle in the example application.
        final localConfigGradleFilePath = '${package.path}/example/android/app/local-config.gradle';
        final copiedConfig = await authConfig.copy(
        localConfigGradleFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedConfig.path}');

        final exampleAppConfigFilePath = '${package.path}/example/android/settings.gradle';
        final copiedExampleAppConfig = await exampleAppConfig.copy(
        exampleAppConfigFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedExampleAppConfig.path}');

        break;
      case 'firebase_auth':
        // Needs minimum compile sdk verstion to 23 specifically for this package.
        final localConfigGradleFilePath = '${package.path}/android/local-config.gradle';
        final copiedConfig = await globalConfig.copy(
        localConfigGradleFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedConfig.path}');

        final exampleAppConfigFilePath = '${package.path}/example/android/settings.gradle';
        final copiedExampleAppConfig = await exampleAppConfig.copy(
        exampleAppConfigFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedExampleAppConfig.path}');

        break;
      case 'firebase_crashlytics':
        final localConfigGradleFilePath = '${package.path}/android/local-config.gradle';

          final copiedConfig = await globalConfig.copy(
          localConfigGradleFilePath,
          );
          print('File copied to: ${copiedConfig.path}');

          final exampleAppConfigFilePath = '${package.path}/example/android/settings.gradle';
          final copiedExampleAppConfig = await crashlyticsExampleAppConfig.copy(
          exampleAppConfigFilePath,
          );
          print('File copied to: ${copiedExampleAppConfig.path}');
          // ignore: avoid_print
        break;
      case 'firebase_performance':
        // Has a more unique settings.gradle for example app. 
        final localConfigGradleFilePath = '${package.path}/android/local-config.gradle';

        final copiedConfig = await globalConfig.copy(
        localConfigGradleFilePath,
        );
        print('File copied to: ${copiedConfig.path}');

        final exampleAppConfigFilePath = '${package.path}/example/android/settings.gradle';
        final copiedExampleAppConfig = await perfExampleAppConfig.copy(
        exampleAppConfigFilePath,
        );
        print('File copied to: ${copiedExampleAppConfig.path}');
        // ignore: avoid_print
        break;
      default:
        // For all other packages, copy the global-config.gradle file to the local-config.gradle file.
        final localConfigGradleFilePath = '${package.path}/android/local-config.gradle';

        final copiedConfig = await globalConfig.copy(
        localConfigGradleFilePath,
        );
        print('File copied to: ${copiedConfig.path}');

        final exampleAppConfigFilePath = '${package.path}/example/android/settings.gradle';
        final copiedExampleAppConfig = await exampleAppConfig.copy(
        exampleAppConfigFilePath,
        );
        print('File copied to: ${copiedExampleAppConfig.path}');
        // ignore: avoid_print
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
