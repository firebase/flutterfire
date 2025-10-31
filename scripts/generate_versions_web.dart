// Copyright 2025 Google LLC
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

import 'dart:io' show Directory, File;
import 'package:path/path.dart' show basename, joinAll;
import 'package:yaml/yaml.dart' show YamlMap, loadYaml;

Future<void> main() async {
  final packagesDir = Directory('packages');
  final webPackages = <String>[];
  
  // Find all packages with _web directories
  await for (final packageDir in packagesDir.list()) {
    if (packageDir is Directory) {
      final packageName = basename(packageDir.path);
      final webDir = Directory(joinAll([packageDir.path, '${packageName}_web']));
      
      if (await webDir.exists()) {
        webPackages.add(packageName);
      }
    }
  }
  
  print('Found web packages: ${webPackages.join(', ')}');
  
  // Process each web package
  for (final packageName in webPackages) {
    await _generateVersionFile(packageName);
  }
  
  print('Generated version files for ${webPackages.length} web packages');
}

Future<void> _generateVersionFile(String packageName) async {
  final webPackageName = '${packageName}_web';
  
  // Path to the web package's pubspec.yaml
  final pubspecPath = joinAll([
    'packages',
    packageName,
    packageName,
    'pubspec.yaml',
  ]);
  
  // Path to the version file to generate
  final versionFilePath = joinAll([
    'packages',
    packageName,
    webPackageName,
    'lib',
    'src',
    '${packageName}_version.dart',
  ]);
  
  try {
    // Read the pubspec.yaml to get the version
    final pubspecFile = File(pubspecPath);
    if (!await pubspecFile.exists()) {
      print('Warning: pubspec.yaml not found for $webPackageName at $pubspecPath');
      return;
    }
    
    final yamlMap = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final currentVersion = yamlMap['version'] as String;
    
    print('Processing $webPackageName version $currentVersion');
    
    // Create the version file content
    final fileContent = '''
// Copyright 2025 Google LLC
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

/// generated version number for the package, do not manually edit
const packageVersion = '$currentVersion';
''';
    
    // Ensure the src directory exists
    final srcDir = Directory(joinAll([
      'packages',
      packageName,
      webPackageName,
      'lib',
      'src',
    ]));
    
    if (!await srcDir.exists()) {
      await srcDir.create(recursive: true);
    }
    
    // Write the version file
    final versionFile = File(versionFilePath);
    await versionFile.writeAsString(fileContent);
    
    print('Generated version file: $versionFilePath');
    
  } catch (e) {
    print('Error processing $webPackageName: $e');
  }
}
