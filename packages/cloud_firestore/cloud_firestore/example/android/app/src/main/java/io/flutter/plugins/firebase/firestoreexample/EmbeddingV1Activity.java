// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestoreexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin;
import io.flutter.view.FlutterMain;

public class EmbeddingV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    FlutterMain.startInitialization(this);
    super.onCreate(savedInstanceState);
    FlutterFirebaseFirestorePlugin.registerWith(
        registrarFor("io.flutter.plugins.firebase.firestore"));
  }
}
