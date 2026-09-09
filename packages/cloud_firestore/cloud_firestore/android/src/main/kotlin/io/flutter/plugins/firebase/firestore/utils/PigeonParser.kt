/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils

import android.util.Log
import com.google.firebase.firestore.AggregateSource as FirestoreAggregateSource
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldPath
import com.google.firebase.firestore.Filter
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenSource as FirestoreListenSource
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.Source as FirestoreSource
import io.flutter.plugins.firebase.firestore.AggregateSource
import io.flutter.plugins.firebase.firestore.DocumentChangeType
import io.flutter.plugins.firebase.firestore.InternalDocumentChange
import io.flutter.plugins.firebase.firestore.InternalDocumentSnapshot
import io.flutter.plugins.firebase.firestore.InternalQueryParameters
import io.flutter.plugins.firebase.firestore.InternalQuerySnapshot
import io.flutter.plugins.firebase.firestore.InternalSnapshotMetadata
import io.flutter.plugins.firebase.firestore.ListenSource
import io.flutter.plugins.firebase.firestore.ServerTimestampBehavior
import io.flutter.plugins.firebase.firestore.Source

object PigeonParser {
  fun parsePigeonSource(source: Source): FirestoreSource {
    return when (source) {
      Source.CACHE -> FirestoreSource.CACHE
      Source.SERVER_AND_CACHE -> FirestoreSource.DEFAULT
      Source.SERVER -> FirestoreSource.SERVER
    }
  }

  fun parsePigeonServerTimestampBehavior(
      serverTimestampBehavior: ServerTimestampBehavior?
  ): DocumentSnapshot.ServerTimestampBehavior {
    if (serverTimestampBehavior == null) {
      return DocumentSnapshot.ServerTimestampBehavior.NONE
    }
    return when (serverTimestampBehavior) {
      ServerTimestampBehavior.NONE -> DocumentSnapshot.ServerTimestampBehavior.NONE
      ServerTimestampBehavior.ESTIMATE -> DocumentSnapshot.ServerTimestampBehavior.ESTIMATE
      ServerTimestampBehavior.PREVIOUS -> DocumentSnapshot.ServerTimestampBehavior.PREVIOUS
    }
  }

  fun toPigeonQuerySnapshot(
      querySnapshot: com.google.firebase.firestore.QuerySnapshot,
      serverTimestampBehavior: DocumentSnapshot.ServerTimestampBehavior
  ): InternalQuerySnapshot {
    return InternalQuerySnapshot(
        documents = toPigeonDocumentSnapshots(querySnapshot.documents, serverTimestampBehavior),
        documentChanges =
            toPigeonDocumentChanges(querySnapshot.documentChanges, serverTimestampBehavior),
        metadata = toPigeonSnapshotMetadata(querySnapshot.metadata))
  }

  fun toPigeonSnapshotMetadata(
      snapshotMetadata: com.google.firebase.firestore.SnapshotMetadata
  ): InternalSnapshotMetadata {
    return InternalSnapshotMetadata(
        hasPendingWrites = snapshotMetadata.hasPendingWrites(),
        isFromCache = snapshotMetadata.isFromCache)
  }

  fun toPigeonDocumentChanges(
      documentChanges: List<com.google.firebase.firestore.DocumentChange>,
      serverTimestampBehavior: DocumentSnapshot.ServerTimestampBehavior
  ): List<InternalDocumentChange?> {
    return documentChanges.map { toPigeonDocumentChange(it, serverTimestampBehavior) }
  }

  fun toPigeonDocumentChange(
      documentChange: com.google.firebase.firestore.DocumentChange,
      serverTimestampBehavior: DocumentSnapshot.ServerTimestampBehavior
  ): InternalDocumentChange {
    return InternalDocumentChange(
        type = toPigeonDocumentChangeType(documentChange.type),
        document = toPigeonDocumentSnapshot(documentChange.document, serverTimestampBehavior),
        oldIndex = documentChange.oldIndex.toLong(),
        newIndex = documentChange.newIndex.toLong())
  }

  fun toPigeonDocumentChangeType(
      type: com.google.firebase.firestore.DocumentChange.Type
  ): DocumentChangeType {
    return when (type) {
      com.google.firebase.firestore.DocumentChange.Type.ADDED -> DocumentChangeType.ADDED
      com.google.firebase.firestore.DocumentChange.Type.MODIFIED -> DocumentChangeType.MODIFIED
      com.google.firebase.firestore.DocumentChange.Type.REMOVED -> DocumentChangeType.REMOVED
    }
  }

  fun parseListenSource(source: ListenSource): FirestoreListenSource {
    return when (source) {
      ListenSource.DEFAULT_SOURCE -> FirestoreListenSource.DEFAULT
      ListenSource.CACHE -> FirestoreListenSource.CACHE
    }
  }

  @Suppress("UNCHECKED_CAST")
  fun toPigeonDocumentSnapshot(
      documentSnapshot: com.google.firebase.firestore.DocumentSnapshot,
      serverTimestampBehavior: DocumentSnapshot.ServerTimestampBehavior
  ): InternalDocumentSnapshot {
    return InternalDocumentSnapshot(
        path = documentSnapshot.reference.path,
        data = documentSnapshot.getData(serverTimestampBehavior) as Map<String?, Any?>?,
        metadata = toPigeonSnapshotMetadata(documentSnapshot.metadata))
  }

