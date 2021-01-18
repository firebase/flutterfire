// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_functions;

/// A reference to a particular Callable HTTPS trigger in Cloud Functions.
///
/// You can get an instance by calling [FirebaseFunctions.instance.httpsCallable].
class HttpsCallable {
  HttpsCallable._(this.delegate);

  /// Returns the underlying [HttpsCallablePlatform] delegate for this
  /// [HttpsCallable] instance. This is useful for testing purposes only.
  @visibleForTesting
  final HttpsCallablePlatform delegate;

  /// Executes this Callable HTTPS trigger asynchronously.
  ///
  /// The data passed into the trigger can be any of the following types:
  ///
  /// `null`
  /// `String`
  /// `num`
  /// [List], where the contained objects are also one of these types.
  /// [Map], where the values are also one of these types.
  ///
  /// The request to the Cloud Functions backend made by this method
  /// automatically includes a Firebase Instance ID token to identify the app
  /// instance. If a user is logged in with Firebase Auth, an auth ID token for
  /// the user is also automatically included.
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    _assertValidParameterType(parameters);
    return HttpsCallableResult<T>._(await delegate.call(parameters));
  }
}

/// Asserts whether a given call parameter is a valid type.
void _assertValidParameterType(dynamic parameter, [bool isRoot = true]) {
  if (parameter is List) {
    for (final element in parameter) {
      _assertValidParameterType(element, false);
    }
    return;
  }

  if (parameter is Map) {
    for (final key in parameter.keys) {
      assert(key is String);
    }
    for (final value in parameter.values) {
      _assertValidParameterType(value, false);
    }
    return;
  }

  assert(parameter == null ||
      parameter is String ||
      parameter is num ||
      parameter is bool);
}
