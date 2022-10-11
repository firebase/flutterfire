import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:cloud_firestore_odm/annotation.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

import 'parse_generator.dart';
import 'templates/collection_reference.dart';
import 'templates/document_reference.dart';
import 'templates/document_snapshot.dart';
import 'templates/named_query.dart';
import 'templates/query_document_snapshot.dart';
import 'templates/query_reference.dart';
import 'templates/query_snapshot.dart';

const _namedQueryChecker = TypeChecker.fromUrl(
  'package:cloud_firestore_odm/annotation.dart#NamedQuery',
);

const _dateTimeChecker = TypeChecker.fromRuntime(DateTime);

const _timestampChecker = TypeChecker.fromUrl(
  'package:cloud_firestore_platform_interface/src/timestamp.dart#Timestamp',
);

const _geoPointChecker = TypeChecker.fromUrl(
  'package:cloud_firestore_platform_interface/src/geo_point.dart#GeoPoint',
);

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

/// A mixin for obtaining the class name of collections/documents/snapshots/etc
/// based on annotation metadata.
mixin Names {
  String? get collectionPrefix;
  DartType get type;

  late final String classPrefix = collectionPrefix ??
      type.getDisplayString(withNullability: false).replaceFirstMapped(
            RegExp('[a-zA-Z]'),
            (match) => match.group(0)!.toUpperCase(),
          );

  late final String collectionReferenceInterfaceName =
      '${classPrefix}CollectionReference';
  late final String collectionReferenceImplName =
      '_\$${classPrefix}CollectionReference';
  late final String documentReferenceName = '${classPrefix}DocumentReference';
  late final String queryReferenceInterfaceName = '${classPrefix}Query';
  late final String queryReferenceImplName = '_\$${classPrefix}Query';
  late final String querySnapshotName = '${classPrefix}QuerySnapshot';
  late final String queryDocumentSnapshotName =
      '${classPrefix}QueryDocumentSnapshot';
  late final String documentSnapshotName = '${classPrefix}DocumentSnapshot';
  late final String originalDocumentSnapshotName = 'DocumentSnapshot<$type>';
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

class NamedQueryData with Names {
  NamedQueryData(this.queryName, {required this.type});

  factory NamedQueryData.fromAnnotation(DartObject dartObject) {
    final queryName = dartObject.getField('queryName')!.toStringValue()!;

    final genericType =
        (dartObject.type! as InterfaceType).typeArguments.single;

    return NamedQueryData(queryName, type: genericType);
  }

  @override
  final DartType type;

  final String queryName;

  late final String namedQueryGetName = '${ReCase(queryName).camelCase}Get';
  late final String namedQueryExtensionName =
      '${ReCase(queryName).pascalCase}Extrension';

  @override
  String? get collectionPrefix => null;
}

class GlobalData {
  /// All the [Collection.prefix] in the library.
  final classPrefixesForLibrary = <Object?, List<String>>{};

  /// The list of all [NamedQuery] in the library.
  final namedQueries = <NamedQueryData>[];
}

@immutable
class CollectionGenerator
    extends ParserGenerator<GlobalData, Data, Collection> {
  @override
  Future<Data> parseElement(
    BuildStep buildStep,
    GlobalData globalData,
    Element element,
  ) async {
    final library = await buildStep.inputLibrary;
    final collectionAnnotations =
        const TypeChecker.fromRuntime(Collection).annotationsOf(element).map(
      (annotation) {
        return _parseCollectionAnnotation(
          library,
          annotation,
          element,
          globalData,
        );
      },
    ).toList();

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
    GlobalData globalData,
  ) {
    // TODO find a way to test validation

    final name = object.getField('name')!.toStringValue();
    final prefix = object.getField('prefix')!.toStringValue();

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

    final hasFreezed =
        const TypeChecker.fromRuntime(Freezed).hasAnnotationOf(type.element2!);
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
                  '_\$\$${redirectedFreezedConstructors.single.redirectedConstructor!.enclosingElement3.name}FieldMap[$key]!';
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

  bool _isSupportedType(DartType type) {
    return type.isDartCoreString ||
        type.isDartCoreNum ||
        type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreBool ||
        type.isPrimitiveList ||
        type.isJsonDocumentReference ||
        _dateTimeChecker.isAssignableFromType(type) ||
        _timestampChecker.isAssignableFromType(type) ||
        _geoPointChecker.isAssignableFromType(type);
    // TODO filter list other than LIst<string|bool|num>
  }

  @override
  Iterable<Object> generateForAll(GlobalData globalData) sync* {
    yield '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, require_trailing_commas, prefer_single_quotes, prefer_double_quotes, use_super_parameters
    ''';

    yield '''
class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();
    ''';

    for (final namedQuery in globalData.namedQueries) {
      yield NamedQueryTemplate(namedQuery, globalData);

      // It is safe to generate snapshots here and in [generateForData]
      // as parse_generator will filter duplicate generations.
      yield QuerySnapshotTemplate(
        documentSnapshotName: namedQuery.documentSnapshotName,
        queryDocumentSnapshotName: namedQuery.queryDocumentSnapshotName,
        querySnapshotName: namedQuery.querySnapshotName,
        type: namedQuery.type,
      );
      yield QueryDocumentSnapshotTemplate(
        documentSnapshotName: namedQuery.documentSnapshotName,
        documentReferenceName: namedQuery.documentReferenceName,
        queryDocumentSnapshotName: namedQuery.queryDocumentSnapshotName,
        type: namedQuery.type,
      );
      yield DocumentSnapshotTemplate(
        documentSnapshotName: namedQuery.documentSnapshotName,
        documentReferenceName: namedQuery.documentReferenceName,
        type: namedQuery.type,
      );
    }
  }

  @override
  Iterable<Object> generateForData(
    GlobalData globalData,
    Data data,
  ) sync* {
    for (final collection in data.allCollections) {
      yield CollectionReferenceTemplate(collection);
      yield DocumentReferenceTemplate(collection);
      yield QueryTemplate(collection);

      yield DocumentSnapshotTemplate(
        documentSnapshotName: collection.documentSnapshotName,
        documentReferenceName: collection.documentReferenceName,
        type: collection.type,
      );
      yield QuerySnapshotTemplate(
        documentSnapshotName: collection.documentSnapshotName,
        queryDocumentSnapshotName: collection.queryDocumentSnapshotName,
        querySnapshotName: collection.querySnapshotName,
        type: collection.type,
      );
      yield QueryDocumentSnapshotTemplate(
        documentSnapshotName: collection.documentSnapshotName,
        documentReferenceName: collection.documentReferenceName,
        queryDocumentSnapshotName: collection.queryDocumentSnapshotName,
        type: collection.type,
      );
    }
  }

  @override
  GlobalData parseGlobalData(LibraryElement library) {
    final globalData = GlobalData();

    for (final element in library.topLevelElements) {
      for (final queryAnnotation in _namedQueryChecker.annotationsOf(element)) {
        globalData.namedQueries.add(
          NamedQueryData.fromAnnotation(queryAnnotation),
        );
      }
    }

    return globalData;
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
        uniqueFields[field.name] ??= field;
      }

      for (final supertype in allSupertypes) {
        if (supertype.isDartCoreObject) continue;

        for (final field in supertype.element2.fields) {
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
