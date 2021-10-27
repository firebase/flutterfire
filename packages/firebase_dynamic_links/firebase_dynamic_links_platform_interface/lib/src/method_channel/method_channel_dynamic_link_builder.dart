// ignore_for_file: require_trailing_commas
// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/src/platform_interface/platform_interface_dynamic_link_builder.dart';
import 'package:firebase_dynamic_links_platform_interface/src/method_channel/method_channel_firebase_dynamic_links.dart';

/// The entry point for accessing a Dynamic Links instance.
///
/// You can get an instance by calling [FirebaseDynamicLinks.instance].
class MethodChannelDynamicLinkBuilder extends DynamicLinkBuilderPlatform {
  /// Create an instance of [MethodChannelDynamicLinkBuilder] with optional [FirebaseApp]
  MethodChannelDynamicLinkBuilder(FirebaseDynamicLinksPlatform dynamicLinks, {
  this.androidParameters,
  required this.uriPrefix,
  this.dynamicLinkParametersOptions,
  this.googleAnalyticsParameters,
  this.iosParameters,
  this.itunesConnectAnalyticsParameters,
  required this.link,
  this.navigationInfoParameters,
  this.socialMetaTagParameters,
  }) : super(dynamicLinks);

  /// Attaches generic default values to method channel arguments.
  Map<String, dynamic> _withChannelDefaults(Map<String, dynamic> other) {
    return {
      'appName': dynamicLinks.app.name,
    }..addAll(other);
  }

  @override
  Future<ShortDynamicLink> shortenUrl(Uri url,
      [DynamicLinkParametersOptions? options]) async {
    final Map<String, dynamic>? reply = await MethodChannelFirebaseDynamicLinks
        .channel
        .invokeMapMethod<String, dynamic>(
            'DynamicLinkParameters#shortenUrl',
            _withChannelDefaults(<String, dynamic>{
              'url': url.toString(),
              'dynamicLinkParametersOptions': options?.data,
            }));
    return _parseShortLink(reply!);
  }

  @override
  Future<Uri> buildUrl() async {
    final String? url = await MethodChannelFirebaseDynamicLinks.channel
        .invokeMethod<String>('DynamicLinkParameters#buildUrl', _withChannelDefaults(_data));
    return Uri.parse(url!);
  }

  @override
  Future<ShortDynamicLink> buildShortLink() async {
    final Map<String, dynamic>? reply = await MethodChannelFirebaseDynamicLinks.channel
        .invokeMapMethod<String, dynamic>(
        'DynamicLinkParameters#buildShortLink', _withChannelDefaults(_data));
    return _parseShortLink(reply!);
  }


  ShortDynamicLink _parseShortLink(Map<String, dynamic> reply) {
    final List<dynamic>? warnings = reply['warnings'];
    return ShortDynamicLink(Uri.parse(reply['url']), warnings?.cast());
  }

  /// Android parameters for a generated Dynamic Link URL.
  final AndroidParameters? androidParameters;

  /// Domain URI Prefix of your App.
  // This value must be your assigned domain from the Firebase console.
  // (e.g. https://xyz.page.link)
  //
  // The domain URI prefix must start with a valid HTTPS scheme (https://).
  final String uriPrefix;

  /// Defines behavior for generating Dynamic Link URLs.
  final DynamicLinkParametersOptions? dynamicLinkParametersOptions;

  /// Analytics parameters for a generated Dynamic Link URL.
  final GoogleAnalyticsParameters? googleAnalyticsParameters;

  /// iOS parameters for a generated Dynamic Link URL.
  final IosParameters? iosParameters;

  /// iTunes Connect parameters for a generated Dynamic Link URL.
  final ItunesConnectAnalyticsParameters? itunesConnectAnalyticsParameters;

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

  Map<String, dynamic> get _data => <String, dynamic>{
    'androidParameters': androidParameters?.data,
    'uriPrefix': uriPrefix,
    'dynamicLinkParametersOptions': dynamicLinkParametersOptions?.data,
    'googleAnalyticsParameters': googleAnalyticsParameters?.data,
    'iosParameters': iosParameters?.data,
    'itunesConnectAnalyticsParameters':
    itunesConnectAnalyticsParameters?.data,
    'link': link.toString(),
    'navigationInfoParameters': navigationInfoParameters?.data,
    'socialMetaTagParameters': socialMetaTagParameters?.data,
  };
}
