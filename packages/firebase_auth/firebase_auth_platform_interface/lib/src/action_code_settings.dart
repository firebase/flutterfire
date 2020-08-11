// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Interface that defines the required continue/state URL with optional
/// Android and iOS bundle identifiers.
class ActionCodeSettings {
  // ignore: public_member_api_docs
  @protected
  ActionCodeSettings({
    this.android,
    this.dynamicLinkDomain,
    this.handleCodeInApp,
    this.iOS,
    @required this.url,
  }) : assert(url != null) {
    if (android != null) {
      assert(android['packageName'] != null);
    }
    if (iOS != null) {
      assert(iOS['bundleId'] != null);
    }
  }

  /// Sets the Android package name.
  final Map<String, dynamic> android;

  /// Sets an optional Dynamic Link domain.
  final String dynamicLinkDomain;

  /// The default is false. When true, the action code link will be sent
  /// as a Universal Link or Android App Link and will be opened by the
  /// app if installed.
  final bool handleCodeInApp;

  /// Sets the iOS bundle ID.
  final Map<String, dynamic> iOS;

  /// Sets the link continue/state URL
  final String url;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'url': url,
      'dynamicLinkDomain': dynamicLinkDomain,
      'handleCodeInApp': handleCodeInApp,
      'android': android == null
          ? null
          : <String, dynamic>{
              'installApp': android['installApp'],
              'minimumVersion': android['minimumVersion'],
              'packageName': android['packageName'],
            },
      'iOS': iOS == null
          ? null
          : <String, dynamic>{
              'bundleId': iOS['bundleId'],
            }
    };
  }

  @override
  String toString() {
    return '$ActionCodeSettings($asMap)';
  }
}
