// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// Firebase Dynamic Links API.
///
/// You can get an instance by calling [FirebaseDynamicLinks.instance].
@Deprecated(
    'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
    'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
    'https://firebase.google.com/support/dynamic-links-faq')
class FirebaseDynamicLinks extends FirebasePluginPlatform {
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  FirebaseDynamicLinks._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_dynamic_links');

  static final Map<String, FirebaseDynamicLinks> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  static FirebaseDynamicLinks get instance {
    return FirebaseDynamicLinks.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  /// Note; multi-app support is only supported on android.
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  static FirebaseDynamicLinks instanceFor({required FirebaseApp app}) {
    if (defaultTargetPlatform == TargetPlatform.android ||
        app.name == defaultFirebaseAppName) {
      return _cachedInstances.putIfAbsent(app.name, () {
        return FirebaseDynamicLinks._(app: app);
      });
    }

    throw UnsupportedError(
      'FirebaseDynamicLinks.instanceFor() only supports non-default FirebaseApp instances on Android.',
    );
  }

  // Cached and lazily loaded instance of [FirebaseDynamicLinksPlatform] to avoid
  // creating a [MethodChannelFirebaseDynamicLinks] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseDynamicLinksPlatform? _delegatePackingProperty;

  FirebaseDynamicLinksPlatform get _delegate {
    return _delegatePackingProperty ??=
        FirebaseDynamicLinksPlatform.instanceFor(app: app);
  }

  /// The [FirebaseApp] for this current [FirebaseDynamicLinks] instance.
  FirebaseApp app;

  /// Attempts to retrieve the dynamic link which launched the app.
  ///
  /// This method always returns a Future. That Future completes to null if
  /// there is no pending dynamic link or any call to this method after the
  /// the first attempt.
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  Future<PendingDynamicLinkData?> getInitialLink() async {
    return _delegate.getInitialLink();
  }

  /// Determine if the app has a pending dynamic link and provide access to
  /// the dynamic link parameters. A pending dynamic link may have been
  /// previously captured when a user clicked on a dynamic link, or
  /// may be present in the dynamicLinkUri parameter. If both are present,
  /// the previously captured dynamic link will take precedence. The captured
  /// data will be removed after first access.
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  Future<PendingDynamicLinkData?> getDynamicLink(Uri url) async {
    return _delegate.getDynamicLink(url);
  }

  /// Listen to a stream for the latest dynamic link events.
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  Stream<PendingDynamicLinkData> get onLink {
    return _delegate.onLink;
  }

  /// Creates a Dynamic Link from the parameters.
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  Future<Uri> buildLink(DynamicLinkParameters parameters) async {
    return _delegate.buildLink(parameters);
  }

  /// Creates a shortened Dynamic Link from the parameters.
  @Deprecated(
      'Note: Firebase Dynamic Links is deprecated and the service will shut down on August 25, 2025. '
      'Please see our Dynamic Links Deprecation FAQ documentation > for guidance on alternative solutions and migration options: '
      'https://firebase.google.com/support/dynamic-links-faq')
  Future<ShortDynamicLink> buildShortLink(
    DynamicLinkParameters parameters, {
    ShortDynamicLinkType shortLinkType = ShortDynamicLinkType.short,
  }) async {
    return _delegate.buildShortLink(parameters, shortLinkType: shortLinkType);
  }
}
