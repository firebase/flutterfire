// ignore_for_file: require_trailing_commas
// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../firebase_dynamic_links_platform_interface.dart';

abstract class DynamicLinkBuilderPlatform extends PlatformInterface {
  /// Constructor.
  DynamicLinkBuilderPlatform(this.dynamicLinks) : super(token: _token);

  /// The [FirebaseAuthPlatform] instance.
  final FirebaseDynamicLinksPlatform dynamicLinks;

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [DynamicLinkBuilderPlatform].
  ///
  /// This is used by the app-facing [DynamicLinkBuilder] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verifyExtends(DynamicLinkBuilderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Shortens a Dynamic Link URL.
  ///
  /// This method may be used for shortening a custom URL that was not generated
  /// using [DynamicLinkBuilder].
  Future<ShortDynamicLink> shortenUrl(Uri url,
      [DynamicLinkParametersOptions? options]) async {
    throw UnimplementedError('shortenUrl() is not implemented');
  }

  /// Generate a long Dynamic Link URL.
  Future<Uri> buildUrl(BuildDynamicLinkParameters parameters) async {
    throw UnimplementedError('buildUrl() is not implemented');
  }

  /// Generate a short Dynamic Link URL.
  Future<ShortDynamicLink> buildShortLink(BuildDynamicLinkParameters parameters) async {
    throw UnimplementedError('buildShortLink() is not implemented');
  }
}
