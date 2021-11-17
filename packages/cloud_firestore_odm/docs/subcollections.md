> Note; this documentation is in a temporary location.

# Subcollections

The ODM provides support for subcollections via the `Collection` annotation. For example, first define
the root collection as normal:

```dart
@JsonSerializable()
class User {
 // ...
}

@Collection<User>('/users')
final usersRef = UserCollectionReference();
```

Let's assume each user document contains a subcollection containing user addresses. Firstly define
the model for an address:

```dart
@JsonSerializable()
class Address {
 // ...
}
```

Next, define the path to the subcollection in a new `Collection` annotation:

```dart
@Collection<User>('/users')
@Collection<Address>('/users/*/addresses')
final usersRef = UserCollectionReference();
```

After [code generation](code-generation.md), we can now access the sub-collection via the `usersRef`
reference:

```dart
AddressCollectionReference addressesRef = usersRef.addresses;
```

The subcollection reference has full access to the same functionality as root collections. To learn
more about usage of references, see the [using references](using-references.md) documentation.
