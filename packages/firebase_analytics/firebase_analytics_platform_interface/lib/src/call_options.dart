// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Additional options that can be passed to Analytics method calls.
///
/// Note; these options are only used on the web.
class CallOptions {
  // ignore: public_member_api_docs
  @protected
  CallOptions({
    required this.global,
  });

  /// If true, this config or event call applies globally to all Google Analytics properties on the page.
  final bool global;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'global': global,
    };
  }

  @override
  String toString() {
    return '$CallOptions($asMap)';
  }
}
