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