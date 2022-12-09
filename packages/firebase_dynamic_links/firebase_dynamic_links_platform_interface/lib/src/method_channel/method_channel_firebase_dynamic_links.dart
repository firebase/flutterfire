// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_dynamic_links_platform_interface/src/method_channel/utils/convert_match_type.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

/// The entry point for accessing a Dynamic Links instance.
///
/// You can get an instance by calling [FirebaseDynamicLinks.instance].
class MethodChannelFirebaseDynamicLinks extends FirebaseDynamicLinksPlatform {
  /// Create an instance of [MethodChannelFirebaseDynamicLinks] with optional [FirebaseApp]
  MethodChannelFirebaseDynamicLinks({FirebaseApp? app})
      : super(appInstance: app) {
    if (_initialized) return;

    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'FirebaseDynamicLink#onLinkSuccess':
          Map<String, dynamic> event =
              Map<String, dynamic>.from(call.arguments);
          PendingDynamicLinkData? data =
              _getPendingDynamicLinkDataFromMap(event);

          if (data != null) {
            _onLinkController.add(data);
          }
          break;
        case 'FirebaseDynamicLink#onLinkError':
          try {
            Map<String, dynamic> error =
                Map<String, dynamic>.from(call.arguments);
            convertPlatformException(error, StackTrace.current);
          } catch (err, stack) {
            _onLinkController.addError(err, stack);
          }
          break;
        default:
          throw UnimplementedError('${call.method} has not been implemented');
      }
    });
    _initialized = true;
  }

  static bool _initialized = false;

  /// The [FirebaseApp] instance to which this [FirebaseDynamicLinks] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/firebase_dynamic_links',
  );

  /// The [StreamController] used to update on the latest dynamic link received.
  static final StreamController<PendingDynamicLinkData> _onLinkController =
      StreamController<PendingDynamicLinkData>.broadcast();

  /// Gets a [FirebaseDynamicLinksPlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseDynamicLinks(app: app);
  }

  /// Attaches generic default values to method channel arguments to allow multi-app support for android.
  Map<String, dynamic> _withChannelDefaults(Map<String, dynamic> other) {
    return {
      'appName': appInstance?.name ?? defaultFirebaseAppName,
    }..addAll(other);
  }

  PendingDynamicLinkData? _getPendingDynamicLinkDataFromMap(
    Map<dynamic, dynamic>? linkData,
  ) {
    if (linkData == null) return null;

    final link = linkData['link'];
    if (link == null) return null;

    PendingDynamicLinkDataAndroid? androidData;
    if (linkData['android'] != null) {
      final Map<dynamic, dynamic> data = linkData['android'];
      androidData = PendingDynamicLinkDataAndroid(
        clickTimestamp: data['clickTimestamp'],
        minimumVersion: data['minimumVersion'],
      );
    }

    PendingDynamicLinkDataIOS? iosData;
    if (linkData['ios'] != null) {
      final Map<dynamic, dynamic> data = linkData['ios'];

      MatchType? matchType = convertMatchType(data['matchType']);
      iosData = PendingDynamicLinkDataIOS(
        minimumVersion: data['minimumVersion'],
        matchType: matchType,
      );
    }

    return PendingDynamicLinkData(
      link: Uri.parse(link),
      android: androidData,
      ios: iosData,
      utmParameters: linkData['utmParameters'] == null
          ? {}
          : Map<String, String?>.from(linkData['utmParameters']),
    );
  }

  @override
  Future<PendingDynamicLinkData?> getInitialLink() async {
    try {
      final Map<String, dynamic>? linkData =
          await channel.invokeMapMethod<String, dynamic>(
        'FirebaseDynamicLinks#getInitialLink',
        _withChannelDefaults({}),
      );

      return _getPendingDynamicLinkDataFromMap(linkData);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<PendingDynamicLinkData?> getDynamicLink(Uri url) async {
    try {
      final Map<String, dynamic>? linkData =
          await channel.invokeMapMethod<String, dynamic>(
        'FirebaseDynamicLinks#getDynamicLink',
        _withChannelDefaults({'url': url.toString()}),
      );

      return _getPendingDynamicLinkDataFromMap(linkData);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Stream<PendingDynamicLinkData> get onLink {
    return _onLinkController.stream;
  }

  @override
  Future<Uri> buildLink(DynamicLinkParameters parameters) async {
    try {
      final String? url =
          await MethodChannelFirebaseDynamicLinks.channel.invokeMethod<String>(
        'FirebaseDynamicLinks#buildLink',
        _withChannelDefaults(parameters.asMap()),
      );

      return Uri.parse(url!);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<ShortDynamicLink> buildShortLink(
    DynamicLinkParameters parameters, {
    ShortDynamicLinkType shortLinkType = ShortDynamicLinkType.short,
  }) async {
    try {
      final Map<String, dynamic>? response =
          await MethodChannelFirebaseDynamicLinks.channel
              .invokeMapMethod<String, dynamic>(
        'FirebaseDynamicLinks#buildShortLink',
        _withChannelDefaults(
          {
            'shortLinkType': shortLinkType.index,
            ...parameters.asMap(),
          },
        ),
      );

      final List<dynamic>? warnings = response!['warnings'];
      return ShortDynamicLink(
        type: shortLinkType,
        shortUrl: Uri.parse(response['url']),
        warnings: warnings?.cast(),
        previewLink: response['previewLink'] != null
            ? Uri.parse(response['previewLink'])
            : null,
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
