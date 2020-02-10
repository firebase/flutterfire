# cloud_firestore_web

The web implementation of [`cloud_firestore`][1].

## Usage

### Import the package

To use this plugin in your Flutter app on the web, simply add it as a
dependency in your `pubspec.yaml` alongside the base `cloud_firestore`
plugin.

_(This is only temporary: in the future we hope to make this package
an "endorsed" implementation of `cloud_firestore`, so it will automatically
be included in your app when you run your Flutter app on the web.)_

Add this to your `pubspec.yaml`:

```yaml
...
dependencies:
  ...
  cloud_firestore: ^0.13.1
  cloud_firestore_web: ^0.1.0
  ...
```

### Updating `index.html`

Due to [this bug in dartdevc][2], you will need to manually add the Firebase
JavaScript files to your `index.html` file.

In your app directory, edit `web/index.html` to add the line:

```html
<html>
    ...
    <body>
        <script src="https://www.gstatic.com/firebasejs/7.5.0/firebase-app.js"></script>
        <script src="https://www.gstatic.com/firebasejs/7.5.0/firebase-firestore.js"></script>
        <script src="main.dart.js"></script>
    </body>
</html>
```

### Using the plugin

Once you have added the `cloud_firebase_web` dependency to your pubspec,
you can use `package:cloud_firebase` as normal.

[1]: ../cloud_firestore
[2]: https://github.com/dart-lang/sdk/issues/33979
