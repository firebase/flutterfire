Project: /docs/database/_project.yaml
Book: /docs/_book.yaml
page_type: guide

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Get Started with Realtime Database

## Prerequisites

1. [Install `firebase_core`](/docs/flutter/setup) and add the initialization code
   to your app if you haven't already.
1. Add your app to your Firebase project in the <a href="https://console.firebase.google.com/">Firebase console</a>.

## Create a Database

{# TODO(markarndt): Decide whether to include common files instead. #}

1.  Navigate to the **Realtime Database** section of the <a href="https://console.firebase.google.com/project/_/database">Firebase console</a>.
    You'll be prompted to select an existing Firebase project.
    Follow the database creation workflow.

1.  Select a starting mode for your security rules:

    **Test mode**

      Good for getting started with the mobile and web client libraries,
      but allows anyone to read and overwrite your data. After testing, **make
      sure to review the [Understand Firebase Realtime Database Rules](/docs/database/security/)
      section.**

    Note: If you create a database in Test mode and make no changes to the
      default world-readable and world-writeable security rules within a trial
      period, you will be alerted by email, then your database rules will
      deny all requests. Note the expiration date during the Firebase console
      setup flow.


    To get started, select testmode.

    **Locked mode**

    Denies all reads and writes from mobile and web clients.
      Your authenticated application servers can still access your database.

1.  Choose a region for the database. Depending on your choice of region,
    the database namespace will be of the form `<databaseName>.firebaseio.com` or
    `<databaseName>.<region>.firebasedatabase.app`. For more information, see
    [select locations for your project](/docs/projects/locations.md##rtdb-locations).

1.  Click **Done**.

When you enable Realtime Database, it also enables the API in the
[Cloud API Manager](https://console.cloud.google.com/projectselector/apis/api/firebasedatabase.googleapis.com/overview).

## Add Firebase Realtime Database to your app

1.  From the root of your Flutter project, run the following command to install the plugin:

    ```bash
    flutter pub add firebase_database
    ```
1.  Once complete, rebuild your Flutter application:

    ```bash
    flutter run
    ```

## Configure database rules

The Realtime Database provides a declarative rules language that allows you to
define how your data should be structured, how it should be indexed, and when
your data can be read from and written to.

<<_usecase_security_preamble.md>>

## Initialize the Firebase Realtime Database package

To start using the Realtime Database package within your project, import it at
the top of your project files:

```dart
import 'package:firebase_database/firebase_database.dart';
```

To use the default Database instance, call the `instance`
getter on `FirebaseDatabase`:

```dart
FirebaseDatabase database = FirebaseDatabase.instance;
```

If you'd like to use it with a secondary Firebase App, use the `instanceFor` method:

```dart
FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
FirebaseDatabase database = FirebaseDatabase.instanceFor(app: secondaryApp);
```

## Next Steps

* Learn how to [structure data](structure-data) for Realtime Database.

* [Scale your data across multiple database instances.](/docs/database/usage/sharding)

* [Read and write data.](read-and-write)

* [View your database in the
  Firebase console.](//console.firebase.google.com/project/_/database/data)
