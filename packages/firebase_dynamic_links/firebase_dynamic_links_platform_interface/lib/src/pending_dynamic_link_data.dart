// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'pending_dynamic_link_data_android.dart';
import 'pending_dynamic_link_data_ios.dart';

/// Provides data from received dynamic link.
class PendingDynamicLinkData {
  const PendingDynamicLinkData({
    required this.link,
    this.android,
    this.ios,
    this.utmParameters = const {},
  });

  /// Provides Android specific data from received dynamic link.
  ///
  /// Can be null if [link] equals null or dynamic link was not received on an
  /// Android device.
  final PendingDynamicLinkDataAndroid? android;

  /// Provides iOS specific data from received dynamic link.
  ///
  /// Can be null if [link] equals null or dynamic link was not received on an
  /// iOS device.
  final PendingDynamicLinkDataIOS? ios;

  /// Deep link parameter of the dynamic link.
  final Uri link;

  /// UTM parameters associated with a dynamic link.
  final Map<String, String?> utmParameters;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() => <String, dynamic>{
        'ios': ios?.asMap(),
        'android': android?.asMap(),
        'link': link.toString(),
        'utmParameters': utmParameters
      };

  @override
  String toString() {
    return '$PendingDynamicLinkData(${asMap()})';
  }
}
