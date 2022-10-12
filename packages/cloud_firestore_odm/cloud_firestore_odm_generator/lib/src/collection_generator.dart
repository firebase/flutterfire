import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:cloud_firestore_odm/annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'collection_data.dart';
import 'named_query_data.dart';
import 'parse_generator.dart';
import 'templates/collection_reference.dart';
import 'templates/document_reference.dart';
import 'templates/document_snapshot.dart';
import 'templates/named_query.dart';
import 'templates/query_document_snapshot.dart';
import 'templates/query_reference.dart';
import 'templates/query_snapshot.dart';

const namedQueryChecker = TypeChecker.fromRuntime(NamedQuery);

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

class GlobalData {
  /// All the [Collection.prefix] in the library.
  final classPrefixesForLibrary = <Object?, List<String>>{};

  /// The list of all [NamedQuery] in the library.
  final namedQueries = <NamedQueryData>[];
}

@immutable
class CollectionGenerator
    extends ParserGenerator<GlobalData, CollectionGraph, Collection> {
  @override
  GlobalData parseGlobalData(LibraryElement library) {
    final globalData = GlobalData();

    for (final element in library.topLevelElements) {
      for (final queryAnnotation in namedQueryChecker.annotationsOf(element)) {
        globalData.namedQueries.add(
          NamedQueryData.fromAnnotation(queryAnnotation),
        );
      }
    }

    return globalData;
  }

  @override
  Future<CollectionGraph> parseElement(
    BuildStep buildStep,
    GlobalData globalData,
    Element element,
  ) async {
    final library = await buildStep.inputLibrary;
    final collectionAnnotations = collectionChecker.annotationsOf(element).map(
      (annotation) {
        return CollectionData.fromAnnotation(
          annotatedElement: element,
          globalData: globalData,
          libraryElement: library,
          annotation: annotation,
        );
      },
    ).toList();

    return CollectionGraph.parse(collectionAnnotations);
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

      // // It is safe to generate snapshots here and in [generateForData]
      // // as parse_generator will filter duplicate generations.
      // yield QuerySnapshotTemplate(
      //   documentSnapshotName: namedQuery.documentSnapshotName,
      //   queryDocumentSnapshotName: namedQuery.queryDocumentSnapshotName,
      //   querySnapshotName: namedQuery.querySnapshotName,
      //   type: namedQuery.type,
      // );
      // yield QueryDocumentSnapshotTemplate(
      //   documentSnapshotName: namedQuery.documentSnapshotName,
      //   documentReferenceName: namedQuery.documentReferenceName,
      //   queryDocumentSnapshotName: namedQuery.queryDocumentSnapshotName,
      //   type: namedQuery.type,
      // );
      // yield DocumentSnapshotTemplate(
      //   documentSnapshotName: namedQuery.documentSnapshotName,
      //   documentReferenceName: namedQuery.documentReferenceName,
      //   type: namedQuery.type,
      // );
    }
  }

  @override
  Iterable<Object> generateForData(
    GlobalData globalData,
    CollectionGraph data,
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
}
