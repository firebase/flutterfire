// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    throw Exception('No FlutterFire dependency arguments provided.');
  }

  // Get the current git branch from GitHub Actions environment or fallback to git command
  final currentBranch = await getCurrentBranch();
  print('Current branch: $currentBranch');

  // Update all Package.swift files to use branch dependencies
  await updatePackageSwiftFiles(currentBranch, arguments);

  final plugins = arguments.join(',');
  await buildSwiftExampleApp('ios', plugins);
  await buildSwiftExampleApp('macos', plugins);
}

Future<String> getCurrentBranch() async {
  // Try GitHub Actions environment variables first
  String? branch = Platform.environment['GITHUB_HEAD_REF']; // For pull requests

  if (branch == null || branch.isEmpty) {
    branch = Platform.environment['GITHUB_REF_NAME']; // For direct pushes
  }

  if (branch == null || branch.isEmpty) {
    // Fallback to git command for local testing
    print('GitHub Actions environment variables not found, trying git command...');
    final result = await Process.run('git', ['branch', '--show-current']);
    if (result.exitCode != 0) {
      throw Exception('Failed to get current git branch: ${result.stderr}');
    }
    branch = result.stdout.toString().trim();
  }

  if (branch.isEmpty) {
    throw Exception('Could not determine current branch from GitHub Actions environment or git command');
  }

  return branch;
}

Future<void> updatePackageSwiftFiles(String branch, List<String> packages) async {
  print('Updating Package.swift files to use branch: $branch');

  // Update each package's Package.swift files
  for (final package in packages) {
    await updatePackageSwiftForPackage(package, branch);
  }
}

Future<void> updatePackageSwiftForPackage(String packageName, String branch) async {
  // Check both ios and macos directories
  final platforms = ['ios', 'macos'];

  for (final platform in platforms) {
    final packageSwiftPath = 'packages/$packageName/$packageName/$platform/$packageName/Package.swift';
    final file = File(packageSwiftPath);

    if (!file.existsSync()) {
      print('Warning: Package.swift not found at $packageSwiftPath');
      continue;
    }

    print('Updating $packageSwiftPath');
    final content = await file.readAsString();

    // Replace exact version dependency with branch dependency
    String updatedContent = content;

    // Pattern to match the exact version dependency
    final exactVersionPattern = RegExp(
      r'\.package\(url: "https://github\.com/firebase/flutterfire", exact: [^)]+\)',
      multiLine: true
    );

    // Replace with branch dependency
    final branchDependency = '.package(url: "https://github.com/firebase/flutterfire", branch: "$branch")';

    if (exactVersionPattern.hasMatch(content)) {
      updatedContent = content.replaceAll(exactVersionPattern, branchDependency);
      await file.writeAsString(updatedContent);
      print('✓ Updated $packageSwiftPath to use branch: $branch');
    } else {
      print('⚠ No exact version dependency found in $packageSwiftPath');
    }
  }
}

Future<void> buildSwiftExampleApp(String platform, String plugins) async {
  final initialDirectory = Directory.current;
  final platformName = platform == 'ios' ? 'iOS' : 'macOS';

  print('Building example app with swift (SPM) integration for $plugins');

  final directory =
      Directory('packages/firebase_core/firebase_core/example/$platform');
  if (!directory.existsSync()) {
    print('Directory does not exist: ${directory.path}');
    exit(1);
  }

  // Change to the appropriate directory
  Directory.current = directory;

  await _runCommand('rm', ['Podfile']);
  await _runCommand('pod', ['deintegrate']);

  // Determine the arguments for the flutter build command
  final flutterArgs = ['build', platform];
  if (platform == 'ios') {
    flutterArgs.add('--no-codesign');
  }

  // Run the flutter build command
  final flutterResult = await _runCommand('flutter', flutterArgs);

  // Check if the flutter build command was successful
  if (flutterResult.exitCode != 0) {
    print('Flutter build failed with exit code ${flutterResult.exitCode}.');
    exit(1);
  }

  // Check the output for the specific string
  if (flutterResult.stdout.contains('Running pod install')) {
    print('Failed. Pods are being installed when they should not be.');
    exit(1);
  } else {
    print(
        'Successfully built $plugins for $platformName project using Swift Package Manager.');

    Directory.current = Directory('..');
    print('See contents of pubspec.yaml:');
    await _runCommand('cat', ['pubspec.yaml']);
  }

  Directory.current = initialDirectory;
}

Future<ProcessResult> _runCommand(
    String command, List<String> arguments) async {
  final process = await Process.start(command, arguments);

  // Listen to stdout
  process.stdout.transform(utf8.decoder).listen((data) {
    print(data);
  });

  // Listen to stderr
  process.stderr.transform(utf8.decoder).listen((data) {
    print('stderr output: $data');
  });

  // Wait for the process to complete
  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    print('Command failed: $command ${arguments.join(' ')}');
  }

  return ProcessResult(process.pid, exitCode, '', '');
}
