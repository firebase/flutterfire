// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore

class FlutterFirebaseFirestoreTransactionResult private constructor(val exception: Exception?) {
  companion object {
    fun failed(exception: Exception): FlutterFirebaseFirestoreTransactionResult {
      return FlutterFirebaseFirestoreTransactionResult(exception)
    }

    fun complete(): FlutterFirebaseFirestoreTransactionResult {
      return FlutterFirebaseFirestoreTransactionResult(null)
    }
  }
}
