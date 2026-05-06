// ⚠️ WARNING: This file uses the legacy Firebase compat SDK loaded via importScripts.
// This approach is deprecated and not recommended for production use.
//
// Instead, use the bundled service worker with the modular Firebase JS SDK:
//   See: ../bundled-service-worker/
//
// To build:
//   cd bundled-service-worker
//   yarn install && yarn build
//
// This outputs a bundled firebase-messaging-sw.js into this directory.

importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: 'AIzaSyB7wZb2tO1-Fs6GbDADUSTs2Qs3w08Hovw',
  appId: '1:406099696497:web:87e25e51afe982cd3574d0',
  messagingSenderId: '406099696497',
  projectId: 'flutterfire-e2e-tests',
  authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
  databaseURL:
      'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
  storageBucket: 'flutterfire-e2e-tests.appspot.com',
  measurementId: 'G-JN95N1JV2E',
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
