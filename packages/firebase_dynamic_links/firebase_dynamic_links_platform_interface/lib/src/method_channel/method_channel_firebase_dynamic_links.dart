// ignore_for_file: require_trailing_commas
// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/src/method_channel/method_channel_dynamic_link_builder.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

/// The entry point for accessing a Dynamic Links instance.
///
/// You can get an instance by calling [FirebaseDynamicLinks.instance].
class MethodChannelFirebaseDynamicLinks extends FirebaseDynamicLinksPlatform {
  /// Create an instance of [MethodChannelFirebaseDynamicLinks] with optional [FirebaseApp]
  MethodChannelFirebaseDynamicLinks({FirebaseApp? app})
      : super(appInstance: app);

  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/firebase_dynamic_links',
  );

  /// The [EventChannel] used for onLink
  static EventChannel onLinkChannel(String id) {
    return EventChannel(
      'plugins.flutter.io/firebase_dynamic_links/onLink/$id',
      channel.codec,
    );
  }

  /// Gets a [FirebaseDynamicLinksPlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseDynamicLinks(app: app);
  }

  PendingDynamicLinkData? getPendingDynamicLinkDataFromMap(
      Map<dynamic, dynamic>? linkData) {
    if (linkData == null) return null;

    final link = linkData['link'];
    if (link == null) return null;

    PendingDynamicLinkDataAndroid? androidData;
    if (linkData['android'] != null) {
      final Map<dynamic, dynamic> data = linkData['android'];
      androidData = PendingDynamicLinkDataAndroid(
        data['clickTimestamp'],
        data['minimumVersion'],
      );
    }

    PendingDynamicLinkDataIOS? iosData;
    if (linkData['ios'] != null) {
      final Map<dynamic, dynamic> data = linkData['ios'];
      iosData = PendingDynamicLinkDataIOS(data['minimumVersion']);
    }

    return PendingDynamicLinkData(
      Uri.parse(link),
      androidData,
      iosData,
    );
  }

  @override
  Future<PendingDynamicLinkData?> getInitialLink() async {
    final Map<String, dynamic>? linkData =
        await channel.invokeMapMethod<String, dynamic>(
            'FirebaseDynamicLinks#getInitialLink');

    return getPendingDynamicLinkDataFromMap(linkData);
  }

  @override
  Future<PendingDynamicLinkData?> getDynamicLink(Uri url) async {
    final Map<String, dynamic>? linkData = await channel
        .invokeMapMethod<String, dynamic>('FirebaseDynamicLinks#getDynamicLink',
            <String, dynamic>{'url': url.toString()});
    return getPendingDynamicLinkDataFromMap(linkData);
  }

  @override
  Stream<PendingDynamicLinkData?> onLink() {
    StreamSubscription<dynamic>? snapshotStream;
    late StreamController<PendingDynamicLinkData?> controller; // ignore: close_sinks

    controller = StreamController<PendingDynamicLinkData?>.broadcast(
      onListen: () async {
        //TODO setup event channel. Make sure this all works.
        final observerId =
            await channel.invokeMethod<String>('FirebaseDynamicLinks#onLink');

        snapshotStream = onLinkChannel(observerId!).receiveBroadcastStream(
          <String, dynamic>{
            'appName': app.name,
          },
        ).listen((event) {
          controller.add(getPendingDynamicLinkDataFromMap(event));
        }, onError: (error, stack) {
          controller.addError(convertPlatformException(error), stack);
        });
      },
      onCancel: () {
        snapshotStream?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  MethodChannelDynamicLinkBuilder createLink(){
    return MethodChannelDynamicLinkBuilder(this);
  }

  // Future<dynamic> _handleMethod(MethodCall call) async {
  //   switch (call.method) {
  //     case 'onLinkSuccess':
  //       PendingDynamicLinkData? linkData;
  //       if (call.arguments != null) {
  //         final Map<dynamic, dynamic>? data =
  //             call.arguments.cast<dynamic, dynamic>();
  //         linkData = getPendingDynamicLinkDataFromMap(data);
  //       }
  //       return _onLinkSuccess!(linkData);
  //     case 'onLinkError':
  //       final Map<dynamic, dynamic> data =
  //           call.arguments.cast<dynamic, dynamic>();
      //TODO use stream handler instead
      // final OnLinkErrorException e = OnLinkErrorException._(
      //     data['code'], data['message'], data['details']);
      // return _onLinkError!(e);
  //   }
  // }
}

//TODO use exception in PI. Remove this.
// /// This object is returned by the handler when an error occurs.
// class OnLinkErrorException extends PlatformException {
//   OnLinkErrorException._(String code, String? message, dynamic details)
//       : super(code: code, message: message, details: details);
// }
