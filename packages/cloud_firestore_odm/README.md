# Cloud Firestore ODM

A collection of packages that generate Firestore bindings for Dart classes, allowing type-safe queries and updates.

> **Note**: Using the ODM requires a Dart SDK >= 2.14.0. This SDK version is available in the latest `stable` channel of Flutter.

## Getting started

> This package is a development preview, APIs may change or be removed.

### 1) Add the ODM `dependencies` to your `pubspec.yaml`:

```yaml
# ...
dependencies:
  firebase_core: "^1.7.0"
  cloud_firestore: "^2.5.3"
  cloud_firestore_odm: "^1.0.0-dev.1"
  # Optional - if you want to use json_serializable.
  json_annotation: ^4.0.0
# ...
```

### 2) Add the ODM `dev_dependencies` to your `pubspec.yaml`:

```yaml
# ...
dev_dependencies:
  # For the code generator
  build_runner: ^2.0.0
  cloud_firestore_odm_generator: "^1.0.0-dev.1"
  # Optional - if you want to use json_serializable.
  json_serializable: ^5.0.0
# ...
```

### 3) Define your models

See the usage section below on how to define your model files with (or without) [json_serializable][json_serializable].

Ensure you include the part declaration in your model dart files, e.g. if your file is called `movie.dart` then include
the following snippet in that file:

```dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
// ... dart imports

// THIS:
part 'movie.g.dart';

// ... rest of your dart code
```

### 4) Run the code generator

Once you've defined your models (or updated them) you'll need run the code generator.

Build once:

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

Or, continuously watch for changes and rebuild with the following command:

```sh
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## Usage

### Defining a Model

Before defining a collection, we first need to define a class representing the content of a document of the collection.

For this, any class with a `fromJson` and `toJson` method will work, such as:

```dart
class Person {
  Person({required this.name, required this.age});

  Person.fromJson(Map<String, Object?> json)
      : this(
    name: json['name'] as String,
    age: json['name'] as int,
  );

  final String name;
  final String age;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }
}
```

This process can be simplified by relying on a separate code-generator to generate the `fromJson` and `toJson`
functions (installed separately).

The official recommendation is to use [json_serializable][json_serializable]. When using [json_serializable][json_serializable], the ODM will detect its usage
and reduce the typical boilerplate by making `fromJson` and `toJson` optional:

```dart
@JsonSerializable()
class Person {
  Person({required this.name, required this.age});

  final String name;
  final int age;
}
```

### Defining a collection reference

Now that we defined a model, we should define a global variable representing our collection reference, using
the `Collection` annotation.

To do so, we must specify the path to the collection and the type of the collection content:

```dart
@JsonSerializable()
class Person {
  Person({required this.name, required this.age});

  final String name;
  final int age;
}

@Collection<Person>('/persons')
final personsRef = PersonCollectionReference();
```

The class `PersonCollectionReference` will be generated from the `Person` class, and will allow manipulating the
collection in a type-safe way. For example, to read the person collection, you could do:

```dart
void main() async {
  PersonQuerySnapshot snapshot = await personsRef.get();

  for (PersonQueryDocumentSnapshot doc in snapshot.docs) {
    Person person = doc.data();
    print(person.name);
  }
}
```

> **Note**: Don't forget to include `part "my_file.g.dart"` at the top of your file.

### Obtaining a document reference.

It is possible to obtain a document reference from a collection reference.

Assuming we have:

```dart

@Collection<Person>('/persons')
final personsRef = PersonCollectionReference();
```

then we can get a document with:

```dart
void main() async {
  PersonDocumentReference doc = personsRef.doc('document-id');

  PersonDocumentSnapshot snapshot = await doc.get();
}
```

### Defining a sub-collection

Once you have defined a collection, you may want to define a sub-collection.

To do that, you first must create a root collection as described previously. From there, you can add extra `@Collection`
annotations to a collection reference for defining sub-collections:

```dart
@Collection<Person>('/persons')
@Collection<Friend>('/persons/*/friends') // defines a sub-collection "friends"
final personsRef = PersonCollectionReference();
```

Then, the sub-collection will be available from a document reference:

```dart
void main() async {
  PersonDocumentReference johnRef = personsRef.doc('john');

  FriendQuerySnapshot johnFriends = await johnRef.friends.get();
}
```

#### Specifying a custom name for the sub-collection

The `@Collection` annotation allows specifying a custom name to access your 
collection reference.

This is helpful in the event where you want your sub-collection to be manipulated
using a name other than the collection ID:

```dart
@Collection<Person>('/persons')
@Collection<Friend>('/persons/*/friends', name: 'myFriendList')
final personsRef = PersonCollectionReference();

void main() async {
  PersonDocumentReference johnRef = personsRef.doc('john');

  FriendQuerySnapshot johnFriends = await johnRef.myFriendList.get();
}
```

### Using document/collection reference in Flutter

Now that we have defined collection/document references, we can use them inside a Flutter app by using
the `FirestoreBuilder` widget.

This widget will subscribe to a reference and expose the document/collection state:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirestoreBuilder<PersonDocumentSnapshot>(
        ref: personsRef.doc('john'),
        builder: (context, AsyncSnapshot<PersonDocumentSnapshot> snapshot, Widget? child) {
          if (snapshot.hasError) return Text('error');
          if (!snapshot.hasData) return Text('loading');

          Person? person = snapshot.requireData.data();
          if (person == null) return Text('The document "john" does not exist.');

          return Text(person.name);
        }
    );
  }
}
```

### Performing queries

Using `@Collection`, our references contains type-safe methods for querying documents.

This includes:

- a variant of `orderBy` for every property of the document, such as:
  ```dart
  personsRef.orderByName() // sorts by Person.name
  personsRef.orderByAge() // sorts by Person.age
  ```
- variants of `where`:
  ```dart
  personsRef.whereName(isEqualTo: 'John');
  personsRef.whereAge(isGreaterThan: 18);
  ```

Collections also contain more classical methods like `personsRef.limit(1)`.

Queries can then be used with `FirestoreBuilder` as usual:

```dart
FirestoreBuilder<PersonQuerySnapshot>(
  ref: personsRef.whereAge(isGreaterThan: 18),
  builder: (context, AsyncSnapshot<PersonQuerySnapshot> snapshot, Widget? child) {
    // ...
  }
);
```

#### Optimizing rebuilds

Through `FirestoreBuilder`, it is possible to optionally optimize widget rebuilds, using the `select` method on a
reference. The basic idea is; rather than listening to the entire snapshot, `select` allows us to listen to only a part
of the snapshot.

For example, if we have a document that returns a `Person` instance, we could voluntarily only listen to that
person's `name` by doing:

```dart
FirestoreBuilder<String>(
  ref: personsRef.doc('id').select((PersonDocumentSnapshot snapshot) => snapshot.data!.name)),
  builder: (context, AsyncSnapshot<String> snapshot, Widget? child) {
    return Text('Hello ${snapshot.data}');
  }
);
```

By doing so, now `Text` will rebuild only when the person's name changes. If that person's age changes, this won't
rebuild our `Text`.

----

### Example

An [example app](cloud_firestore_odm/example) is available;

```sh
cd cloud_firestore_odm/example
flutter pub get
flutter pub run build_runner watch --delete-conflicting-outputs
```

[json_serializable]: (https://pub.dev/packages/json_serializable)

