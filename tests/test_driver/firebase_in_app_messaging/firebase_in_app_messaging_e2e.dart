//TODO reinstate tests using another android emulator.
// Internal tracking: https://linear.app/invertase/issue/FF-40/in-app-messaging-e2e-tests-for-android
// // Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// // for details. All rights reserved. Use of this source code is governed by a
// // BSD-style license that can be found in the LICENSE file.
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
//
// import 'package:drive/drive.dart';
// import 'package:flutter/foundation.dart';
// import '../firebase_default_options.dart';
//
// void setupTests() {
//   group(
//     'firebase_in_app_messaging',
//     () {
//       setUpAll(() async {
//         await Firebase.initializeApp(
//           options: DefaultFirebaseOptions.currentPlatform,
//         );
//       });
//
//       test('triggerEvent', () async {
//         expect(
//           FirebaseInAppMessaging.instance.triggerEvent('someEvent'),
//           completes,
//         );
//       });
//
//       test('logging', () async {
//         expect(
//           FirebaseInAppMessaging.instance.setMessagesSuppressed(true),
//           completes,
//         );
//         expect(
//           FirebaseInAppMessaging.instance
//               .setAutomaticDataCollectionEnabled(true),
//           completes,
//         );
//       });
//     },
//     // Only supported on Android & iOS.
//     skip: kIsWeb ||
//         (defaultTargetPlatform != TargetPlatform.android &&
//             defaultTargetPlatform != TargetPlatform.iOS),
//   );
// }
