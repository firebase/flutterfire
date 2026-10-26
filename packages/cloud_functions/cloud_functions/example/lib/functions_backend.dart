// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_cloud_functions/dart_cloud_functions.dart';

/// The calls this example makes, so the UI can switch at runtime between the
/// native `cloud_functions` plugin and the pure-Dart `dart_cloud_functions`
/// package.
abstract interface class FunctionsBackend {
  /// A short name for the implementation, shown in the UI.
  String get label;

  /// Calls the function called [name] and returns its data.
  Future<Object?> callByName(String name, {required Duration timeout});

  /// Calls the function at [url] and returns its data.
  Future<Object?> callByUrl(String url, {required Duration timeout});

  /// Streams the function called [name].
  Stream<StreamResponse<String, List<dynamic>>> streamByName(String name);
}

/// Calls functions through the native `cloud_functions` plugin.
class NativeFunctionsBackend implements FunctionsBackend {
  @override
  String get label => 'Native';

  @override
  Future<Object?> callByName(String name, {required Duration timeout}) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      name,
      options: HttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Future<Object?> callByUrl(String url, {required Duration timeout}) async {
    final callable = FirebaseFunctions.instance.httpsCallableFromUrl(
      url,
      options: HttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Stream<StreamResponse<String, List<dynamic>>> streamByName(String name) {
    return FirebaseFunctions.instance
        .httpsCallable(name)
        .stream<String, List<dynamic>>();
  }
}

/// Calls functions through the pure-Dart `dart_cloud_functions` package.
class DartFunctionsBackend implements FunctionsBackend {
  @override
  String get label => 'Dart';

  @override
  Future<Object?> callByName(String name, {required Duration timeout}) async {
    final callable = DartFirebaseFunctions.instance.httpsCallable(
      name,
      options: DartHttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Future<Object?> callByUrl(String url, {required Duration timeout}) async {
    final callable = DartFirebaseFunctions.instance.httpsCallableFromUrl(
      url,
      options: DartHttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Stream<StreamResponse<String, List<dynamic>>> streamByName(String name) {
    return Stream.error(
      UnsupportedError('dart_cloud_functions does not support streaming yet.'),
    );
  }
}
