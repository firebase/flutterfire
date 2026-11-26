// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'app_check_interop_token.dart';
import 'firebase.dart';

/// Hands out the signed-in user's ID token for one [FirebaseApp].
///
/// The package that implements Auth for an app registers one, so that
/// Firebase packages that attach the token to their own requests (as the
/// Functions SDKs do) can ask `app.getService<AuthTokenProvider>()` without
/// depending on that package. `null` from `getService` means no Auth
/// implementation is registered for the app.
///
/// Not for app code: use the Auth package's own API instead.
abstract interface class AuthTokenProvider implements FirebaseService {
  /// The signed-in user's ID token, or `null` when nobody is signed in.
  ///
  /// With [forceRefresh], a fresh token is fetched even when the cached one
  /// is still valid.
  ///
  /// Throws the Auth implementation's exception when it can't produce a
  /// token: a failed ID token is a real error the consumer should surface,
  /// as the native Functions SDKs fail the call (the JS SDK sends it without
  /// the token). The App Check and Messaging providers never throw; the
  /// three contracts differ on purpose, each matching its native shape.
  Future<String?> getIdToken({bool forceRefresh = false});
}

/// Hands out App Check tokens for one [FirebaseApp].
///
/// The package that implements App Check for an app registers one, so that
/// Firebase packages that attach the token to their own requests can ask
/// `app.getService<AppCheckTokenProvider>()` without depending on that
/// package. `null` from `getService` means no App Check implementation is
/// registered for the app.
///
/// Not for app code: use the App Check package's own API instead.
abstract interface class AppCheckTokenProvider implements FirebaseService {
  /// The App Check implementation's answer, or `null` when it has no token to
  /// give.
  ///
  /// Never throws, unlike [AuthTokenProvider.getIdToken]: the native interop
  /// shape is a token plus an optional error. When no token can be produced,
  /// the answer carries [AppCheckInteropToken.placeholderToken] and the
  /// reason in [AppCheckInteropToken.error], exactly as the native interop
  /// APIs report it, so consumers can follow the Functions SDKs (send the
  /// placeholder on Android and Apple, omit the header on web) without each
  /// knowing the placeholder.
  ///
  /// With [limitedUse], the answer is a limited-use token rather than a
  /// cached one.
  Future<AppCheckInteropToken?> getToken({bool limitedUse = false});
}

/// Hands out the FCM registration token for one [FirebaseApp].
///
/// The package that implements Messaging for an app registers one, so that
/// Firebase packages that attach the token to their own requests (as the
/// Functions SDKs do) can ask `app.getService<MessagingTokenProvider>()`
/// without depending on that package. `null` from `getService` means no
/// Messaging implementation is registered for the app.
///
/// Not for app code: use the Messaging package's own API instead.
abstract interface class MessagingTokenProvider implements FirebaseService {
  /// The FCM registration token the Messaging implementation holds, or
  /// `null` when it has none.
  ///
  /// Never prompts for notification permission. On Apple platforms this is a
  /// cached read only; on Android and web it may register a token when none
  /// is stored, as native Functions does. On Android the answer is `null`
  /// when the manifest enables the installation ID
  /// (`firebase_messaging_installation_id_enabled`), as native Functions
  /// does: fetching a legacy token then creates a second registration, and
  /// FCM rejects sends to the installation ID. Never throws, unlike
  /// [AuthTokenProvider.getIdToken]: when the token can't be read the answer
  /// is `null`, as the FCM header is best-effort in the native Functions
  /// SDKs too. Messaging serves the default app only, in FlutterFire as in
  /// native FCM, so the answer is `null` for any other app.
  Future<String?> getFcmToken();
}
