# firebase_core_web

The web implementation of [`firebase_core`][1].

## Usage

### Import the package

This package is the endorsed implementation of `firebase_core` for the web platform since version `0.4.3`, so it gets automatically added to your dependencies by depending on `firebase_core: ^0.4.3`.

No modifications to your `pubspec.yaml` should be required in a recent enough version of Flutter (`>=1.12.13+hotfix.4`):

```yaml
...
dependencies:
  ...
  firebase_core: ^0.4.3
  ...
```

### Updating `index.html`

Due to [this bug in dartdevc][2], you will need to manually add the Firebase JavaScript file to your `index.html` file.

In your app directory, edit `web/index.html` to add the line:

```html
<html>
    ...
    <body>
        <script src="https://www.gstatic.com/firebasejs/7.5.0/firebase-app.js"></script>
        <!-- Other firebase SDKs/config here -->
        <script src="main.dart.js"></script>
    </body>
</html>
```

### Initialize Firebase

If your app is using the "default" Firebase app, you need to initialize it now, following the steps in the [Firebase Web Setup][3] docs.

Specifically, you'll want to add the following lines to your `web/index.html` file:

```html
<body>
  <!-- Previously loaded Firebase SDKs -->

  <!-- ADD THIS BEFORE YOUR main.dart.js SCRIPT -->
  <script>
    // TODO: Replace the following with your app's Firebase project configuration.
    // See: https://support.google.com/firebase/answer/7015592
    var firebaseConfig = {
      apiKey: "...",
      authDomain: "[YOUR_PROJECT].firebaseapp.com",
      databaseURL: "https://[YOUR_PROJECT].firebaseio.com",
      projectId: "[YOUR_PROJECT]",
      storageBucket: "[YOUR_PROJECT].appspot.com",
      messagingSenderId: "...",
      appId: "1:...:web:...",
      measurementId: "G-..."
    };
    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
  </script>
  <!-- END OF FIREBASE INIT CODE -->

  <script src="main.dart.js"></script>
</body> 
```

### Using the plugin

Once you have modified your `web/index.html` file you should be able to use `package:firebase_core` as normal.

[1]: ../firebase_core/firebase_core
[2]: https://github.com/dart-lang/sdk/issues/33979
[3]: https://firebase.google.com/docs/web/setup#add-sdks-initialize
