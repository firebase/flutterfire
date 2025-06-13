Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{# The following is at site root, /third_party/devsite/firebase/en/ #}
{% include "_local_variables.html" %}

{% include "docs/storage/_local_variables.html" %}

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Get started with Cloud Storage on Flutter

Cloud Storage for Firebase lets you upload and share user generated content, such
as images and video, which allows you to build rich media content into your
apps. Your data is stored in a
[Google Cloud Storage](//cloud.google.com/storage) bucket — an
exabyte scale object storage solution with high availability and global
redundancy. Cloud Storage for Firebase lets you securely upload these files
directly from mobile devices and web browsers, handling spotty networks with
ease.

## Before you begin {: #before-you-begin}

1.  If you haven't already, make sure you've completed the
    [getting started guide for Flutter apps](/docs/flutter/setup).
    This includes:

    * Creating a Firebase project.

    * Installing and initializing the Firebase SDKs for Flutter.

1.  Make sure your Firebase project is on the {{blaze_plan_with_link}}. If
    you're new to Firebase and Google Cloud, check if you're eligible for a
    [$300 credit](/support/faq#pricing-free-trial).

<<../_includes/_changes-sept-2024-notice.md>>

## Create a default Cloud Storage bucket {:#create-default-bucket}

<<../_includes/_create-default-bucket.md>>

## Set up public access {: #set_up_public_access}

Cloud Storage for Firebase provides a declarative rules language that lets you
define how your data should be structured, how it should be indexed, and when
your data can be read from and written to. By default, read and write access to
Cloud Storage is restricted so only authenticated users can read or write
data. To get started without setting up [Firebase Authentication](/docs/auth), you can
[configure your rules for public access](/docs/storage/security/rules-conditions#public).

This does make Cloud Storage open to anyone, even people not using your
app, so be sure to restrict your Cloud Storage again when you set up
authentication.

## Add the Cloud Storage SDK to your app {:#add-sdk}

1.  From the root of your Flutter project, run the following command to install
    the plugin:

    ```bash
    flutter pub add firebase_storage
    ```

1.  Once complete, rebuild your Flutter application:

    ```bash
    flutter run
    ```

1.  Import the plugin in your Dart code:

    ```dart
    import 'package:firebase_storage/firebase_storage.dart';
    ```

## Set up Cloud Storage {:#set-up-cloud-storage}

1.  Run `flutterfire configure` from your Flutter project directory. This
    updates the Firebase config file (`firebase_options.dart`) in your app's
    codebase so that it has the name of your default {{storage}} bucket.

    Note: Alternatively to updating your config file, you can explicitly
    specify the bucket name when you create an instance of `FirebaseStorage`
    (see next step). You can find the bucket name in the
    [{{firebase_storage}} _Files_ tab](https://console.firebase.google.com/project/_/storage/){: .external}
    of the {{name_appmanager}}.

1.  Access your Cloud Storage bucket by creating an instance of
    `FirebaseStorage`:

    ```dart
    final storage = FirebaseStorage.instance;

    // Alternatively, explicitly specify the bucket name URL.
    // final storage = FirebaseStorage.instanceFor(bucket: "gs://<var>BUCKET_NAME</var>");
    ```

You're ready to start using Cloud Storage!

Next step? Learn how to
[create a Cloud Storage reference](create-reference).

## Advanced setup

There are a few use cases that require additional setup:

  - Using Cloud Storage buckets in
    [multiple geographic regions](//cloud.google.com/storage/docs/bucket-locations)
  - Using Cloud Storage buckets in
    [different storage classes](//cloud.google.com/storage/docs/storage-classes)
  - Using Cloud Storage buckets with multiple authenticated users in the same app

The first use case is perfect if you have users across the world, and want to
store their data near them. For instance, you can create buckets in the US,
Europe, and Asia to store data for users in those regions to reduce latency.

The second use case is helpful if you have data with different access patterns.
For instance: you can set up a multi-regional or regional bucket that stores
pictures or other frequently accessed content, and a nearline or coldline bucket
that stores user backups or other infrequently accessed content.

In either of these use cases, you'll want to
[use multiple Cloud Storage buckets](#use_multiple_storage_buckets).

The third use case is useful if you're building an app, like Google Drive, which
lets users have multiple logged in accounts (for instance, a personal account
and a work account). You can
[use a custom Firebase App](#use_a_custom_firebaseapp)
instance to authenticate each additional account.

### Use multiple Cloud Storage buckets {:#use_multiple_storage_buckets}

If you want to use a Cloud Storage bucket other than the default provided above,
or use multiple Cloud Storage buckets in a single app, you can create an instance
of `FirebaseStorage` that references your custom bucket:

```dart
// Get a non-default Storage bucket
final storage = FirebaseStorage.instanceFor(bucket: "gs://my-custom-bucket");
```

### Working with imported buckets

When importing an existing Cloud Storage bucket into Firebase, you'll
have to grant Firebase the ability to access these files using the
`gsutil` tool, included in the
[Google Cloud SDK](//cloud.google.com/sdk/docs/):

```bash
gsutil -m acl ch -r -u service-PROJECT_NUMBER@gcp-sa-firebasestorage.iam.gserviceaccount.com gs://YOUR-CLOUD-STORAGE-BUCKET
```

You can find your project number as described in the [introduction to
Firebase projects](/docs/projects/learn-more#project-number).

This does not affect newly created buckets, as those have the default access
control set to allow Firebase. This is a temporary measure, and will be
performed automatically in the future.

### Use a custom Firebase App {:#use_a_custom_firebaseapp}

If you're building a more complicated app using a custom `FirebaseApp`, you can
create an instance of `FirebaseStorage` initialized with that app:

```dart
// Use a non-default App
final storage = FirebaseStorage.instanceFor(app: customApp);
```


## Next steps

* Prepare to launch your app:
  * Enable [App Check](/docs/app-check) to help ensure that only
    your apps can access your storage buckets.
  * Set up [budget alerts](/docs/projects/billing/avoid-surprise-bills#set-up-budget-alert-emails)
    for your project in the Google Cloud Console.
  * Monitor the [_Usage and billing_ dashboard](//console.firebase.google.com/project/_/usage)
    in the Firebase console to get an overall picture of your project's
    usage across multiple Firebase services. You can also visit the
    [Cloud Storage _Usage_ dashboard](//console.firebase.google.com/project/_/storage/usage) for more
    detailed usage information.
  * Review the [Firebase launch checklist](/support/guides/launch-checklist).
