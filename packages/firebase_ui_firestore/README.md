# Firebase UI for Firestore

Firebase UI for Firestore enables you to easily integrate your application UI with your Cloud
Firestore database.

## Installation

```sh
flutter pub add cloud_firestore
flutter pub add firebase_ui_firestore
```

## Usage

Import the Firebase UI for Firestore package:

```dart
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
```

### Infinite scrolling

Infinite scrolling is the concept of continuously loading more data from a database
as the user scrolls through your application. This is useful when you have a large
datasets, as it enables the application to render faster as well as reduces network
overhead for data the user might never see.

Firebase UI for Firestore provides a convenient way to implement infinite scrolling
using the Firestore database with the `FirestoreListView` widget.

At a minimum the widget accepts a Firestore query and an item builder. As the user scrolls
down (or across) your list, more data will be automatically fetched from the database (whilst
respecting query conditions such as ordering).

To get started, create a query and provide an item builder. For this example, we'll display
a list of users from the `users` collection:

```dart
final usersQuery = FirebaseFirestore.instance.collection('users').orderBy('name');

FirestoreListView<Map<String, dynamic>>(
  query: usersQuery,
  itemBuilder: (context, snapshot) {
    Map<String, dynamic> user = snapshot.data();

    return Text('User name is ${user['name']}');
  },
);
```

The `FirestoreListView` widget is built on-top of Flutter's own [`ListView`](https://api.flutter.dev/flutter/widgets/ListView-class.html)
widget, and accepts the same parameters which we can optionally provide. For example, to change the scroll-direction to horizontal:

```dart
FirestoreListView<Map<String, dynamic>>(
  scrollDirection: Axis.horizontal,
  // ...
);
```

### Controlling page size

By default, the widget will fetch 10 items from the collection at a time. This can be changed by providing a `pageSize` parameter:

```dart
FirestoreListView<Map<String, dynamic>>(
  pageSize: 20,
  // ...
);
```

In general, it is good practice to keep this value as small as possible to reduce network overhead. If the height (or width)
of an individual item is large, it is recommended to lower the page size.

### Using typed responses

The `cloud_firestore` plugin allows us to type the responses we receive from the database using the `withConverter` API. For more information,
see [the documentation](https://firebase.google.com/docs/firestore/query-data/get-data#custom_objects).

The `FirestoreListView` works with this out of the box. Simply provide a converted query to the widget, for example:

```dart
class User {
  User({required this.name, required this.age});

  User.fromJson(Map<String, Object?> json)
    : this(
        name: json['name']! as String,
        age: json['age']! as int,
      );

  final String name;
  final int age;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }
}

final usersQuery = FirebaseFirestore.instance.collection('users')
  .orderBy('name')
  .withConverter<User>(
     fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
     toFirestore: (user, _) => user.toJson(),
   );

FirestoreListView<User>(
  query: usersQuery,
  itemBuilder: (context, snapshot) {
    // Data is now typed!
    User user = snapshot.data();

    return Text(user.name);
  },
);
```

### Loading and error handling

By default, the widget will display a loading indicator while data is being fetched from the database, and ignore any errors which might be thrown
(such as permission denied). You can override this behavior by providing a `loadingBuilder` and `errorBuilder` parameters to the widget:

```dart
FirestoreListView<Map<String, dynamic>>(
  loadingBuilder: (context) => MyCustomLoadingIndicator(),
  errorBuilder: (context, error, stackTrace) => MyCustomError(error, stackTrace),
  // ...
);
```

### Advanced configuration

In many cases, the `FirestoreListView` widget is enough to render simple lists of collection data.
However, you may have specific requirements which require more control over the widget's behavior
(such as using a [`GridView`](https://api.flutter.dev/flutter/widgets/GridView-class.html)).

The `FirestoreQueryBuilder` provides the building blocks for advanced configuration at the expense of
requiring more boilerplate code. The widget does not provide any underlying list implementation, instead
you are expected to provide this yourself.

Much like the `FirestoreListView` widget, provide a query and builder:

```dart
final usersQuery = FirebaseFirestore.instance.collection('users').orderBy('name');

FirestoreQueryBuilder<Map<String, dynamic>>(
  query: usersQuery,
  builder: (context, snapshot, _) {
    // ... TODO!
  },
);
```

The main difference to note here is that the `builder` property returns a `QueryBuilderSnapshot`, rather
than an individual document. The builder returns the current state of the entire query, such as whether
data is loading, an error has occurred and the documents.

This requires us to implement our own list based implementation. Firstly, let's handle the loading and error
states:

```dart
FirestoreQueryBuilder<Map<String, dynamic>>(
  query: usersQuery,
  builder: (context, snapshot, _) {
    if (snapshot.isFetching) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Something went wrong! ${snapshot.error}');
    }

    // ...
  },
);
```

Next, we now need to return a list-view based implementation for our application to display the data. For example,
to display a grid of users, we can use the [`GridView`](https://api.flutter.dev/flutter/widgets/GridView-class.html) widget:

```dart
FirestoreQueryBuilder<Map<String, dynamic>>(
  query: usersQuery,
  builder: (context, snapshot, _) {
    // ...

    return GridView.builder(
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        // if we reached the end of the currently obtained items, we try to
        // obtain more items
        if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
          // Tell FirestoreQueryBuilder to try to obtain more items.
          // It is safe to call this function from within the build method.
          snapshot.fetchMore();
        }

        final user = snapshot.docs[index].data();

        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[100],
          child: const Text("User name is ${user['name']}"),
        );
      },
    );
  },
);
```

With more power comes more responsibility:

1. Within the `itemBuilder` of our `GridView`, we have to manually ensure that we call the `fetchMore()` method on the snapshot when more data is required.
1. The `FirestoreQueryBuilder` does not provide a list-view based handler, instead you must provide your own implementation.
