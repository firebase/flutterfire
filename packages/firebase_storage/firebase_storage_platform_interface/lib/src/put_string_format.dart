// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The format in which a string can be uploaded to the storage bucket via
/// [Reference.putString].
enum PutStringFormat {
  /// A raw string. It will be uploaded as a Base64 string.
  raw,

  /// A Base64 encoded string.
  base64,

  /// A Base64 URL encoded string.
  base64Url,

  /// A data url string.
  dataUrl,
}
