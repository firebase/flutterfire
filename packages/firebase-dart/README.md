[![Pub Package](https://img.shields.io/pub/v/firebase.svg)](https://pub.dev/packages/firebase)
[![Build Status](https://travis-ci.org/FirebaseExtended/firebase-dart.svg?branch=master)](https://travis-ci.org/FirebaseExtended/firebase-dart)

**NOTE:** This package provides three libraries:

* For browser-based applications:
  [`package:firebase/firebase.dart` and `package:firebase/firestore.dart`](#using-this-package-for-browser-applications)
  are wrappers over the [Firebase JS API](https://firebase.google.com/docs/reference/js/).

* For the Dart VM and Fuchsia:
  [`package:firebase/firebase_io.dart`](#using-this-package-with-the-dart-vm-and-fuchsia)
  is a lightly maintained wrapper over the
  [Firebase Database REST API](https://firebase.google.com/docs/reference/rest/database/).
  *Contributions to expand support to the other REST APIs are appreciated!* 

### Other platforms

* Flutter: [FlutterFire plugins](https://github.com/flutter/plugins/blob/master/FlutterFire.md)

* Node (via dart2js): [Anatoly Pulyaevskiy](https://github.com/pulyaevskiy) has
  been working on unofficial wrappers.
  * [package:firebase_admin_interop](https://pub.dev/packages/firebase_admin_interop)
  * [package:firebase_functions_interop](https://pub.dev/packages/firebase_functions_interop)

## Firebase Configuration
You can find more information on how to use Firebase on the
[Getting started](https://firebase.google.com/docs/web/setup) page.

Don't forget to setup correct **rules** for your
[realtime database](https://firebase.google.com/docs/database/security/),
[storage](https://firebase.google.com/docs/storage/security/) and/or 
[firestore](https://firebase.google.com/docs/firestore/security/get-started)
in the Firebase console. 

If you want to use [Firestore](https://firebase.google.com/docs/firestore/quickstart), 
you need to enable it in the Firebase console and include the
[additional js script](#do-you-need-to-use-firestore).

Authentication also has to be enabled in the Firebase console.
For more info, see the
[next section](#before-tests-and-examples-are-run)
in this document.

## Using this package for browser applications

You must include the right Firebase JavaScript libraries into your `.html` file
to be able to use this package. Usually this means including `firebase-app.js`
as well as one or more libraries corresponding to the features you are using.

For example:

```html
<script src="https://www.gstatic.com/firebasejs/7.13.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/7.13.1/firebase-firestore.js"></script>
```

The firestore library is available in `firestore.dart`. You can find an
example how to use this library in the [example/firestore](example/firestore).

### Real-time Database Example 

```dart
import 'package:firebase/firebase.dart';

void main() {
  initializeApp(
    apiKey: "YourApiKey",
    authDomain: "YourAuthDomain",
    databaseURL: "YourDatabaseUrl",
    projectId: "YourProjectId",
    storageBucket: "YourStorageBucket");

  Database db = database();
  DatabaseReference ref = db.ref('messages');

  ref.onValue.listen((e) {
    DataSnapshot datasnapshot = e.snapshot;
    // Do something with datasnapshot
  });
}
```

### Firestore Example

```dart
import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart' as fs;

void main() {
  initializeApp(
    apiKey: "YourApiKey",
    authDomain: "YourAuthDomain",
    databaseURL: "YourDatabaseUrl",
    projectId: "YourProjectId",
    appId: "YourAppId",
    storageBucket: "YourStorageBucket");

  fs.Firestore store = firestore();
  fs.CollectionReference ref = store.collection('messages');

  ref.onSnapshot.listen((querySnapshot) {
    querySnapshot.docChanges().forEach((change) {
      if (change.type == "added") {
        // Do something with change.doc
      }     
    });
  });
}
```

## Using this package with the Dart VM and Fuchsia

This library also contains a dart:io client.

Create an instance of `FirebaseClient` and then use the appropriate
method (`GET`, `PUT`, `POST`, `DELETE` or `PATCH`).
More info in the
[official documentation](https://firebase.google.com/docs/reference/rest/database/).

The dart:io client also supports authentication. See the documentation on how to get
[auth credentials](https://firebase.google.com/docs/reference/rest/database/user-auth).

```dart
import 'package:firebase/firebase_io.dart';

void main() {
  var credential = ... // Retrieve auth credential
  var fbClient = new FirebaseClient(credential); // FirebaseClient.anonymous() is also available
  
  var path = ... // Full path to your database location with .json appended
  
  // GET
  var response = await fbClient.get(path);
  
  // DELETE
  await fbClient.delete(path);
  
  ...
}
```

## Examples

You can find more examples on realtime database, auth, storage and firestore in
the [example](https://github.com/FirebaseExtended/firebase-dart/tree/master/example)
folder.

## Dart Dev Summit 2016 demo app

[Demo app](https://github.com/Janamou/firebase-demo)
which uses Google login, realtime database and storage.

## Before tests and examples are run

You need to ensure a couple of things before tests and examples in this library
are run.

### All tests and examples

Create `config.json` file (see `config.json.sample`) in `lib/src/assets` folder
with configuration for your Firebase project.

To run the io tests, you need to provide the `service_account.json` file. Go to
`Settings/Project settings/Service accounts` tab in your project's Firebase
console, select the `Firebase Admin SDK` and click on the 
`Generate new private key` button, which downloads you a file.
Rename the file to `service_account.json` and put it into the `lib/src/assets`
folder.

> Warning: Use the contents of
[`lib/src/assets`](https://github.com/FirebaseExtended/firebase-dart/tree/master/lib/src/assets)
is only for development and testing this package.

### App tests

No special action needed here.

### Auth tests and example

Auth tests and some examples need to have **Auth providers** correctly set.
The following providers need to be enabled in Firebase console,
`Auth/Sign-in method` section:

* E-mail/password
* Anonymous
* Phone

### Database tests and example

Database tests and example need to have **public rules** to be able to read and
write to database. Update your rules in Firebase console,
`Database/Realtime Database/Rules` section to:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

> Warning: At the moment, anybody can read and write to your database.
You *usually* don't want to have this in your production apps.
You can find more information on how to setup correct database rules in the 
official
[Firebase documentation](https://firebase.google.com/docs/database/security/). 

### Firestore tests and example

To be able to run tests and example, Firestore needs to be enabled in the 
`Database/Cloud Firestore` section. 

Firestore tests and example need to have **public rules** to be able to read and
write to Firestore. Update your rules in Firebase console,
`Database/Cloud Firestore/Rules` section to:

```
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write;
    }
  }
}
```

> Warning: At the moment, anybody can read and write to your Firestore.
You *usually* don't want to have this in your production apps.
You can find more information on how to setup correct Firestore rules in the 
official
[Firebase documentation](https://firebase.google.com/docs/firestore/security/get-started). 

You also need to include the additional `firebase-firestore.js` script.
See [more info](#do-you-need-to-use-firestore).

### Storage tests and example

Storage tests and example need to have **public rules** to be able to read and
write to storage. Firebase Storage Rules Version 2 is
[required](https://firebase.google.com/docs/storage/web/list-files) for `list` and 
`listAll`. Update your rules in Firebase console, `Storage/Rules` section
to:

```
rules_version = '2';
service firebase.storage {
  match /b/YOUR_STORAGE_BUCKET_URL/o {
    match /{allPaths=**} {
      allow read, write;
    }
  }
}
```

> Warning: At the moment, anybody can read and write to your storage.
You *usually* don't want to have this in your production apps.
You can find more information on how to setup correct storage rules in the 
official
[Firebase documentation](https://firebase.google.com/docs/storage/security/). 


### Remote Config example

In order to use Remote Config functionality in your web app, you need to include the following
script in your `.html` file, in addition to the other Firebase scripts:

```html
<script src="https://www.gstatic.com/firebasejs/7.13.1/firebase-remote-config.js"></script>
```

Remote config parameters are defined in Firebase console. Three data types are supported by the API:
String, Number, and Boolean. All values are stored by Firebase as strings. It's your
responsibility to assure that numbers and booleans are defined appropriately. A boolean
value can be represented as either of: `0/1`, `true/false`, `t/f`, `yes/no`, `y/n`, `on/off`.

For example:
```
title: Welcome
counter: 2
flag: true
```

Below is a simple example of consuming remote config:

```dart
final rc = firebase.remoteConfig();
await rc.ensureInitialized();
rc.defaultConfig = {'title': 'Hello', 'counter': 1, 'flag': false};
print('title: ${rc.getString("title")}');             // <-- Hello
print('counter: ${rc.getNumber("counter").toInt()}'); // <-- 1
print('flag: ${rc.getBoolean("flag")}');              // <-- false
await rc.fetchAndActivate();
print('title: ${rc.getString("title")}');             // <-- Welcome
print('counter: ${rc.getNumber("counter").toInt()}'); // <-- 2
print('flag: ${rc.getBoolean("flag")}');              // <-- true
```

Refer to [Remote Config Documentation](https://firebase.google.com/docs/remote-config) for more details.

### Remote Config tests

In order to test remote config, you need to obtain service account credentials
for your Firebase project. Each Firebase project has a default service account
that will work for this purpose. The service account can be found in the 
GCP console by choosing the project, then in the menu: IAM & admin > Service accounts.

Once you have located the service account, choose Actions > Create key. 
Pick JSON as the format. Put the JSON file in `lib/src/assets/service_account.json`. 

Ensure that the remote config for your project is empty. The unit test will refuse 
to run with the following message if it detects that the remote config of the project
is not empty on start: 
```
This unit test requires remote config to be empty.
```
This is done to avoid overwriting your remote config in case if you run the test
in a Firebase project that is used for other purposes.
