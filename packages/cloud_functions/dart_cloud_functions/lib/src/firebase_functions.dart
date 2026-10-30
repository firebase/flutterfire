// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_cloud_functions/src/client.dart';
import 'package:dart_cloud_functions/src/context.dart';
import 'package:dart_cloud_functions/src/errors.dart';
import 'package:dart_cloud_functions/src/firebase_context.dart';
import 'package:dart_cloud_functions/src/url.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// The entry point for calling callable Cloud Functions from Dart.
///
/// Mirrors `FirebaseFunctions` from `cloud_functions`.
///
/// ```dart
/// final result = await DartFirebaseFunctions.instance
///     .httpsCallable('listFruit')
///     .call();
/// print(result.data);
/// ```
class DartFirebaseFunctions {
  DartFirebaseFunctions._(
    this.app,
    this.region, {
    required CallableContextProvider contextProvider,
    http.Client? httpClient,
  })  : _contextProvider = contextProvider,
        _client = CallableClient(httpClient: httpClient);

  /// Creates an instance that isn't cached, sends requests with [httpClient]
  /// and gets their tokens from [contextProvider].
  @visibleForTesting
  DartFirebaseFunctions.withHttpClient(
    http.Client httpClient, {
    required FirebaseApp app,
    required CallableContextProvider contextProvider,
    String region = _defaultRegion,
  }) : this._(
          app,
          region,
          contextProvider: contextProvider,
          httpClient: httpClient,
        );

  static const _defaultRegion = 'us-central1';
  static final Map<String, DartFirebaseFunctions> _instances = {};

  /// The instance for the default [FirebaseApp] and the `us-central1` region.
  static DartFirebaseFunctions get instance => instanceFor();

  /// The instance for [app] (the default app when omitted) and [region].
  ///
  /// [region] may also be a custom domain such as `https://example.com`, as
  /// in the native SDKs. Calls by name then go to `https://example.com/{name}`.
  ///
  /// Calls carry the ID token of the user signed in to Firebase Auth for
  /// [app], if any.
  static DartFirebaseFunctions instanceFor({
    FirebaseApp? app,
    String region = _defaultRegion,
  }) {
    final resolvedApp = app ?? Firebase.app();
    return _instances.putIfAbsent(
      '${resolvedApp.name}/$region',
      () => DartFirebaseFunctions._(
        resolvedApp,
        region,
        contextProvider: firebaseCallableContext(resolvedApp),
      ),
    );
  }

  /// The app whose Firebase project hosts the functions.
  final FirebaseApp app;

  /// The region the functions are deployed to, such as `us-central1`, or a
  /// custom domain such as `https://example.com`.
  final String region;

  /// Whether tokens, such as the Auth ID token, may be sent over plain HTTP
  /// to a non-loopback host.
  ///
  /// Mirrors `FirebaseFunctions.allowInsecureTokenAttachment` from
  /// `cloud_functions`. Set it before calling a function on a local emulator
  /// from a physical device:
  ///
  /// ```dart
  /// DartFirebaseFunctions.instance
  ///   ..allowInsecureTokenAttachment = true
  ///   ..useFunctionsEmulator('192.168.1.10', 5001);
  /// ```
  ///
  /// Only debug builds honor this value; profile and release builds ignore
  /// it. Unlike in `cloud_functions`, where only Apple platforms check, it
  /// applies on every platform, because this package refuses to send tokens
  /// insecurely on all of them.
  ///
  /// Sending tokens over plain HTTP exposes them on the local network. Enable
  /// this only for a local emulator.
  bool allowInsecureTokenAttachment = false;

  final CallableContextProvider _contextProvider;
  final CallableClient _client;
  String? _emulatorOrigin;

  /// Sends calls by name to the Cloud Functions emulator at [host] and [port].
  ///
  /// On Android, `localhost` and `127.0.0.1` are mapped to `10.0.2.2`, which
  /// is how the Android emulator reaches the host machine, unless
  /// [automaticHostMapping] is false.
  void useFunctionsEmulator(
    String host,
    int port, {
    bool automaticHostMapping = true,
  }) {
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final isLoopback = host == 'localhost' || host == '127.0.0.1';
    final mappedHost =
        automaticHostMapping && isAndroid && isLoopback ? '10.0.2.2' : host;
    _emulatorOrigin = 'http://$mappedHost:$port';
  }

  /// A reference to the callable function called [name].
  DartHttpsCallable httpsCallable(
    String name, {
    DartHttpsCallableOptions options = const DartHttpsCallableOptions(),
  }) {
    return DartHttpsCallable._(this, name: name, options: options);
  }

  /// A reference to the callable function at [url], such as a 2nd gen
  /// function's `*.run.app` URL.
  DartHttpsCallable httpsCallableFromUrl(
    String url, {
    DartHttpsCallableOptions options = const DartHttpsCallableOptions(),
  }) {
    return httpsCallableFromUri(Uri.parse(url), options: options);
  }

  /// A reference to the callable function at [uri].
  DartHttpsCallable httpsCallableFromUri(
    Uri uri, {
    DartHttpsCallableOptions options = const DartHttpsCallableOptions(),
  }) {
    return DartHttpsCallable._(this, uri: uri, options: options);
  }
}

