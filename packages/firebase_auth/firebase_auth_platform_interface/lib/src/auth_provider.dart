// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract class AuthProvider {
  AuthProvider(this.providerId);

  final String providerId;

  @override
  String toString() {
    return 'AuthProvider(providerId: $providerId)';
  }
}
