// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Response from creating a dynamic link with [DynamicLinkBuilder].
class DynamicLink {
  const DynamicLink({required this.url});

  /// url value.
  final Uri url;

  Map<String, dynamic> asMap() => <String, dynamic>{
        'url': url.toString(),
      };

  @override
  String toString() {
    return '$DynamicLink($asMap)';
  }
}
