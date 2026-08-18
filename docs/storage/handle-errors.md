Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{# The following is at site root, /third_party/devsite/firebase/en/ #}
{% include "_local_variables.html" %}

{% include "docs/storage/_local_variables.html" %}

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

<<../_includes/_restrict_access_to_bucket_note.md>>

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
`storage/quota-exceeded`         | Quota on your {{firebase_storage}} bucket has been exceeded. If you're on the {{spark_plan_no_link_short}}, consider upgrading to the {{blaze_plan_with_link}}. If you're already on the {{blaze_plan_no_link_short}}, reach out to Firebase Support.<br><br>**Important**: Starting {{date_require_blaze_maintain_access_to_storage}}, the [{{blaze_plan_no_link_short}} will be _required_ to use {{firebase_storage}}](/docs/storage/faqs-storage-changes-announced-sept-2024), even default buckets.
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
`storage/server-file-wrong-size` | File on the client does not match the size of the file received by the server. Try uploading again.
