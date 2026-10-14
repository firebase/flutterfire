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
/// pubspec.yaml workspace, and that no package declares `flutter_test` as a
/// regular dependency.
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

  final flutterTestDependents = foundPackages
      .where((path) => _dependsOnFlutterTest(p.join(rootDir, path)))
      .toList();

  if (flutterTestDependents.isNotEmpty) {
    print(
      '\nDeclaring `flutter_test` in `dependencies` pins `test_api` for every '
      'consumer of the package, which breaks version solving for apps that use '
      '`package:test` (https://github.com/firebase/flutterfire/issues/17001).\n'
      'Move it to `dev_dependencies`. If a generated Pigeon test API in `lib/` '
      'needs it, import '
      '`package:firebase_core_platform_interface/test_binding.dart` instead.\n'
      '\n`flutter_test` declared as a regular dependency:',
    );
    for (final path in flutterTestDependents) {
      print(' - $path');
    }
    hasError = true;
  }

  if (hasError) {
    exitCode = 1;
  } else {
    print('\nWorkspace is valid! All packages are listed.');
  }
}

/// Whether the published package at [packageDir] lists `flutter_test` in
/// `dependencies`.
///
/// Unpublished packages (example apps, test fixtures) are skipped: their
/// dependencies never reach a consumer's version solving.
bool _dependsOnFlutterTest(String packageDir) {
  final yaml =
      loadYaml(File(p.join(packageDir, 'pubspec.yaml')).readAsStringSync());
  if (yaml is! YamlMap) return false;
  if (yaml['publish_to'] == 'none') return false;
  final dependencies = yaml['dependencies'];
  return dependencies is YamlMap && dependencies.containsKey('flutter_test');
}

/// Walks [dir] for package pubspecs, pruning [_ignoredDirectories] as it
/// descends rather than filtering them out afterwards, so generated build
/// output is never entered.
///
/// Symlinks are not followed: the `.symlinks` directories that CocoaPods
/// creates in example apps point back into `packages`, so following them turns
/// the walk into a cycle.
Iterable<String> _findPackages(Directory dir, String rootDir) sync* {
  for (final entity in dir.listSync(followLinks: false)) {
    if (entity is Directory) {
      if (_ignoredDirectories.contains(p.basename(entity.path))) {
        continue;
      }
      yield* _findPackages(entity, rootDir);
    } else if (entity is File && p.basename(entity.path) == 'pubspec.yaml') {
      final relPath = p.relative(p.dirname(entity.path), from: rootDir);
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
