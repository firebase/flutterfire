# Cloud Firestore Plugin for Flutter

A Flutter plugin to use the [Cloud Firestore API](https://firebase.google.com/docs/firestore/).

[![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dartlang.org/packages/cloud_firestore)

For Flutter plugins for other Firebase products, see [README.md](https://github.com/FirebaseExtended/flutterfire/blob/master/README.md).

## Setup

To use this plugin:

1. Add `cloud_firestore` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

### Android

1. Using the [Firebase Console](http://console.firebase.google.com/), add an Android app to your project.
2. Follow the assistant, and download the generated `google-services.json` file and place it inside `android/app`.
3. Modify the `android/build.gradle` file and the `android/app/build.gradle` file to add the Google services plugin as described by the Firebase assistant. Ensure that your `android/build.gradle` file contains the
`maven.google.com` as [described here](https://firebase.google.com/docs/android/setup#add_the_sdk).

### iOS

1. Using the [Firebase Console](http://console.firebase.google.com/), add an iOS app to your project.
2. Follow the assistant, download the generated `GoogleService-Info.plist` file. Do **NOT** follow the steps named _"Add Firebase SDK"_ and _"Add initialization code"_ in the Firebase assistant.
3. Open `ios/Runner.xcworkspace` with Xcode, and **within Xcode** place the `GoogleService-Info.plist` file inside `ios/Runner`.

### Web

In addition to the `cloud_firestore` dependency, you'll need to modify the `web/index.html` of your app following the Firebase setup instructions:

* [Add Firebase to your JavaScript project](https://firebase.google.com/docs/web/setup#from-the-cdn).

Read more in the [`cloud_firestore_web` README](https://github.com/FirebaseExtended/flutterfire/blob/master/packages/cloud_firestore/cloud_firestore_web/README.md).

## Usage

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
```

Adding a new `DocumentReference`:

```dart
Firestore.instance.collection('books').document()
  .setData({ 'title': 'title', 'author': 'author' });
```

Binding a `CollectionReference` to a `ListView`:

```dart
class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('books').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
                return new ListTile(
                  title: new Text(document['title']),
                  subtitle: new Text(document['author']),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
```

Performing a query:
```dart
Firestore.instance
    .collection('talks')
    .where("topic", isEqualTo: "flutter")
    .snapshots()
    .listen((data) =>
        data.documents.forEach((doc) => print(doc["title"])));
```

Get a specific document:

```dart
Firestore.instance
        .collection('talks')
        .document('document-name')
        .get()
        .then((DocumentSnapshot ds) {
      // use ds as a snapshot
    });
```

Running a transaction:

```dart
final DocumentReference postRef = Firestore.instance.document('posts/123');
Firestore.instance.runTransaction((Transaction tx) async {
  DocumentSnapshot postSnapshot = await tx.get(postRef);
  if (postSnapshot.exists) {
    await tx.update(postRef, <String, dynamic>{'likesCount': postSnapshot.data['likesCount'] + 1});
  }
});
```

## Getting Started

See the `example` directory for a complete sample app using Cloud Firestore.

## Issues and feedback

Please file Flutterfire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md),
and send a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
