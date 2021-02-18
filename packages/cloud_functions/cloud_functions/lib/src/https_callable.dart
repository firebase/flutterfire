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
    assert(_debugIsValidParameterType(parameters));
    return HttpsCallableResult<T>._(await delegate.call(parameters));
  }
}

/// Whether a given call parameter is a valid type.
bool _debugIsValidParameterType(dynamic parameter, [bool isRoot = true]) {
  if (parameter is List) {
    for (final element in parameter) {
      if (!_debugIsValidParameterType(element, false)) {
        return false;
      }
    }
    return true;
  }

  if (parameter is Map) {
    for (final key in parameter.keys) {
      if (key is! String) {
        return false;
      }
    }
    for (final value in parameter.values) {
      if (!_debugIsValidParameterType(value, false)) {
        return false;
      }
    }
    return true;
  }

  return parameter == null ||
      parameter is String ||
      parameter is num ||
      parameter is bool;
}
