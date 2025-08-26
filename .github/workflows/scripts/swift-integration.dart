// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

final debugMode = false;

void main(List<String> arguments) async {
  if (debugMode) {
    print('[DEBUG] main: Starting swift-integration script');
    print('[DEBUG] Arguments: ${arguments.join(', ')}');
    print('[DEBUG] Number of arguments: ${arguments.length}');
  }

  if (arguments.isEmpty) {
    throw Exception('No FlutterFire dependency arguments provided.');
  }

  // Get the current git branch from GitHub Actions environment or fallback to git command
  final currentBranch = await getCurrentBranch();
  print('Current branch: $currentBranch');

  if (debugMode) {
    print(
      '[DEBUG] About to update Package.swift files for branch: $currentBranch',
    );
  }

  // Update all Package.swift files to use branch dependencies
  await updatePackageSwiftFiles(currentBranch, arguments);

  if (debugMode) {
    print('[DEBUG] Package.swift files updated, starting builds');
  }

  final plugins = arguments.join(',');

  if (debugMode) {
    print('[DEBUG] Building iOS first...');
  }
  await buildSwiftExampleApp('ios', plugins);

  if (debugMode) {
    print('[DEBUG] iOS build completed, now building macOS...');
  }
  await buildSwiftExampleApp('macos', plugins);

  if (debugMode) {
    print('[DEBUG] main: All builds completed successfully');
  }
}

Future<String> getCurrentBranch() async {
  if (debugMode) {
    print('[DEBUG] getCurrentBranch: Starting branch detection');
    print('[DEBUG] Environment variables:');
    print(
      '[DEBUG]   GITHUB_HEAD_REF: ${Platform.environment['GITHUB_HEAD_REF']}',
    );
    print(
      '[DEBUG]   GITHUB_REF_NAME: ${Platform.environment['GITHUB_REF_NAME']}',
    );
    print(
      '[DEBUG]   GITHUB_REPOSITORY: ${Platform.environment['GITHUB_REPOSITORY']}',
    );
    print('[DEBUG]   PR_HEAD_REPO: ${Platform.environment['PR_HEAD_REPO']}');
  }

  // Try GitHub Actions environment variables first
  String? branch = Platform.environment['GITHUB_HEAD_REF']; // For pull requests

  if (debugMode && branch != null) {
    print('[DEBUG] Found branch from GITHUB_HEAD_REF: $branch');
  }

  if (branch == null || branch.isEmpty) {
    branch = Platform.environment['GITHUB_REF_NAME']; // For direct pushes
    if (debugMode && branch != null) {
      print('[DEBUG] Found branch from GITHUB_REF_NAME: $branch');
    }
  }

  if (branch == null || branch.isEmpty) {
    // Fallback to git command for local testing
    print(
      'GitHub Actions environment variables not found, trying git command...',
    );
    if (debugMode) {
      print('[DEBUG] Executing: git branch --show-current');
    }
    final result = await Process.run('git', ['branch', '--show-current']);
    if (result.exitCode != 0) {
      if (debugMode) {
        print('[DEBUG] Git command failed with exit code: ${result.exitCode}');
        print('[DEBUG] Git stderr: ${result.stderr}');
      }
      throw Exception('Failed to get current git branch: ${result.stderr}');
    }
    branch = result.stdout.toString().trim();
    if (debugMode) {
      print('[DEBUG] Found branch from git command: $branch');
    }
  }

  if (branch.isEmpty) {
    if (debugMode) {
      print('[DEBUG] No branch found from any method');
    }
    throw Exception(
      'Could not determine current branch from GitHub Actions environment or git command',
    );
  }

  if (debugMode) {
    print('[DEBUG] Final branch: $branch');
  }
  return branch;
}

Future<void> updatePackageSwiftFiles(
  String branch,
  List<String> packages,
) async {
  if (debugMode) {
    print('[DEBUG] updatePackageSwiftFiles: Starting');
    print('[DEBUG] Branch: $branch');
    print(
      '[DEBUG] updatePackageSwiftFiles: Processing ${packages.length} packages',
    );
    print('[DEBUG] Packages: ${packages.join(', ')}');
  }

  // Update each package's Package.swift files
  for (final package in packages) {
    if (debugMode) {
      print('[DEBUG] Processing package: $package');
    }
    await updatePackageSwiftForPackage(package, branch);
  }

  if (debugMode) {
    print('[DEBUG] updatePackageSwiftFiles: Completed processing all packages');
  }
}

