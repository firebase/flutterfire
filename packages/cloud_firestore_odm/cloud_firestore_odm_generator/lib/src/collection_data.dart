// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:cloud_firestore_odm/annotation.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

import 'collection_generator.dart';
import 'names.dart';

const collectionChecker = TypeChecker.fromRuntime(Collection);
const dateTimeChecker = TypeChecker.fromRuntime(DateTime);
const timestampChecker = TypeChecker.fromUrl(
  'package:cloud_firestore_platform_interface/src/timestamp.dart#Timestamp',
);
const geoPointChecker = TypeChecker.fromUrl(
  'package:cloud_firestore_platform_interface/src/geo_point.dart#GeoPoint',
);

const jsonSerializableChecker = TypeChecker.fromRuntime(JsonSerializable);
const freezedChecker = TypeChecker.fromRuntime(Freezed);

class CollectionGraph {
  CollectionGraph._(this.roots, this.subCollections);

  factory CollectionGraph.parse(List<CollectionData> collections) {
    final roots = collections.where((collection) {
      final pathSplit = collection.path.split('/');
      return !pathSplit.any((split) => split == '*');
    }).toList();

    final subCollections = collections.where((collection) {
      final pathSplit = collection.path.split('/');
      return pathSplit.any((split) => split == '*');
    }).toList();

    final allCollections = [...roots, ...subCollections];

    for (final subCollection in subCollections) {
      final lastIDIndex = subCollection.path.lastIndexOf('/*/');
      if (lastIDIndex < 0) {
        // TODO find a way to test this
        throw InvalidGenerationSourceError(
          'Defined a sub-collection with path ${subCollection.path} but '
          'the path does not point to a sub-collection.',
        );
      }
      // From "movies/*/comments/*/retweets" obtains "movies/*/comments"
      final parentPath = subCollection.path.substring(0, lastIDIndex);

      final parentCollection = allCollections.firstWhere(
        (c) => c.path == parentPath,
        orElse: () {
          // TODO find a way to test this
          throw InvalidGenerationSourceError(
            'Defined a subcollection with path "${subCollection.path}" '
            'but no collection with path "$parentPath" found.',
          );
        },
      );

      subCollection._parent = parentCollection;
      parentCollection._children.add(subCollection);
    }

    return CollectionGraph._(roots, subCollections);
  }

  final List<CollectionData> roots;
  final List<CollectionData> subCollections;

  late final allCollections = [...roots, ...subCollections];

  @override
  String toString() {
    return 'Data(roots: $roots, subCollections: $subCollections)';
  }
}

class CollectionData with Names {
  CollectionData({
    required this.type,
    required String? collectionName,
    required this.collectionPrefix,
    required this.path,
    required this.queryableFields,
    required this.fromJson,
    required this.toJson,
    required this.idKey,
    required this.libraryElement,
  }) : collectionName =
            collectionName ?? ReCase(path.split('/').last).camelCase;

  factory CollectionData.fromAnnotation({
    required LibraryElement libraryElement,
    required Element annotatedElement,
    required DartObject annotation,
    required GlobalData globalData,
  }) {
    // TODO find a way to test validation

    final name = annotation.getField('name')!.toStringValue();
    final prefix = annotation.getField('prefix')!.toStringValue();

    // TODO(validate name)

    final path = annotation.getField('path')!.toStringValue()!;
    _assertIsValidCollectionPath(path, annotatedElement);

    final type = CollectionData.modelTypeOfAnnotation(annotation);

    final hasJsonSerializable =
        jsonSerializableChecker.hasAnnotationOf(type.element!);

    if (type.isDynamic) {
      throw InvalidGenerationSourceError(
        'The annotation @Collection was used, but no generic type was specified. ',
        todo: 'Instead of @Collection("path") do @Collection<MyClass>("path").',
        element: annotatedElement,
      );
    }

    final collectionTargetElement = type.element;
    if (collectionTargetElement is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The annotation @Collection can only receive classes as generic argument. ',
        element: annotatedElement,
      );
    }

    final hasFreezed = freezedChecker.hasAnnotationOf(type.element!);
    final redirectedFreezedConstructors =
        collectionTargetElement.constructors.where(
      (element) {
        return element.isFactory &&
            // It should be safe to read "redirectedConstructor" as the build.yaml
            // asks to run the ODM after Freezed
            element.redirectedConstructor != null;
      },
    ).toList();

    // TODO throw when using json_serializable if the Model type and
    // the collection are defined in separate libraries

    // TODO test error handling
    if (redirectedFreezedConstructors.length > 1) {
      throw InvalidGenerationSourceError(
        'Union types when using @freezed are currently unsupported. Use a single constructor instead',
        element: annotatedElement,
      );
    }

