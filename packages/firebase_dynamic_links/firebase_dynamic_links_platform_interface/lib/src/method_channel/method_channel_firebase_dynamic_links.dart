// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

/// The entry point for accessing a Dynamic Links instance.
///
/// You can get an instance by calling [FirebaseDynamicLinks.instance].
class MethodChannelFirebaseDynamicLinks extends FirebaseDynamicLinksPlatform {
  /// Create an instance of [MethodChannelFirebaseDynamicLinks] with optional [FirebaseApp]
  MethodChannelFirebaseDynamicLinks({FirebaseApp? app})
      : super(appInstance: app);

  /// The [FirebaseApp] instance to which this [FirebaseDynamicLinks] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/firebase_dynamic_links',
  );

  /// The [EventChannel] used for onLink
  static EventChannel onLinkChannel(String name) {
    return EventChannel(
      name,
      channel.codec,
    );
  }

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

  PendingDynamicLinkData? getPendingDynamicLinkDataFromMap(
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
      iosData =
          PendingDynamicLinkDataIOS(minimumVersion: data['minimumVersion']);
    }

    return PendingDynamicLinkData(
      link: Uri.parse(link),
      android: androidData,
      ios: iosData,
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

      return getPendingDynamicLinkDataFromMap(linkData);
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
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
      return getPendingDynamicLinkDataFromMap(linkData);
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Stream<PendingDynamicLinkData?> onLink() {
    StreamSubscription<dynamic>? snapshotStream;
    late StreamController<PendingDynamicLinkData?>
        controller; // ignore: close_sinks

    controller = StreamController<PendingDynamicLinkData?>.broadcast(
      onListen: () async {
        // ignore: cast_nullable_to_non_nullable
        String name = await channel.invokeMethod<String>(
          'FirebaseDynamicLinks#onLink',
          _withChannelDefaults({}),
        ) as String;
        final events = onLinkChannel(name);
        snapshotStream = events.receiveBroadcastStream().listen(
          (event) {
            controller.add(getPendingDynamicLinkDataFromMap(event));
          },
          onError: (error, stack) {
            controller.addError(convertPlatformException(error), stack);
          },
        );
      },
      onCancel: () {
        snapshotStream?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<ShortDynamicLink> shortenUrl(
    Uri url, [
    DynamicLinkParametersOptions? options,
  ]) async {
    try {
      final Map<String, dynamic>? reply =
          await MethodChannelFirebaseDynamicLinks.channel
              .invokeMapMethod<String, dynamic>(
        'FirebaseDynamicLinks#shortenUrl',
        _withChannelDefaults(<String, dynamic>{
          'url': url.toString(),
          'dynamicLinkParametersOptions': options?.asMap(),
        }),
      );
      return _parseShortLink(reply!);
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<Uri> buildUrl(DynamicLinkParameters parameters) async {
    try {
      final String? url =
          await MethodChannelFirebaseDynamicLinks.channel.invokeMethod<String>(
        'FirebaseDynamicLinks#buildUrl',
        _withChannelDefaults(parameters.asMap()),
      );
      return Uri.parse(url!);
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  @override
  Future<ShortDynamicLink> buildShortLink(
    DynamicLinkParameters parameters,
  ) async {
    try {
      final Map<String, dynamic>? response =
          await MethodChannelFirebaseDynamicLinks.channel
              .invokeMapMethod<String, dynamic>(
        'FirebaseDynamicLinks#buildShortLink',
        _withChannelDefaults(parameters.asMap()),
      );
      return _parseShortLink(response!);
    } on PlatformException catch (e, s) {
      throw platformExceptionToFirebaseException(e, s);
    }
  }

  ShortDynamicLink _parseShortLink(Map<String, dynamic> response) {
    final List<dynamic>? warnings = response['warnings'];
    return ShortDynamicLink(
      shortUrl: Uri.parse(response['url']),
      warnings: warnings?.cast(),
      previewLink: response['previewLink'] != null
          ? Uri.parse(response['previewLink'])
          : null,
    );
  }
}
