// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_functions.dart';

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

    Object? updatedParameters;
    if (parameters is Map) {
      Map update = {};
      parameters.forEach((key, value) {
        update[key] = _updateRawDataToList(value);
      });
      updatedParameters = update;
    } else if (parameters is List) {
      List update = parameters.map(_updateRawDataToList).toList();
      updatedParameters = update;
    } else {
      updatedParameters = _updateRawDataToList(parameters);
    }
    return HttpsCallableResult<T>._(await delegate.call(updatedParameters));
  }

  /// Streams data to the specified HTTPS endpoint.
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
  Stream<StreamResponse<T, R>> stream<T, R>([Object? input]) async* {
    await for (final value in delegate.stream(input).asBroadcastStream()) {
      if (value is Map) {
        if (value.containsKey('message')) {
          yield Chunk<T, R>(value['message'] as T);
        } else if (value.containsKey('result')) {
          yield Result<T, R>(HttpsCallableResult._(value['result'] as R));
        }
      }
    }
  }
}

dynamic _updateRawDataToList(dynamic value) {
  if (value is Uint8List ||
      value is Int32List ||
      value is Int64List ||
      value is Float32List ||
      value is Float64List) {
    return value.toList();
  } else {
    return value;
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
