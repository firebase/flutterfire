package io.flutter.plugins.firebaseauth;

import com.google.firebase.auth.FirebaseAuth;

public abstract class LinkedAuthStateListener implements FirebaseAuth.AuthStateListener {

  final FirebaseAuth auth;

  protected LinkedAuthStateListener(FirebaseAuth auth) {
    this.auth = auth;
  }

  public FirebaseAuth getAuth() {
    return auth;
  }
}
