// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The settable metadata a storage object reference can be set with.
class SettableMetadata {
  /// Creates a new [SettableMetadata] instance.
  SettableMetadata({
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.contentType,
    this.customMetadata,
  });

  /// Served as the 'Cache-Control' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control.
  final String? cacheControl;

  /// Served as the 'Content-Disposition' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition.
  final String? contentDisposition;

  /// Served as the 'Content-Encoding' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Encoding.
  final String? contentEncoding;

  /// Served as the 'Content-Language' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Language.
  final String? contentLanguage;

  /// Served as the 'Content-Type' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type.
  final String? contentType;

  /// Additional user-defined custom metadata.
  final Map<String, String>? customMetadata;

  /// Returns the settable metadata as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'cacheControl': cacheControl,
      'contentDisposition': contentDisposition,
      'contentEncoding': contentEncoding,
      'contentLanguage': contentLanguage,
      'contentType': contentType,
      'customMetadata': customMetadata,
    };
  }
}
