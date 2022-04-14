// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'match_type.dart';

/// Provides iOS specific data from received dynamic link.
class PendingDynamicLinkDataIOS {
  const PendingDynamicLinkDataIOS({this.minimumVersion, this.matchType});

  /// The minimum version of your app that can open the link.
  ///
  /// It is app developer's responsibility to open AppStore when received link
  /// declares higher [minimumVersion] than currently installed.
  final String? minimumVersion;

  /// The match type of the received Dynamic Link.
  final MatchType? matchType;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() => <String, dynamic>{
        'minimumVersion': minimumVersion,
        'matchType': matchType?.index,
      };

  @override
  String toString() {
    return '$PendingDynamicLinkDataIOS($asMap)';
  }
}
