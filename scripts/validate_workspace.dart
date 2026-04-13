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

// ignore_for_file: avoid_print

/// Validates that all packages in the repository are listed in the root
/// pubspec.yaml workspace.
library;

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

void main() {
  // Ensure running at the root of the git repo
  final gitResult = Process.runSync('git', ['rev-parse', '--show-cdup']);
  if (gitResult.exitCode != 0 ||
      gitResult.stdout.toString().trim().isNotEmpty) {
    print(
      'Error: This script must be run from the root of the git repository.',
    );
    exitCode = 1;
    return;
  }

  final rootDir = Directory.current.path;
  final pubspecFile = File(p.join(rootDir, 'pubspec.yaml'));

  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found at root.');
    exitCode = 1;
    return;
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final yaml = loadYaml(pubspecContent);

  final workspace = yaml['workspace'];
  if (workspace == null || workspace is! YamlList) {
    print('Error: No workspace list found in pubspec.yaml.');
    exitCode = 1;
    return;
  }

  final workspacePaths = workspace.map((e) => e.toString()).toSet();
  print('Workspace paths in pubspec.yaml: ${workspacePaths.length}');

  final foundPackages = <String>[];

  final packagesDir = Directory(p.join(rootDir, 'packages'));
  if (packagesDir.existsSync()) {
    foundPackages.addAll(_findPackages(packagesDir, rootDir));
  }

  final testsDir = Directory(p.join(rootDir, 'tests'));
  if (testsDir.existsSync()) {
    foundPackages.addAll(_findPackages(testsDir, rootDir));
  }

  print('Found pubspec.yaml files: ${foundPackages.length}');

  final missingFromWorkspace =
      foundPackages.where((p) => !workspacePaths.contains(p)).toList();

  final listedButMissingFromDisk =
      workspacePaths.where((p) => !foundPackages.contains(p)).toList();

  var hasError = false;

  if (missingFromWorkspace.isNotEmpty) {
    print('\nMissing from workspace:');
    for (final p in missingFromWorkspace) {
      print(' - $p');
    }
    hasError = true;
  }

  if (listedButMissingFromDisk.isNotEmpty) {
    print('\nListed in workspace but missing from disk:');
    for (final p in listedButMissingFromDisk) {
      print(' - $p');
    }
    hasError = true;
  }

  if (hasError) {
    exitCode = 1;
  } else {
    print('\nWorkspace is valid! All packages are listed.');
  }
}

Iterable<String> _findPackages(Directory dir, String rootDir) sync* {
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && p.basename(entity.path) == 'pubspec.yaml') {
      final path = entity.path;
      final components = p.split(path);
      if (components.any(_ignoredDirectories.contains)) {
        continue;
      }
      final relPath = p.relative(p.dirname(path), from: rootDir);
      if (relPath != '.') {
        yield relPath;
      }
    }
  }
}

const _ignoredDirectories = {
  '.dart_tool',
  '.plugin_symlinks',
  'ephemeral',
  'build',
};
