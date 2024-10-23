// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  // Define the path to the pubspec.yaml file
  const pubspecPath = 'packages/firebase_core/firebase_core/pubspec.yaml';

  // Read the pubspec.yaml file
  final pubspecFile = File(pubspecPath);
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml file not found at $pubspecPath');
    return;
  }

  // Parse the YAML content
  final pubspecContent = pubspecFile.readAsStringSync();
  final pubspecYaml = loadYaml(pubspecContent);

  // Extract the version
  final version = pubspecYaml['version'];
  if (version == null) {
    print('Error: Version not found in pubspec.yaml');
    return;
  }

  const packageIdentifier = 'firebase-core-swift';

  // Generate the tag
  final tag = '$version-$packageIdentifier';
  print('Generated tag for firebase core swift: $tag');

  // Run the git tag command
  final result = Process.runSync('git', ['tag', tag]);

  if (result.exitCode == 0) {
    print('Git tag created successfully for firebase core swift: $tag');
  } else {
    print('Error creating git tag: ${result.stderr}');
  }
}