/// Options for a [DartHttpsCallable].
///
/// Mirrors `HttpsCallableOptions` from `cloud_functions`.
@immutable
class DartHttpsCallableOptions {
  /// Creates options for a callable.
  const DartHttpsCallableOptions({
    this.timeout = const Duration(seconds: 60),
    this.limitedUseAppCheckToken = false,
  });

  /// How long a call may take before it fails with `deadline-exceeded`.
  ///
  /// For [DartHttpsCallable.stream], it's how long a stream may go without
  /// data on Android, iOS and macOS. Web streams have no timeout, as in the
  /// JS SDK.
  final Duration timeout;

  /// Whether to send a limited-use App Check token instead of the standard
  /// one, for functions that use App Check replay protection.
  final bool limitedUseAppCheckToken;
}

/// The value a callable function returned.
///
/// Mirrors `HttpsCallableResult` from `cloud_functions`.
class DartHttpsCallableResult<T> {
  DartHttpsCallableResult._(this.data);

  /// The data the function returned.
  ///
  /// JSON objects arrive as `Map<String, dynamic>` and arrays as
  /// `List<dynamic>`.
  final T data;
}

/// A response from [DartHttpsCallable.stream]: a [DartChunk] the function sent
/// along the way, or its final [DartResult].
///
/// Mirrors `StreamResponse` from `cloud_functions`.
sealed class DartStreamResponse<T, R> {}

/// A chunk the function sent while running, with `sendChunk()`.
///
/// Mirrors `Chunk` from `cloud_functions`.
class DartChunk<T, R> extends DartStreamResponse<T, R> {
  /// Creates a chunk with [partialData].
  DartChunk(this.partialData);

  /// The data the function sent.
  final T partialData;
}

/// The value the function returned, the last response of a stream.
///
/// Mirrors `Result` from `cloud_functions`.
class DartResult<T, R> extends DartStreamResponse<T, R> {
  /// Creates the final response of a stream, with [result].
  DartResult(this.result);

  /// The value the function returned.
  final DartHttpsCallableResult<R> result;
}

/// A reference to a callable function.
///
/// Mirrors `HttpsCallable` from `cloud_functions`. Create one with
/// [DartFirebaseFunctions.httpsCallable],
/// [DartFirebaseFunctions.httpsCallableFromUrl] or
/// [DartFirebaseFunctions.httpsCallableFromUri].
class DartHttpsCallable {
  DartHttpsCallable._(
    this._functions, {
    this.name,
    this.uri,
    required this.options,
  });

  final DartFirebaseFunctions _functions;

  /// The function's name, when the callable was created by name.
  final String? name;

  /// The function's URL, when the callable was created from a URL.
  final Uri? uri;

  /// The options used for every call.
  final DartHttpsCallableOptions options;

  /// Calls the function with [data] and returns what it returned.
  ///
  /// [data] must be JSON-encodable: `null`, a `bool`, `num` or `String`, or a
  /// `List` or `String`-keyed `Map` of those. Failures throw a
  /// `DartFirebaseFunctionsException`.
  Future<DartHttpsCallableResult<T>> call<T>([Object? data]) async {
    final (url, context) = await _prepare();
    final result = await _functions._client.callFunction(
      url,
      data,
      context: context,
      timeout: options.timeout,
    );
    return DartHttpsCallableResult<T>._(result as T);
  }

  /// Streams the function with [data]: each [DartChunk] it sends, then its
  /// [DartResult].
  ///
  /// Only 2nd gen functions stream. [data] must be JSON-encodable, as for
  /// [call]. The request starts when the stream is listened to, and
  /// cancelling the subscription aborts it. Failures arrive as
  /// `DartFirebaseFunctionsException` errors. See
  /// [DartHttpsCallableOptions.timeout] for how timeouts work.
  Stream<DartStreamResponse<T, R>> stream<T, R>([Object? data]) async* {
    final (url, context) = await _prepare();
    final events = _functions._client.streamFunction(
      url,
      data,
      context: context,
      // Web streams have no timeout, as in the JS SDK.
      idleTimeout: kIsWeb ? null : options.timeout,
    );
    await for (final event in events) {
      yield event.isResult
          ? DartResult<T, R>(DartHttpsCallableResult<R>._(event.value as R))
          : DartChunk<T, R>(event.value as T);
    }
  }

  /// Resolves the function's URL and gets the tokens for one request,
  /// refusing to send them insecurely.
  Future<(Uri, CallableContext)> _prepare() async {
    final url = callableUrl(
      projectId: _functions.app.options.projectId,
      region: _functions.region,
      name: name,
      uri: uri,
      origin: _functions._emulatorOrigin,
    );
    final context = await _fetchContext();
    checkTokenTransport(
      url,
      context,
      allowInsecure: kDebugMode && _functions.allowInsecureTokenAttachment,
    );
    return (url, context);
  }

  /// Gets the tokens for one request.
  ///
  /// As in the native SDKs, this happens before the timeout starts, and a
  /// failure fails the call.
  Future<CallableContext> _fetchContext() async {
    try {
      return await _functions._contextProvider(
        limitedUseAppCheckToken: options.limitedUseAppCheckToken,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(callableTokenException(error), stackTrace);
    }
  }
}