    final annotatedElementSource = annotatedElement.librarySource!;

    // TODO(rrousselGit) handle parts
    // Whether the model class and the reference variable are defined in the same file
    // This is important because json_serializable generates private code for
    // decoding a Model class.
    final modelAndReferenceInTheSameLibrary =
        collectionTargetElement.librarySource == annotatedElementSource;

    final fromJson = collectionTargetElement.constructors.firstWhereOrNull(
      (ctor) => ctor.name == 'fromJson',
    );
    if (hasJsonSerializable && !modelAndReferenceInTheSameLibrary) {
      throw InvalidGenerationSourceError(
        '''
When using json_serializable, the `@Collection` annotation and the class that
represents the content of the collection must be in the same file.

- @Collection is from $annotatedElementSource
- `$collectionTargetElement` is from ${collectionTargetElement.librarySource}
''',
        element: annotatedElement,
      );
    }

    if ((!hasJsonSerializable || !modelAndReferenceInTheSameLibrary) &&
        fromJson == null) {
      throw InvalidGenerationSourceError(
        'Used @Collection with the class ${collectionTargetElement.name}, but '
        'the class has no `fromJson` constructor.',
        todo: 'Add a `fromJson` constructor to ${collectionTargetElement.name}',
        element: annotatedElement,
      );
    }

    if (fromJson != null) {
      if (fromJson.parameters.length != 1 ||
          !fromJson.parameters.first.isRequiredPositional ||
          !fromJson.parameters.first.type.isDartCoreMap) {
        // TODO support deserializing generic objects
        throw InvalidGenerationSourceError(
          '@Collection was used with the class ${collectionTargetElement.name} but '
          'its fromJson does not match `Function(Map json)`.',
          element: annotatedElement,
        );
      }
    }

    final toJson = collectionTargetElement
        // Looking into fromJson from superTypes too
        .allMethods
        .firstWhereOrNull((method) => method.name == 'toJson');
    if (!hasJsonSerializable && toJson == null) {
      throw InvalidGenerationSourceError(
        'Used @Collection with the class ${collectionTargetElement.name}, but '
        'the class has no `toJson` method.',
        todo: 'Add a `toJson` method to ${collectionTargetElement.name}',
        element: annotatedElement,
      );
    }

    if (toJson != null) {
      if (toJson.parameters.isNotEmpty || !toJson.returnType.isDartCoreMap) {
        // TODO support serializing generic objects
        throw InvalidGenerationSourceError(
          '@Collection was used with the class ${collectionTargetElement.name} but '
          'its toJson does not match `Map Function()`.',
          element: annotatedElement,
        );
      }
    }

    final data = CollectionData(
      type: type,
      path: path,
      collectionName: name,
      collectionPrefix: prefix,
      libraryElement: libraryElement,
      fromJson: (json) {
        if (fromJson != null) return '$type.fromJson($json)';
        return '_\$${type.toString().public}FromJson($json)';
      },
      toJson: (value) {
        if (toJson != null) return '$value.toJson()';
        return '_\$${type.toString().public}ToJson($value)';
      },
      idKey: collectionTargetElement
          .allFields(
            hasFreezed: hasFreezed,
            freezedConstructors: redirectedFreezedConstructors,
          )
          .firstWhereOrNull((f) => f.hasId())
          ?.name,
      queryableFields: [
        QueryingField(
          'documentId',
          annotatedElement.library!.typeProvider.stringType,
          field: 'FieldPath.documentId',
          updatable: false,
        ),
        ...collectionTargetElement
            .allFields(
              hasFreezed: hasFreezed,
              freezedConstructors: redirectedFreezedConstructors,
            )
            .where((f) => f.isPublic)
            .where((f) => _isSupportedType(f.type))
            .where((f) => !f.hasId())
            .where((f) => !f.isJsonIgnored())
            .map(
          (e) {
            var key = "'${e.name}'";

            if (hasFreezed) {
              key =
                  // two $ because both Freezed and json_serializable add one
                  '_\$\$${redirectedFreezedConstructors.single.redirectedConstructor!.enclosingElement.name}FieldMap[$key]!';
            } else if (hasJsonSerializable) {
              key = '_\$${collectionTargetElement.name.public}FieldMap[$key]!';
            }

            return QueryingField(
              e.name,
              e.type,
              updatable: true,
              field: key,
            );
          },
        ).toList(),
      ],
    );

    final classPrefix = data.classPrefix;

    if (globalData.classPrefixesForLibrary[annotatedElementSource]
            ?.contains(classPrefix) ??
        false) {
      throw InvalidGenerationSourceError(
        'Defined a collection with duplicate class prefix $classPrefix.'
        ' Either use a different class, or set a unique class prefix.',
      );
    }

