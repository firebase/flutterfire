// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// A utility class to parse email action URLs.
class ActionCodeURL {
  const ActionCodeURL(
      {@required this.apiKey,
      @required this.code,
      this.continueURL,
      this.languageCode,
      @required this.operation,
      this.tenantId});

  /// The API key of the email action link.
  final String apiKey;

  /// The action code of the email action link.
  final String code;

  /// The continue URL of the email action link.
  /// Null if not provided.
  final String continueURL;

  /// The language code of the email action link.
  /// Null if not provided.
  final String languageCode;

  /// The action performed by the email link. It
  /// returns from one of the types from [ActionCodeInfo].
  final String operation;

  /// The tenant ID of the email action link. Null if
  /// the email action is from the parent project.
  final String tenantId;

  // TODO: Implementation
  /// Parses the email action link string and returns an
  /// [ActionCodeURL] object if the link is vaid. Otherwise
  /// returns null.
  static ActionCodeURL parseLink(String link) {
    if (link == null || link == "") return null;

    // parse link
    var apiKey;
    var code;
    var operation;
    var continueURL;
    var languageCode;
    var tenantId;
    // validate API key, code, and operation.
    if (!apiKey || !code || !operation) {
      // throw
    }
    return ActionCodeURL(
        apiKey: apiKey,
        operation: operation,
        code: code,
        continueURL: continueURL,
        languageCode: languageCode,
        tenantId: tenantId);
  }
}
