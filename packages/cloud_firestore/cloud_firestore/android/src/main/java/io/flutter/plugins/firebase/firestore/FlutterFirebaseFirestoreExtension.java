package io.flutter.plugins.firebase.firestore;

import com.google.firebase.firestore.FirebaseFirestore;

public class FlutterFirebaseFirestoreExtension {
  private FirebaseFirestore instance;
  private String databaseURL;

  public FlutterFirebaseFirestoreExtension(FirebaseFirestore instance, String databaseURL) {
    this.instance = instance;
    this.databaseURL = databaseURL;
  }

  public FirebaseFirestore getInstance() {
    return instance;
  }

  public String getDatabaseURL() {
    return databaseURL;
  }
}
