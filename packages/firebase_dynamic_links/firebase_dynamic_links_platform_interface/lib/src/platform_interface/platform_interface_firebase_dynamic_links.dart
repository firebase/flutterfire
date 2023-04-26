// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_firebase_dynamic_links.dart';

/// Defines an interface to work with Dynamic Links across platforms
abstract class FirebaseDynamicLinksPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp? appInstance;

  /// Create an instance using [app]
  FirebaseDynamicLinksPlatform({this.appInstance}) : super(token: _token);

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    return appInstance ?? Firebase.app();
  }

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirebaseDynamicLinksPlatform.instanceFor({required FirebaseApp app}) {
    return FirebaseDynamicLinksPlatform.instance.delegateFor(app: app);
  }

  /// The current default [FirebaseDynamicLinksPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseDynamicLinks]
  /// if no other implementation was provided.
  static FirebaseDynamicLinksPlatform get instance {
    return _instance ??= MethodChannelFirebaseDynamicLinks();
  }

  static FirebaseDynamicLinksPlatform? _instance;

  /// Sets the [FirebaseFirestorePlatform.instance]
  static set instance(FirebaseDynamicLinksPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Creates a stream for listening whenever a dynamic link becomes available
  Stream<PendingDynamicLinkData> get onLink {
    throw UnimplementedError('onLink is not implemented');
  }

  /// Attempts to retrieve the dynamic link which launched the app.
  ///
  /// This method always returns a Future. That Future completes to null if
  /// there is no pending dynamic link or any call to this method after the
  /// the first attempt.
  Future<PendingDynamicLinkData?> getInitialLink() {
    throw UnimplementedError('getInitialLink() is not implemented');
  }

  /// Determine if the app has a pending dynamic link and provide access to
  /// the dynamic link parameters. A pending dynamic link may have been
  /// previously captured when a user clicked on a dynamic link, or
  /// may be present in the dynamicLinkUri parameter. If both are present,
  /// the previously captured dynamic link will take precedence. The captured
  /// data will be removed after first access.
  Future<PendingDynamicLinkData?> getDynamicLink(Uri url) async {
    throw UnimplementedError('getDynamicLink() is not implemented');
  }

  /// Generate a long Dynamic Link URL.
  Future<Uri> buildLink(DynamicLinkParameters parameters) async {
    throw UnimplementedError('buildLink() is not implemented');
  }

  /// Generate a short Dynamic Link URL.
  Future<ShortDynamicLink> buildShortLink(
    DynamicLinkParameters parameters, {
    ShortDynamicLinkType shortLinkType = ShortDynamicLinkType.short,
  }) async {
    throw UnimplementedError('buildShortLink() is not implemented');
  }

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is FirebaseDynamicLinksPlatform && other.app.name == app.name;

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => toString().hashCode;

  @override
  String toString() => '$FirebaseDynamicLinksPlatform(app: ${app.name})';
}
