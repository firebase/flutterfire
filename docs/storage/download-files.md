Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Download files with Cloud Storage on Flutter

Cloud Storage for Firebase allows you to quickly and easily download
files from a [Cloud Storage](//cloud.google.com/storage)
bucket provided and managed by Firebase.

Note: By default, a Cloud Storage bucket requires Firebase Authentication to
perform any action on the bucket's data or files. You can
[change your Firebase Security Rules for Cloud Storage](/docs/storage/security/rules-conditions#public)
to allow unauthenticated access. Since Firebase and your project's default
App Engine app share this bucket, configuring public access may make newly
uploaded App Engine files publicly accessible, as well. Be sure to restrict
access to your Cloud Storage bucket again when you set up Authentication.



## Create a Reference

To download a file, first [create a Cloud Storage reference](create-reference)
to the file you want to download.

You can create a reference by appending child paths to the root of your
Cloud Storage bucket, or you can create a reference from an existing
`gs://` or `https://` URL referencing an object in Cloud Storage.

```dart
// Create a storage reference from our app
final storageRef = FirebaseStorage.instance.ref();

// Create a reference with an initial file path and name
final pathReference = storageRef.child("images/stars.jpg");

// Create a reference to a file from a Google Cloud Storage URI
final gsReference =
    FirebaseStorage.instance.refFromURL("gs://YOUR_BUCKET/images/stars.jpg");

// Create a reference from an HTTPS URL
// Note that in the URL, characters are URL escaped!
final httpsReference = FirebaseStorage.instance.refFromURL(
    "https://firebasestorage.googleapis.com/b/YOUR_BUCKET/o/images%20stars.jpg");
```


## Download Files

Once you have a reference, you can download files from Cloud Storage
by calling the `getData()` or `getStream()`. If you prefer to download the file
with another library, you can get a download URL with `getDownloadUrl()`.

### Download in memory

Download the file to a `UInt8List` with the `getData()` method. This is the
easiest way to download a file, but it must load the entire contents of
your file into memory. If you request a file larger than your app's available
memory, your app will crash. To protect against memory issues, `getData()`
takes a maximum amount of bytes to download. Set the maximum size to something
you know your app can handle, or use another download method.

```dart
final islandRef = storageRef.child("images/island.jpg");

try {
  const oneMegabyte = 1024 * 1024;
  final Uint8List? data = await islandRef.getData(oneMegabyte);
  // Data for "images/island.jpg" is returned, use this as needed.
} on FirebaseException catch (e) {
  // Handle any errors.
}
```

### Download to a local file

The `writeToFile()` method downloads a file directly to a local device. Use this if
your users want to have access to the file while offline or to share the file in a
different app. `writeToFile()` returns a `DownloadTask` which you can use to manage
your download and monitor the status of the download.

```dart
final islandRef = storageRef.child("images/island.jpg");

final appDocDir = await getApplicationDocumentsDirectory();
final filePath = "${appDocDir.absolute}/images/island.jpg";
final file = File(filePath);

final downloadTask = islandRef.writeToFile(file);
downloadTask.snapshotEvents.listen((taskSnapshot) {
  switch (taskSnapshot.state) {
    case TaskState.running:
      // TODO: Handle this case.
      break;
    case TaskState.paused:
      // TODO: Handle this case.
      break;
    case TaskState.success:
      // TODO: Handle this case.
      break;
    case TaskState.canceled:
      // TODO: Handle this case.
      break;
    case TaskState.error:
      // TODO: Handle this case.
      break;
  }
});
```

## Download Data via URL

If you already have download infrastructure based around URLs, or just want
a URL to share, you can get the download URL for a file by calling the
`getDownloadURL()` method on a Cloud Storage reference.

```dart
final imageUrl =
    await storageRef.child("users/me/profile.png").getDownloadURL();
```

## Handle Errors

There are a number of reasons why errors may occur on download, including the
file not existing, or the user not having permission to access the desired file.
More information on errors can be found in the [Handle Errors](handle-errors)
section of the docs.

## Full Example

A full example of a download with error handling is shown below:

```dart
final islandRef = storageRef.child("images/island.jpg");

final appDocDir = await getApplicationDocumentsDirectory();
final filePath = "${appDocDir.absolute}/images/island.jpg";
final file = File(filePath);

final downloadTask = islandRef.writeToFile(file);
downloadTask.snapshotEvents.listen((taskSnapshot) {
  switch (taskSnapshot.state) {
    case TaskState.running:
      // TODO: Handle this case.
      break;
    case TaskState.paused:
      // TODO: Handle this case.
      break;
    case TaskState.success:
      // TODO: Handle this case.
      break;
    case TaskState.canceled:
      // TODO: Handle this case.
      break;
    case TaskState.error:
      // TODO: Handle this case.
      break;
  }
});
```

You can also [get and update metadata](file-metadata) for files that are stored
in Cloud Storage.