  fun toPigeonDocumentSnapshots(
      documentSnapshots: List<com.google.firebase.firestore.DocumentSnapshot>,
      serverTimestampBehavior: DocumentSnapshot.ServerTimestampBehavior
  ): List<InternalDocumentSnapshot?> {
    return documentSnapshots.map { toPigeonDocumentSnapshot(it, serverTimestampBehavior) }
  }

  fun parseFieldPath(fieldPaths: List<List<String?>?>): List<FieldPath> {
    return fieldPaths.map { fieldPath -> FieldPath.of(*fieldPath!!.filterNotNull().toTypedArray()) }
  }

  @Suppress("UNCHECKED_CAST")
  fun parseQuery(
      firestore: FirebaseFirestore,
      path: String,
      isCollectionGroup: Boolean,
      parameters: InternalQueryParameters?
  ): Query? {
    try {
      var query: Query =
          if (isCollectionGroup) {
            firestore.collectionGroup(path)
          } else {
            firestore.collection(path)
          }

      if (parameters == null) return query

      if (parameters.filters != null) {
        val filter = filterFromJson(parameters.filters as Map<String, Any?>)
        query = query.where(filter)
      }

      val whereConditions = requireNotNull(parameters.where)
      for (condition in whereConditions) {
        val fieldPath = condition!![0] as FieldPath
        val operator = condition[1] as String
        val value = condition[2]
        query =
            when (operator) {
              "==" -> query.whereEqualTo(fieldPath, value)
              "!=" -> query.whereNotEqualTo(fieldPath, value)
              "<" -> query.whereLessThan(fieldPath, value as Any)
              "<=" -> query.whereLessThanOrEqualTo(fieldPath, value as Any)
              ">" -> query.whereGreaterThan(fieldPath, value as Any)
              ">=" -> query.whereGreaterThanOrEqualTo(fieldPath, value as Any)
              "array-contains" -> query.whereArrayContains(fieldPath, value as Any)
              "array-contains-any" -> query.whereArrayContainsAny(fieldPath, value as List<Any>)
              "in" -> query.whereIn(fieldPath, value as List<Any>)
              "not-in" -> query.whereNotIn(fieldPath, value as List<Any>)
              else -> {
                Log.w(
                    "FLTFirestoreMsgCodec",
                    "An invalid query operator $operator was received but not handled.")
                query
              }
            }
      }

      val limit = parameters.limit
      if (limit != null) query = query.limit(limit)

      val limitToLast = parameters.limitToLast
      if (limitToLast != null) query = query.limitToLast(limitToLast)

      val orderBy = parameters.orderBy ?: return query
      for (order in orderBy) {
        val fieldPath = order!![0] as FieldPath
        val descending = order[1] as Boolean
        val direction = if (descending) Query.Direction.DESCENDING else Query.Direction.ASCENDING
        query = query.orderBy(fieldPath, direction)
      }

      val startAt = parameters.startAt
      if (startAt != null) query = query.startAt(*startAt.toTypedArray())

      val startAfter = parameters.startAfter
      if (startAfter != null) query = query.startAfter(*startAfter.toTypedArray())

      val endAt = parameters.endAt
      if (endAt != null) query = query.endAt(*endAt.toTypedArray())

      val endBefore = parameters.endBefore
      if (endBefore != null) query = query.endBefore(*endBefore.toTypedArray())

      return query
    } catch (exception: Exception) {
      Log.e(
          "FLTFirestoreMsgCodec",
          "An error occurred while parsing query arguments, this is most likely an error with this" +
              " SDK.",
          exception)
      return null
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun filterFromJson(map: Map<String, Any?>): Filter {
    if (map.containsKey("fieldPath")) {
      val op = map["op"] as String
      val fieldPath = map["fieldPath"] as FieldPath
      val value = map["value"]
      return when (op) {
        "==" -> Filter.equalTo(fieldPath, value)
        "!=" -> Filter.notEqualTo(fieldPath, value)
        "<" -> Filter.lessThan(fieldPath, value)
        "<=" -> Filter.lessThanOrEqualTo(fieldPath, value)
        ">" -> Filter.greaterThan(fieldPath, value)
        ">=" -> Filter.greaterThanOrEqualTo(fieldPath, value)
        "array-contains" -> Filter.arrayContains(fieldPath, value)
        "array-contains-any" -> Filter.arrayContainsAny(fieldPath, value as List<*>)
        "in" -> Filter.inArray(fieldPath, value as List<*>)
        "not-in" -> Filter.notInArray(fieldPath, value as List<*>)
        else -> throw Error("Invalid operator")
      }
    }

    val op = map["op"] as String
    val queries = map["queries"] as List<Map<String, Any?>>
    val parsedFilters = ArrayList<Filter>()
    for (query in queries) {
      parsedFilters.add(filterFromJson(query))
    }

    return when (op) {
      "OR" -> Filter.or(*parsedFilters.toTypedArray())
      "AND" -> Filter.and(*parsedFilters.toTypedArray())
      else -> throw Error("Invalid operator")
    }
  }

  fun parseAggregateSource(source: AggregateSource): FirestoreAggregateSource {
    return when (source) {
      AggregateSource.SERVER -> FirestoreAggregateSource.SERVER
    }
  }
}
