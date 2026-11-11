// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../../firebase_core_platform_interface.dart';

/// The entry point for accessing a Firebase app instance.
///
/// To get an instance, call the `app` method on the [FirebaseCore]
/// instance, for example:
///
/// ```dart
/// Firebase.app('SecondaryApp');
/// ```
class MethodChannelFirebaseApp extends FirebaseAppPlatform {
  // ignore: public_member_api_docs
  MethodChannelFirebaseApp(
    String name,
    FirebaseOptions options, {
    bool? isAutomaticDataCollectionEnabled,
  }) : _isAutomaticDataCollectionEnabled =
           isAutomaticDataCollectionEnabled ?? false,
       super(name, options);

  /// Keeps track of whether this app has been deleted by the user.
  bool _isDeleted = false;

  bool _isAutomaticDataCollectionEnabled;

  final _api = FirebaseAppHostApi();

  final _tokenApi = FirebaseTokenHostApi();

  /// Returns whether automatic data collection enabled or disabled.
  @override
  bool get isAutomaticDataCollectionEnabled {
    return _isAutomaticDataCollectionEnabled;
  }

  /// Deletes the current Firebase app instance.
  ///
  /// The default app cannot be deleted.
  @override
  Future<void> delete() async {
    if (_isDefault) {
      throw noDefaultAppDelete();
    }

    if (_isDeleted) {
      return;
    }

    await _api.delete(name);

    MethodChannelFirebase.appInstances.remove(name);
    FirebasePlugin._constantsForPluginApps.remove(name);
    _isDeleted = true;
  }

  /// Sets whether automatic data collection is enabled or disabled.
  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    await _api.setAutomaticDataCollectionEnabled(name, enabled);

    _isAutomaticDataCollectionEnabled = enabled;
  }

  /// Sets whether automatic resource management is enabled or disabled.
  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {
    await _api.setAutomaticResourceManagementEnabled(name, enabled);
  }

  @override
  Future<String?> getAuthIdToken() {
    return _guardTokenCall(() => _tokenApi.getAuthIdToken(name));
  }

  @override
  Future<AppCheckInteropToken?> getAppCheckToken({
    bool limitedUse = false,
  }) async {
    final result = await _guardTokenCall(
      () => _tokenApi.getAppCheckToken(name, limitedUse),
    );
    if (result == null) {
      return null;
    }
    return AppCheckInteropToken(token: result.token, error: result.error);
  }

  @override
  Future<String?> getMessagingToken() {
    return _guardTokenCall(() => _tokenApi.getMessagingToken(name));
  }

  /// Surfaces a failure reported by the native plugin as a [FirebaseException]
  /// for plugin `core`, keeping the code and message native chose.
  ///
  /// Answers `null` on Windows, whose plugin has no token lookup yet: from
  /// core's point of view nothing is linked there, and the contract's answer
  /// for that is `null`, not the channel error an unregistered API would give.
  Future<T?> _guardTokenCall<T>(Future<T?> Function() call) async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return null;
    }
    try {
      return await call();
    } on PlatformException catch (exception, stackTrace) {
      throw FirebaseException(
        plugin: 'core',
        code: exception.code,
        message: exception.message,
        stackTrace: stackTrace,
      );
    }
  }
}
