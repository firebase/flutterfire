// ignore_for_file: require_trailing_commas
// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_dynamic_links;

/// The class used for Dynamic Link URL generation.
///
/// Supports creation of short and long Dynamic Link URLs.
class DynamicLinkBuilder {
  DynamicLinkBuilder._(this.dynamicLink, this._delegate) {
    DynamicLinkBuilderPlatform.verifyExtends(_delegate);
  }

  DynamicLinkBuilderPlatform _delegate;
  FirebaseDynamicLinks dynamicLink;

  Future<ShortDynamicLink> shortenUrl(Uri url,
      [DynamicLinkParametersOptions? options]) async {
    return _delegate.shortenUrl(url, options);
  }

  Future<Uri> buildUrl(BuildDynamicLinkParameters parameters) async {
    return _delegate.buildUrl(parameters);
  }

  Future<ShortDynamicLink> buildShortLink(BuildDynamicLinkParameters parameters) async {
    return _delegate.buildShortLink(parameters);
  }
}



