// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// Writes the package-local `.dart_tool/package_config.json` files that
/// `flutter_plugin_tools format` checks before running `flutter pub get`.
///
/// Flutter 3.50 resolves this pub workspace with a single config at the repo
/// root. The formatter still looks inside each package, treats the missing
/// file as a stale language version, and fetches dependencies once per
/// package. On the macOS format runner that exceeds the job timeout.
///
/// The language version written here is the one the workspace resolve already
/// chose. `dart format` uses that version and does not need another fetch.
/// Run this after bootstrap: `flutter pub get` deletes these files as stray
/// workspace configs.
void main() {
  final configFile = File('.dart_tool/package_config.json');
  if (!configFile.existsSync()) {
    stderr.writeln(
      'missing ${configFile.path}; bootstrap the workspace before formatting',
    );
    exit(1);
  }

  final workspace =
      jsonDecode(configFile.readAsStringSync()) as Map<String, Object?>;
  final versions = <String, String>{
    for (final package
        in (workspace['packages']! as List<Object?>)
            .cast<Map<String, Object?>>())
      if (package['languageVersion'] is String)
        package['name']! as String: package['languageVersion']! as String,
  };

  final rootPubspec = loadYaml(File('pubspec.yaml').readAsStringSync());
  final workspaceList = rootPubspec is YamlMap
      ? rootPubspec['workspace']
      : null;
  if (workspaceList is! YamlList || workspaceList.isEmpty) {
    stderr.writeln('root pubspec.yaml has no workspace list');
    exit(1);
  }
  final members = workspaceList.map((Object? member) => member.toString());

  var written = 0;
  for (final member in members) {
    final pubspec = File('$member/pubspec.yaml');
    if (!pubspec.existsSync()) {
      stderr.writeln('missing ${pubspec.path}');
      exit(1);
    }
    final nameMatch = RegExp(
      r'^name:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec.readAsStringSync());
    if (nameMatch == null) {
      stderr.writeln('${pubspec.path} has no package name');
      exit(1);
    }
    final name = nameMatch.group(1)!;
    final version = versions[name];
    if (version == null) {
      stderr.writeln('no resolved language version for $name');
      exit(1);
    }
    final toolDir = Directory('$member/.dart_tool')..createSync();
    File('${toolDir.path}/package_config.json').writeAsStringSync(
      '${jsonEncode(<String, Object?>{
        'configVersion': 2,
        'packages': <Object?>[
          <String, String>{'name': name, 'rootUri': '../', 'packageUri': 'lib/', 'languageVersion': version},
        ],
      })}\n',
    );
    written++;
  }

  stdout.writeln('Primed language versions for $written packages.');
}
