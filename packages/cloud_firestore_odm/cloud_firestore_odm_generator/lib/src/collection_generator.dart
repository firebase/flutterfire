// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
        final queryData = NamedQueryData.fromAnnotation(queryAnnotation);

        final hasCollectionWithMatchingModelType =
            collectionChecker.annotationsOf(element).any(
          (annotation) {
            final collectionType =
                CollectionData.modelTypeOfAnnotation(annotation);
            return collectionType == queryData.type;
          },
        );

        if (!hasCollectionWithMatchingModelType) {
          throw InvalidGenerationSourceError(
            'The named query "${queryData.queryName}" has no matching @Collection. '
            'Named queries must be associated with a @Collection with the same generic type.',
            element: element,
          );
        }

        globalData.namedQueries.add(queryData);
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