Future<void> updatePackageSwiftForPackage(
  String packageName,
  String branch,
) async {
  if (debugMode) {
    print(
      '[DEBUG] updatePackageSwiftForPackage: Starting for package $packageName',
    );
  }

  // Check both ios and macos directories
  final platforms = ['ios', 'macos'];

  if (debugMode) {
    print('[DEBUG] Will check platforms: ${platforms.join(', ')}');
  }

  for (final platform in platforms) {
    final packageSwiftPath =
        'packages/$packageName/$packageName/$platform/$packageName/Package.swift';
    final file = File(packageSwiftPath);

    if (debugMode) {
      print('[DEBUG] Checking path: $packageSwiftPath');
      print('[DEBUG] File exists: ${file.existsSync()}');
    }

    if (!file.existsSync()) {
      print('Warning: Package.swift not found at $packageSwiftPath');
      continue;
    }

    print('Updating $packageSwiftPath');
    final content = await file.readAsString();

    if (debugMode) {
      print('[DEBUG] File content length: ${content.length} characters');
      print('[DEBUG] Content preview (first 200 chars):');
      print(
        '[DEBUG] ${content.length > 200 ? content.substring(0, 200) : content}...',
      );
    }

    // Replace exact version dependency with branch dependency
    String updatedContent = content;

    // Pattern to match the exact version dependency
    final exactVersionPattern = RegExp(
      r'\.package\(url: "https://github\.com/firebase/flutterfire", exact: [^)]+\)',
      multiLine: true,
    );

    if (debugMode) {
      final matches = exactVersionPattern.allMatches(content);
      print('[DEBUG] Regex pattern matches found: ${matches.length}');
      for (final match in matches) {
        print('[DEBUG] Match: ${match.group(0)}');
      }
    }

    final headRepo = Platform.environment['PR_HEAD_REPO'];
    final baseRepo = Platform.environment['GITHUB_REPOSITORY'];

    if (debugMode) {
      print('[DEBUG] PR_HEAD_REPO: $headRepo');
      print('[DEBUG] GITHUB_REPOSITORY: $baseRepo');
    }

    // handles forked repositories
    final repoSlug = headRepo != baseRepo ? headRepo : baseRepo;
    print('repoSlug: $repoSlug');
    print('branch: $branch');

    if (debugMode) {
      print(
        '[DEBUG] Using repoSlug: $repoSlug (headRepo != baseRepo: ${headRepo != baseRepo})',
      );
    }

    // Replace with branch dependency
    final branchDependency =
        '.package(url: "https://github.com/$repoSlug", branch: "$branch")';

    if (debugMode) {
      print('[DEBUG] Branch dependency string: $branchDependency');
    }

    if (exactVersionPattern.hasMatch(content)) {
      updatedContent = content.replaceAll(
        exactVersionPattern,
        branchDependency,
      );

      if (debugMode) {
        print('[DEBUG] Content was modified, writing to file');
        print('[DEBUG] Updated content preview (first 200 chars):');
        print(
          '[DEBUG] ${updatedContent.length > 200 ? updatedContent.substring(0, 200) : updatedContent}...',
        );
      }

      await file.writeAsString(updatedContent);
      print('✓ Updated $packageSwiftPath to use branch: $branch');
    } else {
      print('⚠ No exact version dependency found in $packageSwiftPath');
      if (debugMode) {
        print('[DEBUG] Content did not match regex pattern');
        print('[DEBUG] Looking for pattern: ${exactVersionPattern.pattern}');
      }
    }
  }

  if (debugMode) {
    print(
      '[DEBUG] updatePackageSwiftForPackage: Completed for package $packageName',
    );
  }
}

