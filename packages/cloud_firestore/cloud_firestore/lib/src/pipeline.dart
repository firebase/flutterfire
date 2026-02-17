// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// A pipeline for querying and transforming Firestore data
class Pipeline {
  final FirebaseFirestore _firestore;
  final PipelinePlatform _delegate;

  Pipeline._(this._firestore, this._delegate) {
    PipelinePlatform.verify(_delegate);
  }

  /// Exposes the [stages] on the pipeline delegate.
  ///
  /// This should only be used for testing to ensure that all
  /// pipeline stages are correctly set on the underlying delegate
  /// when being tested from a different package.
  @visibleForTesting
  List<Map<String, dynamic>> get stages {
    return _delegate.stages;
  }

  /// Executes the pipeline and returns a snapshot of the results
  Future<PipelineSnapshot> execute({ExecuteOptions? options}) async {
    final optionsMap = options != null
        ? {
            'indexMode': options.indexMode.name,
          }
        : null;
    final platformSnapshot = await _delegate.execute(options: optionsMap);
    return _convertPlatformSnapshot(platformSnapshot);
  }

  /// Converts platform snapshot to public snapshot
  PipelineSnapshot _convertPlatformSnapshot(
      PipelineSnapshotPlatform platformSnapshot) {
    final results = platformSnapshot.results.map((platformResult) {
      return PipelineResult(
        document: _JsonDocumentReference(
          _firestore,
          platformResult.document,
        ),
        createTime: platformResult.createTime,
        updateTime: platformResult.updateTime,
      );
    }).toList();

    return PipelineSnapshot._(results, platformSnapshot.executionTime);
  }

  // Pipeline Actions

