# Defining models

> The Cloud Firestore ODM is currently in **alpha**. Expect breaking changes, API changes and more. The documentation is still a work in progress. See the [discussion](https://github.com/firebase/flutterfire/discussions/7475) for more details.

- [Creating models](#creating-models)
- [Creating references](#creating-references)
- [Injecting the document ID in the model](#injecting-the-document-id-in-the-model)
- [Model validation](#model-validation)
  - [Available validators](#available-validators)
    - [`int`](#int)
  - [Custom validators](#custom-validators)
- [Next steps](#next-steps)

## Creating models

A model represents exactly what data we expect to both receive and mutate on Firestore. The ODM
ensures that all data is validated against a model, and if the model is not valid an error will be
thrown.

To get started, assume we have a collection on our Firestore database called "Users". The collection
contains many documents containing user information such as a name, age, email (and so on!). To
define a model for this data, create a class:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';

// This doesn't exist yet...! See "Next Steps"
part 'user.g.dart';

/// A custom JsonSerializable annotation that supports decoding objects such
/// as Timestamps and DateTimes.
/// This variable can be reused between different models
const firestoreSerializable = JsonSerializable(
  converters: firestoreJsonConverters,
  // The following values could alternatively be set inside your `build.yaml`
  explicitToJson: true,
  createFieldMap: true,
);

@firestoreSerializable
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  });

  final String name;
  final int age;
  final String email;
}
```

The `User` model defines that a user must have a name and email as a `String` and age as an `int`.

Supported data types are those of Firestore (string, boolean, number, geo point, timestamp, list), 
plus `DateTime` and `DocumentReference<Map<String, dynamic>>`. Nested object and custom types are 
supported with `@JsonKey` (see [json_serializable](https://pub.dev/packages/json_serializable)). 
In addition to `toJson` and `fromJson`, `@JsonKey` also offer `ignore` and `name` parameters.

A current limitation, typesafe query method and update parameters are not generated for nested object 
and custom types like enum.

:::caution
If your model class is defined in a separate file than the Firestore reference,
you will need to explicitly specify `fromJson`/`toJson` functions as followed:

```dart
@firestoreSerializable
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  });

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

  final String name;
  final int age;
  final String email;

  Map<String, Object?> toJson() => _$UserToJson(this);
}
```

:::

## Creating references

On their own, a model does not do anything. Instead we create a "reference" using a model.
A reference enables the ODM to interact with Firestore using the model.

To create a reference, we use the `Collection` annotation which is used as a pointer to a collection
within the Firestore database. For example, the `users` collection in the root of the database
corresponds to the `Users` model we defined previously:

```dart
@firestoreSerializable
class User {
 // ...
}

@Collection<User>('users')
final usersRef = UserCollectionReference();
```

If you are looking to define a model as a reference on a Subcollection, read the [Working with Subcollections](./subcollections.md) documentation.

## Injecting the document ID in the model

By default, the document ID is not present in the firestore object once decoded.

While you can acccess it using the `DocumentSnapshot`, it isn't always convenient.
A solution to that is to use the `@Id` annotation, to tell Firestore that a
given property in a class would be the document ID:

```dart
@Collection<Person>('users')
@firestoreSerializable
class Person {
  Person({
    required this.name,
    required this.age,
    required this.id,
  });

  // By adding this annotation, this property will not be considered as part
  // of the Firestore document, but instead represent the document ID.
  @Id()
  final String id;

  final String name;
  final int age;
}
```

There are a few restrictions when using this annotation:

- It can be used only once within an object
- The annotated property must be of type `String`.

## Model validation

Defining a model with standard Dart types (e.g. `String`, `int` etc) works for many applications,
but what about more bespoke validation?

For example, a users age cannot be a negative value, so how do we validate against this?

The ODM provides some basic annotation validators which can be used on model properties. In this
example, we can take advantage of the `Min` validator:

```dart
@firestoreSerializable
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  }) {
    // Apply the validator
    _$assertUser(this);
  }

  final String name;
  final String email;

  // Apply the `Min` validator
  @Min(0)
  final int age;
}
```

The `Min` annotation ensures that any value for the `age` property is always positive, otherwise an
error will be thrown.

To ensure validators are applied, the model instance is provided to the generated `$assertUser`
method. Note the name of this class is generated based on the model name (for example a model named
`Product` with validators would generate a `$assertProduct` method).

### Available validators

#### `int`

The following annotations are available for `int` properties:

| Annotation | Description                                        |
| ---------- | -------------------------------------------------- |
| `Min`      | Validates a number is not less than this value.    |
| `Max`      | Validates a number is not greater than this value. |

### Custom validators

In some cases, you may wish to validate data against custom validation. For example, we may want to
ensure the string value provided to `email` is in-fact a valid email address.

To define a custom validator, create a class which implements `Validator`:

```dart
class EmailAddressValidator implements Validator<String> {
  const EmailAddressValidator();

  @override
  void validate(String value) {
    if (!value.endsWith("@google.com")) {
      throw Exception("Email address is not valid!");
    }
  }
}
```

Within the model, you can then apply the validator to the property:

```dart
@firestoreSerializable
class User {
  User({
    required this.name,
    required this.age,
    required this.email,
  }) {
    // Apply the validator
    _$assertUser(this);
  }

  final String name;
  final int age;

  @EmailAddressValidator()
  final String email;
}
```

## Next steps

Some of the code on this page is created via code generation
(e.g. `_$assertUser`, `UserCollectionReference`) - you can learn more about
how to generate this code via the [Code Generation](./code-generation.md) documentation!
