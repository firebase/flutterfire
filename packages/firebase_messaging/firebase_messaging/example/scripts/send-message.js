var admin = require('firebase-admin');
// 1. Get a service account key from your Firebase console and add to the scripts/ directory
var serviceAccount = require('./google-services.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// 2. Get token for your device that is printed in console on app start for FirebaseMessaging example
const token =
'dkFJ5PmYIk4hgyPOWil1gG:APA91bEJR6J9qRPw9GoM0FkiSmJS1a3He3C1p6lDVyJLRVucX_Qo5ftyYlkTSzjLfARdEd-fb05OxcR4Srdg3mX3mCoJZKZyVRJp3iHl7E-hGsBjhgyrJOpqkk9vqfwnwzM7IF0lefGF';


// To run this script, you will need nodejs installed on your computer. Then:
// 3. From your terminal, root to scripts/ directory & run `npm install`.
// 4. Run `npm run send-message` in the scripts/ directory and you will receive messages in any state; foreground, background, terminated.
// If you find your messages have stopped arriving, it is extremely likely they are being throttled by the platform. iOS in particular
// are aggressive with their throttling policy.
admin
  .messaging()
  .sendToDevice(
    [token],
    {
      data: {
        foo:'bar',
      },
      notification: {
        title: 'A great title',
        body: 'Great content',
      },
    },
    {
      // Required for background/terminated app state messages on iOS
      contentAvailable: true,
      // Required for background/terminated app state messages on Android
      priority: 'high',
    }
  )
  .then((res) => {
    if (res.failureCount) {
      console.log('Failed');
    } else {
      console.log('Success');
    }
  })
  .catch((err) => {
    console.log('Error:', err);
  });
