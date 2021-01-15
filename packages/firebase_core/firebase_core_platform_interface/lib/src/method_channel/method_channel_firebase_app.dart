// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_core_platform_interface;

/// The entry point for accessing a Firebase app instance.
///
/// To get an instance, call the `app` method on the [FirebaseCore]
/// instance, for example:
///
/// ```dart
/// Firebase.app('SecondaryApp`);
/// ```
class MethodChannelFirebaseApp extends FirebaseAppPlatform {
  // ignore: public_member_api_docs
  MethodChannelFirebaseApp(
    String name,
    FirebaseOptions options, {
    isAutomaticDataCollectionEnabled,
  })  : _isAutomaticDataCollectionEnabled =
            isAutomaticDataCollectionEnabled ?? false,
        super(name, options);

  /// Keeps track of whether this app has been deleted by the user.
  bool _isDeleted = false;

  bool _isAutomaticDataCollectionEnabled;

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

    await MethodChannelFirebase.channel.invokeMethod<void>(
      'FirebaseApp#delete',
      <String, dynamic>{'appName': name, 'options': options.asMap},
    );

    MethodChannelFirebase.appInstances.remove(name);
    FirebasePluginPlatform._constantsForPluginApps.remove(name);
    _isDeleted = true;
  }

  /// Sets whether automatic data collection is enabled or disabled.
  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    await MethodChannelFirebase.channel.invokeMethod<void>(
      'FirebaseApp#setAutomaticDataCollectionEnabled',
      <String, dynamic>{'appName': name, 'enabled': enabled},
    );

    _isAutomaticDataCollectionEnabled = enabled;
  }

  /// Sets whether automatic resource management is enabled or disabled.
  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {
    await MethodChannelFirebase.channel.invokeMethod<void>(
      'FirebaseApp#setAutomaticResourceManagementEnabled',
      <String, dynamic>{'appName': name, 'enabled': enabled},
    );
  }
}
