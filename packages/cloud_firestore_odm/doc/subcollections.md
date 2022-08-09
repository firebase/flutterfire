# Working with Subcollections

> The Cloud Firestore ODM is currently in **alpha**. Expect breaking changes, API changes and more. The documentation is still a work in progress. See the [discussion](https://github.com/firebase/flutterfire/discussions/7475) for more details.

The ODM provides support for subcollections via the `Collection` annotation. For example, first define
the root collection as normal:

```dart
@firestoreSerializable
class User {
 // ...
}

@Collection<User>('users')
final usersRef = UserCollectionReference();
```

Let's assume each user document contains a subcollection containing user addresses. Firstly define
the model for an address:

```dart
@firestoreSerializable
class Address {
 // ...
}
```

Next, define the path to the subcollection in a new `Collection` annotation:

```dart
@Collection<User>('users')
@Collection<Address>('users/*/addresses')
final usersRef = UserCollectionReference();
```

After [code generation](./code-generation.md), we can now access the sub-collection via the `usersRef`
reference:

```dart
AddressCollectionReference addressesRef = usersRef.doc('myDocumentID').addresses;
```

The subcollection reference has full access to the same functionality as root collections. To learn
more about usage of references, see the [using references](./references.md) documentation.
