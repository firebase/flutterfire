// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Enum used to define the desired path length for shortened Dynamic Link URLs.
enum ShortDynamicLinkType {
  /// Shorten the path to an unguessable string. Such strings are created by base62-encoding randomly
  /// generated 96-bit numbers, and consist of 17 alphanumeric characters. Use unguessable strings
  /// to prevent your Dynamic DynamicLinks from being crawled, which can potentially expose sensitive information.
  unguessable,

  /// Shorten the path to a string that is only as long as needed to be unique, with a minimum length
  /// of 4 characters. Use this if sensitive information would not be exposed if a short
  /// Dynamic Link URL were guessed.
  short,
}
