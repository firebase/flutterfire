// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FirebaseFirestore
import Foundation

final class FirebaseFirestoreExtension {
  let instance: Firestore
  let databaseURL: String

  init(firestoreInstance firestore: Firestore, databaseURL: String) {
    instance = firestore
    self.databaseURL = databaseURL
  }
}
