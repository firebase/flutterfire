/**
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0",
  authDomain: "react-native-firebase-testing.firebaseapp.com",
  databaseURL: "https://react-native-firebase-testing.firebaseio.com",
  projectId: "react-native-firebase-testing",
  storageBucket: "react-native-firebase-testing.appspot.com",
  messagingSenderId: "448618578101",
  appId: "1:448618578101:web:ecaffe2bc4511738",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
