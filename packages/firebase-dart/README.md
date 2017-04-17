# Dart wrapper library for the new Firebase

[![Build Status](https://travis-ci.org/firebase/firebase-dart.svg?branch=master)](https://travis-ci.org/firebase/firebase-dart)

This is a Dart wrapper library for the new 
[Firebase](https://firebase.google.com). 

You can find more information on how to use Firebase on the
[Getting started](https://firebase.google.com/docs/web/setup) page.

Don't forget to setup correct **rules** for your
[realtime database](https://firebase.google.com/docs/database/security/)
and/or
[storage](https://firebase.google.com/docs/storage/security/)
in the Firebase console. 

Authentication also has to be enabled in the Firebase console.
For more info, see the
[next section](https://github.com/firebase/firebase-dart#before-tests-and-examples-are-run)
in this document.

## Usage

### Installation

Install the library from the pub or Github:

```yaml
dependencies:
  firebase: '^3.0.0'
```

### Include Firebase source

You must include the original Firebase JavaScript source into your `.html` file
to be able to use the library.

```html
<script src="https://www.gstatic.com/firebasejs/3.7.8/firebase.js"></script>
```

### Use it

```dart
import 'package:firebase/firebase.dart' as fb;

void main() {
  fb.initializeApp(
    apiKey: "YourApiKey",
    authDomain: "YourAuthDomain",
    databaseURL: "YourDatabaseUrl",
    storageBucket: "YourStorageBucket");

  fb.Database database = fb.database();
  fb.DatabaseReference ref = database.ref("messages");

  ref.onValue.listen((e) {
    fb.DataSnapshot datasnapshot = e.snapshot;
    // Do something with datasnapshot
  });
}
```

### IO Client

This library also contains an IO client. Create an instance of `FirebaseClient` and then use the appropriate
method (`GET`, `PUT`, `POST`, `DELETE` or `PATCH`).
More info in the [official documentation](https://firebase.google.com/docs/reference/rest/database/).

The IO client also supports authentication. See the documentation on how to get
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

You can find more examples on realtime database, auth and storage in the
[example](https://github.com/firebase/firebase-dart/tree/master/example) folder.

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
[`lib/src/assets`](https://github.com/firebase/firebase-dart/tree/master/lib/src/assets)
is only for development and testing this package.

### App tests

No special action needed here.

### Auth tests and example

Auth tests and some examples need to have **Auth providers** correctly set.
The following providers need to be enabled in Firebase console,
`Auth/Sign-in method` section:

* E-mail/password
* Anonymous

### Database tests and example

Database tests and example need to have **public rules** to be able to read and
write to database. Update your rules in Firebase console, `Database/Rules`
section to:

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

### Storage tests and example

Storage tests and example need to have **public rules** to be able to read and
write to storage. Update your rules in Firebase console, `Storage/Rules` section
to:

```
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


## Bugs

If you find a bug, please file an
[issue](https://github.com/firebase/firebase-dart/issues).
