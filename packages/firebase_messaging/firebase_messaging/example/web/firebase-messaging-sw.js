importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

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
