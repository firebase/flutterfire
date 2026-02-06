// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// A pipeline for querying and transforming Firestore data
class Pipeline {
  final List<PipelineStage> _stages;
  final FirebaseFirestore _firestore;

  Pipeline._(this._firestore, this._stages);

  /// Executes the pipeline and returns a snapshot of the results
  Future<PipelineSnapshot> execute() async {
    final platformSnapshot =
        await _firestore._delegate.executePipeline(_toSerializableStages());
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

  /// Converts stages to serializable format for platform communication
  List<Map<String, dynamic>> _toSerializableStages() {
    return _stages.map((stage) => stage.toMap()).toList();
  }

  /// Public method to get serializable stages (used by union stage)
  List<Map<String, dynamic>> getSerializableStages() {
    return _toSerializableStages();
  }

  // Pipeline Actions

  /// Adds fields to documents using expressions
  Pipeline addFields(
    PipelineExpression expression1, [
    PipelineExpression? expression2,
    PipelineExpression? expression3,
    PipelineExpression? expression4,
    PipelineExpression? expression5,
    PipelineExpression? expression6,
    PipelineExpression? expression7,
    PipelineExpression? expression8,
    PipelineExpression? expression9,
    PipelineExpression? expression10,
    PipelineExpression? expression11,
    PipelineExpression? expression12,
    PipelineExpression? expression13,
    PipelineExpression? expression14,
    PipelineExpression? expression15,
    PipelineExpression? expression16,
    PipelineExpression? expression17,
    PipelineExpression? expression18,
    PipelineExpression? expression19,
    PipelineExpression? expression20,
    PipelineExpression? expression21,
    PipelineExpression? expression22,
    PipelineExpression? expression23,
    PipelineExpression? expression24,
    PipelineExpression? expression25,
    PipelineExpression? expression26,
    PipelineExpression? expression27,
    PipelineExpression? expression28,
    PipelineExpression? expression29,
    PipelineExpression? expression30,
  ]) {
    final expressions = <PipelineExpression>[expression1];
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

    return Pipeline._(_firestore, [
      ..._stages,
      _AddFieldsStage(expressions),
    ]);
  }

  /// Aggregates data using aggregate functions
  Pipeline aggregate(
    PipelineAggregateFunction aggregateFunction1, [
    PipelineAggregateFunction? aggregateFunction2,
    PipelineAggregateFunction? aggregateFunction3,
    PipelineAggregateFunction? aggregateFunction4,
    PipelineAggregateFunction? aggregateFunction5,
    PipelineAggregateFunction? aggregateFunction6,
    PipelineAggregateFunction? aggregateFunction7,
    PipelineAggregateFunction? aggregateFunction8,
    PipelineAggregateFunction? aggregateFunction9,
    PipelineAggregateFunction? aggregateFunction10,
    PipelineAggregateFunction? aggregateFunction11,
    PipelineAggregateFunction? aggregateFunction12,
    PipelineAggregateFunction? aggregateFunction13,
    PipelineAggregateFunction? aggregateFunction14,
    PipelineAggregateFunction? aggregateFunction15,
    PipelineAggregateFunction? aggregateFunction16,
    PipelineAggregateFunction? aggregateFunction17,
    PipelineAggregateFunction? aggregateFunction18,
    PipelineAggregateFunction? aggregateFunction19,
    PipelineAggregateFunction? aggregateFunction20,
    PipelineAggregateFunction? aggregateFunction21,
    PipelineAggregateFunction? aggregateFunction22,
    PipelineAggregateFunction? aggregateFunction23,
    PipelineAggregateFunction? aggregateFunction24,
    PipelineAggregateFunction? aggregateFunction25,
    PipelineAggregateFunction? aggregateFunction26,
    PipelineAggregateFunction? aggregateFunction27,
    PipelineAggregateFunction? aggregateFunction28,
    PipelineAggregateFunction? aggregateFunction29,
    PipelineAggregateFunction? aggregateFunction30,
  ]) {
    final functions = <PipelineAggregateFunction>[aggregateFunction1];
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

    return Pipeline._(_firestore, [
      ..._stages,
      _AggregateStage(functions),
    ]);
  }

  /// Gets distinct values based on expressions
  Pipeline distinct(
    PipelineExpression expression1, [
    PipelineExpression? expression2,
    PipelineExpression? expression3,
    PipelineExpression? expression4,
    PipelineExpression? expression5,
    PipelineExpression? expression6,
    PipelineExpression? expression7,
    PipelineExpression? expression8,
    PipelineExpression? expression9,
    PipelineExpression? expression10,
    PipelineExpression? expression11,
    PipelineExpression? expression12,
    PipelineExpression? expression13,
    PipelineExpression? expression14,
    PipelineExpression? expression15,
    PipelineExpression? expression16,
    PipelineExpression? expression17,
    PipelineExpression? expression18,
    PipelineExpression? expression19,
    PipelineExpression? expression20,
    PipelineExpression? expression21,
    PipelineExpression? expression22,
    PipelineExpression? expression23,
    PipelineExpression? expression24,
    PipelineExpression? expression25,
    PipelineExpression? expression26,
    PipelineExpression? expression27,
    PipelineExpression? expression28,
    PipelineExpression? expression29,
    PipelineExpression? expression30,
  ]) {
    final expressions = <PipelineExpression>[expression1];
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

    return Pipeline._(_firestore, [
      ..._stages,
      _DistinctStage(expressions),
    ]);
  }

  /// Finds nearest vectors using vector similarity search
  Pipeline findNearest(
    Field vectorField,
    List<double> vectorValue,
    DistanceMeasure distanceMeasure, {
    int? limit,
  }) {
    return Pipeline._(_firestore, [
      ..._stages,
      _FindNearestStage(vectorField, vectorValue, distanceMeasure,
          limit: limit),
    ]);
  }

  /// Limits the number of results
  Pipeline limit(int limit) {
    return Pipeline._(_firestore, [
      ..._stages,
      _LimitStage(limit),
    ]);
  }

  /// Offsets the results
  Pipeline offset(int offset) {
    return Pipeline._(_firestore, [
      ..._stages,
      _OffsetStage(offset),
    ]);
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

    return Pipeline._(_firestore, [
      ..._stages,
      _RemoveFieldsStage(fieldPaths),
    ]);
  }

  /// Replaces documents with the result of an expression
  Pipeline replaceWith(PipelineExpression expression) {
    return Pipeline._(_firestore, [
      ..._stages,
      _ReplaceWithStage(expression),
    ]);
  }

  /// Samples documents using a sampling strategy
  Pipeline sample(PipelineSample sample) {
    return Pipeline._(_firestore, [
      ..._stages,
      _SampleStage(sample),
    ]);
  }

  /// Selects specific fields using expressions
  Pipeline select(
    PipelineExpression expression1, [
    PipelineExpression? expression2,
    PipelineExpression? expression3,
    PipelineExpression? expression4,
    PipelineExpression? expression5,
    PipelineExpression? expression6,
    PipelineExpression? expression7,
    PipelineExpression? expression8,
    PipelineExpression? expression9,
    PipelineExpression? expression10,
    PipelineExpression? expression11,
    PipelineExpression? expression12,
    PipelineExpression? expression13,
    PipelineExpression? expression14,
    PipelineExpression? expression15,
    PipelineExpression? expression16,
    PipelineExpression? expression17,
    PipelineExpression? expression18,
    PipelineExpression? expression19,
    PipelineExpression? expression20,
    PipelineExpression? expression21,
    PipelineExpression? expression22,
    PipelineExpression? expression23,
    PipelineExpression? expression24,
    PipelineExpression? expression25,
    PipelineExpression? expression26,
    PipelineExpression? expression27,
    PipelineExpression? expression28,
    PipelineExpression? expression29,
    PipelineExpression? expression30,
  ]) {
    final expressions = <PipelineExpression>[expression1];
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

    return Pipeline._(_firestore, [
      ..._stages,
      _SelectStage(expressions),
    ]);
  }

  /// Sorts results using an ordering specification
  Pipeline sort(Ordering ordering) {
    return Pipeline._(_firestore, [
      ..._stages,
      _SortStage(ordering),
    ]);
  }

  /// Unnests arrays into separate documents
  Pipeline unnest(PipelineExpression expression, [String? indexField]) {
    return Pipeline._(_firestore, [
      ..._stages,
      _UnnestStage(expression, indexField),
    ]);
  }

  /// Unions results with another pipeline
  Pipeline union(Pipeline pipeline) {
    return Pipeline._(_firestore, [
      ..._stages,
      _UnionStage(pipeline),
    ]);
  }

  /// Filters documents using a boolean expression
  Pipeline where(BooleanExpression expression) {
    return Pipeline._(_firestore, [
      ..._stages,
      _WhereStage(expression),
    ]);
  }
}
