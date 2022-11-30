// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'src/validator.dart' show Min, Validator, Max;

/// {@macro cloud_firestore_odm.named_query}
class NamedQuery<T> {
  /// {@template cloud_firestore_odm.named_query}
  /// Defines a named query, allowing the ODM to generate utilities to interact
  /// with the query in a type-safe way.
  ///
  /// By doing:
  ///
  /// ```dart
  /// @NamedQuery<Person>('my-query-name')
  /// @Collection<Person>(...)
  /// class Anything {}
  /// ```
  ///
  /// The ODM will generate a `myQueryNameGet` utility, which can be used as followed:
  ///
  /// ```dart
  /// void main() async {
  ///   Future<PersonSnapshot> snapshot = myQueryNameGet();
  /// }
  /// ```
  ///
  ///
  /// **Note**:
  /// Named queries **must** be associated with a [Collection] that has a
  /// matching generic argument.
  ///
  /// This is necessary to ensure that `FirestoreDocumentSnapshot.reference` is
  /// properly set.
  ///
  /// {@endtemplate}
  const NamedQuery(this.queryName);

  /// The name of the Firestore query that will be performed.
  final String queryName;
}

/// {@template cloud_firestore_odm.collection}
/// Defines a collection reference.
///
/// To define a collection reference, first it is necessary to define a class
/// representing the content of a document of the collection.
///
/// That can be done by defining any serializable Dart class, such as by using
/// [json_serializable](https://pub.dev/packages/json_serializable) as followed:
///
/// ```dart
/// @JsonSerializable()
/// class Person {
///   Person({required this.name, required this.age});
///
///   factory Person.fromJson(Map<String, Object?> json) => _$PersonFromJson(json);
///
///   final String name;
///   final String age;
///
///   Map<String, Object?> toJson() => _$PersonToJson(this);
/// }
/// ```
///
///
/// Then, we should define a global variable representing our collection reference,
/// using the `Collection` annotation.
///
/// To do so, we must specify the path to the collection and the type of the collection
/// content:
///
/// ```dart
/// @Collection<Person>('persons')
/// final personsRef = PersonCollectionReference();
/// ```
///
/// The class `PersonCollectionReference` will be generated from the `Person` class,
/// and will allow manipulating the collection in a type-safe way. For example, to
/// read the person collection, you could do:
///
/// ```dart
/// void main() async {
///   PersonQuerySnapshot snapshot = await personsRef.get();
///
///   for (PersonQueryDocumentSnapshot doc in snapshot.docs) {
///     Person person = doc.data();
///     print(person.name);
///   }
/// }
/// ```
///
/// **Note**
/// Don't forget to include `part "my_file.g.dart"` at the top of your file.
///
///
/// ### Obtaining a document reference.
///
///
/// It is possible to obtain a document reference from a collection reference.
///
/// Assuming we have:
///
/// ```dart
/// @Collection<Person>('persons')
/// final personsRef = PersonCollectionReference();
/// ```
///
/// then we can get a document with:
///
/// ```dart
/// void main() async {
///   PersonDocumentReference doc = personsRef.doc('document-id');
///
///   PersonDocumentSnapshot snapshot = await doc.get();
/// }
/// ```
///
/// ### Defining a sub-collection
///
/// Once you have defined a collection, you may want to define a sub-collection.
///
/// To do that, you first must create a root collection as described previously.
/// From there, you can add extra `@Collection` annotations to a collection reference
/// for defining sub-collections:
///
/// ```dart
/// @Collection<Person>('persons')
/// @Collection<Friend>('persons/*/friends', name: 'friends') // defines a sub-collection "friends"
/// final personsRef = PersonCollectionReference();
/// ```
///
/// Then, the sub-collection will be available from a document reference:
///
/// ```dart
/// void main() async {
///   PersonDocumentReference johnRef = personsRef.doc('john');
///
///   FriendQuerySnapshot johnFriends = await johnRef.friends.get();
/// }
/// ```
/// {@endtemplate}
class Collection<T> {
  /// {@macro cloud_firestore_odm.collection}
  const Collection(this.path, {this.name, this.prefix});

  /// Decode a [Collection] from a [Map]
  ///
  /// This is internally used by the code-generator to decode configs from the `build.yaml`
  Collection.fromJson(Map<Object?, Object?> json)
      : this(
          json['path']! as String,
          name: json['name'] as String?,
          prefix: json['prefix'] as String?,
        );

  /// The firestore collection path
  final String path;

  /// The name of the generated collection field. Defaults to the last part of
  /// the collection [path].
  final String? name;

  /// The prefix to use for generated class names. Defaults to the type of [T].
  final String? prefix;
}

/// {@macro cloud_firestore_odm.id}
class Id {
  /// {@template cloud_firestore_odm.id}
  /// Marks a property as the document ID of a document.
  ///
  /// By default, the document ID is not present in the firestore object once decoded.
  ///
  /// While you can acccess it using the `DocumentSnapshot`, it isn't always convenient.
  /// A solution to that is to use the `@Id` annotation, to tell Firestore that a
  /// a given property in a class would be the document ID:
  ///
  /// ```dart
  /// @Collection<Person>('users')
  /// @firestoreSerializable
  /// class Person {
  ///   Person({
  ///     required this.name,
  ///     required this.age,
  ///     required this.id,
  ///   });
  ///
  ///   // By adding this annotation, this property will not be considered as part
  ///   // of the Firestore document, but instead represent the document ID.
  ///   @Id()
  ///   final String id;
  ///
  ///   final String name;
  ///   final int age;
  /// }
  /// ```
  ///
  /// There are a few restrictions when using this annotation:
  ///
  /// - It can be used only once within an object
  /// - The annotated property must be of type `String`.
  /// {@endtemplate}
  const Id();
}
