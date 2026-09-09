// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.firestore

import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.Timestamp
import com.google.firebase.firestore.Blob
import com.google.firebase.firestore.DocumentChange
import com.google.firebase.firestore.DocumentReference
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldPath
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.Filter
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreSettings
import com.google.firebase.firestore.GeoPoint
import com.google.firebase.firestore.LoadBundleTaskProgress
import com.google.firebase.firestore.MemoryCacheSettings
import com.google.firebase.firestore.PersistentCacheSettings
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.QuerySnapshot
import com.google.firebase.firestore.SnapshotMetadata
import com.google.firebase.firestore.VectorValue
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.util.Date

open class FlutterFirebaseFirestoreMessageCodec : StandardMessageCodec() {
  companion object {
    val INSTANCE = FlutterFirebaseFirestoreMessageCodec()

    private const val DATA_TYPE_DATE_TIME: Byte = 180.toByte()
    private const val DATA_TYPE_GEO_POINT: Byte = 181.toByte()
    private const val DATA_TYPE_DOCUMENT_REFERENCE: Byte = 182.toByte()
    private const val DATA_TYPE_BLOB: Byte = 183.toByte()
    private const val DATA_TYPE_ARRAY_UNION: Byte = 184.toByte()
    private const val DATA_TYPE_ARRAY_REMOVE: Byte = 185.toByte()
    private const val DATA_TYPE_DELETE: Byte = 186.toByte()
    private const val DATA_TYPE_SERVER_TIMESTAMP: Byte = 187.toByte()
    private const val DATA_TYPE_TIMESTAMP: Byte = 188.toByte()
    private const val DATA_TYPE_INCREMENT_DOUBLE: Byte = 189.toByte()
    private const val DATA_TYPE_INCREMENT_INTEGER: Byte = 190.toByte()
    private const val DATA_TYPE_DOCUMENT_ID: Byte = 191.toByte()
    private const val DATA_TYPE_FIELD_PATH: Byte = 192.toByte()
    private const val DATA_TYPE_NAN: Byte = 193.toByte()
    private const val DATA_TYPE_INFINITY: Byte = 194.toByte()
    private const val DATA_TYPE_NEGATIVE_INFINITY: Byte = 195.toByte()
    private const val DATA_TYPE_FIRESTORE_INSTANCE: Byte = 196.toByte()
    private const val DATA_TYPE_FIRESTORE_QUERY: Byte = 197.toByte()
    private const val DATA_TYPE_FIRESTORE_SETTINGS: Byte = 198.toByte()
    private const val DATA_TYPE_VECTOR_VALUE: Byte = 199.toByte()
  }

  open override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {
    when (value) {
      is Date -> {
        stream.write(DATA_TYPE_DATE_TIME.toInt())
        writeLong(stream, value.time)
      }
      is Timestamp -> {
        stream.write(DATA_TYPE_TIMESTAMP.toInt())
        writeLong(stream, value.seconds)
        writeInt(stream, value.nanoseconds)
      }
      is GeoPoint -> {
        stream.write(DATA_TYPE_GEO_POINT.toInt())
        writeAlignment(stream, 8)
        writeDouble(stream, value.latitude)
        writeDouble(stream, value.longitude)
      }
      is VectorValue -> {
        stream.write(DATA_TYPE_VECTOR_VALUE.toInt())
        writeValue(stream, value.toArray())
      }
      is DocumentReference -> {
        stream.write(DATA_TYPE_DOCUMENT_REFERENCE.toInt())
        val firestore = value.firestore
        val appName = firestore.app.name
        writeValue(stream, appName)
        writeValue(stream, value.path)
        val databaseURL: String
        synchronized(FlutterFirebaseFirestorePlugin.firestoreInstanceCache) {
          databaseURL =
              FlutterFirebaseFirestorePlugin.getCachedFirebaseFirestoreInstanceForKey(firestore)
                  .databaseURL
        }
        writeValue(stream, databaseURL)
      }
      is DocumentSnapshot -> writeDocumentSnapshot(stream, value)
      is QuerySnapshot -> writeQuerySnapshot(stream, value)
      is DocumentChange -> writeDocumentChange(stream, value)
      is LoadBundleTaskProgress -> writeLoadBundleTaskProgress(stream, value)
      is SnapshotMetadata -> writeSnapshotMetadata(stream, value)
      is Blob -> {
        stream.write(DATA_TYPE_BLOB.toInt())
        writeBytes(stream, value.toBytes())
      }
      is Double -> {
        when {
          value.isNaN() -> stream.write(DATA_TYPE_NAN.toInt())
          value == Double.NEGATIVE_INFINITY -> stream.write(DATA_TYPE_NEGATIVE_INFINITY.toInt())
          value == Double.POSITIVE_INFINITY -> stream.write(DATA_TYPE_INFINITY.toInt())
          else -> super.writeValue(stream, value)
        }
      }
      else -> super.writeValue(stream, value)
    }
  }

