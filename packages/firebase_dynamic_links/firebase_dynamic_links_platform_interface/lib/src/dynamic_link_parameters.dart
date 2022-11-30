// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../firebase_dynamic_links_platform_interface.dart';

/// Interface that defines the all the parameters required to build a dynamic link
class DynamicLinkParameters {
  // ignore: public_member_api_docs
  DynamicLinkParameters({
    required this.link,
    required this.uriPrefix,
    this.longDynamicLink,
    this.androidParameters,
    this.iosParameters,
    this.googleAnalyticsParameters,
    this.itunesConnectAnalyticsParameters,
    this.navigationInfoParameters,
    this.socialMetaTagParameters,
  });

  /// Android parameters for a generated Dynamic Link URL.
  final AndroidParameters? androidParameters;

  /// Domain URI Prefix of your App.
  // This value must be your assigned domain from the Firebase console.
  // (e.g. https://xyz.page.link)
  //
  // The domain URI prefix must start with a valid HTTPS scheme (https://).
  final String uriPrefix;

  /// Analytics parameters for a generated Dynamic Link URL.
  final GoogleAnalyticsParameters? googleAnalyticsParameters;

  /// iOS parameters for a generated Dynamic Link URL.
  final IOSParameters? iosParameters;

  /// iTunes Connect parameters for a generated Dynamic Link URL.
  final ITunesConnectAnalyticsParameters? itunesConnectAnalyticsParameters;

  /// The link the target app will open.
  ///
  /// You can specify any URL the app can handle, such as a link to the app’s
  /// content, or a URL that initiates some app-specific logic such as crediting
  /// the user with a coupon, or displaying a specific welcome screen.
  /// This link must be a well-formatted URL, be properly URL-encoded, and use
  /// the HTTP or HTTPS scheme.
  final Uri link;

  /// Navigation Info parameters for a generated Dynamic Link URL.
  final NavigationInfoParameters? navigationInfoParameters;

  /// Social Meta Tag parameters for a generated Dynamic Link URL.
  final SocialMetaTagParameters? socialMetaTagParameters;

  /// Set the long Dynamic Link when building a short link (i.e. using `buildShortLink()` API). This allows the user to append
  /// additional query strings that would otherwise not be possible (e.g. "ofl" parameter). This will not work if using buildLink() API.
  final Uri? longDynamicLink;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'uriPrefix': uriPrefix,
      'link': link.toString(),
      if (longDynamicLink != null)
        'longDynamicLink': longDynamicLink.toString(),
      if (androidParameters != null)
        'androidParameters': androidParameters?.asMap(),
      if (googleAnalyticsParameters != null)
        'googleAnalyticsParameters': googleAnalyticsParameters?.asMap(),
      if (iosParameters != null) 'iosParameters': iosParameters?.asMap(),
      if (itunesConnectAnalyticsParameters != null)
        'itunesConnectAnalyticsParameters':
            itunesConnectAnalyticsParameters?.asMap(),
      if (navigationInfoParameters != null)
        'navigationInfoParameters': navigationInfoParameters?.asMap(),
      if (socialMetaTagParameters != null)
        'socialMetaTagParameters': socialMetaTagParameters?.asMap(),
    };
  }

  @override
  String toString() {
    return '$DynamicLinkParameters(${asMap()})';
  }
}
