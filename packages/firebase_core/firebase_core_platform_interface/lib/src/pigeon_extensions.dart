// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../firebase_core_platform_interface.dart';

/// Converts the Pigeon [CoreFirebaseOptions] to [FirebaseOptions].
///
/// Replaces the `FirebaseOptions.fromPigeon` constructor, which cannot live in
/// `firebase_core_interface` because [CoreFirebaseOptions] is Flutter code.
extension CoreFirebaseOptionsX on CoreFirebaseOptions {
  /// Returns these options as [FirebaseOptions].
  FirebaseOptions toFirebaseOptions() => FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    databaseURL: databaseURL,
    storageBucket: storageBucket,
    measurementId: measurementId,
    // Placeholder to coordinate with the FlutterFire CLI's current operation.
    recaptchaSiteKey: '',
    trackingId: trackingId,
    deepLinkURLScheme: deepLinkURLScheme,
    androidClientId: androidClientId,
    iosClientId: iosClientId,
    iosBundleId: iosBundleId,
    appGroupId: appGroupId,
  );
}
