# Using References

> The Cloud Firestore ODM is currently in **alpha**. Expect breaking changes, API changes and more. The documentation is still a work in progress. See the [discussion](https://github.com/firebase/flutterfire/discussions/7475) for more details.

A [reference](./defining-models.md#creating-references) provides full type-safe access to a Firestore
Collection and Documents.

The ODM provides a useful `FirestoreBuilder` widget which allows you to access your Firestore data
via the ODM.

## Reading Collections

Provide a collection reference instance to the `FirestoreBuilder`, returning a builder:

```dart

@Collection<User>('users')
final usersRef = UserCollectionReference();

// ...

class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirestoreBuilder<UserQuerySnapshot>(
      ref: usersRef,
      builder: (context, AsyncSnapshot<UserQuerySnapshot> snapshot, Widget? child) {
        if (snapshot.hasError) return Text('Something went wrong!');
        if (!snapshot.hasData) return Text('Loading users...');

        // Access the QuerySnapshot
        UserQuerySnapshot querySnapshot = snapshot.requireData;

        return ListView.builder(
          itemCount: querySnapshot.docs.length,
          itemBuilder: (context, index) {
            // Access the User instance
            User user = querySnapshot.docs[index].data;

            return Text('User name: ${user.name}, age ${user.age}');
          },
        );
      }
    );
  }
}
```

In the above example, a realtime subscription is created by the `FirestoreBuilder` widget and
returns all of the documents within the `users` collection as a `UserDocumentSnapshot`. This usage
of the ODM guarantees the following:

- Each snapshot document is a `User` model instance.
- The data of the model instance is fully validated. If any remote data does not pass model
  validation an error will be thrown.

The `UserDocumentSnapshot` provides access to the `User` model and the `UserDocumentReference`
instance.

## Reading Documents

Similar to collections, you can provide the `FirestoreBuilder` widget a document reference to a
specific document instead by calling the `doc()` method:

```dart

@Collection<User>('users')
final usersRef = UserCollectionReference();

// ...

class User extends StatelessWidget {
  User(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return FirestoreBuilder<UserDocumentSnapshot>(
      // Access a specific document
      ref: usersRef.doc(id),
      builder: (context, AsyncSnapshot<UserDocumentSnapshot> snapshot, Widget? child) {
        if (snapshot.hasError) return Text('Something went wrong!');
        if (!snapshot.hasData) return Text('Loading user...');

        // Access the UserDocumentSnapshot
        UserDocumentSnapshot documentSnapshot = snapshot.requireData;

        if (!documentSnapshot.exists) {
          return Text('User does not exist.');
        }

        User user = documentSnapshot.data!;

        return Text('User name: ${user.name}, age ${user.age}');
      }
    );
  }
}
```

Much like regular Firestore SDK usage, if the document does not exist a snapshot will still
be returned. In this example, we first check for existence before accessing the `User` instance.

## Performing Queries

Another powerful use-case of the ODM is the generation of type-safe querying.

Models define exactly what our data schema is, therefore this allows the ODM to generate
useful type-safe methods for querying.

```dart
@@firestoreSerializable
class User {
  User({
    required this.name,
    required this.age,
  });

  final String name;
  final int age;
}

@Collection<User>('users')
final usersRef = UserCollectionReference();
```

The above `User` model when generated generates some powerful query capabilities:

```dart
usersRef.whereName(isEqualTo: 'John');
usersRef.whereAge(isGreaterThan: 18);
usersRef.orderByAge();
// ..etc!
```

If a value is passed which does not satisfy a validator (e.g. minimum age) an error will be
thrown.

Similar to querying collections, provide a query to the `FirestoreBuilder`:

```dart
FirestoreBuilder<UserQuerySnapshot>(
  ref: usersRef.whereAge(isGreaterThan: 18).orderByAge(),
  builder: (context, AsyncSnapshot<UserDocumentSnapshot> snapshot, Widget? child) {
    // ...
  }
);
```

If any of the query constraints are modified, the state of the builder will be reset.

## Optimizing rebuilds

Through FirestoreBuilder, it is possible to optionally optimize widget rebuilds, using the select method on a reference. The basic idea is; rather than listening to the entire snapshot, select allows us to listen to only a part of the snapshot.

For example, if we have a document that returns a Person instance, we could voluntarily only listen to that person's name by doing:

```dart
FirestoreBuilder<String>(
  ref: usersRef.doc('id').select((UserDocumentSnapshot snapshot) => snapshot.data!.name)),
  builder: (context, AsyncSnapshot<String> snapshot, Widget? child) {
    return Text('Hello ${snapshot.data}');
  }
);
```

By doing so, now Text will rebuild only when the person's name changes. If that person's age changes, this won't rebuild our Text.

> Note: This is a client only optimization. The underlying Firestore SDKs will still continue to subscribe to and receive updates for the entire snapshot and therefore this will not reduce any associated billing costs.
