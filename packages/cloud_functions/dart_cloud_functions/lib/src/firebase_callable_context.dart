// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dart_cloud_functions/src/callable_context.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Gets each request's tokens from the Firebase services of [app].
///
/// The ID token comes from `FirebaseAuth.instanceFor(app: app)`, not from
/// `app.getService<FirebaseAuth>()` as in `firebase_ai`. The service is only
/// registered once the app has used `FirebaseAuth`, so a call made before
/// that would go out without the token of a user restored from a previous
/// launch.
CallableContextProvider firebaseCallableContext(FirebaseApp app) {
  return () async {
    final user = FirebaseAuth.instanceFor(app: app).currentUser;
    return CallableContext(authToken: await user?.getIdToken());
  };
}
