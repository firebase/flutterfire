package io.flutter.plugins.firebase.firestore.utils;

import androidx.annotation.Nullable;
import com.google.firebase.firestore.DocumentSnapshot;

public class ServerTimestampBehaviorConverter {
  public static DocumentSnapshot.ServerTimestampBehavior toServerTimestampBehavior(
      @Nullable String serverTimestampBehavior) {
    if (serverTimestampBehavior == null) {
      return DocumentSnapshot.ServerTimestampBehavior.NONE;
    }
    switch (serverTimestampBehavior) {
      case "estimate":
        return DocumentSnapshot.ServerTimestampBehavior.ESTIMATE;
      case "previous":
        return DocumentSnapshot.ServerTimestampBehavior.PREVIOUS;
      case "none":
      default:
        return DocumentSnapshot.ServerTimestampBehavior.NONE;
    }
  }
}
