// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart' as web;

/// Injects a `<meta>` tag with the provided [attributes] into the [dom.document].
void injectMetaTag(Map<String, String> attributes) {
  final web.Element meta = web.document.createElement('meta');
  for (final MapEntry<String, String> attribute in attributes.entries) {
    meta.setAttribute(attribute.key, attribute.value);
  }
  web.document.head?.append(meta);
}
