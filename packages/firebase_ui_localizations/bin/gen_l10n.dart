// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

late String cwd;
late Directory outDir;

void main() async {
  cwd = Directory.current.path;
  final l10nSrc = Directory(path.join(cwd, 'lib', 'l10n'));
  outDir = Directory(path.join(cwd, 'lib', 'src'));

  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final readFutures = await l10nSrc.list().map((event) {
    final file = File(event.path);
    return file.openRead().transform(const Utf8Decoder()).toList();
  }).toList();

  final sources = await Future.wait(readFutures);

  final labelsByLocale = sources.fold<Map<String, dynamic>>({}, (acc, lines) {
    final fullSrc = lines.join();
    final arbJson = jsonDecode(fullSrc);
    final localeString = arbJson['@@locale'];

    final parsed = localeString.split('_');

    return {
      ...acc,
      parsed[0]: {
        ...(acc[parsed[0]] ?? {}),
        if (parsed.length > 1) parsed[1]: arbJson else 'default': arbJson,
      }
    };
  });

  final genOps = labelsByLocale.entries.map((entry) {
    if (entry.value.length == 1) {
      return [
        generateLocalizationsClass(
          locale: entry.key,
          arb: entry.value['default'],
        )
      ];
    }

    return [
      generateLocalizationsClass(
        locale: entry.key,
        arb: entry.value['default'],
      ),
      ...entry.value.entries
          .where((element) => element.key != 'default')
          .map((e) {
        return generateLocalizationsClass(
          locale: entry.key,
          countryCode: e.key,
          arb: e.value,
        );
      }).toList(),
    ];
  }).expand((element) => element);

  await Future.wait([...genOps.cast<Future>()]);
  await generateLanguagesList(labelsByLocale);
  Process.runSync('dart', ['format', outDir.path]);
}

bool isLabelEntry(MapEntry<String, dynamic> entry) {
  return !entry.key.startsWith('@');
}

String dartFilename(String locale, [String? countryCode]) {
  return '$locale'
      '${countryCode != null ? '_${countryCode.toLowerCase()}' : ''}'
      '.dart';
}

String dartClassName(String locale, [String? countryCode]) {
  return '${locale.capitalize()}'
      '${countryCode?.capitalize() ?? ''}Localizations';
}

Future<void> generateLocalizationsClass({
  required String locale,
  required Map<String, dynamic> arb,
  String? countryCode,
}) async {
  final filename = dartFilename(locale, countryCode);
  final outFile = File(path.join(outDir.path, 'lang', filename));

  if (!outFile.existsSync()) {
    outFile.createSync(recursive: true);
  }

  final out = outFile.openWrite();

  out.writeln("import '../default_localizations.dart';");

  final labels = arb.entries.where(isLabelEntry).map((e) {
    final meta = arb['@${e.key}'] ?? {};

    return Label(
      key: e.key,
      translation: e.value,
      description: meta['description'],
    );
  }).toList();

  out.writeln();

  final className = dartClassName(locale, countryCode);

  out.writeln('class $className extends FirebaseUILocalizationLabels {');
  out.writeln('  const $className();');

  for (var label in labels) {
    final escapedTranslation = jsonEncode(label.translation);

    out.writeln();
    out.writeln('  @override');
    out.writeln('  String get ${label.key} => $escapedTranslation;');
  }

  out.writeln('}');

  await out.flush();
  await out.close();
}

Future<void> generateLanguagesList(Map<String, dynamic> arb) async {
  final outFile = File(path.join(outDir.path, 'all_languages.dart'));

  if (!outFile.existsSync()) {
    outFile.createSync(recursive: true);
  }

  final out = outFile.openWrite();
  out.writeln('import "./default_localizations.dart";');
  out.writeln();

  for (var entry in arb.entries) {
    final locale = entry.key;
    final countryCodes = entry.value.keys.where((e) => e != 'default').toList();

    final filename = dartFilename(locale);
    out.writeln("import 'lang/$filename';");

    for (var countryCode in countryCodes) {
      out.writeln("import 'lang/${dartFilename(locale, countryCode)}';");
    }
  }

  out.writeln();
  out.writeln('final localizations = <String, FirebaseUILocalizationLabels>{');

  for (var entry in arb.entries) {
    final locale = entry.key;
    final countryCodes = entry.value.keys.where((e) => e != 'default').toList();

    out.writeln("  '$locale': const ${dartClassName(locale)}(),");

    for (var countryCode in countryCodes) {
      final key = '${locale}_${countryCode.toLowerCase()}';
      out.writeln("  '$key': const ${dartClassName(locale, countryCode)}(),");
    }
  }

  out.writeln('};');

  await out.flush();
  await out.close();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class Label {
  final String key;
  final String translation;
  final String? description;

  Label({
    required this.key,
    required this.translation,
    this.description,
  });
}