  private fun writeSnapshotMetadata(stream: ByteArrayOutputStream, value: SnapshotMetadata) {
    val metadataMap =
        hashMapOf(
            "hasPendingWrites" to value.hasPendingWrites(), "isFromCache" to value.isFromCache)
    writeValue(stream, metadataMap)
  }

  private fun writeDocumentChange(stream: ByteArrayOutputStream, value: DocumentChange) {
    val type =
        when (value.type) {
          DocumentChange.Type.ADDED -> "DocumentChangeType.added"
          DocumentChange.Type.MODIFIED -> "DocumentChangeType.modified"
          DocumentChange.Type.REMOVED -> "DocumentChangeType.removed"
        }

    val changeMap =
        hashMapOf<String, Any?>(
            "type" to type,
            "data" to value.document.data,
            "path" to value.document.reference.path,
            "oldIndex" to value.oldIndex,
            "newIndex" to value.newIndex,
            "metadata" to value.document.metadata)
    writeValue(stream, changeMap)
  }

  private fun writeQuerySnapshot(stream: ByteArrayOutputStream, value: QuerySnapshot) {
    val paths = ArrayList<String>()
    val querySnapshotMap = HashMap<String, Any?>()
    val documents = ArrayList<Map<String, Any>?>()
    val metadatas = ArrayList<SnapshotMetadata>()

    val serverTimestampBehavior =
        FlutterFirebaseFirestorePlugin.serverTimestampBehaviorHashMap[value.hashCode()]

    for (document in value.documents) {
      paths.add(document.reference.path)
      if (serverTimestampBehavior != null) {
        documents.add(document.getData(serverTimestampBehavior))
      } else {
        documents.add(document.data)
      }
      metadatas.add(document.metadata)
    }

    querySnapshotMap["paths"] = paths
    querySnapshotMap["documents"] = documents
    querySnapshotMap["metadatas"] = metadatas
    querySnapshotMap["documentChanges"] = value.documentChanges
    querySnapshotMap["metadata"] = value.metadata

    FlutterFirebaseFirestorePlugin.serverTimestampBehaviorHashMap.remove(value.hashCode())
    writeValue(stream, querySnapshotMap)
  }

  private fun writeLoadBundleTaskProgress(
      stream: ByteArrayOutputStream,
      snapshot: LoadBundleTaskProgress
  ) {
    val snapshotMap = HashMap<String, Any?>()
    snapshotMap["bytesLoaded"] = snapshot.bytesLoaded
    snapshotMap["documentsLoaded"] = snapshot.documentsLoaded
    snapshotMap["totalBytes"] = snapshot.totalBytes
    snapshotMap["totalDocuments"] = snapshot.totalDocuments

    val convertedState =
        when (snapshot.taskState) {
          LoadBundleTaskProgress.TaskState.RUNNING -> "running"
          LoadBundleTaskProgress.TaskState.SUCCESS -> "success"
          LoadBundleTaskProgress.TaskState.ERROR -> "error"
        }
    snapshotMap["taskState"] = convertedState
    writeValue(stream, snapshotMap)
  }

