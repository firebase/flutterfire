// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of cloud_functions_platform_interface;

class CloudFunctionsException implements Exception {
  CloudFunctionsException._(this.code, this.message, this.details);

  final String code;
  final String message;
  final dynamic details;
}

class MethodChannelCloudFunctions extends CloudFunctionsPlatform {
  MethodChannelCloudFunctions({FirebaseApp app, String region})
      : _app = app ?? FirebaseApp.instance,
        _region = region;

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_functions',
  );

  final FirebaseApp _app;

  final String _region;

  String _origin;

  /// Gets an instance of a Callable HTTPS trigger in Cloud Functions.
  ///
  /// Can then be executed by calling `call()` on it.
  ///
  /// @param functionName The name of the callable function.
  HttpsCallable getHttpsCallable({@required String functionName}) {
    return MethodChannelHttpsCallable._(this, functionName);
  }

  /// Changes this instance to point to a Cloud Functions emulator running locally.
  ///
  /// @param origin The origin of the local emulator, such as "//10.0.2.2:5005".
  CloudFunctionsPlatform useFunctionsEmulator({@required String origin}) {
    _origin = origin;
    return this;
  }
}

/// MethodChannel implementation of [HttpsCallable].
//
/// You can get an instance by calling [CloudFunctionsPlatform.instance.getHttpsCallable].
class MethodChannelHttpsCallable extends HttpsCallable {
  MethodChannelHttpsCallable._(this._cloudFunctions, this._functionName);

  final MethodChannelCloudFunctions _cloudFunctions;
  final String _functionName;

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
  Future<HttpsCallableResult> call([dynamic parameters]) async {
    try {
      final MethodChannel channel = MethodChannelCloudFunctions.channel;
      final dynamic response = await channel
          .invokeMethod<dynamic>('CloudFunctions#call', <String, dynamic>{
        'app': _cloudFunctions._app.name,
        'region': _cloudFunctions._region,
        'origin': _cloudFunctions._origin,
        'timeoutMicroseconds': timeout?.inMicroseconds,
        'functionName': _functionName,
        'parameters': parameters,
      });
      return HttpsCallableResult(response);
    } on PlatformException catch (e) {
      if (e.code == 'functionsError') {
        final String code = e.details['code'];
        final String message = e.details['message'];
        final dynamic details = e.details['details'];
        throw CloudFunctionsException._(code, message, details);
      } else {
        throw Exception('Unable to call function ' + _functionName);
      }
    } catch (e) {
      rethrow;
    }
  }
}
