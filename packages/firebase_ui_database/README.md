# Firebase UI for Realtime Database

Firebase UI enables you to easily integrate your application UI with your Realtime database.

## Installation

```sh
flutter pub add firebase_database
flutter pub add firebase_ui_database
```

## Usage

Import the Firebase UI for Realtime Database package.

```dart
import 'package:firebase_ui_database/firebase_ui_database.dart';
```

### Infinite scrolling

Infinite scrolling is the concept of continuously loading more data from a database
as the user scrolls through your application. This is useful when you have a large
datasets, as it enables the application to render faster as well as reducing network
overhead for data the user might never see.

Firebase UI for Realtime Database provides a convenient way to implement infinite scrolling
using the Realtime Database database with the `FirebaseDatabaseListView` widget.

At a minimum, the widget accepts a Realtime Database query and an item builder. As the user scrolls
down (or across) your list, more data will be automatically fetched from the database (whilst
respecting query conditions such as ordering).

To get started, create a query and provide an item builder. For this example, we'll display
a list of users from the `users` collection:

```dart
final usersQuery = FirebaseDatabase.instance.ref('users').orderByChild('name');

FirebaseDatabaseListView(
  query: usersQuery,
  itemBuilder: (context, snapshot) {
    Map<String, dynamic> user = snapshot.value as Map<String, dynamic>;

    return Text('User name is ${user['name']}');
  },
);
```

The `FirebaseDatabaseListView` widget is built on-top of Flutter's own [`ListView`](https://api.flutter.dev/flutter/widgets/ListView-class.html)
widget, and accepts the same parameters which we can optionally provide. For example, to change the scroll-direction to horizontal:

```dart
FirebaseDatabaseListView(
  scrollDirection: Axis.horizontal,
  // ...
);
```

### Controlling page size

By default, the widget will fetch 10 items from the collection at a time. This can be changed by providing a `pageSize` parameter:

```dart
FirebaseDatabaseListView(
  pageSize: 20,
  // ...
);
```

In general, it is good practice to keep this value as small as possible to reduce network overhead. If the height (or width)
of an individual item is large, it is recommended to lower the page size.

### Loading and error handling

By default, the widget will display a loading indicator while data is being fetched from the database, and ignore any errors which might be thrown
(such as permission denied). You can override this behavior by providing a `loadingBuilder` and `errorBuilder` parameters to the widget:

```dart
FirebaseDatabaseListView(
  loadingBuilder: (context) => MyCustomLoadingIndicator(),
  errorBuilder: (context, error, stackTrace) => MyCustomError(error, stackTrace),
  // ...
);
```

### Advanced configuration

In many cases, the `FirebaseDatabaseListView` widget is enough to render simple lists of collection data.
However, you may have specific requirements which require more control over the widget's behavior
(such as using a [`GridView`](https://api.flutter.dev/flutter/widgets/GridView-class.html)).

The `FirebaseDatabaseQueryBuilder` provides the building blocks for advanced configuration at the expense of
requiring more boilerplate code. The widget does not provide any underlying list implementation, instead
you are expected to provide this yourself.

Much like the `FirebaseDatabaseListView` widget, provide a query and builder:

```dart
final usersQuery = FirebaseDatabase.instance.ref('users').orderByChild('name');

FirebaseDatabaseQueryBuilder(
  query: usersQuery,
  builder: (context, snapshot, _) {
    // ... TODO!
  },
);
```

The main difference to note here is that the `builder` property returns a `FirebaseQueryBuilderSnapshot`, rather
than an individual document. The builder returns the current state of the entire query, such as whether
data is loading, an error has occurred and the documents.

This requires us to implement our own list based implementation. Firstly, let's handle the loading and error
states:

```dart
FirebaseDatabaseQueryBuilder(
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
FirebaseDatabaseQueryBuilder(
  query: usersQuery,
  builder: (context, snapshot, _) {
    // ...

    return GridView.builder(
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        // if we reached the end of the currently obtained items, we try to
        // obtain more items
        if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
          // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
          // It is safe to call this function from within the build method.
          snapshot.fetchMore();
        }

        final user = snapshot.docs[index].value as Map<String, dynamic>;

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
1. The `FirebaseDatabaseQueryBuilder` does not provide a list-view based handler, instead you must provide your own implementation.
