// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of cloud_functions_platform_interface;

/// A reference to a particular Callable HTTPS trigger in Cloud Functions.
///
/// You can get an instance by calling [CloudFunctionsPlatform.instance.getHTTPSCallable].
abstract class HttpsCallable {
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
  Future<HttpsCallableResult> call([dynamic parameters]);

  /// The timeout to use when calling the function.
  Duration timeout;
}
