import { initializeApp } from 'firebase/app';
import {
  experimentalSetDeliveryMetricsExportedToBigQueryEnabled,
  getMessaging,
  isSupported,
  onBackgroundMessage
} from 'firebase/messaging/sw';

declare var self: ServiceWorkerGlobalScope;

self.addEventListener('install', (event) => {
  console.log(self);
  console.log(event);
});

const app = initializeApp({
  apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
  authDomain: 'react-native-firebase-testing.firebaseapp.com',
  databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
  projectId: 'react-native-firebase-testing',
  storageBucket: 'react-native-firebase-testing.appspot.com',
  messagingSenderId: '448618578101',
  appId: '1:448618578101:web:ecaffe2bc4511738',
});

isSupported().then((isSupported) => {
  if (isSupported) {
    const messaging = getMessaging(app);

    experimentalSetDeliveryMetricsExportedToBigQueryEnabled(messaging, true);

    onBackgroundMessage(messaging, ({ notification: notification }) => {
      const { title, body, image } = notification ?? {};

      if (!title) {
        return;
      }

      self.registration.showNotification(title, {
        body,
        icon: image || '/assets/icons/icon-72x72.png',
      });
    });
  }
});
