// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore;

import com.google.firebase.firestore.FirebaseFirestore;

public class FlutterFirebaseFirestoreExtension {
  private final FirebaseFirestore instance;
  private final String databaseURL;

  public FlutterFirebaseFirestoreExtension(FirebaseFirestore instance, String databaseURL) {
    this.instance = instance;
    this.databaseURL = databaseURL;
  }

  public FirebaseFirestore getInstance() {
    return instance;
  }

  public String getDatabaseURL() {
    return databaseURL;
  }
}
