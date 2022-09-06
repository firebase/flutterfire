Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Use file metadata with Cloud Storage on Flutter

After uploading a file to Cloud Storage reference, you can also get
and update the file metadata, for example to view or update the content type.
Files can also store custom key/value pairs with additional file metadata.

Note: By default, a Cloud Storage bucket requires Firebase Authentication to
perform any action on the bucket's data or files. You can
[change your Firebase Security Rules for Cloud Storage](/docs/storage/security/rules-conditions#public)
to allow unauthenticated access. Since Firebase and your project's default
App Engine app share this bucket, configuring public access may make newly
uploaded App Engine files publicly accessible, as well. Be sure to restrict
access to your Cloud Storage bucket again when you set up Authentication.



## Get File Metadata

File metadata contains common properties such as `name`, `size`, and
`contentType` (often referred to as MIME type) in addition to some less
common ones like `contentDisposition` and `timeCreated`. This metadata can be
retrieved from a Cloud Storage reference using
the `getMetadata()` method.

```dart
// Create reference to the file whose metadata we want to retrieve
final forestRef = storageRef.child("images/forest.jpg");

// Get metadata properties
final metadata = await forestRef.getMetadata();

// Metadata now contains the metadata for 'images/forest.jpg'
```


## Update File Metadata

You can update file metadata at any time after the file upload completes by
using the `updateMetadata()` method. Refer to the
[full list](#file-metadata-properties) for more information on what properties
can be updated. Only the properties specified in the metadata are updated,
all others are left unmodified.

```dart
// Create reference to the file whose metadata we want to change
final forestRef = storageRef.child("images/forest.jpg");

// Create file metadata to update
final newMetadata = SettableMetadata(
  cacheControl: "public,max-age=300",
  contentType: "image/jpeg",
);

// Update metadata properties
final metadata = await forestRef.updateMetadata(newMetadata);

// Updated metadata for 'images/forest.jpg' is returned
```

You can delete writable metadata properties by passing `null`:

```dart
// Delete the cacheControl property
final newMetadata = SettableMetadata(cacheControl: null);
final metadata = await forestRef.updateMetadata(newMetadata);
```


## Handle Errors

There are a number of reasons why errors may occur on getting or updating
metadata, including the file not existing, or the user not having permission
to access the desired file. More information on errors can be found in the
[Handle Errors](handle-errors) section of the docs.

## Custom Metadata

You can specify custom metadata using the `customMetadata` parameter of the
`SettableMetadata` constructor:

```dart
// Create reference to the file whose metadata we want to change
final forestRef = storageRef.child("images/forest.jpg");

// Create file metadata to update
final newCustomMetadata = SettableMetadata(
  customMetadata: {
    "location": "Yosemite, CA, USA",
    "activity": "Hiking",
  },
);

// Update metadata properties
final metadata = await forestRef.updateMetadata(newCustomMetadata);

// Updated metadata for 'images/forest.jpg' is returned
```

You can store app-specific data for each file in custom metadata, but we highly
recommend using a database (such as the
[Firebase Realtime Database](/docs/database/overview)) to store and synchronize this type of
data.


## File Metadata Properties {:#file-metadata-properties}

A full list of metadata properties on a file is available below:

Property             | Type                  | Settable?
---------------------|-----------------------|----------
`bucket`             | `String`              | No
`generation`         | `String`              | No
`metageneration`     | `String`              | No
`metadataGeneration` | `String`              | No
`fullPath`           | `String`              | No
`name`               | `String`              | No
`size`               | `int`                 | No
`timeCreated`        | `DateTime`            | No
`updated`            | `DateTime`            | No
`md5Hash`            | `String`              | No
`cacheControl`       | `String`              | Yes
`contentDisposition` | `String`              | Yes
`contentEncoding`    | `String`              | Yes
`contentLanguage`    | `String`              | Yes
`contentType`        | `String`              | Yes
`customMetadata`     | `Map<String, String>` | Yes

Uploading, downloading, and updating files is important, but so is being able
to remove them. Let's learn how to [delete files](delete-files)
from Cloud Storage.
