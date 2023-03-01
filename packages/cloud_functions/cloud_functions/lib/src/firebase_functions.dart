// ignore_for_file: require_trailing_commas
// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_functions;

/// The entry point for accessing FirebaseFunctions.
///
/// You can get an instance by calling [FirebaseFunctions.instance].
class FirebaseFunctions extends FirebasePluginPlatform {
  FirebaseFunctions._({required this.app, String? region})
      : _region = region ??= 'us-central1',
        super(app.name, 'plugins.flutter.io/firebase_functions');

  // Cached and lazily loaded instance of [FirebaseFunctionsPlatform] to avoid
  // creating a [MethodChannelFirebaseFunctions] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseFunctionsPlatform? _delegatePackingProperty;

  /// Returns the underlying [FirebaseFunctionsPlatform] delegate for this
  /// [FirebaseFunctions] instance. This is useful for testing purposes only.
  @visibleForTesting
  FirebaseFunctionsPlatform get delegate {
    return _delegatePackingProperty ??=
        FirebaseFunctionsPlatform.instanceFor(app: app, region: _region);
  }

  /// The [FirebaseApp] for this current [FirebaseFunctions] instance.
  final FirebaseApp app;

  static final Map<String, FirebaseFunctions> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp] and region.
  static FirebaseFunctions get instance {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp] & region.
  static FirebaseFunctions instanceFor({FirebaseApp? app, String? region}) {
    app ??= Firebase.app();
    region ??= 'us-central1';
    String cachedKey = '${app.name}_$region';

    if (_cachedInstances.containsKey(cachedKey)) {
      return _cachedInstances[cachedKey]!;
    }

    FirebaseFunctions newInstance =
        FirebaseFunctions._(app: app, region: region);
    _cachedInstances[cachedKey] = newInstance;

    return newInstance;
  }

  final String _region;

  String? _origin;

  /// A reference to the Callable HTTPS trigger with the given name.
  ///
  /// Should be the name of the Callable function in Firebase
  /// or the URI of the 2nd gen Callable function in Firebase.
  HttpsCallable httpsCallable(
    Object nameOrUri, {
    HttpsCallableOptions? options,
  }) {
    assert(nameOrUri is String || nameOrUri is Uri);
    assert(nameOrUri is Uri || (nameOrUri as String).isNotEmpty);
    options ??= HttpsCallableOptions();
    if (nameOrUri is String) {
      return HttpsCallable._(
          delegate.httpsCallable(_origin, nameOrUri, options));
    } else if (nameOrUri is Uri) {
      return HttpsCallable._(
          delegate.httpsCallableWithUri(_origin, nameOrUri, options));
    }
    throw ArgumentError.value(nameOrUri, 'nameOrUri must be a String or Uri');
  }

  /// Changes this instance to point to a Cloud Functions emulator running locally.
  ///
  /// Set the [host] of the local emulator, such as "localhost"
  /// Set the [port] of the local emulator, such as "5001" (port 5001 is default for functions package)
  void useFunctionsEmulator(String host, int port) {
    String mappedHost = host;
    // Android considers localhost as 10.0.2.2 - automatically handle this for users.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (mappedHost == 'localhost' || mappedHost == '127.0.0.1') {
        // ignore: avoid_print
        print('Mapping Functions Emulator host "$mappedHost" to "10.0.2.2".');
        mappedHost = '10.0.2.2';
      }
    }

    _origin = 'http://$mappedHost:$port';
  }
}
