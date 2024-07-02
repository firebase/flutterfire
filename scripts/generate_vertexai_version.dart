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

import 'dart:io' show Directory, File;
import 'package:path/path.dart' show joinAll;
import 'package:yaml/yaml.dart' show YamlMap, loadYaml;

Future<void> main() async {
  final outputPath = joinAll(
    [
      Directory.current.path,
      'packages',
      'firebase_vertexai',
      'firebase_vertexai',
      'lib',
      'src',
      'vertex_version.dart',
    ],
  );

  final pubspecPath = joinAll(
    [
      Directory.current.path,
      'packages',
      'firebase_vertexai',
      'firebase_vertexai',
      'pubspec.yaml'
    ],
  );
  final yamlMap = loadYaml(File(pubspecPath).readAsStringSync()) as YamlMap;
  final currentVersion = yamlMap['version'] as String;
  final fileContents = File(outputPath).readAsStringSync();

  final lines = fileContents.split('\n');

  const versionLinePrefix = 'const packageVersion = ';
  bool versionLineFound = false;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].startsWith(versionLinePrefix)) {
      lines[i] = "$versionLinePrefix'$currentVersion';";
      versionLineFound = true;
      break;
    }
  }

  if (!versionLineFound) {
    lines.add("$versionLinePrefix'$currentVersion';");
  }

  // Join the lines back into a single string
  final newFileContents = lines.join('\n');

  await File(outputPath).writeAsString(newFileContents);
}