  private fun writeDocumentSnapshot(stream: ByteArrayOutputStream, value: DocumentSnapshot) {
    val snapshotMap = HashMap<String, Any?>()
    snapshotMap["path"] = value.reference.path

    if (value.exists()) {
      val serverTimestampBehavior =
          FlutterFirebaseFirestorePlugin.serverTimestampBehaviorHashMap[value.hashCode()]
      snapshotMap["data"] =
          if (serverTimestampBehavior != null) {
            value.getData(serverTimestampBehavior)
          } else {
            value.data
          }
    } else {
      snapshotMap["data"] = null
    }

    snapshotMap["metadata"] = value.metadata
    FlutterFirebaseFirestorePlugin.serverTimestampBehaviorHashMap.remove(value.hashCode())
    writeValue(stream, snapshotMap)
  }

  open override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      DATA_TYPE_DATE_TIME -> Date(buffer.long)
      DATA_TYPE_TIMESTAMP -> Timestamp(buffer.long, buffer.int)
      DATA_TYPE_GEO_POINT -> {
        readAlignment(buffer, 8)
        GeoPoint(buffer.double, buffer.double)
      }
      DATA_TYPE_VECTOR_VALUE -> {
        @Suppress("UNCHECKED_CAST") val arrayList = readValue(buffer) as ArrayList<Double>
        val doubleArray = DoubleArray(arrayList.size)
        for (i in arrayList.indices) {
          doubleArray[i] = requireNotNull(arrayList[i]) { "Null value at index $i" }
        }
        FieldValue.vector(doubleArray)
      }
      DATA_TYPE_DOCUMENT_REFERENCE -> {
        val firestore = readValue(buffer) as FirebaseFirestore
        val path = readValue(buffer) as String
        firestore.document(path)
      }
      DATA_TYPE_BLOB -> Blob.fromBytes(readBytes(buffer))
      DATA_TYPE_ARRAY_UNION -> FieldValue.arrayUnion(*toArray(readValue(buffer)))
      DATA_TYPE_ARRAY_REMOVE -> FieldValue.arrayRemove(*toArray(readValue(buffer)))
      DATA_TYPE_DELETE -> FieldValue.delete()
      DATA_TYPE_SERVER_TIMESTAMP -> FieldValue.serverTimestamp()
      DATA_TYPE_INCREMENT_INTEGER -> {
        val integerIncrementValue = readValue(buffer) as Number
        FieldValue.increment(integerIncrementValue.toInt().toLong())
      }
      DATA_TYPE_INCREMENT_DOUBLE -> {
        val doubleIncrementValue = readValue(buffer) as Number
        FieldValue.increment(doubleIncrementValue.toDouble())
      }
      DATA_TYPE_DOCUMENT_ID -> FieldPath.documentId()
      DATA_TYPE_FIRESTORE_INSTANCE -> readFirestoreInstance(buffer)
      DATA_TYPE_FIRESTORE_QUERY -> readFirestoreQuery(buffer)
      DATA_TYPE_FIRESTORE_SETTINGS -> readFirestoreSettings(buffer)
      DATA_TYPE_NAN -> Double.NaN
      DATA_TYPE_INFINITY -> Double.POSITIVE_INFINITY
      DATA_TYPE_NEGATIVE_INFINITY -> Double.NEGATIVE_INFINITY
      DATA_TYPE_FIELD_PATH -> {
        val size = readSize(buffer)
        val list = ArrayList<Any?>(size)
        repeat(size) { list.add(readValue(buffer)) }
        FieldPath.of(*list.map { it as String }.toTypedArray())
      }
      else -> super.readValueOfType(type, buffer)
    }
  }

  private fun readFirestoreInstance(buffer: ByteBuffer): FirebaseFirestore {
    val appName = readValue(buffer) as String
    val databaseURL = readValue(buffer) as String
    val settings = readValue(buffer) as FirebaseFirestoreSettings
    synchronized(FlutterFirebaseFirestorePlugin.firestoreInstanceCache) {
      val cachedFirestoreInstance =
          FlutterFirebaseFirestorePlugin.getFirestoreInstanceByNameAndDatabaseUrl(
              appName, databaseURL)
      if (cachedFirestoreInstance != null) {
        return cachedFirestoreInstance
      }

      val app = FirebaseApp.getInstance(appName)
      val firestore = FirebaseFirestore.getInstance(app, databaseURL)
      firestore.firestoreSettings = settings
      FlutterFirebaseFirestorePlugin.setCachedFirebaseFirestoreInstanceForKey(
          firestore, databaseURL)
      return firestore
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun readFirestoreSettings(buffer: ByteBuffer): FirebaseFirestoreSettings {
    val settingsMap = readValue(buffer) as Map<String, Any?>
    val settingsBuilder = FirebaseFirestoreSettings.Builder()

    if (settingsMap["persistenceEnabled"] != null) {
      val persistenceEnabled = settingsMap["persistenceEnabled"] as Boolean
      if (persistenceEnabled) {
        val persistenceSettings = PersistentCacheSettings.newBuilder()
        if (settingsMap["cacheSizeBytes"] != null) {
          var cacheSizeBytes = 104857600L
          val value = settingsMap["cacheSizeBytes"]
          when (value) {
            is Long -> cacheSizeBytes = value
            is Int -> cacheSizeBytes = value.toLong()
          }
          if (cacheSizeBytes == -1L) {
            persistenceSettings.setSizeBytes(FirebaseFirestoreSettings.CACHE_SIZE_UNLIMITED)
          } else {
            persistenceSettings.setSizeBytes(cacheSizeBytes)
          }
        }
        settingsBuilder.setLocalCacheSettings(persistenceSettings.build())
      } else {
        settingsBuilder.setLocalCacheSettings(MemoryCacheSettings.newBuilder().build())
      }
    }

    if (settingsMap["host"] != null) {
      settingsBuilder.setHost(requireNotNull(settingsMap["host"] as String))
      if (settingsMap["sslEnabled"] != null) {
        settingsBuilder.setSslEnabled(requireNotNull(settingsMap["sslEnabled"] as Boolean))
      }
    }

    return settingsBuilder.build()
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

  @Suppress("UNCHECKED_CAST")
  private fun readFirestoreQuery(buffer: ByteBuffer): Query? {
    try {
      val values = readValue(buffer) as Map<String, Any?>
      val firestore = requireNotNull(values["firestore"] as FirebaseFirestore)
      val path = requireNotNull(values["path"] as String)
      val isCollectionGroup = values["isCollectionGroup"] as Boolean
      val parameters = values["parameters"] as Map<String, Any?>?

      var query: Query =
          if (isCollectionGroup) {
            firestore.collectionGroup(path)
          } else {
            firestore.collection(path)
          }

      if (parameters == null) return query

      if (parameters.containsKey("filters")) {
        val filter = filterFromJson(requireNotNull(parameters["filters"] as Map<String, Any?>))
        query = query.where(filter)
      }

      val filters = requireNotNull(parameters["where"] as List<List<Any?>>)
      for (condition in filters) {
        val fieldPath = condition[0] as FieldPath
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

      val limit = parameters["limit"] as Number?
      if (limit != null) query = query.limit(limit.toLong())

      val limitToLast = parameters["limitToLast"] as Number?
      if (limitToLast != null) query = query.limitToLast(limitToLast.toLong())

      val orderBy = parameters["orderBy"] as List<List<Any?>>? ?: return query
      for (order in orderBy) {
        val fieldPath = order[0] as FieldPath
        val descending = order[1] as Boolean
        val direction = if (descending) Query.Direction.DESCENDING else Query.Direction.ASCENDING
        query = query.orderBy(fieldPath, direction)
      }

      val startAt = parameters["startAt"] as List<Any?>?
      if (startAt != null) query = query.startAt(*startAt.toTypedArray())

      val startAfter = parameters["startAfter"] as List<Any?>?
      if (startAfter != null) query = query.startAfter(*startAfter.toTypedArray())

      val endAt = parameters["endAt"] as List<Any?>?
      if (endAt != null) query = query.endAt(*endAt.toTypedArray())

      val endBefore = parameters["endBefore"] as List<Any?>?
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

  private fun toArray(source: Any?): Array<Any?> {
    if (source is List<*>) {
      return source.toTypedArray()
    }
    if (source == null) {
      return emptyArray()
    }
    val sourceType = source.javaClass.canonicalName
    throw IllegalArgumentException(
        "java.util.List was expected, unable to convert '$sourceType' to an object array")
  }
}
