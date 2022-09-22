import 'dart:collection';

export 'src/validator.dart' show Min, Validator, Max;

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
  /// Only a single property can be annotated by `@Id()`.
  /// The annotated property must be of type [String].
  /// {@endtemplate}
  const Id();
}

/// A wrapper over [Map] to inject the document ID in a [Map], without having
/// to clone the [Map].
///
/// Do not use
// ignore: invalid_internal_annotation, used by the code-generator and only it
class $JsonMapWithId extends MapView<String, Object?> {
  $JsonMapWithId(Map<String, Object?> map, this._id, this._idKey) : super(map);

  final String _id;
  final String _idKey;

  @override
  int get length => super.length + 1;

  @override
  Iterable<String> get keys => [_idKey, ...super.keys];

  @override
  bool containsKey(Object? key) {
    if (_idKey == key) return true;
    return super.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    if (_id == value) return true;
    return super.containsValue(value);
  }

  @override
  Object? operator [](Object? key) {
    if (key == _idKey) return _id;
    return super[key];
  }

  @override
  void operator []=(String key, Object? value) {
    if (key == _idKey) {
      throw UnsupportedError('Cannot modify the $_idKey');
    }

    super[key] = value;
  }
}
