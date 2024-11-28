// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

void main() async {
  await buildSwiftExampleApp('ios', 'firebase_core');
  await buildSwiftExampleApp('ios', 'cloud_firestore');
  await buildSwiftExampleApp('macos', 'firebase_core');
  await buildSwiftExampleApp('macos', 'cloud_firestore');
  await buildSwiftExampleApp('ios', 'firebase_remote_config');
  await buildSwiftExampleApp('macos', 'firebase_remote_config');
  await buildSwiftExampleApp('ios', 'cloud_functions');
  await buildSwiftExampleApp('macos', 'cloud_functions');
  await buildSwiftExampleApp('ios', 'firebase_database');
  await buildSwiftExampleApp('macos', 'firebase_database');
}

Future<void> deleteFirstLine(String filePath) async {
  final file = File(filePath);

  if (!file.existsSync()) {
    print('File does not exist: $filePath');
    return;
  }

  final lines = await file.readAsLines();
  if (lines.isNotEmpty) {
    final updatedContent = lines.skip(1).join('\n');
    await file.writeAsString(updatedContent);
    print('First line deleted from $filePath');
  } else {
    print('File is empty: $filePath');
  }
}

Future<void> buildSwiftExampleApp(String platform, String plugin) async {
  final initialDirectory = Directory.current;
  final platformName = platform == 'ios' ? 'iOS' : 'macOS';

  print('Building $plugin $platformName example app with swift (SPM)');

  final directory = Directory('packages/$plugin/$plugin/example/$platform');
  if (!directory.existsSync()) {
    print('Directory does not exist: ${directory.path}');
    exit(1);
  }

  if (platform == 'macos') {
    await deleteFirstLine(
        'packages/$plugin/$plugin/example/macos/Flutter/Flutter-Release.xcconfig');
  }
  // Change to the appropriate directory
  Directory.current = directory;

  // Remove Podfile and deintegrate pods
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
        'Successfully built $plugin $platformName project using Swift Package Manager.');
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