    globalData.classPrefixesForLibrary[annotatedElementSource] ??= [];
    globalData.classPrefixesForLibrary[annotatedElementSource]!
        .add(classPrefix);

    return data;
  }

  static void _assertIsValidCollectionPath(String path, Element element) {
    final allowedCharactersRegex = RegExp(r'^[0-9a-zA-Z/*-_]+$');
    if (!allowedCharactersRegex.hasMatch(path)) {
      throw InvalidGenerationSourceError(
        'The annotation @Collection received "$path" as collection path, '
        ' but the path contains illegal characters.',
        element: element,
      );
    }

    final pathSplit = path.split('/');
    if (pathSplit.length.isEven) {
      throw InvalidGenerationSourceError(
        'The annotation @Collection received "$path" as collection path, '
        ' but this path points to a document instead of a collection',
        element: element,
      );
    }

    for (var i = 0; i < pathSplit.length; i += 2) {
      if (pathSplit[i] == '*') {
        throw InvalidGenerationSourceError(
          'The annotation @Collection received "$path" as collection path, '
          ' but ${pathSplit[i]} is not a valid collection name',
          element: element,
        );
      }
    }
  }

  static DartType modelTypeOfAnnotation(DartObject annotation) {
    return (annotation.type! as ParameterizedType).typeArguments.first;
  }

  static bool _isSupportedType(DartType type) {
    return type.isDartCoreString ||
        type.isDartCoreNum ||
        type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreBool ||
        type.isPrimitiveList ||
        type.isJsonDocumentReference ||
        dateTimeChecker.isAssignableFromType(type) ||
        timestampChecker.isAssignableFromType(type) ||
        geoPointChecker.isAssignableFromType(type);
    // TODO filter list other than LIst<string|bool|num>
  }

  @override
  final String? collectionPrefix;
  @override
  final DartType type;

  final String collectionName;
  final String path;
  final String? idKey;
  final List<QueryingField> queryableFields;
  final LibraryElement libraryElement;

  late final updatableFields =
      queryableFields.where((element) => element.updatable).toList();

  CollectionData? _parent;
  CollectionData? get parent => _parent;

  final List<CollectionData> _children = [];
  List<CollectionData> get children => UnmodifiableListView(_children);

  String Function(String json) fromJson;
  String Function(String value) toJson;

  @override
  String toString() {
    return 'CollectionData(type: $type, collectionName: $collectionName, path: $path)';
  }
}

extension on ClassElement {
  Iterable<MethodElement> get allMethods sync* {
    yield* methods;
    for (final supertype in allSupertypes) {
      if (supertype.isDartCoreObject) continue;
      yield* supertype.methods;
    }
  }

  Iterable<VariableElement> allFields({
    required bool hasFreezed,
    required List<ConstructorElement> freezedConstructors,
  }) sync* {
    if (hasFreezed) {
      yield* freezedConstructors.single.parameters;
    } else {
      final uniqueFields = <String, FieldElement>{};

      for (final field in fields) {
        if (field.getter != null && !field.getter!.isSynthetic) {
          continue;
        }
        uniqueFields[field.name] ??= field;
      }

      for (final supertype in allSupertypes) {
        if (supertype.isDartCoreObject) continue;

        for (final field in supertype.element.fields) {
          if (field.getter != null && !field.getter!.isSynthetic) {
            continue;
          }
          uniqueFields[field.name] ??= field;
        }
      }
      yield* uniqueFields.values;
    }
  }
}

extension on String {
  String get public {
    return startsWith('_') ? substring(1) : this;
  }
}

extension on DartType {
  bool get isJsonDocumentReference {
    return element?.librarySource?.uri.scheme == 'package' &&
        const {'cloud_firestore'}
            .contains(element?.librarySource?.uri.pathSegments.first) &&
        element?.name == 'DocumentReference' &&
        (this as InterfaceType).typeArguments.single.isDartCoreMap;
  }

  bool get isPrimitiveList {
    if (!isDartCoreList) return false;

    final generic = (this as InterfaceType).typeArguments.single;

    return generic.isDartCoreNum ||
        generic.isDartCoreString ||
        generic.isDartCoreBool ||
        generic.isDartCoreObject ||
        generic.isDynamic;
  }
}

extension on Element {
  bool isJsonIgnored() {
    const checker = TypeChecker.fromRuntime(JsonKey);
    final jsonKeys = checker.annotationsOf(this);

    for (final jsonKey in jsonKeys) {
      final ignore = jsonKey.getField('ignore')?.toBoolValue();
      if (ignore ?? false) {
        return true;
      }
    }

    return false;
  }

  bool hasId() {
    const checker = TypeChecker.fromRuntime(Id);
    return checker.hasAnnotationOf(this);
  }
}
