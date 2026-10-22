// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_print

/// Fails if a public library of a published package reaches a `dart:`
/// library that is not available on Wasm, through its own imports or its
/// dependencies'. pub.dev withholds the `is:wasm-ready` tag from such packages,
/// even when (as with `dart:io`) dart2wasm still compiles them.
///
/// The walk follows pana's: imports and exports are followed transitively,
/// conditional imports resolve as they would on Wasm, and `package:flutter`
/// is not descended into. pana starts from `lib/<package>.dart` only; this
/// starts from every library in `lib/` outside `lib/src/`, so it is slightly
/// stricter. Run `melos bootstrap` (or `flutter pub get`) first.
library;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// The `dart:` libraries pana allows for its Wasm runtime (`Runtime.wasm` in
/// https://github.com/dart-lang/pana/blob/master/lib/src/tag/_specs.dart).
const _wasmLibraries = {
  'async',
  'collection',
  'convert',
  'core',
  'developer',
  'math',
  'typed_data',
  '_internal',
  'ui',
  'ui_web',
  'js_interop',
  'js_interop_unsafe',
};

/// Known imports that lead to a library not available on Wasm, by importing
/// package. They are not followed; the script fails once one is no longer
/// reached, so that its entry is removed with the fix.
const _knownViolations = {
  // putFile(File) in the public API; also blocks firebase_storage_web.
  'firebase_storage': {'dart:io'},
  'firebase_storage_platform_interface': {'dart:io'},
};

void main() {
  final rootDir =
      p.dirname(p.dirname(p.absolute(Platform.script.toFilePath())));
  final packageConfig =
      File(p.join(rootDir, '.dart_tool', 'package_config.json'));
  if (!packageConfig.existsSync()) {
    print('Error: ${packageConfig.path} not found. Run `melos bootstrap` '
        'first.');
    exitCode = 1;
    return;
  }
  final graph = _ImportGraph(packageConfig);

  var checked = 0;
  final errors = <String>[];

  // Every package in the workspace that is published, examples excluded.
  final packages = <String, String>{};
  for (final path in _loadYamlMap(p.join(rootDir, 'pubspec.yaml'))['workspace']
      as YamlList) {
    if (!'$path'.startsWith('packages/') ||
        p.split('$path').contains('example')) {
      continue;
    }
    final pubspec = _loadYamlMap(p.join(rootDir, '$path', 'pubspec.yaml'));
    if (pubspec['publish_to'] == 'none') continue;
    packages[pubspec['name'] as String] = p.join(rootDir, '$path');
  }

  for (final MapEntry(key: name, value: path) in packages.entries) {
    final libDir = Directory(p.join(path, 'lib'));
    if (!libDir.existsSync()) continue;
    checked++;

    final publicLibraries = libDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => Uri.parse('package:$name/${p.basename(file.path)}'));
    final violations = graph.findViolations(publicLibraries);
    if (violations.isNotEmpty) errors.add('$name:');
    for (final chain in violations) {
      final reason = chain.last.isScheme('dart')
          ? 'is not available on Wasm'
          : 'could not be resolved (run `melos bootstrap`?)';
      errors.add('  ${chain.last} $reason\n      ${chain.join('\n      -> ')}');
    }
  }

  if (checked == 0) {
    errors.add('No packages found in the workspace.');
  }

  print('Checked $checked packages.');
  for (final MapEntry(key: package, value: imports)
      in _knownViolations.entries) {
    for (final import in imports) {
      if (graph.reachedKnownViolations.contains('$package $import')) {
        print('Skipped known import of $import in $package.');
      } else {
        errors.add('$import is no longer reached through $package: remove '
            'it from _knownViolations.');
      }
    }
  }

  if (errors.isNotEmpty) {
    print('');
    errors.forEach(print);
    exitCode = 1;
  }
}

class _ImportGraph {
  _ImportGraph(File packageConfig) {
    final config =
        jsonDecode(packageConfig.readAsStringSync()) as Map<String, dynamic>;
    for (final package in config['packages'] as List) {
      final root = packageConfig.uri.resolve('${package['rootUri']}/');
      _packageRoots[package['name'] as String] =
          root.resolve(package['packageUri'] as String? ?? 'lib/');
    }
  }

  final _packageRoots = <String, Uri>{};
  final _dependencies = <Uri, List<Uri>>{};

  /// `'<package> <import>'` for each [_knownViolations] entry reached.
  final reachedKnownViolations = <String>{};

  /// Returns the import chain to each import reachable from [libraries] that
  /// is a `dart:` library not available on Wasm, or a `package:` URI that
  /// cannot be resolved.
  List<List<Uri>> findViolations(Iterable<Uri> libraries) {
    final parents = <Uri, Uri?>{for (final library in libraries) library: null};
    List<Uri> chainTo(Uri uri) => [
          for (Uri? u = uri; u != null; u = parents[u]) u,
        ].reversed.toList();

    final violations = [
      for (final library in libraries)
        if (!_isResolvable(library)) [library],
    ];
    final queue = Queue.of(libraries.where(_isResolvable));
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final package = current.pathSegments.first;
      for (final dependency in _dependenciesOf(current)) {
        if (_knownViolations[package]?.contains('$dependency') ?? false) {
          reachedKnownViolations.add('$package $dependency');
        } else if (dependency.isScheme('dart')) {
          if (!_wasmLibraries.contains(dependency.path)) {
            violations.add([...chainTo(current), dependency]);
          }
        } else if (dependency.isScheme('package') &&
            !dependency.toString().startsWith('package:flutter/') &&
            !parents.containsKey(dependency)) {
          parents[dependency] = current;
          if (_isResolvable(dependency)) {
            queue.add(dependency);
          } else {
            violations.add(chainTo(dependency));
          }
        }
      }
    }
    return violations;
  }

  bool _isResolvable(Uri library) =>
      _packageRoots.containsKey(library.pathSegments.first);

  List<Uri> _dependenciesOf(Uri library) =>
      _dependencies[library] ??= _parseDependencies(library);

  List<Uri> _parseDependencies(Uri library) {
    final root = _packageRoots[library.pathSegments.first]!;
    final file =
        File.fromUri(root.resolve(library.pathSegments.skip(1).join('/')));
    // Like pana, a missing file inside a resolved package has no imports.
    if (!file.existsSync()) return const [];

    final unit = parseString(
      content: file.readAsStringSync(),
      path: file.path,
      throwIfDiagnostics: false,
    ).unit;
    return [
      for (final directive in unit.directives.whereType<NamespaceDirective>())
        if (_selectUri(directive) case final uri?) library.resolve(uri),
    ];
  }

  /// The URI a directive resolves to on Wasm, where `dart.library.<name>` is
  /// `'true'` for each of [_wasmLibraries] and every other name is `''`.
  String? _selectUri(NamespaceDirective directive) {
    for (final configuration in directive.configurations) {
      final name = configuration.name.toSource();
      final declared = name.startsWith('dart.library.') &&
              _wasmLibraries.contains(name.substring('dart.library.'.length))
          ? 'true'
          : '';
      if (declared == (configuration.value?.stringValue ?? 'true')) {
        return configuration.uri.stringValue;
      }
    }
    return directive.uri.stringValue;
  }
}

YamlMap _loadYamlMap(String path) =>
    loadYaml(File(path).readAsStringSync()) as YamlMap;
