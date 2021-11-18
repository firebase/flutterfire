// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The Dynamic Link analytics parameters.
class GoogleAnalyticsParameters {
  const GoogleAnalyticsParameters({
    this.campaign,
    this.content,
    this.medium,
    this.source,
    this.term,
  });

  /// The utm_campaign analytics parameter.
  final String? campaign;

  /// The utm_content analytics parameter.
  final String? content;

  /// The utm_medium analytics parameter.
  final String? medium;

  /// The utm_source analytics parameter.
  final String? source;

  /// The utm_term analytics parameter.
  final String? term;

  Map<String, dynamic> asMap() => <String, dynamic>{
        'campaign': campaign,
        'content': content,
        'medium': medium,
        'source': source,
        'term': term,
      };

  @override
  String toString() {
    return '$GoogleAnalyticsParameters($asMap)';
  }
}