  /// Adds fields to documents using expressions
  Pipeline addFields(
    Selectable selectable1, [
    Selectable? selectable2,
    Selectable? selectable3,
    Selectable? selectable4,
    Selectable? selectable5,
    Selectable? selectable6,
    Selectable? selectable7,
    Selectable? selectable8,
    Selectable? selectable9,
    Selectable? selectable10,
    Selectable? selectable11,
    Selectable? selectable12,
    Selectable? selectable13,
    Selectable? selectable14,
    Selectable? selectable15,
    Selectable? selectable16,
    Selectable? selectable17,
    Selectable? selectable18,
    Selectable? selectable19,
    Selectable? selectable20,
    Selectable? selectable21,
    Selectable? selectable22,
    Selectable? selectable23,
    Selectable? selectable24,
    Selectable? selectable25,
    Selectable? selectable26,
    Selectable? selectable27,
    Selectable? selectable28,
    Selectable? selectable29,
    Selectable? selectable30,
  ]) {
    final selectables = <Selectable>[selectable1];
    if (selectable2 != null) selectables.add(selectable2);
    if (selectable3 != null) selectables.add(selectable3);
    if (selectable4 != null) selectables.add(selectable4);
    if (selectable5 != null) selectables.add(selectable5);
    if (selectable6 != null) selectables.add(selectable6);
    if (selectable7 != null) selectables.add(selectable7);
    if (selectable8 != null) selectables.add(selectable8);
    if (selectable9 != null) selectables.add(selectable9);
    if (selectable10 != null) selectables.add(selectable10);
    if (selectable21 != null) selectables.add(selectable21);
    if (selectable22 != null) selectables.add(selectable22);
    if (selectable23 != null) selectables.add(selectable23);
    if (selectable24 != null) selectables.add(selectable24);
    if (selectable25 != null) selectables.add(selectable25);
    if (selectable26 != null) selectables.add(selectable26);
    if (selectable27 != null) selectables.add(selectable27);
    if (selectable28 != null) selectables.add(selectable28);
    if (selectable29 != null) selectables.add(selectable29);
    if (selectable30 != null) selectables.add(selectable30);
    final stage = _AddFieldsStage(selectables);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Aggregates data using aggregate functions
  Pipeline aggregate(
    AliasedAggregateFunction aggregateFunction1, [
    AliasedAggregateFunction? aggregateFunction2,
    AliasedAggregateFunction? aggregateFunction3,
    AliasedAggregateFunction? aggregateFunction4,
    AliasedAggregateFunction? aggregateFunction5,
    AliasedAggregateFunction? aggregateFunction6,
    AliasedAggregateFunction? aggregateFunction7,
    AliasedAggregateFunction? aggregateFunction8,
    AliasedAggregateFunction? aggregateFunction9,
    AliasedAggregateFunction? aggregateFunction10,
    AliasedAggregateFunction? aggregateFunction11,
    AliasedAggregateFunction? aggregateFunction12,
    AliasedAggregateFunction? aggregateFunction13,
    AliasedAggregateFunction? aggregateFunction14,
    AliasedAggregateFunction? aggregateFunction15,
    AliasedAggregateFunction? aggregateFunction16,
    AliasedAggregateFunction? aggregateFunction17,
    AliasedAggregateFunction? aggregateFunction18,
    AliasedAggregateFunction? aggregateFunction19,
    AliasedAggregateFunction? aggregateFunction20,
    AliasedAggregateFunction? aggregateFunction21,
    AliasedAggregateFunction? aggregateFunction22,
    AliasedAggregateFunction? aggregateFunction23,
    AliasedAggregateFunction? aggregateFunction24,
    AliasedAggregateFunction? aggregateFunction25,
    AliasedAggregateFunction? aggregateFunction26,
    AliasedAggregateFunction? aggregateFunction27,
    AliasedAggregateFunction? aggregateFunction28,
    AliasedAggregateFunction? aggregateFunction29,
    AliasedAggregateFunction? aggregateFunction30,
  ]) {
    final functions = <AliasedAggregateFunction>[aggregateFunction1];
    if (aggregateFunction2 != null) functions.add(aggregateFunction2);
    if (aggregateFunction3 != null) functions.add(aggregateFunction3);
    if (aggregateFunction4 != null) functions.add(aggregateFunction4);
    if (aggregateFunction5 != null) functions.add(aggregateFunction5);
    if (aggregateFunction6 != null) functions.add(aggregateFunction6);
    if (aggregateFunction7 != null) functions.add(aggregateFunction7);
    if (aggregateFunction8 != null) functions.add(aggregateFunction8);
    if (aggregateFunction9 != null) functions.add(aggregateFunction9);
    if (aggregateFunction10 != null) functions.add(aggregateFunction10);
    if (aggregateFunction11 != null) functions.add(aggregateFunction11);
    if (aggregateFunction12 != null) functions.add(aggregateFunction12);
    if (aggregateFunction13 != null) functions.add(aggregateFunction13);
    if (aggregateFunction14 != null) functions.add(aggregateFunction14);
    if (aggregateFunction15 != null) functions.add(aggregateFunction15);
    if (aggregateFunction16 != null) functions.add(aggregateFunction16);
    if (aggregateFunction17 != null) functions.add(aggregateFunction17);
    if (aggregateFunction18 != null) functions.add(aggregateFunction18);
    if (aggregateFunction19 != null) functions.add(aggregateFunction19);
    if (aggregateFunction20 != null) functions.add(aggregateFunction20);
    if (aggregateFunction21 != null) functions.add(aggregateFunction21);
    if (aggregateFunction22 != null) functions.add(aggregateFunction22);
    if (aggregateFunction23 != null) functions.add(aggregateFunction23);
    if (aggregateFunction24 != null) functions.add(aggregateFunction24);
    if (aggregateFunction25 != null) functions.add(aggregateFunction25);
    if (aggregateFunction26 != null) functions.add(aggregateFunction26);
    if (aggregateFunction27 != null) functions.add(aggregateFunction27);
    if (aggregateFunction28 != null) functions.add(aggregateFunction28);
    if (aggregateFunction29 != null) functions.add(aggregateFunction29);
    if (aggregateFunction30 != null) functions.add(aggregateFunction30);

    final stage = _AggregateStage(functions);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Performs optionally grouped aggregation operations on the documents from previous stages.
  ///
  /// This method allows you to calculate aggregate values over a set of documents, optionally
  /// grouped by one or more fields or expressions. You can specify:
  ///
  /// - **Grouping Fields or Expressions**: One or more fields or functions to group the documents by.
  ///   For each distinct combination of values in these fields, a separate group is created.
  ///   If no grouping fields are provided, a single group containing all documents is used.
  ///
  /// - **Aggregate Functions**: One or more accumulation operations to perform within each group.
  ///   These are defined using [AliasedAggregateFunction] expressions, which are typically created
  ///   by calling `.as('alias')` on [PipelineAggregateFunction] instances. Each aggregation calculates
  ///   a value (e.g., sum, average, count) based on the documents within its group.
  ///
  /// Example:
  /// ```dart
  /// pipeline.aggregateStage(
  ///   AggregateStage(
  ///     accumulators: [
  ///       Expression.field('likes').sum().as('total_likes'),
  ///       Expression.field('likes').average().as('avg_likes'),
  ///     ],
  ///     groups: [Expression.field('category')],
  ///   ),
  /// );
  /// ```
  ///
  /// With options:
  /// ```dart
  /// pipeline.aggregateStage(
  ///   AggregateStage(
  ///     accumulators: [
  ///       Expression.field('likes').sum().as('total_likes'),
  ///     ],
  ///   ),
  ///   options: AggregateOptions(),
  /// );
  /// ```
  Pipeline aggregateStage(
    AggregateStage aggregateStage, {
    AggregateOptions? options,
  }) {
    final stage = _AggregateStageWithOptions(
      aggregateStage,
      options ?? AggregateOptions(),
    );
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Gets distinct values based on expressions
  Pipeline distinct(
    Selectable expression1, [
    Selectable? expression2,
    Selectable? expression3,
    Selectable? expression4,
    Selectable? expression5,
    Selectable? expression6,
    Selectable? expression7,
    Selectable? expression8,
    Selectable? expression9,
    Selectable? expression10,
    Selectable? expression11,
    Selectable? expression12,
    Selectable? expression13,
    Selectable? expression14,
    Selectable? expression15,
    Selectable? expression16,
    Selectable? expression17,
    Selectable? expression18,
    Selectable? expression19,
    Selectable? expression20,
    Selectable? expression21,
    Selectable? expression22,
    Selectable? expression23,
    Selectable? expression24,
    Selectable? expression25,
    Selectable? expression26,
    Selectable? expression27,
    Selectable? expression28,
    Selectable? expression29,
    Selectable? expression30,
  ]) {
    final expressions = <Selectable>[expression1];
    if (expression2 != null) expressions.add(expression2);
    if (expression3 != null) expressions.add(expression3);
    if (expression4 != null) expressions.add(expression4);
    if (expression5 != null) expressions.add(expression5);
    if (expression6 != null) expressions.add(expression6);
    if (expression7 != null) expressions.add(expression7);
    if (expression8 != null) expressions.add(expression8);
    if (expression9 != null) expressions.add(expression9);
    if (expression10 != null) expressions.add(expression10);
    if (expression11 != null) expressions.add(expression11);
    if (expression12 != null) expressions.add(expression12);
    if (expression13 != null) expressions.add(expression13);
    if (expression14 != null) expressions.add(expression14);
    if (expression15 != null) expressions.add(expression15);
    if (expression16 != null) expressions.add(expression16);
    if (expression17 != null) expressions.add(expression17);
    if (expression18 != null) expressions.add(expression18);
    if (expression19 != null) expressions.add(expression19);
    if (expression20 != null) expressions.add(expression20);
    if (expression21 != null) expressions.add(expression21);
    if (expression22 != null) expressions.add(expression22);
    if (expression23 != null) expressions.add(expression23);
    if (expression24 != null) expressions.add(expression24);
    if (expression25 != null) expressions.add(expression25);
    if (expression26 != null) expressions.add(expression26);
    if (expression27 != null) expressions.add(expression27);
    if (expression28 != null) expressions.add(expression28);
    if (expression29 != null) expressions.add(expression29);
    if (expression30 != null) expressions.add(expression30);

    final stage = _DistinctStage(expressions);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Finds nearest vectors using vector similarity search
  Pipeline findNearest(
    Field vectorField,
    List<double> vectorValue,
    DistanceMeasure distanceMeasure, {
    int? limit,
  }) {
    final stage = _FindNearestStage(vectorField, vectorValue, distanceMeasure,
        limit: limit);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Limits the number of results
  Pipeline limit(int limit) {
    final stage = _LimitStage(limit);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Offsets the results
  Pipeline offset(int offset) {
    final stage = _OffsetStage(offset);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Removes specified fields from documents
  Pipeline removeFields(
    String fieldPath1, [
    String? fieldPath2,
    String? fieldPath3,
    String? fieldPath4,
    String? fieldPath5,
    String? fieldPath6,
    String? fieldPath7,
    String? fieldPath8,
    String? fieldPath9,
    String? fieldPath10,
    String? fieldPath11,
    String? fieldPath12,
    String? fieldPath13,
    String? fieldPath14,
    String? fieldPath15,
    String? fieldPath16,
    String? fieldPath17,
    String? fieldPath18,
    String? fieldPath19,
    String? fieldPath20,
    String? fieldPath21,
    String? fieldPath22,
    String? fieldPath23,
    String? fieldPath24,
    String? fieldPath25,
    String? fieldPath26,
    String? fieldPath27,
    String? fieldPath28,
    String? fieldPath29,
    String? fieldPath30,
  ]) {
    final fieldPaths = <String>[fieldPath1];
    if (fieldPath2 != null) fieldPaths.add(fieldPath2);
    if (fieldPath3 != null) fieldPaths.add(fieldPath3);
    if (fieldPath4 != null) fieldPaths.add(fieldPath4);
    if (fieldPath5 != null) fieldPaths.add(fieldPath5);
    if (fieldPath6 != null) fieldPaths.add(fieldPath6);
    if (fieldPath7 != null) fieldPaths.add(fieldPath7);
    if (fieldPath8 != null) fieldPaths.add(fieldPath8);
    if (fieldPath9 != null) fieldPaths.add(fieldPath9);
    if (fieldPath10 != null) fieldPaths.add(fieldPath10);
    if (fieldPath11 != null) fieldPaths.add(fieldPath11);
    if (fieldPath12 != null) fieldPaths.add(fieldPath12);
    if (fieldPath13 != null) fieldPaths.add(fieldPath13);
    if (fieldPath14 != null) fieldPaths.add(fieldPath14);
    if (fieldPath15 != null) fieldPaths.add(fieldPath15);
    if (fieldPath16 != null) fieldPaths.add(fieldPath16);
    if (fieldPath17 != null) fieldPaths.add(fieldPath17);
    if (fieldPath18 != null) fieldPaths.add(fieldPath18);
    if (fieldPath19 != null) fieldPaths.add(fieldPath19);
    if (fieldPath20 != null) fieldPaths.add(fieldPath20);
    if (fieldPath21 != null) fieldPaths.add(fieldPath21);
    if (fieldPath22 != null) fieldPaths.add(fieldPath22);
    if (fieldPath23 != null) fieldPaths.add(fieldPath23);
    if (fieldPath24 != null) fieldPaths.add(fieldPath24);
    if (fieldPath25 != null) fieldPaths.add(fieldPath25);
    if (fieldPath26 != null) fieldPaths.add(fieldPath26);
    if (fieldPath27 != null) fieldPaths.add(fieldPath27);
    if (fieldPath28 != null) fieldPaths.add(fieldPath28);
    if (fieldPath29 != null) fieldPaths.add(fieldPath29);
    if (fieldPath30 != null) fieldPaths.add(fieldPath30);

    final stage = _RemoveFieldsStage(fieldPaths);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Replaces documents with the result of an expression
  Pipeline replaceWith(Expression expression) {
    final stage = _ReplaceWithStage(expression);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Samples documents using a sampling strategy
  Pipeline sample(PipelineSample sample) {
    final stage = _SampleStage(sample);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Selects specific fields using selectable expressions
  Pipeline select(
    Selectable expression1, [
    Selectable? expression2,
    Selectable? expression3,
    Selectable? expression4,
    Selectable? expression5,
    Selectable? expression6,
    Selectable? expression7,
    Selectable? expression8,
    Selectable? expression9,
    Selectable? expression10,
    Selectable? expression11,
    Selectable? expression12,
    Selectable? expression13,
    Selectable? expression14,
    Selectable? expression15,
    Selectable? expression16,
    Selectable? expression17,
    Selectable? expression18,
    Selectable? expression19,
    Selectable? expression20,
    Selectable? expression21,
    Selectable? expression22,
    Selectable? expression23,
    Selectable? expression24,
    Selectable? expression25,
    Selectable? expression26,
    Selectable? expression27,
    Selectable? expression28,
    Selectable? expression29,
    Selectable? expression30,
  ]) {
    final expressions = <Selectable>[expression1];
    if (expression2 != null) expressions.add(expression2);
    if (expression3 != null) expressions.add(expression3);
    if (expression4 != null) expressions.add(expression4);
    if (expression5 != null) expressions.add(expression5);
    if (expression6 != null) expressions.add(expression6);
    if (expression7 != null) expressions.add(expression7);
    if (expression8 != null) expressions.add(expression8);
    if (expression9 != null) expressions.add(expression9);
    if (expression10 != null) expressions.add(expression10);
    if (expression11 != null) expressions.add(expression11);
    if (expression12 != null) expressions.add(expression12);
    if (expression13 != null) expressions.add(expression13);
    if (expression14 != null) expressions.add(expression14);
    if (expression15 != null) expressions.add(expression15);
    if (expression16 != null) expressions.add(expression16);
    if (expression17 != null) expressions.add(expression17);
    if (expression18 != null) expressions.add(expression18);
    if (expression19 != null) expressions.add(expression19);
    if (expression20 != null) expressions.add(expression20);
    if (expression21 != null) expressions.add(expression21);
    if (expression22 != null) expressions.add(expression22);
    if (expression23 != null) expressions.add(expression23);
    if (expression24 != null) expressions.add(expression24);
    if (expression25 != null) expressions.add(expression25);
    if (expression26 != null) expressions.add(expression26);
    if (expression27 != null) expressions.add(expression27);
    if (expression28 != null) expressions.add(expression28);
    if (expression29 != null) expressions.add(expression29);
    if (expression30 != null) expressions.add(expression30);

    final stage = _SelectStage(expressions);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Sorts results using an ordering specification
  Pipeline sort(Ordering ordering) {
    final stage = _SortStage(ordering);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Unnests arrays into separate documents
  Pipeline unnest(Selectable expression, [String? indexField]) {
    final stage = _UnnestStage(expression, indexField);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Unions results with another pipeline
  Pipeline union(Pipeline pipeline) {
    final stage = _UnionStage(pipeline);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }

  /// Filters documents using a boolean expression
  Pipeline where(BooleanExpression expression) {
    final stage = _WhereStage(expression);
    return Pipeline._(
      _firestore,
      _delegate.addStage(stage.toMap()),
    );
  }
}
