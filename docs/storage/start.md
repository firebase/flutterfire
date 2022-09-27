Project: /docs/storage/_project.yaml
Book: /docs/_book.yaml
page_type: guide

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


## Prerequisites

[Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup) if you
haven't already done so.


## Create a default Cloud Storage bucket {:#create-default-bucket}

1.  From the navigation pane of the [Firebase console](https://console.firebase.google.com/), select **Storage**,
    then click **Get started**.

1.  Review the messaging about securing your Cloud Storage data using security
    rules. During development, consider
    [setting up your rules for public access](#set_up_public_access).

1.  Select a [location](/docs/projects/locations#types) for your default
    Cloud Storage bucket.

      * This location setting is your project's
        [_default Google Cloud Platform (GCP) resource location_](/docs/firestore/locations#default-cloud-location).
        Note that this location will be used for GCP services in your project
        that require a location setting, specifically, your
        [Cloud Firestore](/docs/firestore) database and your
        [App Engine](//cloud.google.com/appengine/docs/) app
        (which is required if you use Cloud Scheduler).

      * If you aren't able to select a location, then your project already
        has a default GCP resource location. It was set either during project
        creation or when setting up another service that requires a location
        setting.

    If you're on the Blaze plan, you can
    [create multiple buckets](#use_multiple_storage_buckets), each with its own
    [location](//cloud.google.com/storage/docs/bucket-locations).

    Note: After you set your project's default GCP resource location, you
    cannot change it.

1.  Click **Done**.


## Set up public access {:#set_up_public_access}

Cloud Storage for Firebase provides a declarative rules language that allows you
to define how your data should be structured, how it should be indexed, and when
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

The first step in accessing your Cloud Storage bucket is to create an
instance of `FirebaseStorage`:

```dart
final storage = FirebaseStorage.instance;
```

You're ready to start using Cloud Storage!

First, let's learn how to [create a Cloud Storage reference](create-reference).

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
  * Enable [App Check](/docs/app-check/overview) to help ensure that only
    your apps can access your storage buckets.
  * Set up [budget alerts](/docs/projects/billing/avoid-surprise-bills#set-up-budget-alert-emails)
    for your project in the Google Cloud Console.
  * Monitor the [_Usage and billing_ dashboard](//console.firebase.google.com/project/_/usage)
    in the Firebase console to get an overall picture of your project's
    usage across multiple Firebase services. You can also visit the
    [Cloud Storage _Usage_ dashboard](//console.firebase.google.com/project/_/storage/usage) for more
    detailed usage information.
  * Review the [Firebase launch checklist](/support/guides/launch-checklist).
