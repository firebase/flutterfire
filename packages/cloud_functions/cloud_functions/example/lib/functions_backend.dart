// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

/// One response of a streaming call, from either implementation.
///
/// `cloud_functions` can't build its own `Result` outside the plugin, so both
/// backends map their responses to these.
sealed class StreamEvent {}

/// A chunk the function sent while running.
class StreamChunk extends StreamEvent {
  StreamChunk(this.data);

  final Object? data;
}

/// The value the function returned, which ends the stream.
class StreamResult extends StreamEvent {
  StreamResult(this.data);

  final Object? data;
}

/// The implementations the example can switch between at runtime.
enum FunctionsImplementation {
  /// The native `cloud_functions` plugin.
  native('Native'),

  /// The pure-Dart `dart_cloud_functions` package.
  dart('Dart');

  const FunctionsImplementation(this.label);

  /// A short name for the implementation, shown in the UI.
  final String label;

  /// A backend that calls [app]'s functions with this implementation.
  FunctionsBackend backendFor(FirebaseApp app) => switch (this) {
    native => NativeFunctionsBackend(app),
    dart => DartFunctionsBackend(app),
  };
}

/// The calls this example makes, so the UI can switch at runtime between the
/// native `cloud_functions` plugin and the pure-Dart `dart_cloud_functions`
/// package.
abstract interface class FunctionsBackend {
  /// Calls the function called [name] and returns its data.
  Future<Object?> callByName(String name, {required Duration timeout});

  /// Calls the function at [url] and returns its data.
  Future<Object?> callByUrl(String url, {required Duration timeout});

  /// Streams the function called [name]: its chunks, then its result.
  Stream<StreamEvent> streamByName(String name);
}

/// Calls [app]'s functions through the native `cloud_functions` plugin.
class NativeFunctionsBackend implements FunctionsBackend {
  NativeFunctionsBackend(this.app);

  /// The app whose functions this backend calls.
  final FirebaseApp app;

  FirebaseFunctions get _functions => FirebaseFunctions.instanceFor(app: app);

  @override
  Future<Object?> callByName(String name, {required Duration timeout}) async {
    final callable = _functions.httpsCallable(
      name,
      options: HttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Future<Object?> callByUrl(String url, {required Duration timeout}) async {
    final callable = _functions.httpsCallableFromUrl(
      url,
      options: HttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Stream<StreamEvent> streamByName(String name) {
    return _functions
        .httpsCallable(name)
        .stream<Object?, Object?>()
        .map(
          (response) => switch (response) {
            Chunk(:final partialData) => StreamChunk(partialData),
            Result(:final result) => StreamResult(result.data),
          },
        );
  }
}

/// Calls [app]'s functions through the pure-Dart `dart_cloud_functions`
/// package.
class DartFunctionsBackend implements FunctionsBackend {
  DartFunctionsBackend(this.app);

  /// The app whose functions this backend calls.
  final FirebaseApp app;

  DartFirebaseFunctions get _functions =>
      DartFirebaseFunctions.instanceFor(app: app);

  @override
  Future<Object?> callByName(String name, {required Duration timeout}) async {
    final callable = _functions.httpsCallable(
      name,
      options: DartHttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Future<Object?> callByUrl(String url, {required Duration timeout}) async {
    final callable = _functions.httpsCallableFromUrl(
      url,
      options: DartHttpsCallableOptions(timeout: timeout),
    );
    return (await callable.call<Object?>()).data;
  }

  @override
  Stream<StreamEvent> streamByName(String name) {
    return _functions
        .httpsCallable(name)
        .stream<Object?, Object?>()
        .map(
          (response) => switch (response) {
            DartChunk(:final partialData) => StreamChunk(partialData),
            DartResult(:final result) => StreamResult(result.data),
          },
        );
  }
}
