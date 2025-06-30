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
// Tested against every example app in the packages.
// NOTICE: This script does not update auth or vertexai packages as they are manually updated.
// Furthermore, this script does not update the test app.
void main() async {
  final workspace = await getMelosWorkspace();
  // To edit versions for all packages, edit the global-config.gradle file in ./scripts/global-config.gradle
  final globalConfigPath = joinAll(
    [
      Directory.current.path,
      'scripts',
      'global-config.gradle',
    ],
  );

  // Define files using paths
  final globalConfig = File(globalConfigPath);
  
  // Check if the files exist
  if (!globalConfig.existsSync()) {
    throw Exception(
    'global_config.gradle file not found in the expected location.',
    );
  }

  for (final package in workspace.filteredPackages.values) {
    switch (package.name) {
      case 'cloud_firestore':
      case  'cloud_functions':
      case 'firebase_analytics':
      case 'firebase_app_check':
      case 'firebase_app_installations':
      case 'firebase_core':
      case 'firebase_crashlytics':
      case 'firebase_database':
      case 'firebase_dynamic_links':
      case 'firebase_in_app_messaging':
      case 'firebase_messaging':
      case 'firebase_ml_model_downloader':
      case 'firebase_performance':
      case 'firebase_remote_config':
      case 'firebase_storage':
        final localConfigGradleFilePath = '${package.path}/android/local-config.gradle';

        final copiedConfig = await globalConfig.copy(
        localConfigGradleFilePath,
        );
        print('File copied to: ${copiedConfig.path}');

        final gradlePropertiesFilePath = '${package.path}/example/android/gradle.properties';
        extractAndWriteProperty(
          globalConfig: globalConfig,
          gradlePropertiesFile: File(gradlePropertiesFilePath),
        );
        print('successfully wrote property to $gradlePropertiesFilePath');
        break;
      case 'firebase_data_connect':
        // Only has gradle in the example application.
        final localConfigGradleFilePath = '${package.path}/example/android/app/local-config.gradle';
        final copiedConfig = await globalConfig.copy(
        localConfigGradleFilePath,
        );
        // ignore: avoid_print
        print('File copied to: ${copiedConfig.path}');
        
        final gradlePropertiesFilePath = '${package.path}/example/android/gradle.properties';
        extractAndWriteProperty(
          globalConfig: globalConfig,
          gradlePropertiesFile: File(gradlePropertiesFilePath),
        );
        print('successfully wrote property to $gradlePropertiesFilePath');
        break;
      case 'firebase_vertexai':
      case 'firebase_ai':
      case 'firebase_auth':
        // skip these packages, manually update.
        break;
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

Future<void> extractAndWriteProperty({
  required File globalConfig,
  required File gradlePropertiesFile,
}) async {

  const String propertyName = 'androidGradlePluginVersion';
  if (!await globalConfig.exists()) {
    print('Global config file not found: ${globalConfig.path}');
    return;
  }

  final globalContent = await globalConfig.readAsString();

  // Extract the property from the ext block
  final regex = RegExp('$propertyName\\s*=\\s*[\'"]?([^\\n\'"]+)[\'"]?');
  final match = regex.firstMatch(globalContent);

  if (match == null) {
    print('Property $propertyName not found in global config.');
    return;
  }

  final value = match.group(1);

  final lines = await gradlePropertiesFile.exists()
      ? await gradlePropertiesFile.readAsLines()
      : [];

  bool updated = false;

  final updatedLines = lines.map((line) {
    if (line.startsWith('$propertyName=')) {
      updated = true;
      return '$propertyName=$value';
    }
    return line;
  }).toList();

  if (!updated) {
    updatedLines.add('$propertyName=$value');
  }

  await gradlePropertiesFile.writeAsString(updatedLines.join('\n'));

  print('Wrote $propertyName=$value to ${gradlePropertiesFile.path}');
}
