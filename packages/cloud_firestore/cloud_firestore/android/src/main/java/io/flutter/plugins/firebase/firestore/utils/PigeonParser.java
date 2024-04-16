/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.firebase.firestore.AggregateSource;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.Filter;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.ListenSource;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.Source;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class PigeonParser {

  public static Source parsePigeonSource(GeneratedAndroidFirebaseFirestore.Source source) {
    switch (source) {
      case CACHE:
        return Source.CACHE;
      case SERVER_AND_CACHE:
        return Source.DEFAULT;
      case SERVER:
        return Source.SERVER;
      default:
        throw new IllegalArgumentException("Unknown source: " + source);
    }
  }

  public static DocumentSnapshot.ServerTimestampBehavior parsePigeonServerTimestampBehavior(
      @Nullable GeneratedAndroidFirebaseFirestore.ServerTimestampBehavior serverTimestampBehavior) {
    if (serverTimestampBehavior == null) {
      return DocumentSnapshot.ServerTimestampBehavior.NONE;
    }
    switch (serverTimestampBehavior) {
      case NONE:
        return DocumentSnapshot.ServerTimestampBehavior.NONE;
      case ESTIMATE:
        return DocumentSnapshot.ServerTimestampBehavior.ESTIMATE;
      case PREVIOUS:
        return DocumentSnapshot.ServerTimestampBehavior.PREVIOUS;
      default:
        throw new IllegalArgumentException(
            "Unknown server timestamp behavior: " + serverTimestampBehavior);
    }
  }

  public static GeneratedAndroidFirebaseFirestore.PigeonQuerySnapshot toPigeonQuerySnapshot(
      com.google.firebase.firestore.QuerySnapshot querySnapshot,
      DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior) {
    GeneratedAndroidFirebaseFirestore.PigeonQuerySnapshot.Builder pigeonQuerySnapshot =
        new GeneratedAndroidFirebaseFirestore.PigeonQuerySnapshot.Builder();
    pigeonQuerySnapshot.setMetadata(toPigeonSnapshotMetadata(querySnapshot.getMetadata()));
    pigeonQuerySnapshot.setDocumentChanges(
        toPigeonDocumentChanges(querySnapshot.getDocumentChanges(), serverTimestampBehavior));
    pigeonQuerySnapshot.setDocuments(
        toPigeonDocumentSnapshots(querySnapshot.getDocuments(), serverTimestampBehavior));
    return pigeonQuerySnapshot.build();
  }

  public static GeneratedAndroidFirebaseFirestore.PigeonSnapshotMetadata toPigeonSnapshotMetadata(
      com.google.firebase.firestore.SnapshotMetadata snapshotMetadata) {
    GeneratedAndroidFirebaseFirestore.PigeonSnapshotMetadata.Builder pigeonSnapshotMetadata =
        new GeneratedAndroidFirebaseFirestore.PigeonSnapshotMetadata.Builder();
    pigeonSnapshotMetadata.setHasPendingWrites(snapshotMetadata.hasPendingWrites());
    pigeonSnapshotMetadata.setIsFromCache(snapshotMetadata.isFromCache());
    return pigeonSnapshotMetadata.build();
  }

  public static List<GeneratedAndroidFirebaseFirestore.PigeonDocumentChange>
      toPigeonDocumentChanges(
          List<com.google.firebase.firestore.DocumentChange> documentChanges,
          DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior) {
    List<GeneratedAndroidFirebaseFirestore.PigeonDocumentChange> pigeonDocumentChanges =
        new ArrayList<>(documentChanges.size());
    for (com.google.firebase.firestore.DocumentChange documentChange : documentChanges) {
      pigeonDocumentChanges.add(toPigeonDocumentChange(documentChange, serverTimestampBehavior));
    }
    return pigeonDocumentChanges;
  }

  public static GeneratedAndroidFirebaseFirestore.PigeonDocumentChange toPigeonDocumentChange(
      com.google.firebase.firestore.DocumentChange documentChange,
      DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior) {
    GeneratedAndroidFirebaseFirestore.PigeonDocumentChange.Builder pigeonDocumentChange =
        new GeneratedAndroidFirebaseFirestore.PigeonDocumentChange.Builder();
    pigeonDocumentChange.setType(toPigeonDocumentChangeType(documentChange.getType()));
    pigeonDocumentChange.setOldIndex((long) documentChange.getOldIndex());
    pigeonDocumentChange.setNewIndex((long) documentChange.getNewIndex());
    pigeonDocumentChange.setDocument(
        toPigeonDocumentSnapshot(documentChange.getDocument(), serverTimestampBehavior));
    return pigeonDocumentChange.build();
  }

  public static GeneratedAndroidFirebaseFirestore.DocumentChangeType toPigeonDocumentChangeType(
      com.google.firebase.firestore.DocumentChange.Type type) {
    switch (type) {
      case ADDED:
        return GeneratedAndroidFirebaseFirestore.DocumentChangeType.ADDED;
      case MODIFIED:
        return GeneratedAndroidFirebaseFirestore.DocumentChangeType.MODIFIED;
      case REMOVED:
        return GeneratedAndroidFirebaseFirestore.DocumentChangeType.REMOVED;
      default:
        throw new IllegalArgumentException("Unknown change type: " + type);
    }
  }

  public static ListenSource parseListenSource(
      GeneratedAndroidFirebaseFirestore.ListenSource source) {
    switch (source) {
      case DEFAULT_SOURCE:
        return ListenSource.DEFAULT;
      case CACHE:
        return ListenSource.CACHE;
      default:
        throw new IllegalArgumentException("Unknown ListenSource value: " + source);
    }
  }

  public static GeneratedAndroidFirebaseFirestore.PigeonDocumentSnapshot toPigeonDocumentSnapshot(
      com.google.firebase.firestore.DocumentSnapshot documentSnapshot,
      DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior) {
    GeneratedAndroidFirebaseFirestore.PigeonDocumentSnapshot.Builder pigeonDocumentSnapshot =
        new GeneratedAndroidFirebaseFirestore.PigeonDocumentSnapshot.Builder();
    pigeonDocumentSnapshot.setMetadata(toPigeonSnapshotMetadata(documentSnapshot.getMetadata()));
    pigeonDocumentSnapshot.setData(documentSnapshot.getData(serverTimestampBehavior));
    pigeonDocumentSnapshot.setPath(documentSnapshot.getReference().getPath());
    return pigeonDocumentSnapshot.build();
  }

  public static List<GeneratedAndroidFirebaseFirestore.PigeonDocumentSnapshot>
      toPigeonDocumentSnapshots(
          List<com.google.firebase.firestore.DocumentSnapshot> documentSnapshots,
          DocumentSnapshot.ServerTimestampBehavior serverTimestampBehavior) {
    List<GeneratedAndroidFirebaseFirestore.PigeonDocumentSnapshot> pigeonDocumentSnapshots =
        new ArrayList<>(documentSnapshots.size());
    for (com.google.firebase.firestore.DocumentSnapshot documentSnapshot : documentSnapshots) {
      pigeonDocumentSnapshots.add(
          toPigeonDocumentSnapshot(documentSnapshot, serverTimestampBehavior));
    }
    return pigeonDocumentSnapshots;
  }

  public static List<FieldPath> parseFieldPath(List<List<String>> fieldPaths) {
    List<FieldPath> paths = new ArrayList<>(fieldPaths.size());
    for (List<String> fieldPath : fieldPaths) {
      paths.add(FieldPath.of(fieldPath.toArray(new String[0])));
    }
    return paths;
  }

  public static Query parseQuery(
      FirebaseFirestore firestore,
      @NonNull String path,
      boolean isCollectionGroup,
      GeneratedAndroidFirebaseFirestore.PigeonQueryParameters parameters) {
    try {
      Query query;
      if (isCollectionGroup) {
        query = firestore.collectionGroup(path);
      } else {
        query = firestore.collection(path);
      }

      if (parameters == null) return query;

      boolean isFilterQuery = parameters.getFilters() != null;
      if (isFilterQuery) {
        Filter filter = filterFromJson(parameters.getFilters());
        query = query.where(filter);
      }

      List<List<Object>> whereConditions = Objects.requireNonNull(parameters.getWhere());

      for (List<Object> condition : whereConditions) {
        FieldPath fieldPath = (FieldPath) condition.get(0);
        String operator = (String) condition.get(1);
        Object value = condition.get(2);

        if ("==".equals(operator)) {
          query = query.whereEqualTo(fieldPath, value);
        } else if ("!=".equals(operator)) {
          query = query.whereNotEqualTo(fieldPath, value);
        } else if ("<".equals(operator)) {
          query = query.whereLessThan(fieldPath, value);
        } else if ("<=".equals(operator)) {
          query = query.whereLessThanOrEqualTo(fieldPath, value);
        } else if (">".equals(operator)) {
          query = query.whereGreaterThan(fieldPath, value);
        } else if (">=".equals(operator)) {
          query = query.whereGreaterThanOrEqualTo(fieldPath, value);
        } else if ("array-contains".equals(operator)) {
          query = query.whereArrayContains(fieldPath, value);
        } else if ("array-contains-any".equals(operator)) {
          @SuppressWarnings("unchecked")
          List<Object> listValues = (List<Object>) value;
          query = query.whereArrayContainsAny(fieldPath, listValues);
        } else if ("in".equals(operator)) {
          @SuppressWarnings("unchecked")
          List<Object> listValues = (List<Object>) value;
          query = query.whereIn(fieldPath, listValues);
        } else if ("not-in".equals(operator)) {
          @SuppressWarnings("unchecked")
          List<Object> listValues = (List<Object>) value;
          query = query.whereNotIn(fieldPath, listValues);
        } else {
          Log.w(
              "FLTFirestoreMsgCodec",
              "An invalid query operator " + operator + " was received but not handled.");
        }
      }

      // "limit" filters
      Number limit = parameters.getLimit();
      if (limit != null) query = query.limit(limit.longValue());

      Number limitToLast = parameters.getLimitToLast();
      if (limitToLast != null) query = query.limitToLast(limitToLast.longValue());

      // "orderBy" filters
      List<List<Object>> orderBy = parameters.getOrderBy();
      if (orderBy == null) return query;

      for (List<Object> order : orderBy) {
        FieldPath fieldPath = (FieldPath) order.get(0);
        boolean descending = (boolean) order.get(1);

        Query.Direction direction =
            descending ? Query.Direction.DESCENDING : Query.Direction.ASCENDING;

        query = query.orderBy(fieldPath, direction);
      }

      // cursor queries
      List<Object> startAt = parameters.getStartAt();
      if (startAt != null) query = query.startAt(Objects.requireNonNull(startAt.toArray()));

      List<Object> startAfter = parameters.getStartAfter();
      if (startAfter != null)
        query = query.startAfter(Objects.requireNonNull(startAfter.toArray()));

      List<Object> endAt = parameters.getEndAt();
      if (endAt != null) query = query.endAt(Objects.requireNonNull(endAt.toArray()));

      List<Object> endBefore = parameters.getEndBefore();
      if (endBefore != null) query = query.endBefore(Objects.requireNonNull(endBefore.toArray()));

      return query;
    } catch (Exception exception) {
      Log.e(
          "FLTFirestoreMsgCodec",
          "An error occurred while parsing query arguments, this is most likely an error with this SDK.",
          exception);
      return null;
    }
  }

  private static Filter filterFromJson(Map<String, Object> map) {
    if (map.containsKey("fieldPath")) {
      // Deserialize a FilterQuery
      String op = (String) map.get("op");
      FieldPath fieldPath = (FieldPath) map.get("fieldPath");
      Object value = map.get("value");

      assert fieldPath != null;
      assert op != null;

      // All the operators from Firebase
      switch (op) {
        case "==":
          return Filter.equalTo(fieldPath, value);
        case "!=":
          return Filter.notEqualTo(fieldPath, value);
        case "<":
          return Filter.lessThan(fieldPath, value);
        case "<=":
          return Filter.lessThanOrEqualTo(fieldPath, value);
        case ">":
          return Filter.greaterThan(fieldPath, value);
        case ">=":
          return Filter.greaterThanOrEqualTo(fieldPath, value);
        case "array-contains":
          return Filter.arrayContains(fieldPath, value);
        case "array-contains-any":
          return Filter.arrayContainsAny(fieldPath, (List<? extends Object>) value);
        case "in":
          return Filter.inArray(fieldPath, (List<? extends Object>) value);
        case "not-in":
          return Filter.notInArray(fieldPath, (List<? extends Object>) value);
        default:
          throw new Error("Invalid operator");
      }
    }
    // Deserialize a FilterOperator
    String op = (String) map.get("op");
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> queries = (List<Map<String, Object>>) map.get("queries");

    // Map queries recursively
    ArrayList<Filter> parsedFilters = new ArrayList<>();
    for (Map<String, Object> query : queries) {
      parsedFilters.add(filterFromJson(query));
    }

    if (op.equals("OR")) {
      return Filter.or(parsedFilters.toArray(new Filter[0]));
    } else if (op.equals("AND")) {
      return Filter.and(parsedFilters.toArray(new Filter[0]));
    }

    throw new Error("Invalid operator");
  }

  public static AggregateSource parseAggregateSource(
      GeneratedAndroidFirebaseFirestore.AggregateSource source) {
    switch (source) {
      case SERVER:
        return AggregateSource.SERVER;
      default:
        throw new IllegalArgumentException("Unknown AggregateSource value: " + source);
    }
  }
}
