package io.flutter.plugins.firebase.firestore.utils;

import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldPath;
import com.google.firebase.firestore.Source;
import io.flutter.plugins.firebase.firestore.GeneratedAndroidFirebaseFirestore;
import java.util.ArrayList;
import java.util.List;

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
      GeneratedAndroidFirebaseFirestore.ServerTimestampBehavior serverTimestampBehavior) {
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
}
