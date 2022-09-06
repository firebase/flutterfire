Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Create a Cloud Storage reference on Flutter

Your files are stored in a
[Cloud Storage](//cloud.google.com/storage) bucket. The
files in this bucket are presented in a hierarchical structure, just like the
file system on your local hard disk, or the data in the Firebase Realtime Database.
By creating a reference to a file, your app gains access to it. These references
can then be used to upload or download data, get or update metadata or delete
the file. A reference can either point to a specific file or to a higher level
node in the hierarchy.

If you've used the [Firebase Realtime Database](/docs/database), these paths should
seem very familiar to you. However, your file data is stored in
Cloud Storage, **not** in the Realtime Database.


## Create a Reference

Create a reference to upload, download, or delete a file,
or to get or update its metadata. A reference
can be thought of as a pointer to a file in the cloud. References are
lightweight, so you can create as many as you need. They are also reusable for
multiple operations.

Create a reference using the `FirebaseStorage` singleton instance and
calling its `ref()` method.

```dart
final storageRef = FirebaseStorage.instance.ref();
```

Next, you can create a reference to a location lower in the tree,
say `"images/space.jpg"` by using the `child()` method on an existing reference.

```dart
// Create a child reference
// imagesRef now points to "images"
final imagesRef = storageRef.child("images");

// Child references can also take paths
// spaceRef now points to "images/space.jpg
// imagesRef still points to "images"
final spaceRef = storageRef.child("images/space.jpg");
```

## Navigate with References

You can also use the `parent` and `root` properties to navigate up in our
file hierarchy. `parent` navigates up one level,
while `root` navigates all the way to the top.

```dart
// parent allows us to move our reference to a parent node
// imagesRef2 now points to 'images'
final imagesRef2 = spaceRef.parent;

// root allows us to move all the way back to the top of our bucket
// rootRef now points to the root
final rootRef = spaceRef.root;
```

`child()`, `parent`, and `root` can be chained together multiple
times, as each is a reference. But accessing `root.parent` results in `null`.

```dart
// References can be chained together multiple times
// earthRef points to 'images/earth.jpg'
final earthRef = spaceRef.parent?.child("earth.jpg");

// nullRef is null, since the parent of root is null
final nullRef = spaceRef.root.parent;
```


## Reference Properties

You can inspect references to better understand the files they point to
using the `fullPath`, `name`, and `bucket` properties. These properties
get the file's full path, name and bucket.

```dart
// Reference's path is: "images/space.jpg"
// This is analogous to a file path on disk
spaceRef.fullPath;

// Reference's name is the last segment of the full path: "space.jpg"
// This is analogous to the file name
spaceRef.name;

// Reference's bucket is the name of the storage bucket that the files are stored in
spaceRef.bucket;
```

## Limitations on References

Reference paths and names can contain any sequence of valid Unicode characters,
but certain restrictions are imposed including:

1. Total length of reference.fullPath must be between 1 and 1024 bytes when UTF-8 encoded.
1. No Carriage Return or Line Feed characters.
1. Avoid using `#`, `[`, `]`, `*`, or `?`, as these do not work well with
   other tools such as the [Firebase Realtime Database](/docs/database/overview)
   or [gsutil](https://cloud.google.com/storage/docs/gsutil).

## Full Example

```dart
// Points to the root reference
final storageRef = FirebaseStorage.instance.ref();

// Points to "images"
Reference? imagesRef = storageRef.child("images");

// Points to "images/space.jpg"
// Note that you can use variables to create child values
final fileName = "space.jpg";
final spaceRef = imagesRef.child(fileName);

// File path is "images/space.jpg"
final path = spaceRef.fullPath;

// File name is "space.jpg"
final name = spaceRef.name;

// Points to "images"
imagesRef = spaceRef.parent;
```

Next, let's learn how to [upload files](upload-files) to Cloud Storage.
