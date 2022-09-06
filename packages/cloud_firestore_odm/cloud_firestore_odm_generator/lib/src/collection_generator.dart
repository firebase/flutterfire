import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:cloud_firestore_odm/annotation.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

import 'parse_generator.dart';
import 'templates/collection_reference.dart';
import 'templates/document_reference.dart';
import 'templates/document_snapshot.dart';
import 'templates/query_document_snapshot.dart';
import 'templates/query_reference.dart';
import 'templates/query_snapshot.dart';
import 'templates/template.dart';

class QueryingField {
  QueryingField(
    this.name,
    this.type, {
    required this.field,
    required this.updatable,
  });

  final String name;
  final DartType type;
  final String field;
  final bool updatable;
}

class CollectionData {
  CollectionData({
    required this.type,
    required String? collectionName,
    required this.path,
    required this.queryableFields,
    required this.fromJson,
    required this.toJson,
    required this.libraryElement,
  }) : collectionName =
            collectionName ?? ReCase(path.split('/').last).camelCase;

  final DartType type;
  final String collectionName;
  final String path;
  final List<QueryingField> queryableFields;
  final LibraryElement libraryElement;

  late final updatableFields =
      queryableFields.where((element) => element.updatable).toList();

  CollectionData? _parent;
  CollectionData? get parent => _parent;

  final List<CollectionData> _children = [];
  List<CollectionData> get children => UnmodifiableListView(_children);

  late final String className =
      type.getDisplayString(withNullability: false).replaceFirstMapped(
            RegExp('[a-zA-Z]'),
            (match) => match.group(0)!.toUpperCase(),
          );

  late final String collectionReferenceInterfaceName =
      '${className}CollectionReference';
  late final String collectionReferenceImplName =
      '_\$${className}CollectionReference';
  late final String documentReferenceName = '${className}DocumentReference';
  late final String queryReferenceInterfaceName = '${className}Query';
  late final String queryReferenceImplName = '_\$${className}Query';
  late final String querySnapshotName = '${className}QuerySnapshot';
  late final String queryDocumentSnapshotName =
      '${className}QueryDocumentSnapshot';
  late final String documentSnapshotName = '${className}DocumentSnapshot';
  late final String originalDocumentSnapshotName = 'DocumentSnapshot<$type>';

  String Function(String json) fromJson;
  String Function(String value) toJson;

  @override
  String toString() {
    return 'CollectionData(type: $type, collectionName: $collectionName, path: $path)';
  }
}

class Data {
  Data(this.roots, this.subCollections);

  final List<CollectionData> roots;
  final List<CollectionData> subCollections;

  late final allCollections = [...roots, ...subCollections];

  @override
  String toString() {
    return 'Data(roots: $roots, subCollections: $subCollections)';
  }
}

const _dateTimeChecker = TypeChecker.fromRuntime(DateTime);

const _timestampChecker = TypeChecker.fromUrl(
  'package:cloud_firestore_platform_interface/src/timestamp.dart#Timestamp',
);

const _geoPointChecker = TypeChecker.fromUrl(
  'package:cloud_firestore_platform_interface/src/geo_point.dart#GeoPoint',
);

@immutable
class CollectionGenerator extends ParserGenerator<void, Data, Collection> {
  final _collectionTemplates = <Template<CollectionData>>[
    CollectionReferenceTemplate(),
    DocumentReferenceTemplate(),
    DocumentSnapshotTemplate(),
    QueryTemplate(),
    QuerySnapshotTemplate(),
    QueryDocumentSnapshotTemplate(),
  ];

  @override
  Future<Data> parseElement(
    BuildStep buildStep,
    void globalData,
    Element element,
  ) async {
    final library = await buildStep.inputLibrary;
    final collectionAnnotations = const TypeChecker.fromRuntime(Collection)
        .annotationsOf(element)
        .map(
          (annotation) =>
              _parseCollectionAnnotation(library, annotation, element),
        )
        .toList();

    final roots = collectionAnnotations.where((collection) {
      final pathSplit = collection.path.split('/');
      return !pathSplit.any((split) => split == '*');
    }).toList();

    final subCollections = collectionAnnotations.where((collection) {
      final pathSplit = collection.path.split('/');
      return pathSplit.any((split) => split == '*');
    }).toList();

    _initializeCollectionGraph(roots, subCollections);

    return Data(roots, subCollections);
  }

