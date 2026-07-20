// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

enum _SearchQueryType {
  string,
  expression,
}

/// Specifies how a pipeline search stage is performed.
///
/// Search stages must be the first stage after a pipeline source.
final class SearchStage implements PipelineSerializable {
  final _SearchQueryType _queryType;
  final Object _query;
  final List<Ordering>? _sort;
  final List<Selectable>? _addFields;
  final String? _languageCode;
  final int? _limit;
  final int? _offset;
  final int? _retrievalDepth;

  SearchStage._({
    required _SearchQueryType queryType,
    required Object query,
    List<Ordering>? sort,
    List<Selectable>? addFields,
    String? languageCode,
    int? limit,
    int? offset,
    int? retrievalDepth,
  })  : _queryType = queryType,
        _query = query,
        _sort = sort,
        _addFields = addFields,
        _languageCode = languageCode,
        _limit = limit,
        _offset = offset,
        _retrievalDepth = retrievalDepth;

  /// Creates a search stage from a raw query string.
  SearchStage.withQuery(
    String query, {
    List<Ordering>? sort,
    List<Selectable>? addFields,
    String? languageCode,
    int? limit,
    int? offset,
    int? retrievalDepth,
  }) : this._(
          queryType: _SearchQueryType.string,
          query: query,
          sort: sort,
          addFields: addFields,
          languageCode: languageCode,
          limit: limit,
          offset: offset,
          retrievalDepth: retrievalDepth,
        );

  /// Creates a search stage from a search query expression.
  SearchStage.withQueryExpression(
    BooleanExpression query, {
    List<Ordering>? sort,
    List<Selectable>? addFields,
    String? languageCode,
    int? limit,
    int? offset,
    int? retrievalDepth,
  }) : this._(
          queryType: _SearchQueryType.expression,
          query: query,
          sort: sort,
          addFields: addFields,
          languageCode: languageCode,
          limit: limit,
          offset: offset,
          retrievalDepth: retrievalDepth,
        );

  @override
  Map<String, dynamic> toMap() {
    final args = <String, dynamic>{
      'query_type': _queryType.name,
      'query': _query is Expression ? _query.toMap() : _query,
    };

    if (_sort != null) {
      args['sort'] = _sort.map((ordering) => ordering.toMap()).toList();
    }
    if (_addFields != null) {
      args['add_fields'] = _addFields.map((field) => field.toMap()).toList();
    }
    if (_languageCode != null) {
      args['language_code'] = _languageCode;
    }
    if (_limit != null) {
      args['limit'] = _limit;
    }
    if (_offset != null) {
      args['offset'] = _offset;
    }
    if (_retrievalDepth != null) {
      args['retrieval_depth'] = _retrievalDepth;
    }

    return args;
  }
}
