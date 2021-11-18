// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'short_dynamic_link_path_length.dart';

/// Options class for defining how Dynamic Link URLs are generated.
class DynamicLinkParametersOptions {
  const DynamicLinkParametersOptions({this.shortDynamicLinkPathLength});

  /// Specifies the length of the path component of a short Dynamic Link.
  final ShortDynamicLinkPathLength? shortDynamicLinkPathLength;

  Map<String, dynamic> asMap() => <String, dynamic>{
        'shortDynamicLinkPathLength': shortDynamicLinkPathLength?.index,
      };

  @override
  String toString() {
    return '$DynamicLinkParametersOptions($asMap)';
  }
}