Future<void> buildSwiftExampleApp(String platform, String plugins) async {
  final initialDirectory = Directory.current;
  final platformName = platform == 'ios' ? 'iOS' : 'macOS';

  if (debugMode) {
    print('[DEBUG] buildSwiftExampleApp: Starting build for $platformName');
    print('[DEBUG] Initial directory: ${initialDirectory.path}');
    print('[DEBUG] Platform: $platform');
    print('[DEBUG] Plugins: $plugins');
  }

  print('Building example app with swift (SPM) integration for $plugins');

  final directory = Directory(
    'packages/firebase_core/firebase_core/example/$platform',
  );

  if (debugMode) {
    print('[DEBUG] Target directory: ${directory.path}');
    print('[DEBUG] Directory exists: ${directory.existsSync()}');
  }

  if (!directory.existsSync()) {
    print('Directory does not exist: ${directory.path}');
    exit(1);
  }

  // Change to the appropriate directory
  if (debugMode) {
    print(
      '[DEBUG] Changing directory from ${Directory.current.path} to ${directory.path}',
    );
  }
  Directory.current = directory;

  if (debugMode) {
    print('[DEBUG] Current directory after change: ${Directory.current.path}');
    print('[DEBUG] Listing current directory contents:');
    try {
      final contents = Directory.current.listSync();
      for (final item in contents) {
        print('[DEBUG]   ${item.path.split('/').last}');
      }
    } catch (e) {
      print('[DEBUG] Error listing directory: $e');
    }
  }

  await _runCommand('rm', ['Podfile']);
  await _runCommand('pod', ['deintegrate']);

  // Check what SPM packages are being resolved before build
  if (debugMode) {
    print('[DEBUG] Checking for existing SPM packages directory...');
    final spmPackagesDir = Directory('$platform/Flutter/ephemeral/Packages');
    if (spmPackagesDir.existsSync()) {
      print('[DEBUG] SPM Packages directory exists: ${spmPackagesDir.path}');
      try {
        final packages = spmPackagesDir.listSync(recursive: true);
        for (final package in packages) {
          if (package is Directory) {
            print('[DEBUG] SPM Package directory: ${package.path}');
          }
        }
      } catch (e) {
        print('[DEBUG] Error listing SPM packages: $e');
      }
    } else {
      print('[DEBUG] SPM Packages directory does not exist yet');
    }
  }

  // Determine the arguments for the flutter build command
  final flutterArgs = ['build', platform];
  if (platform == 'ios') {
    flutterArgs.add('--no-codesign');
  }

  if (debugMode) {
    print('[DEBUG] Flutter command args: ${flutterArgs.join(' ')}');
  }

  if (platform == 'macos') {
    // TODO: temp solution to macos to remove firebase_messaging from build
    // See: https://github.com/firebase/flutterfire/actions/runs/17042278122/job/48308815666?pr=17634#step:8:787
    await _runCommand('flutter', ['pub', 'remove', 'firebase_messaging']);
    await _runCommand('flutter', ['clean']);
  }

  // Run the flutter build command
  final flutterResult = await _runCommand('flutter', flutterArgs);

  // Check what SPM packages were resolved after build
  if (debugMode && flutterResult.exitCode != 0) {
    print('[DEBUG] Build failed, checking SPM packages directory for clues...');
    final spmPackagesDir = Directory('$platform/Flutter/ephemeral/Packages');
    if (spmPackagesDir.existsSync()) {
      print(
        '[DEBUG] SPM Packages directory after failed build: ${spmPackagesDir.path}',
      );
      try {
        final packages = spmPackagesDir.listSync(recursive: true);
        for (final package in packages) {
          if (package is Directory &&
              package.path.contains('firebase_messaging')) {
            print('[DEBUG] Found firebase_messaging package: ${package.path}');
            // Check if it's trying to access iOS resources from macOS build
            final resourcesDir = Directory(
              '${package.path}/Sources/firebase_messaging/Resources',
            );
            if (resourcesDir.existsSync()) {
              print('[DEBUG] Resources directory exists: ${resourcesDir.path}');
              final resources = resourcesDir.listSync();
              for (final resource in resources) {
                print('[DEBUG] Resource: ${resource.path}');
              }
            } else {
              print(
                '[DEBUG] Resources directory does not exist: ${resourcesDir.path}',
              );
            }
          }
        }
      } catch (e) {
        print('[DEBUG] Error listing SPM packages after build: $e');
      }
    }
  }

  if (debugMode) {
    print('[DEBUG] Flutter build exit code: ${flutterResult.exitCode}');
  }

  // Check if the flutter build command was successful
  if (flutterResult.exitCode != 0) {
    print('Flutter build failed with exit code ${flutterResult.exitCode}.');
    if (debugMode) {
      print('[DEBUG] Flutter build failed, exiting');
    }
    exit(1);
  }

  // Check the output for the specific string
  if (flutterResult.stdout.contains('Running pod install')) {
    print('Failed. Pods are being installed when they should not be.');
    if (debugMode) {
      print(
        '[DEBUG] Found "Running pod install" in output, this should not happen with SPM',
      );
    }
    exit(1);
  } else {
    print(
      'Successfully built $plugins for $platformName project using Swift Package Manager.',
    );

    if (debugMode) {
      print('[DEBUG] Build successful, changing to parent directory');
    }
    Directory.current = Directory('..');
    print('See contents of pubspec.yaml:');
    await _runCommand('cat', ['pubspec.yaml']);
  }

  if (debugMode) {
    print('[DEBUG] Restoring original directory: ${initialDirectory.path}');
  }
  Directory.current = initialDirectory;

  if (debugMode) {
    print('[DEBUG] buildSwiftExampleApp: Completed build for $platformName');
  }
}

Future<ProcessResult> _runCommand(
  String command,
  List<String> arguments,
) async {
  if (debugMode) {
    print(
      '[DEBUG] _runCommand: Executing command: $command ${arguments.join(' ')}',
    );
    print('[DEBUG] Current working directory: ${Directory.current.path}');
  }

  final process = await Process.start(command, arguments);

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  // Listen to stdout
  process.stdout.transform(utf8.decoder).listen((data) {
    stdoutBuffer.write(data);
  });

  // Listen to stderr
  process.stderr.transform(utf8.decoder).listen((data) {
    stderrBuffer.write(data);
    print('stderr output: $data');
  });

  // Wait for the process to complete
  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    print('Command failed: $command ${arguments.join(' ')}');
    if (debugMode) {
      print('[DEBUG] Command failed with exit code $exitCode');
    }
  }

  return ProcessResult(
    process.pid,
    exitCode,
    stdoutBuffer.toString(),
    stderrBuffer.toString(),
  );
}