  void _initializeCollectionGraph(
    List<CollectionData> roots,
    List<CollectionData> subCollections,
  ) {
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
  }

  void _assertIsValidCollectionPath(String path, Element element) {
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

  CollectionData _parseCollectionAnnotation(
    LibraryElement libraryElement,
    DartObject object,
    Element annotatedElement,
  ) {
    // TODO find a way to test validation

    final name = object.getField('name')!.toStringValue();

    // TODO(validate name)

    final path = object.getField('path')!.toStringValue()!;
    _assertIsValidCollectionPath(path, annotatedElement);

    final type = (object.type! as ParameterizedType).typeArguments.first;

    final hasJsonSerializable = const TypeChecker.fromRuntime(JsonSerializable)
        .hasAnnotationOf(type.element2!);

    if (type.isDynamic) {
      throw InvalidGenerationSourceError(
        'The annotation @Collection was used, but no generic type was specified. ',
        todo: 'Instead of @Collection("path") do @Collection<MyClass>("path").',
        element: annotatedElement,
      );
    }

    final collectionTargetElement = type.element2;
    if (collectionTargetElement is! ClassElement) {
      throw InvalidGenerationSourceError(
        'The annotation @Collection can only receive classes as generic argument. ',
        element: annotatedElement,
      );
    }

    // TODO(rrousselGit) handle parts
    // Whether the model class and the reference variable are defined in the same file
    // This is important because json_serializable generates private code for
    // decoding a Model class.
    final modelAndReferenceInTheSameLibrary =
        collectionTargetElement.librarySource.fullName ==
            annotatedElement.librarySource!.fullName;

    final fromJson = collectionTargetElement.constructors.firstWhereOrNull(
      (ctor) => ctor.name == 'fromJson',
    );
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

    final toJson = collectionTargetElement.methods.firstWhereOrNull(
      (ctor) => ctor.name == 'toJson',
    );
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

    return CollectionData(
      type: type,
      path: path,
      collectionName: name,
      libraryElement: libraryElement,
      fromJson: (json) {
        if (fromJson != null) return '$type.fromJson($json)';
        return '_\$${type.toString().public}FromJson($json)';
      },
      toJson: (value) {
        if (toJson != null) return '$value.toJson()';
        return '_\$${type.toString().public}ToJson($value)';
      },
      queryableFields: [
        QueryingField(
          'documentId',
          annotatedElement.library!.typeProvider.stringType,
          field: 'FieldPath.documentId',
          updatable: false,
        ),
        ...collectionTargetElement.fields
            .where((f) => f.isPublic)
            .where(
              (f) =>
                  f.type.isDartCoreString ||
                  f.type.isDartCoreNum ||
                  f.type.isDartCoreInt ||
                  f.type.isDartCoreDouble ||
                  f.type.isDartCoreBool ||
                  f.type.isPrimitiveList ||
                  f.type.isJsonDocumentReference ||
                  _dateTimeChecker.isAssignableFromType(f.type) ||
                  _timestampChecker.isAssignableFromType(f.type) ||
                  _geoPointChecker.isAssignableFromType(f.type),
              // TODO filter list other than LIst<string|bool|num>
            )
            .where((f) => !f.isJsonIgnored())
            .map(
          (e) {
            final key = '"${e.name}"';

            return QueryingField(
              e.name,
              e.type,
              updatable: true,
              field: hasJsonSerializable
                  ? '_\$${collectionTargetElement.name.public}FieldMap[$key]!'
                  : key,
            );
          },
        ).toList(),
      ],
    );
  }

  @override
  Iterable<Object> generateForAll(void globalData) sync* {
    yield '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides
    ''';

    yield '''
class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();
    ''';
  }

  @override
  Iterable<Object> generateForData(
    void globalData,
    Data data,
  ) sync* {
    for (final collection in data.allCollections) {
      for (final template in _collectionTemplates) {
        if (template.accepts(collection)) {
          yield template.generate(collection);
        }
      }
    }
  }

  @override
  void parseGlobalData(LibraryElement library) {}
}

extension on String {
  String get public {
    return startsWith('_') ? substring(1) : this;
  }
}

extension on DartType {
  bool get isJsonDocumentReference {
    return element2?.librarySource?.uri.scheme == 'package' &&
        const {'cloud_firestore'}
            .contains(element2?.librarySource?.uri.pathSegments.first) &&
        element2?.name == 'DocumentReference' &&
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

extension on FieldElement {
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
}
