// ignore_for_file: require_trailing_commas
// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/src/platform_interface/platform_interface_dynamic_link_builder.dart';
import 'package:firebase_dynamic_links_platform_interface/src/method_channel/method_channel_firebase_dynamic_links.dart';

class MethodChannelDynamicLinkBuilder extends DynamicLinkBuilderPlatform {
  MethodChannelDynamicLinkBuilder(FirebaseDynamicLinksPlatform dynamicLinks)
      : super(dynamicLinks);

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
  Future<Uri> buildUrl(BuildDynamicLinkParameters parameters) async {
    final String? url = await MethodChannelFirebaseDynamicLinks.channel
        .invokeMethod<String>('DynamicLinkParameters#buildUrl',
            _withChannelDefaults(parameters.asMap()));
    return Uri.parse(url!);
  }

  @override
  Future<ShortDynamicLink> buildShortLink(
      BuildDynamicLinkParameters parameters) async {
    final Map<String, dynamic>? response =
        await MethodChannelFirebaseDynamicLinks.channel
            .invokeMapMethod<String, dynamic>(
                'DynamicLinkParameters#buildShortLink',
                _withChannelDefaults(parameters.asMap()));
    return _parseShortLink(response!);
  }

  ShortDynamicLink _parseShortLink(Map<String, dynamic> response) {
    final List<dynamic>? warnings = response['warnings'];
    return ShortDynamicLink(
        Uri.parse(response['url']), warnings?.cast(), response['previewLink']);
  }
}
