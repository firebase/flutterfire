Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Handle errors for Cloud Storage on Flutter

Sometimes when you're building an app, things don't go as planned and an
error occurs!

When in doubt, catch the exception thrown by the function
and see what the error message has to say.

```dart
final storageRef = FirebaseStorage.instance.ref().child("files/uid");
try {
  final listResult = await storageRef.listAll();
} on FirebaseException catch (e) {
  // Caught an exception from Firebase.
  print("Failed with error '${e.code}': ${e.message}");
}
```

Note: By default, a Cloud Storage bucket requires Firebase Authentication to
perform any action on the bucket's data or files. You can
[change your Firebase Security Rules for Cloud Storage](/docs/storage/security/rules-conditions#public)
to allow unauthenticated access. Since Firebase and your project's default
App Engine app share this bucket, configuring public access may make newly
uploaded App Engine files publicly accessible, as well. Be sure to restrict
access to your Cloud Storage bucket again when you set up Authentication.


## Handle Error Messages

There are a number of reasons why errors may occur, including the file
not existing, the user not having permission to access the desired file, or the
user cancelling the file upload.

To properly diagnose the issue and handle the error, here is a full list of
all the errors our client will raise, and how they occurred.

Code                             | Description
---------------------------------|--------------------------------------------
`storage/unknown`                | An unknown error occurred.
`storage/object-not-found`       | No object exists at the desired reference.
`storage/bucket-not-found`       | No bucket is configured for Cloud Storage
`storage/project-not-found`      | No project is configured for Cloud Storage
`storage/quota-exceeded`         | Quota on your Cloud Storage bucket has been exceeded. If you're on the no-cost tier, upgrade to a paid plan. If you're on a paid plan, reach out to Firebase support.
`storage/unauthenticated`        | User is unauthenticated, please authenticate and try again.
`storage/unauthorized`           | User is not authorized to perform the desired action, check your security rules to ensure they are correct.
`storage/retry-limit-exceeded`   | The maximum time limit on an operation (upload, download, delete, etc.) has been excceded. Try uploading again.
`storage/invalid-checksum`       | File on the client does not match the checksum of the file received by the server. Try uploading again.
`storage/canceled`               | User canceled the operation.
`storage/invalid-event-name`     | Invalid event name provided. Must be one of [`running`, `progress`, `pause`]
`storage/invalid-url`            | Invalid URL provided to `refFromURL()`. Must be of the form: `gs://bucket/object` or `https://firebasestorage.googleapis.com/v0/b/bucket/o/object?token=<TOKEN>`
`storage/invalid-argument`       | The argument passed to `put()` must be `File`, `Blob`, or `UInt8` Array. The argument passed to `putString()` must be a raw, `Base64`, or `Base64URL` string.
`storage/no-default-bucket`      | No bucket has been set in your config's `storageBucket` property.
`storage/cannot-slice-blob`      | Commonly occurs when the local file has changed (deleted, saved again, etc.). Try uploading again after verifying that the file hasn't changed.
`storage/server-file-wrong-size` | File on the client does not match the size of the file recieved by the server. Try uploading again.
