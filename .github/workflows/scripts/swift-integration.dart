import 'dart:io';

void main() async {
  await buildSwiftExampleApp('ios', 'firebase_core');
  await buildSwiftExampleApp('macos', 'firebase_core');
  await buildSwiftExampleApp('ios', 'cloud_firestore');
  await buildSwiftExampleApp('macos', 'cloud_firestore');
}

Future<void> buildSwiftExampleApp(String platform, String plugin) async {
  final platformName = platform == 'ios' ? 'iOS' : 'macOS';

  print('Building firebase core $platformName example app with swift (SPM)');

  final directory = Directory('packages/$plugin/$plugin/example/$platform');
  if (!directory.existsSync()) {
    print('Directory does not exist: ${directory.path}');
    exit(1);
  }

  // Change to the appropriate directory
  Directory.current = directory;

  // Remove Podfile and deintegrate pods
  await _runCommand('rm', ['Podfile']);
  await _runCommand('pod', ['deintegrate']);

  // Run the flutter build command
  final flutterResult = await _runCommand('flutter', ['build', platform, '--no-codesign']);

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
    print('Successfully built $platformName project using Swift Package Manager.');
  }
}

Future<ProcessResult> _runCommand(String command, List<String> arguments) async {
  final result = await Process.run(command, arguments);
  if (result.exitCode != 0) {
    print('Command failed: $command ${arguments.join(' ')}');
    print('Error: ${result.stderr}');
  }
  return result;
}
