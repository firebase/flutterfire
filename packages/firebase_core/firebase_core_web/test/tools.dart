// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

/// Injects a `<meta>` tag with the provided [attributes] into the [dom.document].
void injectMetaTag(Map<String, String> attributes) {
  final Element meta = document.createElement('meta');
  for (final MapEntry<String, String> attribute in attributes.entries) {
    meta.setAttribute(attribute.key, attribute.value);
  }
  document.head?.append(meta);
}
