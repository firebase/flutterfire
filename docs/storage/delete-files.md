Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{# The following is at site root, /third_party/devsite/firebase/en/ #}
{% include "_local_variables.html" %}

{% include "docs/storage/_local_variables.html" %}

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Delete files with Cloud Storage on Flutter

After uploading files to Cloud Storage, you can also delete them.

<<../_includes/_restrict_access_to_bucket_note.md>>

## Delete a File

To delete a file, first [create a reference](create-reference)
to that file. Then call the `delete()` method on that reference.

```dart
// Create a reference to the file to delete
final desertRef = storageRef.child("images/desert.jpg");

// Delete the file
await desertRef.delete();
```

Warning: Deleting a file is a permanent action! If you care about restoring
deleted files, make sure to back up your files, or
[enable Object Versioning](https://cloud.google.com/storage/docs/using-object-versioning#set)
on your Cloud Storage bucket.


## Handle Errors

There are a number of reasons why errors may occur on file deletes,
including the file not existing, or the user not having permission
to delete the desired file. More information on errors can be found in the
[Handle Errors](handle-errors) section of the docs.
