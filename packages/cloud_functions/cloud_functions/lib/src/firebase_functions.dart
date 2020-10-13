// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_functions;

/// The entry point for accessing FirebaseFunctions.
///
/// You can get an instance by calling [FirebaseFunctions.instance].
class FirebaseFunctions extends FirebasePluginPlatform {
  // Cached and lazily loaded instance of [FirebaseFunctionsPlatform] to avoid
  // creating a [MethodChannelFirebaseFunctions] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseFunctionsPlatform _delegatePackingProperty;

  FirebaseFunctionsPlatform get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty =
          FirebaseFunctionsPlatform.instanceFor(app: app, region: _region);
    }
    return _delegatePackingProperty;
  }

  /// The [FirebaseApp] for this current [FirebaseFunctions] instance.
  final FirebaseApp app;

  FirebaseFunctions._({this.app, String region})
      : _region = region ??= 'us-central1',
        super(app.name, 'plugins.flutter.io/firebase_functions');

  static final Map<String, FirebaseFunctions> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp] and region.
  static FirebaseFunctions get instance {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp] & region.
  static FirebaseFunctions instanceFor({FirebaseApp app, String region}) {
    app ??= Firebase.app();
    region ??= 'us-central1';
    String cachedKey = '${app.name}_$region';

    if (_cachedInstances.containsKey(cachedKey)) {
      return _cachedInstances[cachedKey];
    }

    FirebaseFunctions newInstance =
        FirebaseFunctions._(app: app, region: region);
    _cachedInstances[cachedKey] = newInstance;

    return newInstance;
  }

  // ignore: public_member_api_docs
  @Deprecated(
      "Constructing CloudFunctions is deprecated, use 'FirebaseFunctions.instance' or 'FirebaseFunctions.instanceFor' instead")
  factory FirebaseFunctions({FirebaseApp app, String region}) {
    return FirebaseFunctions.instanceFor(app: app, region: region);
  }

  final String _region;

  String _origin;

  /// A reference to the Callable HTTPS trigger with the given name.
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions options}) {
    assert(name != null);
    assert(name.isNotEmpty);
    options ??= HttpsCallableOptions();
    return HttpsCallable._(_delegate.httpsCallable(_origin, name, options));
  }

  @Deprecated("Deprecated in favor of httpsCallable()")
  // ignore: public_member_api_docs
  HttpsCallable getHttpsCallable({@required String functionName}) {
    return httpsCallable(functionName);
  }

  /// Changes this instance to point to a Cloud Functions emulator running locally.
  ///
  /// Set the [origin] of the local emulator, such as "http://localhost:5001", or `null`
  /// to remove.
  void useFunctionsEmulator({@required String origin}) {
    if (origin != null) {
      assert(origin.isNotEmpty);

      // Android considers localhost as 10.0.2.2 - automatically handle this for users.
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (origin.startsWith('http://localhost')) {
          origin = origin.replaceFirst('http://localhost', 'http://10.0.2.2');
        } else if (origin.startsWith('http://127.0.0.1')) {
          origin = origin.replaceFirst('http://127.0.0.1', 'http://10.0.2.2');
        }
      }
    }

    _origin = origin;
  }
}

@Deprecated("Deprecated in favor of FirebaseFunctions")
// ignore: public_member_api_docs
class CloudFunctions extends FirebaseFunctions {
  /// Returns an instance using the default [FirebaseApp].
  static FirebaseFunctions get instance {
    return FirebaseFunctions.instanceFor(
      app: Firebase.app(),
    );
  }

  // ignore: public_member_api_docs
  @Deprecated(
      "Constructing CloudFunctions is deprecated, use 'FirebaseFunctions.instance' or 'FirebaseFunctions.instanceFor' instead")
  factory CloudFunctions({FirebaseApp app, String region}) {
    return FirebaseFunctions.instanceFor(app: app, region: region);
  }
}
