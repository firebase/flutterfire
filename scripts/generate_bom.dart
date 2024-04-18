// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pubspec_parse/pubspec_parse.dart' as pubspec;

import 'bom_analysis.dart';

const packagesDir = 'packages';
const versionsFile = 'VERSIONS.md';
const versionsJsonFile = 'scripts/versions.json';
const androidVersionFile =
    '$packagesDir/firebase_core/firebase_core/android/gradle.properties';
const iosVersionFile =
    '$packagesDir/firebase_core/firebase_core/ios/firebase_sdk_version.rb';
const webVersionFile =
    '$packagesDir/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart';
const windowsVersionFile =
    '$packagesDir/firebase_core/firebase_core/windows/CMakeLists.txt';

// Used to display the packages in the correct order
const List<String> packages = [
  'firebase_core',
  'firebase_auth',
  'cloud_firestore',
  'firebase_storage',
  'cloud_functions',
  'firebase_database',
  'firebase_messaging',
  'firebase_crashlytics',
  'firebase_performance',
  'firebase_remote_config',
  'firebase_analytics',
  'firebase_dynamic_links',
  'firebase_in_app_messaging',
  'firebase_app_check',
  'firebase_app_installations',
  'firebase_ml_model_downloader',
];

const jsonEncoder = JsonEncoder.withIndent('    ');

void main(List<String> arguments) async {
  final suggestedVersion = await getBoMNextVersion();
  if (suggestedVersion == null) {
    print('No changes detected');
    return;
  }
  stdout.write('New BoM version number ($suggestedVersion): ');
  final readData = stdin.readLineSync()?.trim() ?? '';
  String version = readData.isEmpty ? suggestedVersion : readData;
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Fetch native versions
  String androidSdkVersion = await getSdkVersion(
    androidVersionFile,
    'FirebaseSDKVersion=(.+)',
  );

  String iosSdkVersion = await getSdkVersion(
    iosVersionFile,
    r"def firebase_sdk_version!\(\)\s*'(.+)'",
  );

  String webSdkVersion = await getSdkVersion(
    webVersionFile,
    "const String supportedFirebaseJsSdkVersion = '(.+)'",
  );

  String windowsSdkVersion = await getSdkVersion(
    windowsVersionFile,
    r'set\(FIREBASE_SDK_VERSION "(.+)"\)',
  );

  // Read current versions JSON file
  File currentVersionsJson = File(versionsJsonFile);
  Map<String, dynamic> currentVersions =
      jsonDecode(currentVersionsJson.readAsStringSync());

  // Create JSON data
  Map<String, Map<String, Object>> jsonData = <String, Map<String, Object>>{
    version: {
      'date': date,
      'firebase_sdk': {
        'android': androidSdkVersion,
        'ios': iosSdkVersion,
        'web': webSdkVersion,
        'windows': windowsSdkVersion,
      },
      'packages': <String, String>{},
    },
  };

  for (final package in packages) {
    String packageVersion = getPluginVersion(package);
    (jsonData[version]!['packages']! as Map)[package] = packageVersion;
  }

  // Write JSON to file
  File versionsJson = File(versionsJsonFile);
  versionsJson.writeAsStringSync(
    jsonEncoder.convert({
      ...jsonData,
      ...currentVersions,
    }),
  );

  print('JSON version data has been successfully written to $versionsJsonFile');

  // Append static text part to beginning of the document
  await appendStaticText(
    version,
    date,
    androidSdkVersion,
    iosSdkVersion,
    webSdkVersion,
    windowsSdkVersion,
    packages,
  );

  print('Version $version has been generated successfully!');

  // Commit the files and create an annotated tag and a commit
  Process.runSync('git', ['add', versionsFile, versionsJsonFile]);
  Process.runSync(
    'git',
    ['tag', '-a', 'BoM-v$version', '-m', 'BoM Version $version'],
  );
  Process.runSync('git', ['commit', '-m', 'chore: BoM Version $version']);
}

Future<String> getSdkVersion(
  String versionFile,
  String pattern,
) async {
  RegExp regex = RegExp(pattern);
  String fileContents = await File(versionFile).readAsString();
  Match? match = regex.firstMatch(fileContents);
  return match?.group(1)?.trim() ?? 'Version not found';
}

String getPluginVersion(String package) {
  String filePath = '$packagesDir/$package/$package/pubspec.yaml';
  pubspec.Pubspec pubspecFile = pubspec.Pubspec.parse(
    File(filePath).readAsStringSync(),
  );
  return pubspecFile.version.toString();
}

Future<void> appendStaticText(
  String? version,
  String date,
  String androidSdkVersion,
  String iosSdkVersion,
  String webSdkVersion,
  String windowsSdkVersion,
  List<String> packages,
) async {
  File currentContent = File(versionsFile);
  String content = currentContent.readAsStringSync();

  // Removing previous header
  String pattern =
      '# FlutterFire Compatible Versions\r?\n\r?\nThis document is listing all the compatible versions of the FlutterFire plugins. This document is updated whenever a new version of the FlutterFire plugins is released.\r?\n\r?\n# Versions';
  content = content.replaceAll(RegExp(pattern), '');

  // Opening the file in append mode
  IOSink sink = File(versionsFile).openWrite();

  // Writing static text and version information
  sink.writeln('# FlutterFire Compatible Versions');
  sink.writeln();
  sink.writeln(
    'This document is listing all the compatible versions of the FlutterFire plugins. This document is updated whenever a new version of the FlutterFire plugins is released.',
  );
  sink.writeln();
  sink.writeln('# Versions');
  sink.writeln();
  sink.writeln(
    '## [Flutter BoM $version ($date)](https://github.com/firebase/flutterfire/blob/master/CHANGELOG.md#$date)',
  );
  sink.writeln();
  sink.writeln('<!--- When ready can be included');
  sink.writeln('Install this version using FlutterFire CLI');
  sink.writeln();
  sink.writeln('```bash');
  sink.writeln('flutterfire install $version');
  sink.writeln('```');
  sink.writeln('-->');
  sink.writeln();
  sink.writeln('### Included Native Firebase SDK Versions');
  sink.writeln('| Firebase SDK | Version | Link |');
  sink.writeln('|--------------|---------|------|');
  sink.writeln(
    '| Android SDK | $androidSdkVersion | [Release Notes](https://firebase.google.com/support/release-notes/android) |',
  );
  sink.writeln(
    '| iOS SDK | $iosSdkVersion | [Release Notes](https://firebase.google.com/support/release-notes/ios) |',
  );
  sink.writeln(
    '| Web SDK | $webSdkVersion | [Release Notes](https://firebase.google.com/support/release-notes/js) |',
  );
  sink.writeln(
    '| Windows SDK | $windowsSdkVersion | [Release Notes](https://firebase.google.com/support/release-notes/cpp-relnotes) |',
  );
  sink.writeln();
  sink.writeln('### FlutterFire Plugin Versions');
  sink.writeln('| Plugin | Version |');
  sink.writeln('|--------|---------|');

  // Adding rows for each package
  for (final package in packages) {
    String packageVersion = getPluginVersion(package);
    sink.writeln(
      '| [$package](https://pub.dev/packages/$package/versions/$packageVersion) | $packageVersion |',
    );
  }

  // Write the rest of the content
  sink.write(content);

  // Closing the sink to flush all data to the file
  await sink.flush();
  await sink.close();
}
